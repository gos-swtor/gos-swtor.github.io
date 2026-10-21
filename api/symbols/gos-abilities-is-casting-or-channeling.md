# gos.abilities.is_casting_or_channeling

Read the current busy observation; named cast details can be independently unavailable.

## Signature

```text
gos.abilities.is_casting_or_channeling()
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.is_casting_or_channeling()`

Returns the current busy observation as a boolean. It can remain true briefly
while `current_cast()` is nil because busy state and named cast identity have
different availability. A missing ability snapshot also returns false.

## Related documentation

[Full abilities contract](../abilities.md)
