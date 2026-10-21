# unit:hp

Read observed health and optional percentage, or nil.

## Signature

```text
unit:hp()
```

## Contract and usage

### `unit:hp()`

Returns observed health, or `nil` when unavailable:

```text
{
  current = number,
  max = number,
  percent = number | nil
}
```

`percent` uses `0..100` and is omitted when `max <= 0`. Validate `max > 0`
before computing `current / max`, which produces a `0..1` ratio instead.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md) | [Seer death prediction](../../examples/live-seer-triage.md)
