# unit:effect

Query a named or definition-key-matched aggregate; check readiness and completeness.

## Signature

```text
unit:effect(name, options)
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

### `unit:effect(name, options?)`

Returns one case-insensitive named aggregate:

```text
{
  status = "ready" | "pending" | "unavailable",
  reason = string,
  age_ms = integer | nil,
  truncated = boolean,

  -- Present only when status == "ready":
  present = boolean | nil,
  has_charges = boolean | nil,
  charge_conflicted = boolean | nil,
  stacks = integer | nil,
  has_timer = boolean | nil,
  remaining = number | nil,
  kind = "buff" | "debuff" | "passive" | "other" | "none" | nil,
  has_ownership = boolean | nil,
  mine = boolean | nil
}
```

Options:

```lua
local proc = player:effect("Tidal Force", {
  kind = "buff",       -- any, buff, debuff, passive, or other
  timed = true,         -- require or reject a timer
  charged = false,      -- require or reject a charge observation
})

if proc.status == "ready" and proc.present then
  local remaining = proc.has_timer and proc.remaining or nil
end
```

The singular query prefers exact local-player-owned rows when local and foreign
effects share a name. `mine` is output metadata, not a filter. A truncated scan
that cannot prove absence returns an unavailable result rather than
`present=false`.

Omitted options impose no kind, timer, or charge filter. Supplied filters combine
with AND; unknown keys and wrong filter types raise a Lua error. `charged=true`
includes conflicted charge observations, so it does not guarantee a usable
`stacks` value. Require `has_charges=true` and `charge_conflicted=false` before
making a stack-count decision. `remaining` and `duration` use seconds;
`age_ms` and `last_known_age_ms` use milliseconds.

`has_ownership=false` means source identity is unavailable; `mine=false` alone
does not establish foreign ownership. Kind follows the observed effect classification;
an absent timer or an `Other` list does not prove an effect is passive.

Common public reasons are `none`, `observation_pending`, `unsupported_unit`,
`observation_capacity`, and `not_captured`. Treat other reasons as diagnostics:
branch on `status` rather than undocumented reason strings.

### Exact effect identity

`definition_key` identifies an effect definition, not an effect instance, a unit, or a castable ability. Same-name variants can have different keys. Treat keys as opaque and use an observed value; do not manufacture one. A key never makes a pending or historical row current. Both query forms accept a `definition_key` filter. To query only by key, pass an empty name to `unit:effect("", { definition_key = observed_key })`.

Plural rows expose `has_duration` and, when available, total `duration` in seconds. Duration is independent of `remaining`; do not estimate it from the first timer value you happen to see.

## Related documentation

[Full effects contract](../effects.md) | [Operative Kolto Probe upkeep](../../examples/live-operative-probes.md) | [Sage PoM and proc prediction](../../examples/live-sage-pom-prediction.md) | [Commando Supercharge timing](../../examples/live-commando-supercharge.md)
