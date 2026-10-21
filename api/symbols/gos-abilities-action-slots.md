# gos.abilities.action_slots

Read an array of observed on-bar abilities; availability is reported by loadout.

## Signature

```text
gos.abilities.action_slots()
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### Ability Row

`gos.abilities.action_slots()` returns a pure array of current on-bar rows.
Use `loadout().action_bar_available` and `action_bar_truncated` to distinguish
a coherent empty bar from missing/incomplete observations.
`gos.abilities.info(ability)` returns one matching row, including a known
off-bar row, or `nil`.

```text
{
  name = string,
  name_source = "client" | "core",
  on_bar = boolean,
  ability_handle = "ability:..." | nil,
  activation_handle = "ability:..." | nil,
  slot_index = integer | nil,
  key_number = integer | nil,
  ready = boolean,
  submission_pending = boolean,
  has_cooldown_remaining = boolean,
  cooldown_remaining = number | nil,
  has_cooldown_duration = boolean,
  cooldown_duration = number | nil,
  has_current_charges = boolean,
  current_charges = integer | nil,
  has_max_charges = boolean,
  max_charges = integer | nil,
  has_resource_cost = boolean,
  resource_cost = number | nil,
  has_line_of_sight_requirement = boolean,
  line_of_sight_required = boolean | nil
}
```

`slot_index` is zero-based. `ability_handle` is accepted by ability lookup and
submission functions. `activation_handle` is for comparing activation and
event identity; do not pass it as the submission ability.

`name_source` identifies observed client text versus Core-derived display text;
Core text may differ from localized UI spelling. Name-based ability queries prefer the current on-bar group
over historical off-bar rows and reject distinct IDs with the same matching
name within that group. Duplicate bindings of one ID remain valid. Use the
`ability_handle` for an unambiguous lookup.

Charge and resource fields remain absent until their current observations are
available. Do not infer charge counts or costs from timers.

`has_line_of_sight_requirement` says whether the requirement is known; only then is `line_of_sight_required` meaningful. This metadata is not a visibility test. Use the cast-readiness result to observe whether line of sight was actually checked.

## Related documentation

[Full abilities contract](../abilities.md)
