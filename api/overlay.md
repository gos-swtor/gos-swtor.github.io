# Drawing and interaction

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

### PointSpec

Every `draw_*` primitive accepts the same point format. One-point primitives use
`options.at`; lines use `options.from` and `options.to`. Unit examples require a
current unit from `gos.world()`.

```text
-- Exactly one base per point.
{ screen = { x = 100, y = 200 }, pixel_offset = { x = 0, y = 0 } }
{ world = { x = 1, y = 2, z = 3 }, pixel_offset = { x = 0, y = -10 } }
{
  unit = unit, -- or unit_handle = "unit:..."
  anchor = "origin", -- default for PointSpec units
  world_offset = { x = 0, y = 0.2, z = 0 },
  local_offset = { right = 0, up = 0, forward = 0 },
  pixel_offset = { x = 0, y = -24 },
}
{ unit = unit, anchor = "top" | "center" | "bottom",
  pixel_offset = { x = 0, y = -4 } }
```

World and local offsets use the same game-world units as `unit:position()`;
`0.1` world unit is one metre. `local_offset` uses `unit:basis()` and requires
current rotation. Box anchors, screen points and absolute-world points accept
only `pixel_offset`.

Unit origins use the current render pose. World/local offsets are applied in
3D, projection uses the current camera, and `pixel_offset` is applied last.
No screen-box fallback is substituted for a missing unit origin.

Malformed or conflicting points raise a Lua error. Missing prepared unit
position, rotation required by a local offset, or a box anchor returns `false`. Camera and
projection checks happen during rendering: an accepted drawing may be omitted
if its point becomes unavailable or lies behind the camera. A true return does
not establish visibility.

Legacy unit/options and flat screen-anchor forms remain accepted; use PointSpec
for new drawings.

### Common Draw Options

```text
{
  ttl = 0.25,
  frame = false,
  at = PointSpec, -- or from/to for a line
  color = color,
  thickness = number,
  center_x = boolean,
  center_y = boolean
}
```

Use `frame=true` for UI redrawn by a callback. Each run replaces that callback's
previous drawings; skipped scheduler ticks retain them. Otherwise the drawing
expires after `ttl` seconds and must be refreshed to remain visible.

Colors accept a name, packed RGBA integer, or
`{ r = 255, g = 255, b = 255, a = 255 }`. Names are `white`, `black`,
`gray`/`grey`, `yellow`, `green`, `red`, `cyan`, `blue`, `orange` and `magenta`.
Alternative option keys are `w`/`h` for `width`/`height`, `background_color` for
`bg_color`, and `num_points` for `segments`.

Shared limits are 512 active draw commands across frame and TTL output,
192 frame commands per callback, and 32 frame callback owners. IDs allow 31 bytes,
text 63 bytes, and image paths 259 bytes. Empty, oversized or zero-containing
IDs raise a Lua error; IDs are never truncated. Text and image paths are
truncated, so keep them within their byte limits.

Replacement matches callback owner, target identity, draw kind and exact ID.
Short local IDs are safe across callbacks. Use stable widget IDs: changing the
target or draw kind can leave the earlier TTL drawing alive.

### `gos.overlay.draw_text(id, options)`

Draws nonempty `text` at `options.at`. Supports `font_size`, `shadow` and the
common color/alignment options.

```lua
gos.overlay.draw_text("status", {
  at = { unit = unit, anchor = "top",
         pixel_offset = { x = 0, y = -24 } },
  text = "READY", color = "green", font_size = 16,
  shadow = true, center_x = true, frame = true,
})
```

### `gos.overlay.draw_line(id, options)`

Requires both `from` and `to`. Each endpoint has an independent PointSpec, so a
line can join screen, world or unit points. Supports `color` and `thickness`.

```lua
gos.overlay.draw_line("cast_target", {
  from = { unit = source, anchor = "center" },
  to = { unit = target, anchor = "center" },
  color = "red", thickness = 2.5, frame = true,
})
```

### `gos.overlay.draw_rect(id, options)`

Alias: `gos.overlay.draw_rectangle(id, options)`.

Requires positive `width` and `height`. Supports `filled`, `fill_color`,
`rounding`, `border` and `border_color`.

```lua
gos.overlay.draw_rect("rect", {
  at = { unit = unit, anchor = "top",
         pixel_offset = { x = -40, y = -14 } },
  width = 80, height = 10,
  color = "yellow", filled = false, rounding = 2,
})
```

### `gos.overlay.draw_bar(id, options)`

Requires positive `width` and `height`; clamps `value` to `0..1`. Supports
`bg_color`, `border` and `border_color`.

```lua
gos.overlay.draw_bar("health", {
  at = { unit = unit, anchor = "top",
         pixel_offset = { x = -45, y = -18 } },
  width = 90, height = 6,
  value = 0.5, color = "green",
  bg_color = { r = 12, g = 14, b = 16, a = 220 },
  border = true, border_color = "black",
})
```

### `gos.overlay.draw_circle(id, options)`

Requires exactly one positive `radius` in screen pixels or `world_radius` in
world units. Supports `color`, `thickness` and `segments`. Screen-radius circles
also support `filled`.

```lua
gos.overlay.draw_circle("screen_circle", {
  at = { unit = unit, anchor = "center" },
  radius = 18, color = "orange",
  segments = 32, filled = false,
})
```

`world_radius` draws an unfilled X/Z world circle. It requires an absolute world
point or a current unit origin. A 30-metre circle uses `world_radius = 3`:

