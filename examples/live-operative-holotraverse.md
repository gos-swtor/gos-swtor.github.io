---
title: Operative Lua Addon Example - Cursor Holotraverse
description: Learn how the Operative Lua script chooses a Holotraverse destination from cursor proximity, screen projection and the ability's range.
---
# Operative: cursor Holotraverse

Aim near a character to choose a Holotraverse destination. The script picks the eligible character closest to your cursor, using their body center on screen. They must also be within the ability's 30-metre range.

Source: `operative/cursor_holotraverse.lua`, in the official Operative / Scoundrel package. Its mirror maps Holotraverse to Trick Move.

## Choose the nearest eligible body center

The candidate must be alive, on screen, within range, and match an exact player/NPC/companion and reaction filter. Unknown health, distance or classification rejects it. Projection alone does not establish line of sight.

For example, a character 18 pixels from the cursor beats one 42 pixels away even if the latter is closer in world space. The default circle is 120 pixels. Equal distances use a stable handle tie-breaker.

!!! note "Code from the class script"
    Keep the module's `M` table, `MAX_UNITS = 512`, `MAX_RANGE_METERS = 30`, `METERS_PER_WORLD_UNIT = 10`, and `finite`, `method`, `alive`, `M.matches` helpers. Those helpers validate numbers, call unit methods, check living HP and apply exact filters. The two functions below return copied scalar data rather than retaining units.

## Picker

```lua
local function eligible(unit,player,filter)
    if unit==nil then return false,"target_unresolved" end
    if unit==player then return false,"self_target" end
    local is_local=method(unit,"is_local_player")
    if is_local~=false then return false,"local_player_flag_not_false" end
    if not alive(unit) then
        local hp=method(unit,"hp")
        local dead=type(hp)=="table" and finite(hp.current) and hp.current<=0
        return false,dead and "target_dead" or "target_hp_unavailable_or_invalid"
    end
    if not M.matches(filter,method(unit,"type"),method(unit,"reaction")) then
        return false,"target_filter_mismatch"
    end
    if method(unit,"is_on_screen")~=true then return false,"target_not_projected" end
    -- Native distance is the same game-world unit used by the existing routes.
    local distance=method(unit,"distance")
    if not finite(distance) or distance<0 then return false,"target_distance_unavailable" end
    if distance*METERS_PER_WORLD_UNIT>MAX_RANGE_METERS then return false,"target_out_of_range" end
    return true,"eligible"
end

function M.pick(world,cursor,filter,radius,counts)
    if not world or not world.player or not cursor or cursor.available~=true or
        not finite(cursor.x) or not finite(cursor.y) or not finite(cursor.width) or not finite(cursor.height) or
        cursor.width<=0 or cursor.height<=0 or not finite(radius) or radius<=0 then
        return nil,"cursor_unavailable"
    end
    local units=method(world,"units")
    if type(units)~="table" or #units>MAX_UNITS then return nil,"world_unavailable" end
    local best,limit=nil,radius*radius
    if counts then
        counts.total,counts.eligible,counts.range,counts.projection,counts.other,counts.outside = #units,0,0,0,0,0
        counts.nearest_px=nil
    end
    for _,unit in ipairs(units) do
        local allowed,gate=eligible(unit,world.player,filter)
        if counts and not allowed then
            if gate=="target_out_of_range" then counts.range=counts.range+1
            elseif gate=="target_not_projected" then counts.projection=counts.projection+1
            else counts.other=counts.other+1 end
        end
        if allowed then
            if counts then counts.eligible=counts.eligible+1 end
            local pos=method(unit,"screen_position","center")
            local handle=method(unit,"handle")
            if type(pos)=="table" and finite(pos.x) and finite(pos.y) and type(handle)=="string" and
                pos.x>=0 and pos.y>=0 and pos.x<cursor.width and pos.y<cursor.height then
                local dx,dy=pos.x-cursor.x,pos.y-cursor.y
                local d2=dx*dx+dy*dy
                if counts then
                    local pixels=math.sqrt(d2)
                    counts.nearest_px=math.min(counts.nearest_px or pixels,pixels)
                    if d2>limit then counts.outside=counts.outside+1 end
                end
                if d2<=limit and (not best or d2<best.d2 or (d2==best.d2 and handle<best.handle)) then
                    best={handle=handle,d2=d2,x=pos.x,y=pos.y}
                end
            elseif counts then
                counts.projection=counts.projection+1
            end
        end
    end
    return best,best and "candidate" or "no_target_in_cursor_radius"
end
```

## Use the result

Call `M.pick(world, gos.input.cursor(), "All", 120)` with a fresh `world = gos.world()`. It returns `{handle, d2, x, y}` and a reason, or nil if nobody qualifies. `d2` is squared pixel distance; optional `counts` records why candidates were rejected. The scan stops if cursor data is missing or the list has more than 512 units.

The full script scans at most once per 50 ms. Before casting, it finds the chosen character again and checks that they are still valid. It uses `target_fallback = "none"` so a missing destination cannot redirect the cast to the selected target.

**Hold Shift+V** to keep trying, including while waiting for cooldown. Releasing either key stops new requests; one already sent may still finish. While held, the script waits for each command to finish before choosing another destination.

[Cursor input](../api/input.md) | [Projection and distance](../api/world.md) | [Explicit targets](../api/abilities.md) | [Command lifecycle](../guides/command-lifecycle.md)
