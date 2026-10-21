# unit:toughness

Read the observed toughness label and number, or nil.

## Signature

```text
unit:toughness()
```

## Contract and usage

### `unit:toughness()`

Returns two values: a toughness label and its numeric value. Returns `nil` when
no recognized toughness value is available.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
