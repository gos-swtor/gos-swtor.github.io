# gos.overlay.unit_label

Add or refresh a temporary unit-anchored label.

## Signature

```text
gos.overlay.unit_label(id, unit, options)
```

## Contract and usage

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

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

## Related documentation

[Full overlay contract](../overlay.md)
