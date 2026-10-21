local next_interval_ms = nil
if presence_throw_tick_count >= 2 and
    type(presence_throw_first_tick_ms) == "number" and
    event.timestamp > presence_throw_first_tick_ms then
    next_interval_ms =
        (event.timestamp - presence_throw_first_tick_ms) /
        (presence_throw_tick_count - 1)
elseif type(presence_tick_interval_mean_ms) == "number" then
    next_interval_ms = presence_tick_interval_mean_ms
end
presence_throw_predicted_next_tick_ms =
    type(next_interval_ms) == "number" and
    event.timestamp + next_interval_ms or nil

local function observed_presence_stacks(state)
    local presence = state.effects.presenceOfMind
    return presence.present and
        type(presence.stacks) == "number" and presence.stacks or 0
end

local function presence_projection(state)
    local observed = observed_presence_stacks(state)
    if observed >= PRESENCE_MAX_STACKS then
        return true, observed, "observed"
    end
    return false, observed, "observed"
end
