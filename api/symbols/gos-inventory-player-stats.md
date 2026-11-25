# gos.inventory.player_stats

Read observed player ratings and independently available character-sheet values.

## Signature

```text
gos.inventory.player_stats()
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

### `gos.inventory.player_stats()`

Returns the prepared current player's observed stats:

```text
{
  status = "pending" | "ready" | "unavailable",
  values = { [stat_key] = number, ... } | nil,
  item_rating = integer | nil, sampled_ms = integer | nil,
  sheet = {
    status = "pending" | "ready" | "unavailable",
    values = {
      weapon_damage_min = number | nil, weapon_damage_max = number | nil,
      offhand_damage_min = number | nil, offhand_damage_max = number | nil,
      weapon_accuracy = number | nil,
      melee_bonus_damage = number | nil, ranged_bonus_damage = number | nil,
      damage_reduction = number | nil, defense_chance = number | nil,
      shield_chance = number | nil, shield_absorb = number | nil,
      alacrity = number | nil, force_regeneration = number | nil
    } | nil
  }
}
```

`sheet` is always present, even when the outer stats are pending or unavailable.
Its `values` table is present only when the sheet observation is ready, and each
derived value remains optional. A ready ratings map does not guarantee a ready
sheet or applicable offhand damage.

`item_rating` is the observed equipped item rating, not a sum of bag ratings.
`sampled_ms` is the Core's monotonic sample timestamp. Chance, reduction,
accuracy, and alacrity values in `sheet.values` are fractions: 1 means 100%.
`force_regeneration` is per second. The outer `values` dictionary uses the raw
units of each individual stat. Do not apply the sheet's fraction interpretation
to the item's unnormalized `shield_chance_raw`/`shield_absorb_raw` fields.

```lua
gos.on_tick(function()
  local stats = gos.inventory.player_stats()
  local sheet = stats.sheet
  if stats.status == "ready" and sheet.status == "ready" then
    local accuracy = sheet.values.weapon_accuracy
    if accuracy ~= nil then
      gos.log.info("Observed weapon accuracy", accuracy * 100, "%")
    end
  end
end, { interval_ms = 2000 })
```

## Related documentation

[Full inventory contract](../inventory.md)
