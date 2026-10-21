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
