# unit:effects

Read current effect rows and separately marked presentation-only history.

## Signature

```text
unit:effects(filter)
```

## Contract and usage

Resolve the unit in the current world before querying it. A stale unit raises a Lua `stale_unit` error; this is distinct from a current unit returning a pending or unavailable effect observation.

Queries return the latest completed poll, rather than reading effects
synchronously. A ready sample remains usable while its refresh is queued;
applications/removals appear at the next publication. Timers age from the
original sample between polls.

Check `status` and completeness. A complete ready observation establishes
presence/absence as of that poll. Pending or unavailable data is not an empty
effect list.

### `unit:effects(filter?)`

Returns the matching observed rows without merging same-name variants:

```text
{
  status = "ready" | "pending" | "unavailable",
  reason = string,
  age_ms = integer | nil,
  last_known_age_ms = integer | nil,
  truncated = boolean,
  last_known_truncated = boolean,
  items = { EffectRow, ... },
  last_known_items = { EffectRow, ... }
}
```

Both arrays use this row shape:

```text
{
  definition_key = "effectdef:<16 uppercase hex digits>" | nil,
  name = string,
  name_source = "client" | "core",
  freshness = "current" | "last_known",
  has_charges = boolean,
  charge_conflicted = boolean,
  stacks = integer | nil,
  has_timer = boolean,
  remaining = number | nil,
  has_duration = boolean,
  duration = number | nil,
  kind = "buff" | "debuff" | "passive" | "other",
  has_ownership = boolean,
  mine = boolean
}
```

The optional filter accepts `name`, `kind`, `definition_key`, `timed`, and `charged` with the same
semantics as the singular query. A ready empty `items` table proves no matching
current captured effect only when `truncated == false`. Pending, unavailable, or
truncated observations do not prove absence.

`last_known_truncated` reports capacity loss only in presentation continuity.
It does not weaken an otherwise complete current observation and must not be
used as a gameplay-availability gate.

Both arrays always exist. `items` contains current rows only when `status` is
ready. `last_known_items` retains presentation history for this unit, including
while current data is pending, unavailable or incompletely enriched. Its timers
age from the original sample and expire at zero. Those historical rows do not
make the observation ready and must not drive rotations, targeting or tactical
action cues.

```lua
local debuffs = target:effects({ kind = "debuff", timed = true })
if debuffs.status == "ready" then
  for _, effect in ipairs(debuffs.items) do
    if effect.mine then
      gos.log.debug(effect.name, effect.remaining or "untimed")
    end
  end
end
```

### Exact effect identity

`definition_key` identifies an effect definition, not an effect instance, a unit, or a castable ability. Same-name variants can have different keys. Treat keys as opaque and use an observed value; do not manufacture one. A key never makes a pending or historical row current. Both query forms accept a `definition_key` filter. To query only by key, pass an empty name to `unit:effect("", { definition_key = observed_key })`.

Plural rows expose `has_duration` and, when available, total `duration` in seconds. Duration is independent of `remaining`; do not estimate it from the first timer value you happen to see.

## Related documentation

[Full effects contract](../effects.md)
