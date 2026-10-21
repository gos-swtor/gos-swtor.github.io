# world:presence

Read bounded camera-independent character-roster presence; unknown is not absence.

## Signature

```text
world:presence(handle)
```

## Contract and usage

### `world:presence(handle)`

Reads prepared character-roster membership independently of camera projection.
Pass a well-formed nonzero opaque unit handle; malformed handles raise a Lua
error. This is a snapshot read, not a new world scan.

```text
{
  state = "present" | "absent" | "unknown",
  complete = boolean,
  revision = integer,
  session_generation = integer,
  sample_ms = integer | nil
}
```

`present` means the identity appeared in the raw character roster. `absent`
means a recently observed identity disappeared from a later complete capture.
An untracked identity is `unknown`, even when `complete` is true. Neither
`absent` nor a failed `world:resolve` establishes stealth, death, or cast legality.
Objects and synthetic selected-target entries do not establish roster membership.

Evidence has a bounded 250 ms window: stale, incomplete, failed, or mismatched
session captures return `complete = false` and `state = "unknown"`. Recently
departed identities also expire out of the retained history, becoming unknown.
`revision` counts Core captures, not Lua callbacks; repeated calls at one
revision are not independent disappearance observations. `sample_ms` is the
monotonic capture timestamp in milliseconds, omitted before any capture.
Retain the session with a saved handle and reject old-session evidence.

### Unit Identity And Lifetime

Every `GosUnit` state-reading method raises `stale_unit` after its world
generation expires. `unit:handle()` is the exception and remains available so
the unit can be reacquired with a fresh `world:resolve(handle)`.

Within one world, repeated lookups of the same unit compare equal with `==`.
Values from different generations compare unequal even when their handles
match.

## Related documentation

[Full world and units contract](../world.md)
