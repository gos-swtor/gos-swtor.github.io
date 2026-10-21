---
title: Commando and Mercenary Lua Healing Routine - Supercharge
description: See how the Commando combat routine times Supercharged Kolto Cell, resets Advanced Medical Probe and reserves energy for the next heal.
---
# Commando: when to use Supercharge

Supercharged Kolto Cell resets Advanced Medical Probe (AMP) and restores ten energy cells. The script checks whether that reset will let it heal again, and whether it can afford the next heal. Reaching ten stacks alone is not enough.

Source: `commando/combat_medic.lua` in the official Commando / Mercenary package. Bodyguard uses the same decisions with Healing Scan and Supercharged Kolto Gas.

## Use the heal before resetting it

If AMP is ready and someone needs it, cast AMP first. Once its cooldown appears, use Cell to reset it. This gets a heal from the ready ability before spending the reset.

If AMP is ready but energy is too low, Cell can go first when its ten cells make AMP affordable. The script also checks that enough energy will remain after the heal. For example, with a 100-cell maximum, a 20-cell heal and a 30-cell reserve, starting at 45 cells is enough: Cell raises it to 55, and the heal leaves 35.

The script waits for the healing GCD to finish before using Cell, so the buff does not start while the next heal is still blocked. It also checks movement and the chosen ally before spending the stacks.

## Build the last stacks with a useful heal

While AMP is on cooldown, the script looks for a heal that can finish the stack count:

| Current state | What it tries |
| --- | --- |
| Eight stacks and Potent Medicine learned | Medical Probe for the last two stacks |
| Nine stacks, with no need for a stronger direct heal | Med Shot for the last stack |
| Six to eight stacks and SC-4 Treatment Scanner active | Successive Treatment to build stacks during a needed channel |

Medical Probe still follows its setting for use above the direct-heal HP limit. The builder must be useful to someone who needs healing, and the script must have energy for both the builder and the AMP after Cell. Urgent healing comes first. Cell waits until ten stacks are actually observed, even when a channel is expected to produce them.

## The energy check and builder choice

The first block checks energy after Cell and AMP. The second chooses a stack-building heal and includes its cost in the same calculation. Mercenary heat is converted to available energy with `max - current` before these checks.

!!! note "Code from the class script"
    These extracts use the settings, current patient rows and helper functions in `commando/combat_medic.lua`. Use the full class package to run the rotation.

```lua
local after_refund=math.min(resource.max,resource.current+10)
local reserve=reserve_for(recipient)
if recipient.isSelf and hard_self then
    reserve=math.min(healing_reserve(recipient,cfg),cfg.critical_floor)
end
if after_refund<amp.cost or (after_refund-amp.cost)/resource.max*100<reserve then
    return nil,"insufficient_energy_for_amp_window"
end

stack_builder_plan=function()
    if not cfg.supercharge or support~=false or gcd>0 or hard_self or not healing_observation.complete then return nil,nil,"scheduler_guard" end
    local recipient=rows[1]
    if not recipient or triage_band(recipient,cfg)<2 or recipient.hp>cfg.focused_hp or skips[recipient.handle] then return nil,nil,"recipient_not_routine_or_needed" end
    local name,reason
    if supercharge_stacks==8 and learned(loadout,"Potent Medicine") then
        if recipient.hp>cfg.direct_hp and not cfg.medical_probe_bridge then return nil,nil,"probe_bridge_disabled" end
        name,reason="Medical Probe","amp_stack_completion"
    elseif supercharge_stacks==9 and recipient.hp>cfg.direct_hp then
        name,reason="Med Shot","amp_stack_completion"
    elseif sc4==true and type(supercharge_stacks)=="number" and
        supercharge_stacks>=6 and supercharge_stacks<=8 then
        -- SC-4 can supply the current 2-4 stack deficit during a useful
        -- Treatment channel. The plan never credits those stacks early.
        name,reason="Successive Treatment","sc4_stack_builder"
    else return nil,nil,"no_single_builder" end
    local amp=metadata("Advanced Medical Probe")
    local builder=metadata(name)
    if not amp or not amp_on_cooldown(amp.info) or not builder or not metadata("Supercharged Kolto Cell") or
        not movable("Advanced Medical Probe",amp.spec) or not movable(name,builder.spec) or not energy_known then return nil,nil,"ability_cooldown_mobility_or_energy_unknown" end
    -- Budget both actions using observed costs and the authored Cell
    -- refund. No predicted regeneration, crit refund, SC-4 stack credit,
    -- or extra Field Triage discount is used for admission.
    local after_refund=math.min(resource.max,resource.current-builder.cost+10)
    if after_refund<amp.cost or (after_refund-amp.cost)/resource.max*100<reserve_for(recipient) then return nil,nil,"followup_energy_budget" end
    local advice=amp_target_advice(recipient)
    if not advice or (advice.ok~=true and advice.reason~="cooldown" and advice.reason~="insufficient_resource") then return nil,nil,"amp_native_admission" end
    return name,recipient,reason
end
```

Before AMP is sent, the script checks its current cost and whether Core will allow the cast. The energy calculation above does not change the observed resource value.

[Resources](../api/world.md) | [Costs and cooldowns](../api/abilities.md)
