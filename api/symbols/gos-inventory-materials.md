# gos.inventory.materials

Read prepared Materials storage totals and available names.

## Signature

```text
gos.inventory.materials()
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

### `gos.inventory.materials()`

Returns Materials storage, not a filtered copy of the carried bag. Before a
ready observation the table contains only `status="pending"` or `"unavailable"`.
A ready result has `revision` and a dense `items` array; an empty ready array
means the observed storage is empty.

```text
{
  status = "ready", revision = integer,
  items = {
    { prototype_handle = "item_prototype:...", catalog_key = "itemdef:..." | nil,
      quantity = integer,
      prototype = string | nil, name = string | nil,
      name_source = "en_us_catalog" | nil }, ...
  }
}
```

Material rows identify stored totals by prototype, not physical bag slots or
individual item instances. There is no `slot`, instance `handle`, `name_status`,
or `names_complete` field here. The pinned English catalog can supply names and
prototype paths even when the corresponding material definition is not loaded;
an unmapped name remains absent. Material quantities are independent of carried
bag quantities. Keep the bag and Materials revisions separate.
The native capture is bounded to 2048 material definitions; validated quantities
are positive integers up to 1,000,000,000. Exceeding a capture bound makes the
observation unavailable rather than publishing a truncated ready inventory.

## Related documentation

[Full inventory contract](../inventory.md)
