---
title: SWTOR Lua Tutorial - Create a Read-Only Status Panel
description: Build a small SWTOR health overlay with Lua settings and logs. Download the complete status-panel script and learn how to locate its active and shared roots.
---
# Your first status panel

A complete read-only script with settings and an overlay. It does not target or
cast and needs no helper modules. Unknown health stays unknown.

[Download status-panel.lua](code/status-panel.lua){: download="status-panel.lua" }
and follow [Install and run your first script](../guides/getting-started.md#install-and-run-your-first-script)
to find the active folder, reload and enable it. Select **Example: Status Panel >
Overlay > Show panel**. Its **Log** tab shows the actual `SCRIPT_PATH` and
`COMMON_PATH` once at load time; enable the **INFO** filter to see them.

## Complete code

```lua
local ID = "example_status_panel"
gos.log.info("SCRIPT_PATH", SCRIPT_PATH)
gos.log.info("COMMON_PATH", COMMON_PATH)
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
    at = { screen = { x = 30, y = 80 } }, text = text,
    color = "cyan", font_size = 18, shadow = true, frame = true,
  })
end, { interval_ms = 100 })
```
