# gos.abilities.cooldown_duration

Read observed total cooldown in seconds, or nil when unavailable.

## Signature

```text
gos.abilities.cooldown_duration(name)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.cooldown_duration(ability)`

Returns observed total cooldown duration in seconds, or `nil` when the ability
or its duration observation is unavailable.

## Related documentation

[Full abilities contract](../abilities.md)
