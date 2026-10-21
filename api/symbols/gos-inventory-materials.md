# gos.inventory.materials

Read prepared Materials storage totals and available names.

## Signature

```text
gos.inventory.materials()
```

## Contract and usage

Read carried-bag and Materials storage snapshots during a tick. These queries
do not change items and do not cover equipped gear or bank contents.
All three functions take no arguments; extra arguments raise a Lua error.
Repeated reads in one Lua tick use the same prepared snapshot, not an immediate
client refresh. Tables can be retained as historical data, but are not live views.

### `gos.inventory.materials()`

Returns Materials storage, not a filtered copy of the carried bag. Before a
ready observation the table contains only `status="pending"` or `"unavailable"`.
A ready result has `revision` and a dense `items` array; an empty ready array
means the observed storage is empty.

```text
{
  status = "ready", revision = integer,
  items = {
    { prototype_handle = "item_prototype:...", quantity = integer,
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

## Related documentation

[Full inventory contract](../inventory.md)
