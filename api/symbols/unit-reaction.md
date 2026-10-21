# unit:reaction

Read friendly, neutral, hostile or unclassified relationship.

## Signature

```text
unit:reaction()
```

## Contract and usage

### `unit:reaction()`

Returns `friendly`, `neutral`, `hostile` or `unclassified`.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
