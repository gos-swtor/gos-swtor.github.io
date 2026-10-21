# unit:screen_position

Read a current projected top, center or bottom unit anchor in pixels; return nil when unavailable.

## Signature

```text
unit:screen_position(anchor)
```

## Contract and usage

### `unit:screen_position(anchor?)`

Read a projected anchor from this unit's current, generation-validated render
observation. This method reads prepared screen coordinates; it does not perform
a world-to-screen calculation on demand, a screen-to-world raycast, or a
line-of-sight test.

`anchor` is an optional lowercase string:

| Anchor | Point returned |
| --- | --- |
| `"top"` | Top-center of the prepared unit box |
| `"center"` | Vertical midpoint of the prepared unit box; the default |
| `"bottom"` | Bottom-center of the prepared unit box |

Omitting the argument or passing nil uses `"center"`. Unsupported anchor
strings, non-string non-nil values, or extra arguments raise a Lua error.
`"middle"` and `"screen"` are not accepted aliases for this method.

```text
{ x = number, y = number } | nil
```

The returned X and Y are render-viewport pixels, with the origin at the top-left,
X increasing rightwards and Y increasing downwards. They share the coordinate
space of [gos.input.cursor()](../input.md#gosinputcursor) and screen overlays.
They are not the game-world coordinates returned by `unit:position()`, and no
world-unit-to-metre conversion applies. These are box anchors, not anatomical
bones or an exact clickable outline. Values are not clamped to the viewport.

Return `nil` when the current observation is not on screen or the prepared
projection is unavailable/invalid. Do not reuse last-known pixels as a current
targeting observation. An expired `GosUnit` raises `stale_unit` rather than
returning nil; reacquire the unit from the current world before reading it.

```lua
gos.on_tick(function()
  local world = gos.world()
  local unit = world and world.current_target
  if not unit or type(unit.screen_position) ~= "function" then return end
  local point = unit:screen_position() -- default center
  if not point then return end
  gos.overlay.draw_circle("unit_anchor", {
    at = { screen = { x = point.x, y = point.y } },
    radius = 12, filled = false, frame = true,
  })
end)
```

A non-nil point proves only that these screen coordinates are available. Check
health, reaction, range and native ability admission separately before acting.
The method does not capture mouse input, change selection or cast anything, and
can return a position even when the cursor query is unavailable. See the
[cursor example](../input.md#gosinputcursor) for a pixel-radius comparison.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md) | [Operative cursor Holotraverse](../../examples/live-operative-holotraverse.md)
