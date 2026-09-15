local ID = "example_status_panel"
gos.settings.register(ID, {
  title = "Example: Status Panel", version = 1,
  activation = { mode = "always" },
  fields = {{ key = "show", type = "bool", label = "Show panel", default = true }},
})
gos.on_tick(function()
  local settings = gos.settings.get(ID)
  if not settings.enabled or not settings.active or not settings.show then return end
  local player = gos.world().player
  local hp = player and player:hp() or nil
  local text = (hp and hp.percent ~= nil)
    and string.format("Health: %.0f%%", hp.percent) or "Health: unavailable"
  gos.overlay.draw_text("example_status", {
    anchor = "screen", x = 30, y = 80, text = text,
    color = "cyan", font_size = 18, shadow = true, frame = true,
  })
end, { interval_ms = 100 })
