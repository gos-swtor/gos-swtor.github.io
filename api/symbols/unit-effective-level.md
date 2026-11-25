# unit:effective_level

Read the observed synced or boosted local-player level, or nil when unavailable.

## Signature

```text
unit:effective_level()
```

## Contract and usage

### `unit:effective_level()`

Returns the observed synced or boosted character level as an integer, or `nil`.
It uses the matching prepared local-player context and is currently unavailable
for other units. Effective level is separate from actual level and does not
establish whether an inventory item can be equipped. Unknown observations stay
`nil`; they do not reuse the actual level. An expired unit raises `stale_unit`.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
