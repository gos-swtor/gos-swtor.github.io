# unit:name

Read the observed display name, or nil.

## Signature

```text
unit:name()
```

## Contract and usage

### `unit:name()`

Returns the prepared actor display name, or `nil`. It uses the same name store
as combat events and `gos.actor_names`; it does not look up a name on demand.
A later metadata read may contain a newer name. Names are labels, not identity.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
