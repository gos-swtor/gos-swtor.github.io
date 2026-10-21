# unit:rotation

Read current character yaw in radians, or nil when its prepared pose is unavailable.

## Signature

```text
unit:rotation()
```

## Contract and usage

### `unit:rotation()`

Returns prepared character yaw in radians, or `nil` when unavailable. Yaw is
normalized to `[-math.pi, math.pi]`; zero faces world `-Z`. Pitch, roll, scale
and raw transforms are not exposed.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
