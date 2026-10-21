# unit:item_rating

Read the prepared overall equipped item rating, or nil when unavailable.

## Signature

```text
unit:item_rating()
```

## Contract and usage

### `unit:item_rating()`

Returns the unit's overall equipped item rating as an integer, or `nil` when
unavailable. This is distinct from character level and an inventory item's
rating. Local and other captured units use the same prepared observation.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
