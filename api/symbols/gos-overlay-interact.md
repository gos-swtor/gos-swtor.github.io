# gos.overlay.interact

Refresh a screen interaction rectangle and read mouse interaction state.

## Signature

```text
gos.overlay.interact(id, rect)
```

## Contract and usage

Submit drawings and interaction regions from `gos.on_tick`. Every draw function
returns a boolean indicating whether the submission was accepted.

### `gos.overlay.interact(id, rect)`

Requires an active script callback. An empty or over-31-byte ID, an ID containing embedded zero bytes, an invalid rectangle, nonpositive TTL, or wrong arguments raise a Lua error. Drawing and interaction IDs use the same validation and are never truncated. Registers a temporary screen rectangle and returns left-mouse interaction:

```text
local state = gos.overlay.interact("button", {
  x = 20, y = 20, width = 120, height = 28, ttl = 0.25,
})

-- state:
{
  hovered = boolean,
  pressed = boolean,
  down = boolean,
  released = boolean,
  clicked = boolean,
  mouse_x = number,
  mouse_y = number,
  entity_handle = "unit:..." | nil,
  entity_generation = integer,
  entity_session_generation = integer,
  target_intent = userdata | nil
}
```

Refresh the rectangle before its TTL expires. A press retains capture through
release. The Release snapshot retains at most 64 active interaction rectangles,
with at most 40 contributed by one callback owner, subject to the 32-owner frame ceiling. If registration or input observation is unavailable, the result can contain all false flags and zero coordinates with no separate availability flag. That state alone is not proof that the pointer is outside the rectangle; stay within the published budgets.

For an entity-associated region, supply `rect.entity = unit:handle()` from the
current world. This optional field accepts a Core unit-handle string, not a
`GosUnit`; malformed values raise a Lua error. Omit it for ordinary UI buttons.
The returned `entity_handle` is pinned on press, so a reordered list cannot turn
the eventual click into a selection of the row's new occupant. Generation fields
are zero when no entity observation exists.

`entity_generation` describes the displayed snapshot, not session identity.
Resolve the returned handle in a fresh world and compare
`entity_session_generation` to `world.session_generation`; ordinary tick changes
must not invalidate a click. Do not use the row's current entity instead.
For a completed entity click, `target_intent` is an immutable, script-owned ticket
for `gos.target.select`. It can be absent when a click could not be authenticated.
Do not manufacture a replacement or retry without it after rejection.

The following is a callback integration fragment; `displayed_unit` and the
rectangle come from your current layout, while `pending_target` is retained by
your script. It uses the pressed identity, not the layout's later contents:

```lua
local world = gos.world()
local state = gos.overlay.interact("ally_row", {
  x = 20, y = 60, width = 180, height = 28, ttl = 0.25,
  entity = displayed_unit:handle(),
})
if state.clicked and state.target_intent and state.entity_handle and
   state.entity_session_generation == world.session_generation then
  local clicked_unit = world:resolve(state.entity_handle)
  if clicked_unit then
    local ok, reason, handle = gos.target.select(clicked_unit, state.target_intent)
    if ok then pending_target = handle end
    -- Rejection is not permission to retry this click without its ticket.
  end
end
```

Poll any retained handle with `gos.target.status` in subsequent ticks; do not
resubmit it on every update. See the [target request contract](../world.md#gostargetselectunit-target_intent)
for the two-second ticket window, native user-intent ordering, bounded receipt
retention and cancellation limits. Rendering or registering a rectangle alone
does not change the game's selected target.

## Related documentation

[Full overlay contract](../overlay.md)
