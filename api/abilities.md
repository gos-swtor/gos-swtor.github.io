# Abilities and commands

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.loadout()`

Returns the selected local loadout:

```text
{
  status = "pending" | "ready" | "unavailable",
  action_bar_available = boolean,
  action_bar_truncated = boolean,
  combat_style = string | nil,
  discipline = string | nil,
  talents_available = boolean | nil,
  known = { [ability_or_active_talent_display_name] = true } | nil
}
```

The last four fields are present only when `status == "ready"`. `known`
contains currently owned abilities and active talents. The active talent set includes both selectable choices (for example
`Force Mobility`) and automatically learned/passive progression rows (for
example `Force Shelter`). Talents remain distinct from ability metadata
internally: presence in `known` does not make a passive castable or give it an
`ability_handle`. Talent discovery is enrichment only; a transient invalid
talent snapshot never makes the owned-ability loadout unavailable.
When `talents_available=false`, missing talent names are not proof that those
talents are unselected. Action-bar availability is independent of loadout
identity; an empty or incomplete bar does not imply a player-session change.

```lua
local loadout = gos.abilities.loadout()
if loadout.status ~= "ready" then
  return
end

if loadout.combat_style == "sage" and
   loadout.discipline == "Telekinetics" and
   loadout.known["Telekinetic Gust"] then
  -- Exact current loadout match.
