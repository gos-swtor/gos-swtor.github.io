local AbilityExecutor = require("ability_executor")
local executor = AbilityExecutor.new()
local ID = "example_single_action"
gos.settings.register(ID, {
  title = "Example: Single Action", version = 1,
  activation = { mode = "hold", label = "Action key", default = "mouse4" },
  fields = {{ key = "ability", type = "string", label = "Ability name", default = "Force Stun", max_length = 96 }},
})
gos.on_tick(function()
  executor:tick() -- Poll even after the activation key is released.
  local settings = gos.settings.get(ID)
  if not settings.enabled or not settings.active then
    if executor:has_pending() then executor:cancel("inactive") end
    return
  end
  if executor:has_pending() then return end
  local loadout = gos.abilities.loadout()
  if loadout.status ~= "ready" or not loadout.known[settings.ability] then return end
  local world = gos.world()
  local target = world.current_target
  if not world.player or not target or target:reaction() ~= "hostile" then return end
  local hp = target:hp()
  if not hp or hp.current <= 0 then return end
  if not gos.abilities.can_cast(settings.ability, target).ok then return end
  executor:submit(settings.ability, target, {
    idempotencyKey = "example_action:" .. target:handle(),
    target_fallback = "none",
  })
end)
