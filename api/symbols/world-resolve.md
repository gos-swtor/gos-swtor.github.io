# world:resolve

Resolve an opaque handle in the current world; absent units return nil.

## Signature

```text
world:resolve(handle)
```

## Contract and usage

### `world:resolve(handle)`

Resolves a well-formed opaque unit handle in the current generation. It returns
a current `GosUnit` or `nil` when that identity is not currently captured.

```lua
local saved_handle, saved_epoch

gos.on_tick(function()
  local world = gos.world()
  if saved_epoch ~= world.actor_epoch then saved_handle = nil end
  saved_epoch = world.actor_epoch
  if world.current_target and saved_epoch then
    saved_handle = world.current_target:handle()
  end

  local current = saved_handle and world:resolve(saved_handle) or nil
end)
```

Calling `units`, `resolve`, or `presence` on an expired world raises `stale_world`.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md) | [Operative cursor Holotraverse](../../examples/live-operative-holotraverse.md)
