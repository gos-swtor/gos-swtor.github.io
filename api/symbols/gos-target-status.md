# gos.target.status

Observe an owned target-selection request without replaying it.

## Signature

```text
gos.target.status(request_handle)
```

## Contract and usage

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

See also: [`gos.target.select(unit, target_intent?)`](../world.md#gostargetselectunit-target_intent) | [`gos.target.cancel(request_handle)`](../world.md#gostargetcancelrequest_handle)

## Related documentation

[Full world and units contract](../world.md)
