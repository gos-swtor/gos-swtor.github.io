---
title: Sage Lua Combat Routine - Presence of Mind and Proc Prediction
description: Follow the Sage Lua routine's learned Throw tick timing, Presence of Mind prediction and Tidal Force tracking without submitting the same spell twice.
---
# Sage: Presence of Mind and proc prediction

Sage predicts when Presence of Mind should update and tracks the events that grant Tidal Force. This lets it prepare the next spell while waiting for the buff snapshot. It tracks which proc is already being used to avoid submitting the same spell twice.

## Presence of Mind: learn the Throw tick timing

The PoM example comes from `sage/balance.lua` in the official Sage / Sorcerer package. The Sorcerer version uses Wrath and Force Lightning.

The script records when Telekinetic Throw starts and when its damage ticks arrive. After two ticks, it calculates their average spacing:

`tick interval = (latest tick time - first tick time) / (tick count - 1)`

It adds that interval to the latest tick time to estimate the next one. For ticks at 1000 ms and 1450 ms, the next estimate is 1900 ms. With only one tick, it uses the spacing learned from earlier channels when available.

Time passing does not add a stack. When the starting stacks plus received Throw ticks reach four, the script waits for the PoM buff update instead of starting filler. The next spell still requires four observed stacks.

## Check the buff before spending it

A buff snapshot may predate the damage tick. The script uses the snapshot's age to tell whether a lower stack count is old information. A lower count sampled at least two milliseconds after the tick cancels the expectation; the small margin avoids rounding errors in the timestamps.

Once the next spell has been submitted, late Throw ticks cannot make the script spend the same proc again. An interrupted channel or missing combat records clears the pending expectation.

!!! note "Code from the class script"
    These extracts show the next-tick calculation and the observed-stack check in `sage/balance.lua`. They use that script's channel state, validated buff data and `PRESENCE_MAX_STACKS = 4`; the event reader and cast handling stay in the full package. Times in the first block are milliseconds.

```lua
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
```

## Telekinetics: Tidal Force uses the same kind of evidence

This approach is useful beyond Balance. In `sage/telekinetics.lua`, the script watches Forcequake starting and events where spells such as Turbulence spend Force. It also tracks when Tidal Force's internal cooldown ends. When a matching event arrives after that cooldown, it can prepare Telekinetic Wave before the buff snapshot catches up.

Unlike the PoM check above, that exact Tidal Force event can authorize the next spell. The script marks the proc as claimed when Wave is submitted, then checks whether the cast actually started before deciding if it can be used again. It matches the later buff observation to the event record and keeps the proc claimed while Wave is pending.

[Combat events](../api/symbols/gos-events-combat.md) | [Buff observations](../api/effects.md) | [Command status](../api/symbols/gos-abilities-command-status.md)
