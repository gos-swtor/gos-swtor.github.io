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
