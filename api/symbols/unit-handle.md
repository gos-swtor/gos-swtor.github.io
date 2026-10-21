# unit:handle

Get an opaque identity that can be resolved in a fresh world; do not parse it.

## Signature

```text
unit:handle()
```

## Contract and usage

### `unit:handle()`

Returns an opaque `unit:...` identity, or `nil` if unavailable. This method also
works on an expired unit. Save the handle with its session/actor epoch and resolve
it in a fresh world before reading current state.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
