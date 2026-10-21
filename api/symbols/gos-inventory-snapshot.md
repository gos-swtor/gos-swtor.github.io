# gos.inventory.snapshot

Read the bag and Materials subtables from one prepared inventory snapshot.

## Signature

```text
gos.inventory.snapshot()
```

## Contract and usage

Read carried-bag and Materials storage snapshots during a tick. These queries
do not change items and do not cover equipped gear or bank contents.
All three functions take no arguments; extra arguments raise a Lua error.
Repeated reads in one Lua tick use the same prepared snapshot, not an immediate
client refresh. Tables can be retained as historical data, but are not live views.

### `gos.inventory.snapshot()`

Returns `{ bag = table, materials = table }`. The two subtables have independent
availability and revision values. See [`gos.inventory.bag()`](../inventory.md#gosinventorybag)
and [`gos.inventory.materials()`](../inventory.md#gosinventorymaterials) for their fields.
A ready bag does not imply ready Materials data or complete item metadata.

```lua
gos.on_tick(function()
  local inventory = gos.inventory.snapshot()
  if inventory.bag.status == "ready" then
    gos.log.info("Bag slots used", inventory.bag.used, "/", inventory.bag.capacity)
  end
end, { interval_ms = 2000 })
```

## Related documentation

[Full inventory contract](../inventory.md)
