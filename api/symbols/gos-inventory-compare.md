# gos.inventory.compare

Compare observed bag and equipped item contributions; eligibility and special effects remain separate.

## Signature

```text
gos.inventory.compare(bag_slot, equipped_slot)
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

### `gos.inventory.compare(bag_slot, equipped_slot)`

Compares one occupied carried-bag slot with one occupied equipment destination.
Both arguments must be Lua integers, with `bag_slot` in 1..512 and
`equipped_slot` in 1..64. Numeric strings, fractional values, wrong argument
counts, and out-of-range slots raise a Lua error. There is no default destination.

The minimal result is `{status="unavailable", scope="item_stats"}` when the
prepared containers or either occupied row are absent. It returns `pending`
with `context_revision` while either row's sampled context differs from the
current snapshot. An empty equipment destination is not a zero-stat item.

Once both rows belong to the current context, the result can include:

```text
{
  status = "ready" | "unavailable", scope = "item_stats",
  context_revision = integer,
  candidate_handle = "item:...", equipped_handle = "item:...",
  bag_slot = integer, equipped_slot = integer,
  stat_delta = { status = "ready" | "unavailable",
    values = { [stat_key] = number, ... } | nil },
  item_rating_delta = integer | nil, armor_rating_delta = integer | nil,
  weapon_damage_min_delta = number | nil, weapon_damage_max_delta = number | nil,
  shield_chance_raw_delta = number | nil, shield_absorb_raw_delta = number | nil,
  nominal_weapon_delta = {
    status = "ready" | "unavailable", scope = "nominal_item" | nil,
    minimum = number | nil, maximum = number | nil
  },
  eligibility_status = "ready" | "unavailable", eligible = boolean | nil,
  equip_result = string | nil, effects_need_review = boolean
}
```

Numeric deltas are **candidate minus equipped**. The outer `status` follows
the native numeric `stat_delta`; zero stat deltas are omitted from its ready
`values` dictionary. Metadata deltas appear only when both source values were
observed. `nominal_weapon_delta` is ready only when both nominal observations
are ready. None of these values projects final character-sheet gains.

Eligibility is independent of numeric readiness. `eligible` appears only when
general eligibility and the requested destination's acceptance were both
observed. `effects_need_review=true` includes unresolved effect identities as
well as known special effects on either item. Even a ready, eligible comparison
does not resolve proc/set/tactical interactions or equip the candidate.

```lua
gos.on_tick(function()
  local inventory = gos.inventory.snapshot()
  if inventory.bag.status ~= "ready" or inventory.equipped.status ~= "ready" then return end
  local candidate = inventory.bag.items[1]
  local worn = inventory.equipped.items[1]
  if not candidate or not worn then return end
  local comparison = gos.inventory.compare(candidate.slot, worn.slot)
  if comparison.status == "ready" then
    gos.log.info("Item-stat comparison", comparison.bag_slot, comparison.equipped_slot,
      "eligibility", comparison.eligibility_status, "effects need review", comparison.effects_need_review)
  end
end, { interval_ms = 2000 })
```

## Related documentation

[Full inventory contract](../inventory.md)
