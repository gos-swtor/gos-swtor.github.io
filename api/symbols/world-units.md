# world:units

Get currently captured units with strict AND-combined filters.

## Signature

```text
world:units(filter)
```

## Contract and usage

### `world:units(filter?)`

Returns an array of current units. An omitted filter returns all captured units.
Supported filters are strict and combine with AND:

```lua
local hostile_players = world:units({
  type = "player",
  reaction = "hostile",
  local_player = false,
})
```

Filter fields:

```text
{
  type = "player" | "companion" | "npc" | "object" | "unknown",
  reaction = "friendly" | "neutral" | "hostile" | "unclassified",
  local_player = boolean,
  current_target = boolean
}
```

A reaction filter never matches objects. Unknown keys, invalid values, and
wrong value types raise a Lua error.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
