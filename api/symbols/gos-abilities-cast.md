# gos.abilities.cast

Queue one asynchronous action. Queued does not mean activated.

## Signature

```text
gos.abilities.cast(name, target, options)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

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

See also: [`gos.abilities.result_codes`](../abilities.md#gosabilitiesresult_codes) | [`gos.abilities.command_status(command_handle)`](../abilities.md#gosabilitiescommand_statuscommand_handle)

## Related documentation

[Full abilities contract](../abilities.md) | [Operative cursor Holotraverse](../../examples/live-operative-holotraverse.md)
