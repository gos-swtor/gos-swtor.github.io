# gos.inventory.bag

Read current carried-bag rows with optional item identity, metadata, stats and equipment facts.

## Signature

```text
gos.inventory.bag()
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

## Related documentation

[Full inventory contract](../inventory.md)
