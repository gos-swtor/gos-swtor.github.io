# gos.settings.set

Queue a validated update to one of the caller's registered fields.

## Signature

```text
gos.settings.set(script_id, key, value)
```

## Contract and usage

`register` and `get` raise Lua errors for invalid schemas, unknown registrations
or unavailable context. `set` returns `true, nil` for an accepted update or
`false, error` for an operational rejection. Malformed calls and unsupported
Lua value types still raise errors.

### `gos.settings.set(script_id, key, value)`

Queues a validated setting update from a running tick:

```lua
local ok, error = gos.settings.set(SCRIPT_ID, "show_status", false)
```

Returns `true, nil` when queued or `false, error` when rejected. The new value
appears in a later settings snapshot. A script may update only its own
registered fields; this API does not change script enablement or execution
order.

Acceptance does not establish durable disk persistence. Core applies queued
values separately and retries failed settings saves; its menu surfaces pending
save errors. Read a later snapshot for the applied value. Do not resubmit the
same update every tick solely because disk persistence is uncertain.

## Related documentation

[Full settings contract](../settings.md)
