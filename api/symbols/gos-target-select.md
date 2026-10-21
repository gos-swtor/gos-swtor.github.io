# gos.target.select

Request an intentional persistent selected-target change; confirm it in a later snapshot.

## Signature

```text
gos.target.select(unit, target_intent)
```

## Contract and usage

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

See also: [`gos.target.status(request_handle)`](../world.md#gostargetstatusrequest_handle) | [`gos.target.cancel(request_handle)`](../world.md#gostargetcancelrequest_handle)

## Related documentation

[Full world and units contract](../world.md)
