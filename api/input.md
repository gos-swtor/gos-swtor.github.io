# Keyboard and mouse

### Key and button state

```lua
gos.input.is_down(button)       -- boolean
gos.input.was_pressed(button)   -- boolean for this update
gos.input.was_released(button)  -- boolean for this update
gos.input.state(button)         -- detailed table
```

`state` returns:

```text
{
  name = string,
  virtual_key = integer,
  known = boolean,
  down = boolean,
  pressed = boolean,
  released = boolean
}
```

Buttons may be a canonical name, supported alias, integer virtual-key value in
`1..255`, decimal text, hexadecimal text, or `vk:NN` text. Canonical names
include `mouse1` through `mouse5`, common navigation/modifier keys, digits,
letters, and `f1` through `f12`. Unknown string names and out-of-range integer keys return false; `state` also sets `known=false`. Unsupported argument types such as a table, boolean or nil raise a Lua argument error instead of returning an unknown-button state.

Canonical single-digit strings are keyboard keys: `"5"` means the 5 key, not virtual-key value 5. Use `"vk:5"` or integer `5` for that numeric virtual key. Canonical names and aliases are case-insensitive.

Input edges are shared snapshot values and are not consumed by reading them.

Press/release edges belong to the current update; they are not accumulated separately for a throttled callback. A callback using `interval_ms` can miss an edge between its runs. Process edge-driven actions every update, or deliberately use held-state semantics instead. `known` identifies a recognized button argument, not a guarantee that a current input sample was available.

### `gos.input.cursor()`

Read the latest prepared cursor sample in render-viewport pixels inside
`gos.on_tick`. This is a read-only query: it does not register an interaction
rectangle, capture input, move the pointer, select a target, or cast an ability.
It accepts no arguments; extra arguments, including an explicit nil, raise a
Lua argument error.

```text
{
  available = boolean,
  x = number | nil,
  y = number | nil,
  width = integer | nil,
  height = integer | nil
}
```

When `available` is true, `x` and `y` are cursor coordinates and `width` and
`height` are the positive render-viewport dimensions. The origin is the top-left;
X increases rightwards and Y increases downwards. Coordinates are in the same
pixel space as [unit screen anchors](world.md#unitscreen_positionanchor) and
screen-space overlay drawings, not desktop coordinates or game-world units.
The cursor sample is quantized to whole pixels, returned as Lua numbers.

When unavailable, the result contains only `{ available = false }`. All four
coordinate/dimension fields are omitted; they are not zero-valued substitutes.
This includes a missing render/input sample, no foreground game focus, a cursor
outside the viewport, an open GoS menu, GoS text or hotkey capture, a GoS
interaction rectangle under the pointer, or while either the left or right mouse button is held, including mouse-look
drags. Read viewport size independently through
[gos.overlay.viewport()](overlay.md#gosoverlayviewport) when cursor input is
unavailable.

**Availability is not a game-UI focus check.** SWTOR chat, inventory and other
native UI controls are not identified by this API. Reading the cursor or a key
does not consume that key or prevent the game from acting on the same binding.
An action hotkey therefore needs a deliberate input policy; do not treat
`available = true` as permission to cast while typing in chat.

The sample is prepared by rendering; this call does not force a new input or
projection update and does not promise that separate reads share a frame token.
Do not reuse an earlier available sample to make a later gameplay decision after
the current sample becomes unavailable.

This display-only example marks the current target when its projected center
is within a 120-pixel cursor radius. It does not change the selected target.

```lua
gos.on_tick(function()
  if type(gos.input.cursor) ~= "function" then return end
  local cursor = gos.input.cursor()
  if not cursor.available then return end
  local world = gos.world()
  local unit = world and world.current_target
  if not unit or type(unit.screen_position) ~= "function" then return end
  local point = unit:screen_position("center")
  if not point then return end
  local dx, dy = point.x - cursor.x, point.y - cursor.y
  if dx * dx + dy * dy <= 120 * 120 then
    gos.overlay.draw_circle("cursor_target", {
      at = { screen = { x = point.x, y = point.y } },
      radius = 18, filled = false, frame = true,
    })
  end
end)
```

For nearest-unit selection, compare squared pixel distances across a bounded
set of freshly captured, explicitly filtered units. Projection alone does not
prove that a unit is alive, friendly, in ability range, in line of sight, or a
legal ability target. Keep those checks separate from screen proximity.
Older Core builds may not provide these two methods; the example checks their
existence and takes no action when either is absent.
