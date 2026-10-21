# unit:target

Read this unit's observed target and target-observation availability.

## Signature

```text
unit:target()
```

## Contract and usage

### `unit:target()`

Returns two values: the unit's currently observed target and whether that
observation is known. It takes no arguments beyond `self`.

```lua
local target, known = unit:target()
if not known then
  -- No usable target observation: preserve unknown, not "no target".
elseif target then
  local target_handle = target:handle()
  -- A current-generation target, not a fallback to the player's selection.
else
  -- No target was observed, or it is absent from the prepared world.
end
```

`known=true, target=nil` cannot distinguish those last two cases. The method
never substitutes the local player's selected target. Returned units obey the
same generation lifetime and interning rules as other world lookups; reacquire
handles in a later world instead of retaining their userdata. An expired unit
raises `stale_unit` and extra arguments raise a Lua error.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
