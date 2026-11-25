# unit:is_level_shifted

Read the independent local-player level-shift flag; nil is distinct from false.

## Signature

```text
unit:is_level_shifted()
```

## Contract and usage

### `unit:is_level_shifted()`

Returns the observed level-shift flag as `true`, `false`, or `nil` when the
matching local-player observation is unavailable. Other units currently return
`nil`. Check explicitly for `nil` before treating `false` as a known result.
Equal actual and effective levels do not prove `false`: this method reports the
observed flag independently. An expired unit raises `stale_unit`.

```lua
gos.on_tick(function()
  local player = gos.world().player
  if not player then return end
  local actual = player:level()
  local effective = player:effective_level()
  local shifted = player:is_level_shifted()
  if actual == nil or effective == nil or shifted == nil then return end
  -- All three values are observed, including shifted == false.
end)
```

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
