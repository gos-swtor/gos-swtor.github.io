# gos.abilities.cooldown_remaining

Read observed remaining cooldown in seconds, or nil when unavailable.

## Signature

```text
gos.abilities.cooldown_remaining(name)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.cooldown_remaining(ability)`

Returns observed remaining cooldown in seconds, or `nil` when the ability or
its cooldown observation is unavailable.

## Related documentation

[Full abilities contract](../abilities.md)
