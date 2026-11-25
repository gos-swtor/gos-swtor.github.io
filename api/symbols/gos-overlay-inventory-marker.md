# gos.overlay.inventory_marker

Submit a frame-owned, click-through marker for an exact current carried-bag item.

## Signature

```text
gos.overlay.inventory_marker(id, options)
```

## Contract and usage

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

### `gos.overlay.inventory_marker(id, options)`

Submits a click-through marker around an exact current bag item. Returns `true`
when the current callback accepts the drawing, or `false` when its item,
presentation, callback owner, or frame budget is unavailable. Acceptance does
not guarantee that the marker is later drawn: the item, visible cell, player,
session, and inventory view are checked again during rendering.

```lua
gos.on_tick(function()
  local bag = gos.inventory.bag()
  if bag.status ~= "ready" then return end
  local item = bag.items[1]
  if not item then return end
  local accepted = gos.overlay.inventory_marker("bag-candidate", {
    bag_slot = item.slot,
    item_handle = item.handle,
    color = "green",
    tradeoff = false,
  })
end)
```

`id` uses the shared overlay ID rules: 1 to 31 bytes, without embedded zero
bytes. Invalid IDs raise a Lua error. `options` must be a table. `bag_slot` uses
Lua's integer conversion and must be in `1..512`: integer-valued numbers and
convertible numeric strings are accepted; a fractional/nonconvertible value,
missing field, or out-of-range slot raises a Lua error. `item_handle` uses Lua's
string conversion, so a number is converted to text and normally fails the item
match rather than raising a type error. Missing or nonconvertible handles raise
a Lua error. A slot/handle that does not match the current bag returns `false`.
Use the item's physical `slot`, not its position
in the compact `items` array or a retained catalog key.

`color` accepts the [common color forms](../overlay.md#common-draw-options) and defaults to
pale green. `tradeoff` uses Lua truthiness: omitted, `nil`, or `false` gives a
chevron; a truthy value gives a small diamond, in addition to the marker's
corners. Pass an actual boolean for clarity; Lua treats `0` as truthy.
This is visual decoration; it does not register a click region or equip, select,
transfer, or trade the item.

The drawing belongs to the callback's frame, sharing its command budget. Submit
it again whenever that callback redraws; there is no independent marker TTL.
Core resolves the latest prepared bag rectangle instead of trusting a saved
screen coordinate. Closing or switching the bag view, moving/replacing the
item, changing player/session, or losing current presentation can withdraw it.
Use [inventory presentation](../inventory.md#gosinventorypresentation) when the
script also needs the read-only grid/cell observations.

## Related documentation

[Full overlay contract](../overlay.md)
