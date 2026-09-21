local ID = "example_position_marker"
gos.settings.register(ID, {
  title = "Example: Position Marker", version = 1,
  activation = { mode = "always" },
  fields = {{ key = "mark_key", type = "hotkey", label = "Mark target", default = "mouse5" }},
})
gos.on_tick(function()
  local settings = gos.settings.get(ID)
  if not settings.enabled or not settings.active then return end
  if not gos.input.was_pressed(settings.mark_key) then return end
  local target = gos.world().current_target
  local position = target and target:position() or nil
  if not position then return end
  gos.overlay.draw_circle("example_last_seen", {
    at = { world = { x = position.x, y = position.y, z = position.z } },
    world_radius = 0.8, segments = 32, thickness = 2,
    color = "cyan", ttl = 8,
  })
end)