end
```

### Ability Row

`gos.abilities.action_slots()` returns a pure array of current on-bar rows.
Use `loadout().action_bar_available` and `action_bar_truncated` to distinguish
a coherent empty bar from missing/incomplete observations.
`gos.abilities.info(ability)` returns one matching row, including a known
off-bar row, or `nil`.

```text
{
  name = string,
  name_source = "client" | "core",
  on_bar = boolean,
  ability_handle = "ability:..." | nil,
  activation_handle = "ability:..." | nil,
  slot_index = integer | nil,
  key_number = integer | nil,
  ready = boolean,
  submission_pending = boolean,
  has_cooldown_remaining = boolean,
  cooldown_remaining = number | nil,
  has_cooldown_duration = boolean,
  cooldown_duration = number | nil,
  has_current_charges = boolean,
  current_charges = integer | nil,
  has_max_charges = boolean,
  max_charges = integer | nil,
  has_resource_cost = boolean,
  resource_cost = number | nil,
  has_line_of_sight_requirement = boolean,
  line_of_sight_required = boolean | nil
}
```

`slot_index` is zero-based. `ability_handle` is accepted by ability lookup and
submission functions. `activation_handle` is for comparing activation and
event identity; do not pass it as the submission ability.

`name_source` identifies observed client text versus Core-derived display text;
Core text may differ from localized UI spelling. Name-based ability queries prefer the current on-bar group
over historical off-bar rows and reject distinct IDs with the same matching
name within that group. Duplicate bindings of one ID remain valid. Use the
`ability_handle` for an unambiguous lookup.

Charge and resource fields remain absent until their current observations are
available. Do not infer charge counts or costs from timers.

`has_line_of_sight_requirement` says whether the requirement is known; only then is `line_of_sight_required` meaningful. This metadata is not a visibility test. Use the cast-readiness result to observe whether line of sight was actually checked.

### `gos.abilities.info(ability)`

Returns the matching prepared Ability Row or `nil`. In addition to the shared
row fields, a returned info row includes `metadata_request_status`:

| Value | Meaning |
| --- | --- |
| `registered` | A metadata request was registered |
| `pending` | An existing request remains pending |
| `deferred_capacity` | Request capacity is full; try on a later tick |
| `satisfied` | The current row satisfies the request |
| `invalid` | No request can be made in the current context |

Requests are serviced later and are not permanent subscriptions. `satisfied`
does not prove castability or guarantee every optional field; check `has_*`
flags and optional values. A known off-bar row can return `invalid` because
requests currently require an on-bar ability and valid script/player context.
The row is still usable. `metadata_request_status` belongs only to `info()`,
not `action_slots()` rows. Retry pending requests on a later tick.

### Readiness Helpers

These helpers read prepared local-player observations. Timers use seconds;
`nil` means the observation is unavailable, rather than a zero timer.

### `gos.abilities.cooldown_remaining(ability)`

Returns observed remaining cooldown in seconds, or `nil` when the ability or
its cooldown observation is unavailable.

### `gos.abilities.cooldown_duration(ability)`

Returns observed total cooldown duration in seconds, or `nil` when the ability
or its duration observation is unavailable.

### `gos.abilities.gcd_remaining()`

Returns the local player's observed global cooldown in seconds, or `nil` when
the snapshot or GCD observation is unavailable.

### `gos.abilities.is_ready(ability)`

`is_ready()` reads the resolved ability row's readiness flag and returns false when the row is unavailable. It does not perform the target-specific validation done by `can_cast()`. A ready row does not prove target visibility, facing, range or command admission.

### `gos.abilities.is_casting_or_channeling()`

Returns the current busy observation as a boolean. It can remain true briefly
while `current_cast()` is nil because busy state and named cast identity have
different availability. A missing ability snapshot also returns false.

### `gos.abilities.current_cast()`

Returns the current cast/channel observation, or `nil` when its active snapshot
is unavailable:

```text
{
  ability_handle = "ability:..." | nil,
  name = string,
  has_timing = boolean,
  remaining = number | nil
}
```

`name` is `"-"` when the display name is unavailable. `remaining` is in seconds
and is present only when `has_timing=true`.

### `gos.abilities.result_codes`

Stable numeric branch keys returned by `can_cast` and `cast`:

```text
{
  unknown = 0,
  ok = 1,
  queued = 2,
  missing_target = 3,
  missing_ability_name = 4,
  ability_not_resolved = 5,
  ability_not_found = 6,
  ability_not_bound = 7,
  cooldown = 8,
  gcd = 9,
  busy = 10,
  ability_command_busy = 11,
  ability_command_unavailable = 12,
  command_busy = 13,
  bad_argument = 14,
  cast_unavailable = 15,
  no_combat_snapshot = 16,
  core_unavailable = 17,
  cast_failed = 18,
  target_override_failed = 19,
  stale_unit = 20,
  target_unavailable = 21,
  fallback_target_unavailable = 22,
  unsupported_target = 23,
  ability_metadata_unavailable = 24,
  ability_submission_pending = 25,
  explicit_target_sync_pending = 26,
  explicit_target_sync_suspended = 27,
  castability_pending = 28,
  castability_unavailable = 29,
  ability_disabled = 30,
  target_dead = 31,
  player_dead = 32,
  too_far = 33,
  stunned = 34,
  not_facing = 35,
  insufficient_resource = 36,
  target_view_blocked = 37,
  too_close = 38,
  target_not_dead = 39,
  target_untargetable = 40,
  incapacitated = 41
}
```

Branch on `code`, not the explanatory `reason` string.

### Ability Result

`can_cast` and `cast` return a common result table. Optional fields appear only
when relevant:

```text
{
  ok = boolean,
  code = integer,
  reason = string,
  wait_ms = integer,
  client_check_available = boolean,
  client_eff_result = integer | nil,
  client_los_checked = boolean,
  client_request_capacity_deferred = boolean,
  blocker = table | nil,
  lifecycle_capture_lost = boolean,
  lifecycle_unavailable_mask = integer,
  command_admission_blocked = boolean,
  target_valid = boolean,
  target_override = boolean,
  target_mode = "none" | "selected" | "explicit" | "selected_fallback",
  target_fallback = "none" | "selected",
  fallback_used = boolean,
  fallback_reason = string | nil,
  requested_target_handle = "unit:..." | nil,
  target_handle = "unit:..." | nil,
  dry_run = boolean,

  name = string | nil,
  ability_handle = "ability:..." | nil,
  on_bar = boolean | nil,
  submission_pending = boolean | nil,
  cooldown_remaining = number | nil,
  cooldown_duration = number | nil,
  gcd_duration = number | nil,
  uses_global_cooldown = boolean | nil,
  has_resource_cost = boolean | nil,
  resource_cost = number | nil,
  has_line_of_sight_requirement = boolean | nil,
  line_of_sight_required = boolean | nil,
  gcd_remaining = number | nil,
  busy = boolean | nil,
  current_cast_name = string | nil,
  current_cast_has_timing = boolean | nil,
  current_cast_remaining = number | nil,

  command_handle = "ability_command:..." | nil,
  command_state = string | nil
}
```

`wait_ms` reports only a currently known cooldown, applicable global cooldown,
or busy wait. Core consults the global GCD only when exact ability metadata says
that ability has a positive GCD duration; off-GCD abilities remain eligible while
the global GCD is active. Cast/channel busy remains a separate conservative gate.
It is not a future scheduling promise. Shared client admission additionally
checks modified resource costs, minimum/maximum range, the client's facing
gate/cone, ordinary unit target death and attackability, ability enabled state,
caster death/stun/incapacitation with ability exceptions, and gated character LOS.

Readiness is a current local observation, not a promise of game acceptance. `castability_pending` and `castability_unavailable` do not acquire a command; retry on a later tick or evaluate another action. Do not turn transient blocked results into a permanent target blacklist.

`lifecycle_capture_lost` reports lost lifecycle observations. `lifecycle_unavailable_mask` is opaque availability metadata, not a documented bit layout; do not decode it or infer success from it. Preserve unavailable outcomes and rely on the public result code and command status.

`client_check_available` distinguishes a completed local check from missing context. `client_los_checked` reports whether line of sight was checked. `client_eff_result` is optional rejection metadata; branch on the public `code`. Ability-specific rules may still reject a submitted action.

`client_request_capacity_deferred` indicates that the bounded client-check request capacity deferred this observation. It does not mean the target is invalid or the ability failed. Retry on a later bounded tick rather than spinning; it is distinct from `metadata_request_status` on an info row. `blocker` is optional diagnostic-only metadata; its internal keys and numeric values are not a stable public contract. Use the documented result code and command ownership instead.

The built-in **Line of sight** and **Targeting you** overlays are visual features; they add no Lua query methods or unit fields. A clear visual line does not report another player's ability readiness or replace `can_cast()` and command status.

### Target and readiness semantics

`can_cast()` answers **ready now**, not **may be queued for later**. `cast()` with an omitted target may be admitted to the normal command queue while a cast or GCD is still finishing; acceptance is not guaranteed. Consequently, requiring `can_cast().ok` before every such submission is a conservative policy that can prevent otherwise valid prequeueing.

An explicit unit or handle uses **ready-now admission**, including when that unit currently equals the selected target. It therefore has different prequeue behavior from an omitted target. Changing selection or adding a fallback does not preserve the same explicit-target contract.

Malformed target handles, wrong argument types and unknown cast-option keys raise Lua errors. A well-formed but unresolved explicit handle instead produces a result with code `target_unavailable`; stale unit targets produce code `stale_unit`. These are ability result codes, distinct from a stale unit method raising an error. An unhandled Lua error disables the callback until reload.

### `gos.abilities.can_cast(ability, target?)`

Checks current readiness and supported local conditions. Abilities requiring no external target can be checked without one and report `target_mode="none"`. Other omitted targets use the captured selection. An explicit target is a current `GosUnit` or its opaque handle and is never silently converted to targetless mode.

```lua
local world = gos.world()
if not world.current_target then return end
local readiness = gos.abilities.can_cast("Force Stun", world.current_target)
if readiness.ok then
  -- Ready according to the current local snapshot.
