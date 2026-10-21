# gos.target.cancel

Cancel an owned target request only while it is still queued.

## Signature

```text
gos.target.cancel(request_handle)
```

## Contract and usage

### `gos.target.cancel(request_handle)`

Requests cancellation of this script's still-queued selection request. Returns
the same status shape as `gos.target.status`, with an additional `ok` boolean.
`ok=true` confirms successful cancellation before invocation; `ok=false` may
mean dispatch already began, the request is terminal, it is not owned by this
script, or the handle is unknown. Inspect the returned state. Cancellation does
not undo a selection that already happened and does not stop dispatched work.
A failed cancellation is not permission to forget or replay a pending request.

See also: [`gos.target.select(unit, target_intent?)`](../world.md#gostargetselectunit-target_intent) | [`gos.target.status(request_handle)`](../world.md#gostargetstatusrequest_handle)

## Related documentation

[Full world and units contract](../world.md)
