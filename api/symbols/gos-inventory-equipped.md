# gos.inventory.equipped

Read prepared equipped item rows by physical slot, including their optional metadata and stats.

## Signature

```text
gos.inventory.equipped()
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

### `gos.inventory.equipped()`

Returns the player's equipment subtable from `snapshot()`. Its container and
occupied-row shapes are the same as `bag()`, including independent `status`,
`revision`, `capacity`, `used`, `names_complete`, and dense `items`.
It does not enumerate outfitter outfits or companion equipment.

Equipped `slot` values are physical client destinations, bounded to 1..64. They
can exceed the container's reported `capacity`, which counts entries rather
than defining the largest physical equipment slot. Keep duplicate implant and
relic destinations separate. Prefer the observed `slot_type`, such as
`conSlotEquipHumanImplant`, `conSlotEquipHumanRelic`, or
`conSlotEquipHumanTactical`, over guessed slot numbers or display names.
Unsupported slot-type values remain absent. `slot_type` is a client enum name,
not an instruction to parse the opaque item handle.

## Related documentation

[Full inventory contract](../inventory.md)
