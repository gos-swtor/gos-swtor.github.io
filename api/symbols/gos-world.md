# gos.world

Acquire the current generation-bound world and its optional player and target.

## Signature

```text
gos.world()
```

## Contract and usage

### `gos.world()`

Returns the current generation-bound world:

```text
{
  generation = integer,
  session_generation = integer,
  actor_epoch = "actors:..." | nil,
  actor_revision = integer | nil,
  player = GosUnit | nil,
  current_target = GosUnit | nil,
  units = function,
  resolve = function,
  presence = function
}
```

`player` is the local player. `current_target` is the currently captured target.
Either may be `nil` when unavailable. `actor_epoch` is the stable metadata-session
token, not the per-tick `generation`. `actor_revision` changes when retained actor
name metadata changes; ordinary unit movement does not change it. Both metadata
fields are omitted when the actor-name authority is unavailable.

`generation` identifies one prepared snapshot and can change every tick.
`session_generation` instead identifies the Core session and remains
stable across ordinary ticks. It is zero when no combat snapshot is available. Use the
session value to reject interactions saved from another session; do not reject
a valid click merely because its snapshot generation differs from this tick.
Neither field makes an old `GosUnit` current: resolve saved handles again.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
