    local function update_running_mean(mean, samples, value)
        if type(value) ~= "number" or value <= 0.0 then
            return mean, samples
        end
        samples = samples + 1
        if type(mean) ~= "number" then
            return value, samples
        end
        return mean + (value - mean) / samples, samples
    end

    local function reset_presence_lifecycle(reset_cursor)
        presence_throw_active = false
        presence_throw_tick_count = 0
        presence_stack_tick_ready = false
        presence_stack_tick_ready_ms = nil
        presence_stack_tick_disproved = false
        presence_throw_start_stacks = nil
        presence_throw_activation_ms = nil
        presence_throw_first_tick_ms = nil
        presence_throw_last_tick_ms = nil
        presence_throw_predicted_next_tick_ms = nil
        presence_completion_observed = false
        presence_event_fault = nil
        if reset_cursor then
            presence_stack_tick_suppressed = false
            presence_combat_cursor = nil
            presence_player_handle = nil
            presence_throw_handle = nil
            presence_last_observed_stacks = nil
        end
    end

    local function report_presence_event_fault(options, reason)
        if type(options) ~= "table" or options.decisionLog ~= true then
            presence_event_fault = nil
            return
        end
        if presence_event_fault == reason then
            return
        end
        presence_event_fault = reason
        emit_diagnostic(options, "warn",
            "route=balance phase=presence_lifecycle state=unavailable" ..
            " reason=" .. tostring(reason))
    end

    local function observe_presence_lifecycle(options, world)
        local player = world and world.player or nil
        local player_handle = safe_method(player, "handle")
        local throw_info = gos.abilities.info("Telekinetic Throw")
        local throw_handle = type(throw_info) == "table" and
            throw_info.activation_handle or nil
        local throw_name = type(throw_info) == "table" and
            type(throw_info.name) == "string" and throw_info.name or nil
        if type(player_handle) ~= "string" or
            type(throw_handle) ~= "string" or
            type(throw_name) ~= "string" then
            return false, false, nil, 0, 0
        end

        if (presence_player_handle ~= nil and
                presence_player_handle ~= player_handle) or
            (presence_throw_handle ~= nil and
                presence_throw_handle ~= throw_handle) then
            reset_presence_lifecycle(true)
            presence_first_tick_mean_ms = nil
            presence_first_tick_samples = 0
            presence_tick_interval_mean_ms = nil
            presence_tick_interval_samples = 0
        end
        presence_player_handle = player_handle
        presence_throw_handle = throw_handle

        local batch = gos.events.combat(presence_combat_cursor)
        if type(batch) ~= "table" or type(batch.cursor) ~= "number" or
            type(batch.dropped) ~= "number" or
            type(batch.more) ~= "boolean" or
            type(batch.events) ~= "table" then
            reset_presence_lifecycle(false)
            report_presence_event_fault(options, "invalid_batch")
            return false, false, nil, 0, 0
        end

        presence_combat_cursor = batch.cursor
        if batch.dropped > 0 then
            reset_presence_lifecycle(false)
            report_presence_event_fault(options,
                "dropped_" .. tostring(batch.dropped))
        else
            presence_event_fault = nil
        end

        for index = 1, #batch.events do
            local event = batch.events[index]
            if type(event) == "table" and
                event.source_handle == player_handle then
                local lifecycle_event = event.kind == "ability" and
                    event.ability_handle == throw_handle
                local damage_tick = event.kind == "damage" and
                    presence_throw_active and event.name == throw_name and
                    type(event.timestamp) == "number"
                if lifecycle_event and event.action == "ability_activate" then
                    presence_throw_active = true
                    presence_throw_tick_count = 0
                    presence_stack_tick_ready = false
                    presence_stack_tick_ready_ms = nil
                    presence_stack_tick_disproved = false
                    presence_stack_tick_suppressed = false
                    presence_throw_start_stacks = presence_last_observed_stacks
                    presence_throw_activation_ms =
                        type(event.timestamp) == "number" and event.timestamp or nil
                    presence_throw_first_tick_ms = nil
                    presence_throw_last_tick_ms = nil
                    presence_throw_predicted_next_tick_ms =
                        type(presence_throw_activation_ms) == "number" and
                        type(presence_first_tick_mean_ms) == "number" and
                        presence_throw_activation_ms + presence_first_tick_mean_ms or nil
                    presence_completion_observed = false
                elseif damage_tick then
                    local previous_tick_ms = presence_throw_last_tick_ms
                    presence_throw_tick_count = presence_throw_tick_count + 1
                    if not presence_stack_tick_ready and
                        not presence_stack_tick_disproved and
                        type(presence_throw_start_stacks) == "number" and
                        presence_throw_start_stacks + presence_throw_tick_count >=
                            PRESENCE_MAX_STACKS then
                        if presence_stack_tick_suppressed then
                            emit_diagnostic(options, "debug",
                                "route=balance phase=presence_handoff" ..
                                " state=late_stack_tick_ignored" ..
                                " reason=spender_executor_owned" ..
                                " start=" ..
                                    number_text(presence_throw_start_stacks, 0) ..
                                " ticks=" .. tostring(presence_throw_tick_count))
                        else
                            presence_stack_tick_ready = true
                            presence_stack_tick_ready_ms = event.timestamp
                            emit_diagnostic(options, "info",
                                "route=balance phase=presence_handoff" ..
                                " state=stack_tick_observed" ..
                                " start=" ..
                                    number_text(presence_throw_start_stacks, 0) ..
                                " ticks=" .. tostring(presence_throw_tick_count))
                        end
                    end
                    if presence_throw_first_tick_ms == nil then
                        presence_throw_first_tick_ms = event.timestamp
                        if type(presence_throw_activation_ms) == "number" and
                            event.timestamp > presence_throw_activation_ms then
                            presence_first_tick_mean_ms,
                                presence_first_tick_samples = update_running_mean(
                                    presence_first_tick_mean_ms,
                                    presence_first_tick_samples,
                                    event.timestamp - presence_throw_activation_ms)
                        end
                    end
                    if type(previous_tick_ms) == "number" and
                        event.timestamp > previous_tick_ms then
                        presence_tick_interval_mean_ms,
                            presence_tick_interval_samples = update_running_mean(
                                presence_tick_interval_mean_ms,
                                presence_tick_interval_samples,
                                event.timestamp - previous_tick_ms)
                    end
                    presence_throw_last_tick_ms = event.timestamp

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
                elseif lifecycle_event and
                    (event.action == "ability_interrupt" or
                        event.action == "ability_cancel") then
                    reset_presence_lifecycle(false)
                elseif lifecycle_event and
                    event.action == "ability_deactivate" then
                    if presence_throw_active then
                        presence_completion_observed = true
                    end
                    presence_throw_active = false
                end
            end
        end

        return batch.more == true, batch.cursor, #batch.events, batch.dropped
    end

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
