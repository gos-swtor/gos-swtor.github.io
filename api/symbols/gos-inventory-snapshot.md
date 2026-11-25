# gos.inventory.snapshot

Read bag, Materials, equipment and player stats from one prepared inventory snapshot.

## Signature

```text
gos.inventory.snapshot()
```

## Contract and usage

Read the player's carried bag, equipped gear, Materials storage, and prepared
character stats during a tick. Compare observed item contributions without
equipping an item. These functions are read-only: they do not equip gear,
transfer bank/storage items, or operate companions. The separate
[GTN interface](../gtn.md) can use current carried-bag identities for sell listings.

`snapshot`, `bag`, `materials`, `equipped`, `player_stats`, and `presentation`
take no arguments; extra arguments raise a Lua error. `compare` requires exactly
two integer slot arguments. The bag/equipment/stat queries use the prepared
snapshot for the current Lua tick, rather than forcing a client refresh.
`presentation` reads an independently updated native UI publication.
Returned tables can be retained as history, but are not live views.

Bag, equipped, and Materials items with known catalog identity expose `catalog_key`:
`itemdef:` followed by 16 uppercase hexadecimal digits. This key is stable across
processes and matches the same GTN catalog item. It is descriptive data, never a
replacement for a current item or prototype handle when submitting commands.

### `gos.inventory.snapshot()`

Returns the following table. Each subtable has its own availability. Bag,
equipment, and Materials revisions are independent; `player_stats` has a sample
timestamp instead of a revision.

```text
{
  context_revision = integer | nil,
  bag = table, materials = table, equipped = table, player_stats = table
}
```

See [`gos.inventory.bag()`](../inventory.md#gosinventorybag),
[`gos.inventory.materials()`](../inventory.md#gosinventorymaterials),
[`gos.inventory.equipped()`](../inventory.md#gosinventoryequipped), and
[`gos.inventory.player_stats()`](../inventory.md#gosinventoryplayer_stats) for each subtable's
contract. A ready container does not imply complete item metadata or ready stats.
`context_revision` is absent when no prepared inventory snapshot is available.
When present, it changes when the prepared character context changes, such as
level/scaling or instance context. Item rows carry the context in which their
metadata was sampled. Use [`compare`](../inventory.md#gosinventorycomparebag_slot-equipped_slot) to reject a mixed
context while the worker refreshes those rows.

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
