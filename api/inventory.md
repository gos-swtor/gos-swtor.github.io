# Inventory

Read the player's carried bag, equipped gear, Materials storage, and prepared
character stats during a tick. Compare observed item contributions without
equipping an item. These functions are read-only: they do not equip gear,
transfer bank/storage items, or operate companions. The separate
[GTN interface](gtn.md) can use current carried-bag identities for sell listings.

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

See [`gos.inventory.bag()`](#gosinventorybag),
[`gos.inventory.materials()`](#gosinventorymaterials),
[`gos.inventory.equipped()`](#gosinventoryequipped), and
[`gos.inventory.player_stats()`](#gosinventoryplayer_stats) for each subtable's
contract. A ready container does not imply complete item metadata or ready stats.
`context_revision` is absent when no prepared inventory snapshot is available.
When present, it changes when the prepared character context changes, such as
level/scaling or instance context. Item rows carry the context in which their
metadata was sampled. Use [`compare`](#gosinventorycomparebag_slot-equipped_slot) to reject a mixed
context while the worker refreshes those rows.

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
      prototype_handle = "item_prototype:...", catalog_key = "itemdef:..." | nil,
      prototype = string | nil,
      quantity = integer | nil, name = string | nil,
      name_source = "client" | "en_us_catalog" | nil,
      name_status = "pending" | "ready" | "unavailable",
      item_rating = integer | nil, item_level = integer | nil,
      enhanced_item_level = integer | nil, required_level = integer | nil,
      durability = integer | nil, max_durability = integer | nil,
      quality = string | nil, bound = boolean | nil, armor_rating = integer | nil,
      weapon_damage_min = number | nil, weapon_damage_max = number | nil,
      shield_chance_raw = number | nil, shield_absorb_raw = number | nil,
      nominal_weapon = table,
      slot_type = string | nil,
      stats = table, shell_stats = table, adjustments = table,
      context_revision = integer, sampled_ms = integer | nil,
      augment_slot_available = boolean | nil,
      can_equip = boolean | nil, equip_result = string | nil,
      slot_acceptance = { [equipped_slot] = boolean, ... },
      equip_effects_status = "ready" | "unavailable",
      has_special_effects = boolean | nil,
      on_equip_handle = "item_ability:..." | nil,
      set_bonus_handle = "item_set:..." | nil,
      components = table
    }, ...
  }
}
```

`items` is a dense Lua array of occupied slots, sorted by physical `slot`.
Slots are one-based, but an array index is not the physical slot when there are
empty spaces. `used` counts occupied slots, not the sum of item quantities.
Handles are opaque identities, not addresses; neither item handle can be passed
to `world:resolve`, which accepts unit handles only. Do not parse or construct them.
The native bag bound is 512 slots. Use observed `capacity` for the current bag;
the bound does not imply that all 512 slots are unlocked.

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
Equipment/loadout changes can invalidate prepared stat samples before the next
successful metadata update. Item/prototype/component/effect handles are scoped
to the current Core process and domain; `catalog_key` is the cross-process
static-data identity. Reacquire current rows after a character/session change.

#### Item stats and equipment facts

`stats`, `shell_stats`, and `adjustments` each have this independent shape:

```text
{ status = "pending" | "ready" | "unavailable",
  values = { [stat_key] = number, ... } | nil }
```

`values` exists only when that particular stat observation is ready. The native
stat-map bound is 517 entries. Common keys are `mastery`, `endurance`, `presence`,
`armor`, `power`, `critical`, `alacrity`, `accuracy`, `defense`, `shield`, `absorb`,
`force_power`, and `tech_power`. Other keys retain their client enum names, such
as `STAT_cbt_force_accuracy`; the values use that stat's native units. There is
no public `complete` flag on these tables.

These are observed item contributions, not a projected change to the player's
final character sheet. `shell_stats` and `adjustments` are separate observations;
do not blindly add them to `stats` and count contributions twice.

`nominal_weapon` always contains `status`. When ready, it also contains
`scope="nominal_item"`, `applicable`, `minimum`, and `maximum`. Confirmed
non-weapons have `applicable=false` and zero nominal damage. Nominal weapon
values describe the item independently of contextual raw
`weapon_damage_min`/`weapon_damage_max`; they do not predict final sheet damage.

`can_equip` is present only when the client supplied an equipment result.
`equip_result` is the available client result name, such as `conResultOk` or
`conResultItemRequiresLevel`. Check both general eligibility and the destination:
`slot_acceptance[physical_equipped_slot]` is a sparse numeric-key table, with
`true` for observed acceptance, `false` for observed rejection, and `nil` for
unknown. Iterate explicit known destinations or `pairs`, not `ipairs`.
Neither field submits an equipment command or proves a later command will work.

`equip_effects_status="ready"` means both the on-equip and set-bonus identities
were observed, including an observed absence. Only then is `has_special_effects`
present. Nonzero identities may publish `on_equip_handle` and `set_bonus_handle`
independently. Missing identities must not be interpreted as no special effects;
these fields do not describe proc behavior, value a tactical, or predict DPS/HPS.

`components` has its own `status`, plus a dense `items` array only when ready.
It is bounded to six observed components. Each component has `slot`, an opaque
`item_component:...` `handle`, optional name/rating/level/durability/quality/binding/
armor/weapon/shield metadata, `name_status`, `nominal_weapon`, and its own `stats`.
Component rows do not publish an item `prototype_handle`, `catalog_key`, or
component-type field. A ready empty component array is distinct from unavailable
component data. `augment_slot_available` remains a separate optional boolean.

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

### `gos.inventory.presentation()`

Reads prepared native bag-icon geometry in **render-viewport pixels**. It covers
the standalone inventory (`view_id=1`) and the bag embedded in the character
sheet (`view_id=2`), not equipped-slot rectangles or bank layouts. It does not
open a window, click a slot, or refresh the semantic inventory capture.

When the publication is absent or belongs to a different player/session, only
`{status="unavailable"}` is returned; even `current` is absent in that case.
For a matching owner, diagnostic identity fields are returned before readiness:

```text
{
  status = "pending" | "ready" | "unavailable", current = boolean,
  owner = "unit:...", session_generation = integer,
  revision = integer, sampled_ms = integer, age_ms = integer | nil,
  reason = "ready" | "no_window" | "other_tab" | "hidden_movie" |
    "binding_changed" | "invalid_viewport" | "cell_unavailable" | "unknown",
  binding_revision = integer, ui_sequence = integer,
  view_id = integer, cell_count = integer, failed_slot = integer | nil,
  visible = boolean | nil, viewport_width = integer | nil, viewport_height = integer | nil,
  grid_rect = {x = number, y = number, width = number, height = number} | nil,
  rows = {
    {slot = integer, handle = "item:..." | nil, empty = boolean,
     visible = boolean, hovered = boolean,
     x = number, y = number, width = number, height = number}, ...
  } | nil
}
```

`visible`, viewport dimensions, `grid_rect`, and the dense `rows` array exist
only when `status="ready"`. Rows include verified empty cells: `empty=true`
has no item `handle`. Match the physical `slot` and current semantic item
`handle` before attaching a screen-space annotation. The publication is bounded
to 512 cells, with per-cell visibility and hover observations.

Require `status="ready"`, `current=true`, and suitable window/row visibility
before using raw rectangles. Ready geometry can become stale independently of
inventory revisions; retained coordinates are never a live UI binding. In the
current implementation, `current` also requires a matching live owner/session,
valid UI binding, and a native sample no older than 100 ms. Use `age_ms` for the
native UI sample age rather than subtracting this timestamp from a different
clock. Item-bound annotations have their separate
[`gos.overlay.inventory_marker`](overlay.md) contract.

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
