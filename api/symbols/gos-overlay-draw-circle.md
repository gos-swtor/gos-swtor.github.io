# gos.overlay.draw_circle

Draw a screen-radius or world-radius circle at a shared PointSpec.

## Signature

```text
gos.overlay.draw_circle(id, unit_or_options, options)
```

## Contract and usage

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

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

## Related documentation

[Full overlay contract](../overlay.md)
