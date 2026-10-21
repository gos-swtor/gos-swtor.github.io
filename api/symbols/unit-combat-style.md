# unit:combat_style

Read a stable lowercase combat-style key, or nil.

## Signature

```text
unit:combat_style()
```

## Contract and usage

### `unit:combat_style()`

Returns a stable lowercase combat-style key, or `nil`. Style and discipline are
independently optional; another player's style can be known while their
current discipline is unavailable.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
