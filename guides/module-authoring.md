---
title: SWTOR Lua Scripting - Write Reusable Addon Modules
description: Organize SWTOR Lua addons into entry scripts and reusable modules, locate the configured shared root, and keep settings, callbacks and command ownership clear.
---
# Write reusable modules

Put formatting, event histories and decision logic in modules that a top-level
script can load with `require`.

## Separate responsibilities

A top-level script owns settings, activation and callbacks. Plain modules can transform copied data without registering callbacks. An event collector can maintain a bounded model. A presentation callback draws that prepared model. When commands are involved, exactly one top-level executor owns them and is passed to routes.

A small project can consist of an entry point in the active scripts root and shared files such as `my_tool_model.lua` and `my_tool_format.lua` in the approved common root. Load them with `require("my_tool_model")`. Module state is cached per top-level script environment, not shared global state across every script.

Use [Getting started](getting-started.md#install-and-run-your-first-script) to
locate the actual `SCRIPT_PATH` and `COMMON_PATH` for your installation.
Packaged helpers have [their own availability requirements](helpers.md#make-the-helper-modules-available).

A Lua reload recreates callbacks and module state. Successful Official Script
Library installs, updates and removals reload enabled scripts automatically,
including local scripts. Make load-time initialization safe to repeat.

## Example: a plain Lua module

```lua
-- my_tool_format.lua
local Format = {}
function Format.health(hp)
  if not hp or hp.percent == nil then return "unknown" end
  return string.format("%.0f%%", hp.percent)
end
return Format
```

Use it from another script:

```lua
local Format = require("my_tool_format")
gos.on_tick(function()
  local player = gos.world().player
  local text = Format.health(player and player:hp() or nil)
  -- Draw the prepared text or store it in your presentation model.
end, { interval_ms = 100 })
```

For histories, see the [bounded ring-buffer module](../examples/bounded-history.md). Retain copied scalar data or opaque handles, not generation-bound world or unit objects.

See [Runtime and data](runtime.md) for available Lua libraries and
[sandbox file helpers](../api/files.md) for permitted load-time resources.
