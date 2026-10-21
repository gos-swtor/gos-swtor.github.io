# gos.overlay.viewport

Read exact viewport dimensions only when available.

## Signature

```text
gos.overlay.viewport()
```

## Contract and usage

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

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
[gos.input.cursor()](../input.md#gosinputcursor). For a unit's projected anchor, use
[unit:screen_position()](../world.md#unitscreen_positionanchor). Neither query
registers an interaction rectangle. Viewport availability alone does not imply
that cursor input is available.

## Related documentation

[Full overlay contract](../overlay.md)
