---
title: Operative Medicine Lua Healing - Kolto Probe Stacks
description: Read the Operative Medicine routine's Lua helper for maintaining two Kolto Probe stacks and refreshing them before expiry while preserving healing priorities.
---
# Operative: maintain Kolto Probe stacks

Keep two Kolto Probe stacks on an ally and refresh them before they expire. This helper says whether another Probe is needed. The class script handles urgent healing first and checks whether it can cast.

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

`build_1` and `build_2` mean a stack is needed. `refresh_expiring` means the remaining time is below the chosen refresh setting. `healthy` means no refresh is needed. If the buff cannot be read, `observation_unknown` stops the helper from repeatedly asking for Probe. A missing timer does not mean the buff has expired.

## Check ownership when reusing this

The source helper treats `mine ~= true` as zero owned stacks. It counts a present owned HoT as one stack if the stack count is unknown. Those choices affect when it asks for another Probe; `observation_unknown` only covers cases where the helper returns nil.

For a general HoT tracker, require `has_ownership` before treating a row as foreign and preserve unknown charge counts. `mine = false` alone does not prove another player owns the HoT.

[Effects and ownership](../api/effects.md) | [Command lifecycle](../guides/command-lifecycle.md)
