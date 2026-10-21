# Bounded incoming damage counter

Count damage reported against your character from the moment the script starts listening. The display also shows lost records, so you can tell when the total is incomplete.

The total is the sum of `event.amount`. It resets when disabled or when the player or session changes. Each update reads at most 256 events and accepts only those matching the player's handle and session.

[Download incoming-damage.lua](code/incoming-damage.lua){: download="incoming-damage.lua" }
and follow the [first-script installation steps](../guides/getting-started.md#install-and-run-your-first-script).
No helper modules are required.

## Complete code

```lua
local ID = "example_incoming_damage"
gos.settings.register(ID, {
  title = "Example: Incoming Damage", version = 1,
  activation = { mode = "always" }, fields = {},
})
local cursor, owner, epoch
local total, samples, dropped = 0, 0, 0
local MAX_BATCHES = 4

gos.on_tick(function()
  local settings = gos.settings.get(ID)
  local world = gos.world()
  local player = world.player
  local handle = player and player:handle() or nil
  if not settings.enabled or not settings.active or not handle or not world.actor_epoch then
    cursor, owner, epoch = nil, nil, nil
    total, samples, dropped = 0, 0, 0
    return
  end
  if handle ~= owner or world.actor_epoch ~= epoch then
    owner, epoch, cursor = handle, world.actor_epoch, nil
    total, samples, dropped = 0, 0, 0
  end
  for _ = 1, MAX_BATCHES do
    local batch = gos.events.combat(cursor)
    cursor = batch.cursor
    dropped = dropped + batch.dropped
    for _, event in ipairs(batch.events) do
      if event.kind == "damage" and event.actor_epoch == epoch and event.target_handle == handle
          and type(event.amount) == "number" then
        total = total + event.amount
        samples = samples + 1
      end
    end
    if not batch.more then break end
  end
  gos.overlay.draw_text("example_damage", {
    at = { screen = { x = 30, y = 110 } }, frame = true,
    text = string.format("Taken %.0f | hits %d | lost %d", total, samples, dropped),
    color = dropped > 0 and "orange" or "white", font_size = 16,
  })
end, { interval_ms = 100 })
```
