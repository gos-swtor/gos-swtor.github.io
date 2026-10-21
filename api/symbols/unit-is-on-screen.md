# unit:is_on_screen

Read whether this unit has a current on-screen observation.

## Signature

```text
unit:is_on_screen()
```

## Contract and usage

### `unit:is_on_screen()`

Returns whether this unit has a current on-screen render observation. This is
projection availability, not line of sight or cast permission.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
