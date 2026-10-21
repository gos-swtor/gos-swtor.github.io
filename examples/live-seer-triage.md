---
title: Sage Seer Lua Healing Routine - Predictive Triage
description: Use incoming damage and healing over time to compare predicted ally health and time to death, with Lua examples from the Sage Seer routine.
---
# Seer: predict who needs healing next

An ally at 80% HP can be closer to death than one at 50%. Seer estimates how fast each ally is losing health, accounts for healing over time, and predicts their health two and four seconds ahead. It also estimates seconds until death if that damage continues.

Source: `combat/pressure_formula.lua`, used through `combat/pressure_tracker.lua` by `sage/seer.lua` in the official Sage / Sorcerer package.

## Measure damage over three periods

The tracker groups recent damage into separate periods so the same hit is counted once. It divides each total by maximum HP and the period's length to get health lost per second.

| How long ago the damage happened | Weight for the two-second estimate | Weight for the four-second estimate |
| --- | ---: | ---: |
| Up to 0.75 seconds | 45% | 15% |
| 0.75 to 2 seconds | 35% | 45% |
| 2 to 4 seconds | 20% | 40% |

The formula gives more weight to attackers who keep hitting the same ally. `recent_attackers` hit within the last 0.75 seconds; `persistent_attackers` also hit in an older period. This helps distinguish a single spike from continuing damage.

## Estimate health and time to death

`fast_pressure` and `slow_pressure` are the estimated fractions of maximum HP lost per second. The formula subtracts that damage from current health and adds part of the expected healing over time: 80% for the two-second estimate and 70% for the four-second estimate.

**Time to death = current health fraction / net health lost per second.** Net loss subtracts the expected healing rate from the damage rate. The `0.001` minimum keeps the division finite; a large result means little or no continuing danger in this model.

For example, at 80% HP with an estimated loss of 40% of maximum HP per second and no healing over time, the result is two seconds until death. That ally can move ahead of a stable ally at 50%.

!!! note "Code from the class script"
    These are the calculation blocks from `combat/pressure_formula.lua`. The full function calculates `ratio`, the three damage rates and attacker counts before these lines. `hot2` and `hot4` are estimated healing amounts divided by maximum HP.

```lua
local focus_mult = 1.0 +
    0.06 * clamp(recent_attackers - 1, 0, 3) +
    0.20 * persistent_attackers
fast_pressure = focus_mult *
    (0.45 * d075 + 0.35 * d075_2 + 0.20 * d2_4)
slow_pressure = focus_mult *
    (0.15 * d075 + 0.45 * d075_2 + 0.40 * d2_4)

local hot2 = math.max(0, safe(input.hot_healing_2s, 0)) / maximum
local hot4 = math.max(0, safe(input.hot_healing_4s, 0)) / maximum
local projected2 = clamp(ratio - 2.0 * fast_pressure + 0.80 * hot2, 0, 1)
local projected4 = clamp(ratio - 4.0 * slow_pressure + 0.70 * hot4, 0, 1)
local net_pressure = math.max(0.001, slow_pressure - 0.70 * (hot4 / 4.0))
local ttd = ratio / net_pressure
```

## How Seer uses it

With **Incoming Damage Formula** selected, Seer can raise an ally's priority when predicted health or time to death shows urgent danger. It keeps current HP for ordinary cases. The tracker estimates healing over time from recent ticks of the player's tracked HoTs; it does not assume another healer will cast a rescue.

These are estimates from recent combat, not exact death times. If combat records are dropped, the tracker clears its history and stops using predictions while it gathers fresh data.

[Combat events](../api/symbols/gos-events-combat.md) | [Health](../api/world.md)
