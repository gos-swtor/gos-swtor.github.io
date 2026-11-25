---
title: Operative Medicine Lua Healing - Kolto Probe Stacks
description: Inspect Kolto Probe stacks and refresh timing, and see when Operative Medicine prioritizes patient rescue over HoT upkeep.
---
# Operative: maintain Kolto Probe stacks

Check whether an ally needs another owned Kolto Probe stack or a refresh. This excerpt is a small state check retained in the class module; it does not select patients or submit casts. The full Medicine / Sawbones route applies separate healing priorities before HoT upkeep.

Source: `operative/medicine.lua`, in the official Operative / Scoundrel package.

!!! note "Code from the class script"
    Requires `mine_effect_snapshot`, `finite_number`, `KOLTO_PROBE`, `KOLTO_PROBE_MAX_STACKS`, and `policy.koltoProbeRefreshSeconds`. The snapshot is nil when unresolved, otherwise a table with `stacks` and optional `remaining` in seconds. Resolve an eligible ally from the current world before calling it.

## Refresh decision

```lua
local function kolto_probe_needs_refresh(unit, policy)
    local state = mine_effect_snapshot(unit, KOLTO_PROBE, "buff")
    -- Unknown observation is not evidence that the HoT is missing; fail closed
    -- so the route cannot spam Kolto Probe while Core catches up.
    if state == nil then return false, "observation_unknown" end
    if state.stacks < KOLTO_PROBE_MAX_STACKS then
        return true, "build_" .. tostring(state.stacks + 1)
    end
    if finite_number(state.remaining) and
        state.remaining <= policy.koltoProbeRefreshSeconds then
        return true, "refresh_expiring"
    end
    return false, "healthy"
end
```

`build_1` and `build_2` mean a stack is needed. `refresh_expiring` means the remaining time is at or below the chosen refresh setting. `healthy` means the Probe coverage needs no work; it says nothing about the patient's HP or safety. If the buff cannot be read, `observation_unknown` stops the helper from repeatedly asking for Probe. A missing timer does not mean the buff has expired.

## Where Probe upkeep fits in Medicine 1.0.1

A refresh being due does not make it the next healing action. The surrounding route decides which patient needs help and whether upkeep should yield.

| Situation | Before | Now |
| --- | --- | --- |
| An isolated patient needs rescue, including yourself | Missing Probe setup or HoT upkeep on healthier teammates could postpone direct support. | Direct support takes priority within the selected healing style's rescue band. |
| Several nearby patients are recovering | Starting fresh HoTs could delay group heals. | Established HoT upkeep retains its place; Nanotech and Kolto Waves get an opportunity before fresh HoT seeding when their group conditions are met. |
| Another patient becomes endangered while maintenance is pending | An unaccepted off-patient HoT choice could be retried before checking the new urgency. | Fresh patient needs can replace that unaccepted choice. Already accepted commands keep their ownership. |

The existing rescue bands are Safe 82%, Balanced 80%, and Efficient 66%. An isolated 71% patient with two stable Probe stacks can therefore need direct support in Safe or Balanced even though this helper returns `healthy`. Efficient retains its lower rescue band. During established nearby group recovery, ordinary HoT upkeep can still run; emergency and urgent-pressure healing keep priority.

Standing still does not force a cast-time heal. Movement, Tactical Advantage, and observed procs still affect the choice of direct heal. Routine Kolto Waves also needs enough injured allies in its area and an Energy budget for the full channel. These decisions belong to the full route, not this coverage helper.

## Check ownership when reusing this

The source helper treats `mine ~= true` as zero owned stacks. It counts a present owned HoT as one stack if the stack count is unknown. Those choices affect when it asks for another Probe; `observation_unknown` only covers cases where the helper returns nil.

For a general HoT tracker, require `has_ownership` before treating a row as foreign and preserve unknown charge counts. `mine = false` alone does not prove another player owns the HoT.

[Effects and ownership](../api/effects.md) | [Command lifecycle](../guides/command-lifecycle.md)
