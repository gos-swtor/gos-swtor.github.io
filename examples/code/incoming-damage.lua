local ID = "example_incoming_damage"
gos.settings.register(ID, {
  title = "Example: Incoming Damage", version = 1,
  activation = { mode = "always" }, fields = {},
})
local cursor, owner
local total, samples, dropped = 0, 0, 0
local MAX_BATCHES = 4

gos.on_tick(function()
  local settings = gos.settings.get(ID)
  local player = gos.world().player
  local handle = player and player:handle() or nil
  if not settings.enabled or not settings.active or not handle then
    cursor, owner = nil, nil
    total, samples, dropped = 0, 0, 0
    return
  end
  if handle ~= owner then
    owner, cursor = handle, nil
    total, samples, dropped = 0, 0, 0
  end
  for _ = 1, MAX_BATCHES do
    local batch = gos.events.combat(cursor)
    cursor = batch.cursor
    dropped = dropped + batch.dropped
    for _, event in ipairs(batch.events) do
      if event.kind == "damage" and event.target_handle == handle
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
