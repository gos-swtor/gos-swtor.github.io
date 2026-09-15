local function zealous_focus_has_room(state)
    return state.abilities["Zealous Strike"] ~= nil and
        state.focus <= state.focusMax - ZEALOUS_FOCUS_GAIN
end

local function zen_gate(state, options)
    if type(options) == "table" and options.automaticZen == false then
        return false, "setting_disabled"
    end
    if state.centering == nil then
        return false, "centering_unavailable"
    end
    if not state.centering.present then
        return false, "centering_absent"
    end
    if type(state.centering.stacks) ~= "number" then
        return false, "centering_stacks_unavailable"
    end
    if state.centering.stacks < ZEN_CENTERING_COST then
        return false, "centering_" .. number_text(state.centering.stacks, 0) ..
            "_of_" .. tostring(ZEN_CENTERING_COST)
    end
    local focus_room = state.focusMax - state.focus
    if focus_room < ZEN_IMMEDIATE_FOCUS_GAIN then
        return false, "focus_room_" .. number_text(focus_room, 0) ..
            "_need_" .. tostring(ZEN_IMMEDIATE_FOCUS_GAIN)
    end
    if not zen_has_spender(state, options) then
        return false, "no_spender_after_focus_gain"
    end
    local castable, reason = can_use(state, "Zen", options)
    if not castable then
        return false, reason
    end
    return true, "centering_30"
end
