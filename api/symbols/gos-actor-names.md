# gos.actor_names

Read a bounded, epoch-checked snapshot of retained actor names without live-unit lookup.

## Signature

```text
gos.actor_names(handles, epoch)
```

## Contract and usage

### `gos.actor_names(handles, epoch?)`

Read cached actor names inside an update callback, without resolving live units
or requesting new names from the game.

`handles` must be a dense array of zero to 64 well-formed nonzero Core unit
handles. Sparse arrays, non-array keys, wrong types, malformed handles, and
extra arguments raise a Lua error. Duplicate handles are permitted and return
one row for each requested position. `epoch` is an optional nonzero opaque
`actors:...` string previously supplied by Core; malformed tokens raise an error.
Omitting it requests the current store. **Historical callers must supply the
epoch saved with the handles**, never the current epoch substituted later.

```text
{
  status = "ready" | "epoch_mismatch" | "unavailable",
  epoch = "actors:..." | nil,
  revision = integer,
  items = {
    {
      handle = "unit:...",
      status = "ready" | "not_retained",
      revision = integer,
      name = string | nil
    }, ...
  }
}
```

A ready response is a complete snapshot in request order, including explicit
`not_retained` rows. Names are nonempty UTF-8 strings no longer than 63 bytes.
A missing record has no `name` and a record `revision` of zero. `not_retained`
means the store does not currently retain a verified name: it may never have
observed one or may have evicted it. It does not claim the actor is dead or that
a saved name became invalid. Retention is bounded; eventual recovery is not
promised. Previously delivered event/presentation strings remain usable.

An `epoch_mismatch` response contains no items and identifies the current epoch;
do not retry the old handles with that epoch merely to obtain a name. An
`unavailable` response also contains no items. A successful response's revision
and rows belong to the same snapshot.

Each request returns its full result, including when the revision is unchanged.
Use `actor_revision` from a world/event batch to skip redundant reads only after
reading that exact handle set. A new set or chunk needs an initial read even at
the same global revision.
Record revisions order updates within one epoch. An older event name may fill
an unnamed label but must not overwrite a newer metadata result.

```lua
local saved_handle, saved_epoch
local last_revision
local display_name

gos.on_tick(function()
  local world = gos.world()
  if not saved_handle and world.current_target and world.actor_epoch then
    saved_handle = world.current_target:handle()
    saved_epoch = world.actor_epoch
  end
  if not saved_handle or saved_epoch ~= world.actor_epoch then return end
  if last_revision == world.actor_revision then return end
  local snapshot = gos.actor_names({ saved_handle }, saved_epoch)
  if snapshot.status ~= "ready" then return end
  local row = snapshot.items[1]
  if row.status == "ready" then display_name = row.name end
  last_revision = snapshot.revision
  -- Retain display_name when the row is not_retained; do not invent a label.
end, { interval_ms = 250 })
```

This example tracks one actor for the captured epoch. Reset its saved handle,
epoch and revision when choosing a different actor. Updating a label should not
change event totals or order.

## Related documentation

[Full world and units contract](../world.md)
