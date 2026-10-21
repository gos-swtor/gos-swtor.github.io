# unit:distance

Current distance in game-world units, or nil; multiply by 10 for metres.

## Signature

```text
unit:distance()
```

## Contract and usage

### `unit:distance()`

Returns current distance in game-world units, or `nil` when unavailable.

```lua
local distance = unit:distance()
local metres = distance and distance * 10 or nil
```

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

### World-space units

Distance, position and velocity use the same game-world coordinate scale.
One world unit is ten metres. Convert range thresholds exactly once; a
30-metre threshold is 3 world units. World-space circle radii use this scale too.

## Related documentation

[Full world and units contract](../world.md) | [Operative cursor Holotraverse](../../examples/live-operative-holotraverse.md)
