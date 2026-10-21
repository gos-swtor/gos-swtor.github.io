# World and units

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

### `unit:item_rating()`

Returns the unit's overall equipped item rating as an integer, or `nil` when
unavailable. This is distinct from character level and an inventory item's
rating. Local and other captured units use the same prepared observation.

### `gos.target.select(unit, target_intent?)`

Requests a persistent selected-target change for a current-generation non-object
`GosUnit`. Keep the optional third return value to observe the request:

```lua
local ok, error, request_handle = gos.target.select(ally)
```

`true, nil, handle` means a request was accepted, not that selection occurred.
`true, nil, nil` normally means the current snapshot already selects that unit.
The handle is an opaque string, distinct from a unit or ability-command handle.
Poll `gos.target.status(handle)` on later ticks instead of submitting every tick.

Operational failures return `false, reason, nil`, with `busy`, `invalid_target`,
`stale_world`, `stale_intent`, `request_capacity`, or `unavailable`. Wrong argument
types and stale userdata raise Lua errors (`stale_unit` for expired units).
Only one or two arguments are accepted. Omitted/nil `target_intent` remains
supported for intentional script-driven selection.

For a captured overlay click, pass the immutable `state.target_intent` ticket
from `gos.overlay.interact`. It is bound to the submitting script instance,
pressed entity and session. Another entity/session/script, a newer native user
selection, or a ticket at least two seconds old produces `stale_intent`.
Repeating a still-valid ticket returns its retained receipt rather than replaying
the click. Never replace a rejected ticket with a ticketless retry.

Queued requests have a two-second dispatch/observation window, measured from the
click for a ticket or from submission otherwise. Busy shared work can defer
progress. A newer request can supersede this script's still-cancellable queued
request; it does not cancel another script's dispatched work. Capacity is bounded
to 64 retained target requests. The deadline does not forcibly stop running work.

Selection persists and is separate from explicit ability targeting: default
explicit casts do not call this API or persistently change the selected target.
See `gos.target.status` for confirmation and `gos.target.cancel` for safe queued
cancellation.

### `gos.target.status(request_handle)`

Reads this script instance's retained request without changing selection.
Use the opaque string returned by `gos.target.select`. Malformed strings,
unknown/evicted requests, and requests owned by another script report
`known=false`, `terminal=true`, `state="unknown"`; they are not success receipts.
A non-string argument can raise a Lua argument error.

```text
{
  known = boolean, terminal = boolean,
  state = "unknown" | "queued" | "dispatched" | "observed" |
          "expired" | "cancelled" | "superseded" | "failed" | "unconfirmed",
  request_handle = string | nil, target_handle = "unit:..." | nil,
  invocation_returned = boolean, callback_completed = boolean,
  blocker = table | nil
}
```

`queued` and `dispatched` are nonterminal. `observed` means a later prepared
selection matched this request's target and session within its observation
window. It does not promise the target is still selected now. `expired` means
the queued request expired before dispatch; `cancelled` and `superseded` describe
successfully retired queued intent. `failed` reports a pre-invocation failure.
`unconfirmed` means the request may have taken effect but confirmation is missing,
including a completed invocation without an in-window matching observation or
a session change. Do not equate it with cancellation or automatically replay it.

`invocation_returned` and `callback_completed` describe invocation progress,
not selection proof. A dispatched request is not forcibly interrupted when its
deadline passes. `blocker` is optional diagnostic-only metadata: its internal
keys and numeric values are not a stable scripting contract. Branch on the
public state, not those internals. Receipts have bounded retention; save only
the result information your UI needs, and do not carry requests across reloads.

### `gos.target.cancel(request_handle)`

Requests cancellation of this script's still-queued selection request. Returns
the same status shape as `gos.target.status`, with an additional `ok` boolean.
`ok=true` confirms successful cancellation before invocation; `ok=false` may
mean dispatch already began, the request is terminal, it is not owned by this
script, or the handle is unknown. Inspect the returned state. Cancellation does
not undo a selection that already happened and does not stop dispatched work.
A failed cancellation is not permission to forget or replay a pending request.

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


### `unit:screen_position(anchor?)`

Read a projected anchor from this unit's current, generation-validated render
observation. This method reads prepared screen coordinates; it does not perform
a world-to-screen calculation on demand, a screen-to-world raycast, or a
line-of-sight test.

`anchor` is an optional lowercase string:

| Anchor | Point returned |
| --- | --- |
| `"top"` | Top-center of the prepared unit box |
| `"center"` | Vertical midpoint of the prepared unit box; the default |
| `"bottom"` | Bottom-center of the prepared unit box |

Omitting the argument or passing nil uses `"center"`. Unsupported anchor
strings, non-string non-nil values, or extra arguments raise a Lua error.
`"middle"` and `"screen"` are not accepted aliases for this method.

```text
{ x = number, y = number } | nil
```

