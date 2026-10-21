# gos.abilities.is_ready

Read the local ability-row readiness flag, not target-specific cast admission.

## Signature

```text
gos.abilities.is_ready(name)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.is_ready(ability)`

`is_ready()` reads the resolved ability row's readiness flag and returns false when the row is unavailable. It does not perform the target-specific validation done by `can_cast()`. A ready row does not prove target visibility, facing, range or command admission.

## Related documentation

[Full abilities contract](../abilities.md)
