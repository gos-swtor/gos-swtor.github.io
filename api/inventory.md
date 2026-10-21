# Inventory

Read carried-bag and Materials storage snapshots during a tick. These queries
do not change items and do not cover equipped gear or bank contents.
All three functions take no arguments; extra arguments raise a Lua error.
Repeated reads in one Lua tick use the same prepared snapshot, not an immediate
client refresh. Tables can be retained as historical data, but are not live views.

### `gos.inventory.snapshot()`

Returns `{ bag = table, materials = table }`. The two subtables have independent
availability and revision values. See [`gos.inventory.bag()`](#gosinventorybag)
and [`gos.inventory.materials()`](#gosinventorymaterials) for their fields.
A ready bag does not imply ready Materials data or complete item metadata.

```lua
gos.on_tick(function()
  local inventory = gos.inventory.snapshot()
  if inventory.bag.status == "ready" then
    gos.log.info("Bag slots used", inventory.bag.used, "/", inventory.bag.capacity)
  end
end, { interval_ms = 2000 })
```

### `gos.inventory.bag()`

Returns the bag subtable from the prepared inventory snapshot. Check `status`
before reading any other field. `pending` and `unavailable` contain only `status`;
they are not evidence of an empty bag. Only a ready table with `used == 0`
represents an observed empty bag.

```text
{
  status = "ready", revision = integer,
  capacity = integer, used = integer, names_complete = boolean,
  items = {
    {
      slot = integer, handle = "item:...",
      prototype_handle = "item_prototype:...", prototype = string | nil,
      quantity = integer | nil, name = string | nil,
      name_source = "client" | "en_us_catalog" | nil,
      name_status = "pending" | "ready" | "unavailable",
      item_rating = integer | nil, item_level = integer | nil,
      enhanced_item_level = integer | nil, required_level = integer | nil,
      durability = integer | nil, max_durability = integer | nil,
      quality = string | nil, bound = boolean | nil,
      weapon_damage_min = number | nil, weapon_damage_max = number | nil,
      shield_chance_raw = number | nil, shield_absorb_raw = number | nil
    }, ...
  }
}
```

`items` is a dense Lua array of occupied slots, sorted by physical `slot`.
Slots are one-based, but an array index is not the physical slot when there are
empty spaces. `used` counts occupied slots, not the sum of item quantities.
Handles are opaque identities, not addresses; neither item handle can be passed
to `world:resolve`, which accepts unit handles only. Do not parse or construct them.

Optional metadata arrives independently. Missing `quantity` does not mean one;
missing `bound` is unknown, whereas `bound=false` is an observed false value.
`names_complete` means every occupied row has a name, not that all metadata is
ready. A name may be localized by the client or supplied by the pinned English
catalog; `prototype` is an identifier path, not a display-name substitute.
`quality` is one of `cheap`, `standard`, `premium`, `prototype`, `artifact`,
`legendary`, `legacy`, `quest`, `currency`, or `moddable`; unsupported values
are omitted. The two shield fields are unnormalized client floats: do not
interpret them as percentages or 0..1 ratios without separate evidence.
Revisions identify changed prepared data, including metadata updates. Reset
consumer caches across `gos.world().session_generation` changes; revisions are
not an account-wide inventory history or a promise that an item still exists.

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