The returned X and Y are render-viewport pixels, with the origin at the top-left,
X increasing rightwards and Y increasing downwards. They share the coordinate
space of [gos.input.cursor()](input.md#gosinputcursor) and screen overlays.
They are not the game-world coordinates returned by `unit:position()`, and no
world-unit-to-metre conversion applies. These are box anchors, not anatomical
bones or an exact clickable outline. Values are not clamped to the viewport.

Return `nil` when the current observation is not on screen or the prepared
projection is unavailable/invalid. Do not reuse last-known pixels as a current
targeting observation. An expired `GosUnit` raises `stale_unit` rather than
returning nil; reacquire the unit from the current world before reading it.

```lua
gos.on_tick(function()
  local world = gos.world()
  local unit = world and world.current_target
  if not unit or type(unit.screen_position) ~= "function" then return end
  local point = unit:screen_position() -- default center
  if not point then return end
  gos.overlay.draw_circle("unit_anchor", {
    at = { screen = { x = point.x, y = point.y } },
    radius = 12, filled = false, frame = true,
  })
end)
```

A non-nil point proves only that these screen coordinates are available. Check
health, reaction, range and native ability admission separately before acting.
The method does not capture mouse input, change selection or cast anything, and
can return a position even when the cursor query is unavailable. See the
[cursor example](input.md#gosinputcursor) for a pixel-radius comparison.

### `unit:name()`

Returns the prepared actor display name, or `nil`. It uses the same name store
as combat events and `gos.actor_names`; it does not look up a name on demand.
A later metadata read may contain a newer name. Names are labels, not identity.

### `unit:combat_style()`

Returns a stable lowercase combat-style key, or `nil`. Style and discipline are
independently optional; another player's style can be known while their
current discipline is unavailable.

### `unit:discipline()`

Returns the observed display discipline name, or `nil`. A remote player's last
coherent discipline may remain available during a temporary acquisition gap;
a style change or conflicting evidence clears it. No separate freshness field
is exposed. Use `gos.abilities.loadout()` for the local player's exact ability
membership, rather than inferring a learned kit from a display label.

### `unit:handle()`

Returns an opaque `unit:...` identity, or `nil` if unavailable. This method also
works on an expired unit. Save the handle with its session/actor epoch and resolve
it in a fresh world before reading current state.

### `unit:type()`

Returns `player`, `companion`, `npc`, `object` or `unknown`.

### `unit:reaction()`

Returns `friendly`, `neutral`, `hostile` or `unclassified`.

### `unit:toughness()`

Returns two values: a toughness label and its numeric value. Returns `nil` when
no recognized toughness value is available.

### `unit:is_local_player()`

Returns whether this current unit is the local player.

### `unit:is_current_target()`

Returns whether this current unit is the captured selected target.

### `unit:is_on_screen()`

Returns whether this unit has a current on-screen render observation. This is
projection availability, not line of sight or cast permission.

### `unit:hp()`

Returns observed health, or `nil` when unavailable:

```text
{
  current = number,
  max = number,
  percent = number | nil
}
```

`percent` uses `0..100` and is omitted when `max <= 0`. Validate `max > 0`
before computing `current / max`, which produces a `0..1` ratio instead.

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

### World-space units

Distance, position and velocity use the same game-world coordinate scale.
One world unit is ten metres. Convert range thresholds exactly once; a
30-metre threshold is 3 world units. World-space circle radii use this scale too.

### `unit:distance()`

Returns current distance in game-world units, or `nil` when unavailable.

```lua
local distance = unit:distance()
local metres = distance and distance * 10 or nil
```

### `unit:position()`

Returns the unit's prepared game-world position, or `nil` when unavailable:

```text
{ x = number, y = number, z = number }
```

The pose is checked against the unit's identity; another actor's earlier position
is not retained as a replacement.

### `unit:rotation()`

Returns prepared character yaw in radians, or `nil` when unavailable. Yaw is
normalized to `[-math.pi, math.pi]`; zero faces world `-Z`. Pitch, roll, scale
and raw transforms are not exposed.

### `unit:basis()`

Returns a normalized upright basis derived from the current yaw, or `nil` when
rotation is unavailable:

```text
{
  yaw = number,
  forward = { x = number, y = number, z = number },
  right = { x = number, y = number, z = number },
  up = { x = 0, y = 1, z = 0 }
}
```

Yaw is in radians, normalized to `[-math.pi, math.pi]`; zero faces world `-Z`.
The vectors are `forward={sin(yaw),0,-cos(yaw)}` and
`right={cos(yaw),0,sin(yaw)}`. This is geometry, not proof of a server-side
positional ability condition.

### `unit:velocity()`

Returns the prepared velocity and its magnitude, or `nil` when unavailable:

```text
{ x = number, y = number, z = number, speed = number }
```

### `unit:speed()`

Returns the magnitude of the prepared velocity, or `nil` when unavailable.
