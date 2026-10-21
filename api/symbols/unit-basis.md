# unit:basis

Read the current normalized yaw basis with forward, right and up axes, or nil.

## Signature

```text
unit:basis()
```

## Contract and usage

### `unit:basis()`

Returns a normalized upright basis derived from the current yaw, or `nil` when
rotation is unavailable:

```text
{
  yaw = number,
  forward = { x = number, y = number, z = number },
  right = { x = number, y = number, z = number },
  up = { x = 0, y = 1, z = 0 }
}
```

Yaw is in radians, normalized to `[-math.pi, math.pi]`; zero faces world `-Z`.
The vectors are `forward={sin(yaw),0,-cos(yaw)}` and
`right={cos(yaw),0,sin(yaw)}`. This is geometry, not proof of a server-side
positional ability condition.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
