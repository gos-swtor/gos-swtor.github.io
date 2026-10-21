# gos.abilities.gcd_remaining

Read remaining global cooldown in seconds, or nil.

## Signature

```text
gos.abilities.gcd_remaining()
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.gcd_remaining()`

Returns the local player's observed global cooldown in seconds, or `nil` when
the snapshot or GCD observation is unavailable.

## Related documentation

[Full abilities contract](../abilities.md)
