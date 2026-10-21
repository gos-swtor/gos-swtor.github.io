# unit:discipline

Read the observed display discipline, or nil.

## Signature

```text
unit:discipline()
```

## Contract and usage

### `unit:discipline()`

Returns the observed display discipline name, or `nil`. A remote player's last
coherent discipline may remain available during a temporary acquisition gap;
a style change or conflicting evidence clears it. No separate freshness field
is exposed. Use `gos.abilities.loadout()` for the local player's exact ability
membership, rather than inferring a learned kit from a display label.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
