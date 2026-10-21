# unit:resource

Read observed resource, kind and optional percentage.

## Signature

```text
unit:resource()
```

## Contract and usage

### `unit:resource()`

Returns observed resource, or `nil` when unavailable:

```text
{
  current = number,
  max = number,
  percent = number | nil,
  kind = "force" | "focus" | "rage" | "energy" | "heat" |
         "ammo_plasma" | "ammo_ion" | "ammo_ap" | "ammo_normal" |
         "unknown"
}
```

`percent` uses `0..100` and is omitted when `max <= 0`. Check `kind` before
interpreting a resource amount; raw heat increases as capacity is spent.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md) | [Commando Supercharge timing](../../examples/live-commando-supercharge.md)
