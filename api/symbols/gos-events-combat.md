# gos.events.combat

Consume ordered combat events using a retained cursor, with loss and backlog reporting.

## Signature

```text
gos.events.combat(cursor)
```

## Contract and usage

### `gos.events.combat(cursor?)`

Reads an ordered bounded event stream. Omit the cursor on the first call to
subscribe at the current head, then pass the returned cursor on later calls.

```lua
local combat_cursor

gos.on_tick(function()
  local batch = gos.events.combat(combat_cursor)
  combat_cursor = batch.cursor

  for _, event in ipairs(batch.events) do
    -- Consume in order.
  end

  if batch.dropped > 0 then
    gos.log.warn("Combat events dropped", batch.dropped)
  end
end)
```

The cursor must be a non-negative integer or nil. Extra arguments, an invalid/future cursor, an unavailable stream, or a failed read raise a Lua error; they do not return a successful empty batch. Subscribe inside a tick callback, not while loading. Preserve the returned cursor exactly: filtered-out unknown events may advance it even when the returned array is empty.

Batch shape:

```text
{
  cursor = integer,
  dropped = integer,
  more = boolean,
  actor_epoch = "actors:..." | nil,
  actor_revision = integer,
  events = { CombatEvent, ... }
}
```

Each call returns at most 64 events. If `more=true`, call again with the returned
cursor on a later bounded pass. `dropped` reports records overwritten before a
stale cursor could read them.

Event shape; fields other than `kind` are optional:

```text
{
  kind = "damage" | "heal" | "ability" | "effect" |
         "resource" | "death" | "combat",
  action = string | nil,
  result = string | nil,
  source_handle = "unit:..." | nil,
  target_handle = "unit:..." | nil,
  source_name = string | nil,
  target_name = string | nil,
  actor_epoch = "actors:..." | nil,
  ability_handle = "ability:..." | nil,
  effect_handle = "effect:..." | nil,
  name = string | nil,
  amount = number | nil,
  effective_amount = number | nil,
  damage_type = string | nil,
  critical = boolean | nil,
  timestamp = integer | nil
}
```

`name` is not emitted for effect-kind events. Do not build buff-name matching around `event.name`; use the documented effect queries for current effect observations. Event timestamps are monotonic milliseconds, not Unix timestamps.

Actor names are optional, verified display labels for their respective handles.
They are immutable event snapshots, not grouping keys. Separate actors with the
same name must remain separate. Absence of a name never means absence of damage.
The name authority is shared with `unit:name()` and `gos.actor_names`.

The batch's `actor_epoch` and `actor_revision` describe the **current** metadata
store. Each event's `actor_epoch` describes its production session, which may
be older than the batch when queued events cross a session transition. Never
substitute the batch epoch for an event epoch. Preserve names already delivered
with old events; do not enrich old handles using a newer epoch. Epoch tokens are
opaque process-local strings, not identifiers to persist across Core reloads.

Use `gos.actor_names(handles, epoch)` for bounded late name updates without
waiting for another combat event. It does not modify or replay existing events.
Missing actor/effect metadata does not justify guessing a name from the ability.

Handles can still be resolved against the current world for **live unit state**
when the unit is captured in the same actor epoch; historical labels do not
require this lookup:

```lua
local world = gos.world()
local source = event.actor_epoch and event.actor_epoch == world.actor_epoch and
  event.source_handle and world:resolve(event.source_handle) or nil
```

## Related documentation

[Full combat events contract](../events.md) | [Seer death prediction](../../examples/live-seer-triage.md) | [Sage PoM and proc prediction](../../examples/live-sage-pom-prediction.md)