end
```

### `gos.abilities.cast(ability, target?, options?)`

Submits one asynchronous command. An explicit target may be a current `GosUnit` or an opaque unit handle. By default this does not persistently change the visible selected target. Use `gos.target.select` separately when a persistent selection change is intended.

With no target, targetless abilities need no external unit; other abilities use the selected target at dispatch. A queued command is not activation proof. Let the command status report progress rather than repeatedly submitting the same action.

Supported options:

```text
{
  target_fallback = "none" | "selected",  -- explicit targets only
  replace_command = "ability_command:..." -- only when replacement_allowed
}
```

`target_fallback` defaults to `none`. Selected fallback is opt-in and applies
only when an explicit target cannot be used before the command is queued. Supplying this option, even as `"none"`, with an omitted/nil target raises a Lua error. Omit the option to use its no-fallback default.

`ok=true` with `code == gos.abilities.result_codes.queued` means Core accepted
the command for asynchronous processing. It does not mean the ability began.
Retain `command_handle` and poll `command_status`. Release ownership only when
`terminal=true` and `cleanup_pending=false`.

After polling the retained command in the owning callback, submit only when it
has cleared:

```lua
if pending_command then return end
local target = gos.world().current_target
if not target then return end
local result = gos.abilities.cast("Force Stun", target, {
  target_fallback = "none",
})

if result.ok then
  pending_command = result.command_handle
end
```

Only one nonterminal command may be owned at a time. If a submission returns
`ability_command_busy`, use the returned command handle/status instead of
submitting repeatedly.

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

### `gos.abilities.release_command(command_handle)`

Requests safe cancellation of this script instance's command and returns the command-status fields plus `ok`. A readable handle is not an ownership grant: another script's retained command returns `ok=false`, with `reason="foreign_command_owner"`, even when its status is otherwise known.
`ok=true` means the command was cancelled before dispatch or was already cancelled. It does not stop an ability that has already begun. A dispatched command that cannot be cancelled, an unknown handle, or an already-terminal non-cancelled command returns `ok=false`; inspect `known`, `terminal`, `cleanup_pending` and the outcome instead of treating every false result as an active command.

### `gos.abilities.abandon_command(command_handle)`

Compatibility endpoint returning command-status fields plus `ok`. It does not change a command: `ok=true` requires a retained command owned by this script instance that is already terminal. Foreign, unknown, evicted, or in-flight commands return `ok=false`, including an otherwise known expired-history tombstone. It does not drop an in-flight command or bypass cleanup. New scripts should retain and resolve command ownership instead of abandoning it.
