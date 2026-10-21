# unit:position

Read game-world coordinates for this observation, or nil.

## Signature

```text
unit:position()
```

## Contract and usage

### `unit:position()`

Returns the unit's prepared game-world position, or `nil` when unavailable:

```text
{ x = number, y = number, z = number }
```

The pose is checked against the unit's identity; another actor's earlier position
is not retained as a replacement.

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

[Full world and units contract](../world.md)
