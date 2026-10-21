# gos.abilities.command_status

Read command lifecycle, activation evidence, cleanup and observed outcome.

## Signature

```text
gos.abilities.command_status(command_handle)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.command_status(command_handle)`

Returns the stable public command state:

```text
{
  known = boolean,
  state = "unknown" | "queued" | "dispatching" | "dispatched" | "native_queued" |
          "accepted" | "targeting" | "synchronizing" | "submitted" |
          "acknowledged" | "failed" | "superseded" | "cancelled" | "abandoned" | "expired",
  terminal = boolean,
  acknowledged = boolean,
  activation_proven = boolean,
  cleanup_pending = boolean,
  game_result_known = boolean,
  invocation_started = boolean,
  invocation_exited = boolean,
  invocation_returned = boolean,
  callback_completed = boolean,
  game_result = integer,
  game_result_name = string,
  game_result_source = "activation_return" | "server_result" | "server_notification" | "",
  replacement_allowed = boolean,
  reason = string,
  command_handle = "ability_command:..." | nil,
  retained_command_handle = "ability_command:..." | nil,
  name = string | nil,
  target_mode = "none" | "selected" | "explicit" | "selected_fallback",
  target_fallback = "none" | "selected",
  fallback_used = boolean,
  fallback_reason = string | nil,
  requested_target_handle = "unit:..." | nil,
  target_override_applied = boolean,
  target_restore_attempted = boolean,
  target_restore_succeeded = boolean
}
```

Use `terminal` to detect lifecycle completion and `cleanup_pending` to retain
ownership until target cleanup finishes. Neither means the ability succeeded.
`activation_proven` and `acknowledged` report positive start evidence.

`dispatching` means native dispatch is in progress. `superseded` is terminal:
other work or a changed player/ability context overtook the command. A terminal
`submitted` status can have `activation_proven=false`: Core observed submission,
but has no start proof. Missing proof alone is not permission to replay it.
Retained terminal receipts may acquire later outcome information.

`game_result_known` distinguishes a captured game result from missing data;
use `game_result_name` for display. `game_result_source` distinguishes an
immediate activation return from a later server result or notification.
Invocation fields describe transport progress only: `invocation_started`
records entry, `invocation_exited` records exit including exceptions,
`invocation_returned` records a normal return, and `callback_completed` records
completion of the owning callback. Target override/restore flags likewise
describe target handling, rather than ability activation.

A finished receipt evicted from the 64-record command history returns `known=true`, `terminal=true`, `state="expired"`, `reason="command_history_expired"`. This releases ownership without inventing an activation or failure outcome; missing outcome flags on that tombstone are not negative gameplay evidence. An unrecognized handle remains unknown. Handles do not survive Core restart/load.

```lua
if pending_command then
  local status = gos.abilities.command_status(pending_command)
  if status.known and status.terminal and not status.cleanup_pending then
    pending_command = nil
  end
end
```

When `replacement_allowed=true`, submit a replacement with
`replace_command=status.command_handle`. A successful replacement returns a new
command handle. Only replace a command owned by this script instance: reading a
known status or seeing `replacement_allowed=true` does not grant ownership of
another script's command.

## Related documentation

[Full abilities contract](../abilities.md) | [Sage PoM and proc prediction](../../examples/live-sage-pom-prediction.md)