```lua
gos.overlay.draw_circle("range", {
  at = { unit = unit, anchor = "origin" },
  world_radius = 30 / 10,
  color = "cyan", segments = 64, thickness = 2,
})
```

To keep a marker after a unit disappears, copy its position while available and
submit an absolute world point. This fragment uses the saved `last` position;
it does not track the unit or establish its current location:

```lua
gos.overlay.draw_circle("last_seen", {
  at = { world = { x = last.x, y = last.y, z = last.z } },
  world_radius = 8 / 10,
  color = "magenta", thickness = 3, ttl = 8,
})
```

### `gos.overlay.draw_image(id, options)`

Draws the image at `path`. Omitted width or height uses that texture dimension.
`tint` is an alias for `color`.

```lua
gos.overlay.draw_image("icon", {
  at = { unit = unit, anchor = "origin",
         world_offset = { x = 0, y = 0.2, z = 0 },
         pixel_offset = { x = 0, y = -24 } },
  path = SPRITE_PATH .. "icon.png", width = 24, height = 24,
  tint = "white", center_x = true,
})
```

Relative paths use `SCRIPT_PATH`; `SPRITE_PATH` is suitable for packaged images.
Image paths must stay inside the approved filesystem roots. Network-share,
device, URL and escaping paths are rejected. Loading runs separately, so an
accepted draw does not guarantee that the image decoded or appeared.

### `gos.overlay.unit_label(id, unit, options)`

This legacy label helper accepts `text`, a named `color`, and `ttl`. Its replacement key is the target and ID, without callback ownership, so keep its names distinct across scripts. Use `draw_text` for script-owned UI. It does not implement the generic `draw_*` options such as `frame`, `anchor`, font sizing or RGBA color tables.

Adds or refreshes a simple unit label:

```lua
local ok = gos.overlay.unit_label("focus", unit, {
  text = "FOCUS",
  color = "red",
  ttl = 0.25,
})
```

The Release snapshot retains at most 32 active labels.

### `gos.overlay.viewport()`

Returns the exact current render viewport:

```text
{
  available = boolean,
  width = integer | nil,
  height = integer | nil
}
```

No guessed dimensions are returned when `available=false`.

For a read-only pointer sample in this pixel space, use
[gos.input.cursor()](input.md#gosinputcursor). For a unit's projected anchor, use
[unit:screen_position()](world.md#unitscreen_positionanchor). Neither query
registers an interaction rectangle. Viewport availability alone does not imply
that cursor input is available.


### `gos.overlay.interact(id, rect)`

Requires an active script callback. An empty or over-31-byte ID, an ID containing embedded zero bytes, an invalid rectangle, nonpositive TTL, or wrong arguments raise a Lua error. Drawing and interaction IDs use the same validation and are never truncated. Registers a temporary screen rectangle and returns left-mouse interaction:

```text
local state = gos.overlay.interact("button", {
  x = 20, y = 20, width = 120, height = 28, ttl = 0.25,
})

-- state:
{
  hovered = boolean,
  pressed = boolean,
  down = boolean,
  released = boolean,
  clicked = boolean,
  mouse_x = number,
  mouse_y = number,
  entity_handle = "unit:..." | nil,
  entity_generation = integer,
  entity_session_generation = integer,
  target_intent = userdata | nil
}
```

Refresh the rectangle before its TTL expires. A press retains capture through
release. The Release snapshot retains at most 64 active interaction rectangles,
with at most 40 contributed by one callback owner, subject to the 32-owner frame ceiling. If registration or input observation is unavailable, the result can contain all false flags and zero coordinates with no separate availability flag. That state alone is not proof that the pointer is outside the rectangle; stay within the published budgets.

For an entity-associated region, supply `rect.entity = unit:handle()` from the
current world. This optional field accepts a Core unit-handle string, not a
`GosUnit`; malformed values raise a Lua error. Omit it for ordinary UI buttons.
The returned `entity_handle` is pinned on press, so a reordered list cannot turn
the eventual click into a selection of the row's new occupant. Generation fields
are zero when no entity observation exists.

`entity_generation` describes the displayed snapshot, not session identity.
Resolve the returned handle in a fresh world and compare
`entity_session_generation` to `world.session_generation`; ordinary tick changes
must not invalidate a click. Do not use the row's current entity instead.
For a completed entity click, `target_intent` is an immutable, script-owned ticket
for `gos.target.select`. It can be absent when a click could not be authenticated.
Do not manufacture a replacement or retry without it after rejection.

The following is a callback integration fragment; `displayed_unit` and the
rectangle come from your current layout, while `pending_target` is retained by
your script. It uses the pressed identity, not the layout's later contents:

```lua
local world = gos.world()
local state = gos.overlay.interact("ally_row", {
  x = 20, y = 60, width = 180, height = 28, ttl = 0.25,
  entity = displayed_unit:handle(),
})
if state.clicked and state.target_intent and state.entity_handle and
   state.entity_session_generation == world.session_generation then
  local clicked_unit = world:resolve(state.entity_handle)
  if clicked_unit then
    local ok, reason, handle = gos.target.select(clicked_unit, state.target_intent)
    if ok then pending_target = handle end
    -- Rejection is not permission to retry this click without its ticket.
  end
end
```

Poll any retained handle with `gos.target.status` in subsequent ticks; do not
resubmit it on every update. See the [target request contract](world.md#gostargetselectunit-target_intent)
for the two-second ticket window, native user-intent ordering, bounded receipt
retention and cancellation limits. Rendering or registering a rectangle alone
does not change the game's selected target.
