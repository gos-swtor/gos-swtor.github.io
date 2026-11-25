# unit:level

Read actual local-player character level, or nil; other units currently have no observation.

## Signature

```text
unit:level()
```

## Contract and usage

### `unit:level()`

Returns the actual character level as an integer, or `nil` when unavailable.
The current implementation captures this for the local player only. Other
units return `nil`; it does not infer their level from item rating, HP, or the
selected target. The current prepared inventory context must match the player.

Use actual level for an observed character-level requirement. It is separate
from [item and equipment observations](../inventory.md). The usual current-unit
lifetime applies: an expired unit raises `stale_unit`.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
