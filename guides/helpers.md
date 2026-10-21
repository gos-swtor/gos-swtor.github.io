# Reusable helper modules

These optional modules load from the shared common root in packages that
include them. They build on the public Lua API.

## Make the helper modules available

These are Lua files supplied by packages, not built-in `gos` functions.
The [GoS Common package](https://github.com/gos-swtor/official-scripts/tree/main/packages/gos-common)
includes `combat/ability_executor.lua`. Core installs the exact shared dependency
requested by an official routine through **Official Script Library**. Shared
packages have no entry script to enable separately.

For a local example such as [Single Action](../examples/single-action.md), first
check that `combat/ability_executor.lua` exists under the actual `COMMON_PATH`
reported by the [status panel](getting-started.md#install-and-run-your-first-script).
If it is missing, obtain that module from the official package and copy it into
`COMMON_PATH` while keeping the `combat` subdirectory, then click **Reload**.
That executor module has no other `require` dependencies. Other helpers may
need more files; keep the dependencies listed by their package together.
Do not overwrite shared modules used by installed routines with an unrelated
version. A missing module is a load error to fix in **Log**, not a reason to
remove the `require` or replace the executor.

## `ability_executor`

Use one executor for a top-level rotation and pass it to sub-routes. The
top-level callback polls it; a route cancels only a command it owns.

This fragment assumes your script supplies `Settings`, `should_cast` and
`target_or_nil`. [Single Action](../examples/single-action.md) supplies a complete
entry script once the helper above is available.

```lua
local AbilityExecutor = require("combat.ability_executor")
local executor = AbilityExecutor.new()

gos.on_tick(function()
  executor:tick()

  if not Settings.active then
    if executor:owns_command() then
      executor:cancel("inactive")
    end
    return
  end

  if executor:can_submit() and should_cast then
    executor:submit("Ability Name", target_or_nil, {
      idempotencyKey = "route-action",
    })
  end
end)
```

### Ownership and submission

| Method | Use |
| --- | --- |
| `new()` | Create the top-level executor. |
| `tick()` | Poll its command and refresh at most one retained receipt. Call even after the activation key is released. |
| `owns_command()` / `can_submit()` | Check whether it owns a command / can submit another. |
| `submit(ability, target, options)` | Attempt an action with a required nonempty `idempotencyKey`. |
| `can_replace()` / `replace(...)` | Check and request replacement of its current command. |
| `cancel(reason)` | Request cancellation; keep polling until ownership ends. |
| `status()` | Read a copy of the last observation published by `tick()` or an operation. |

`idempotencyKey` belongs to the helper, not native cast options. Repeating the
same key, ability and target while owned deduplicates the request. A busy
result is not automatically adopted: `adoptBusy=true` also requires a retained
receipt matching the handle, key, ability and target.

The explicit-target fallback defaults to none. Omit `target_fallback` when the
target is nil; even `"none"` is invalid without an explicit target.
`expectedStartAt` and `timeout` are rejected with
`unsupported_executor_lifecycle_option`. Missing `idempotencyKey` returns
`idempotency_key_required`; invalid options submit no native command.

### Results and receipts

An operation result describes both the attempted action and any command still
owned by the executor:

- `accepted` (`ok` for compatibility) can be true for a deduplicated request;
  `new_command` says whether it created a command.
- `owns_command`, `blocks_submission`, `can_submit` and `can_replace` describe
  current ownership. `admission_pending` alone acquires no command.
- `request_ability` / `request_idempotency_key` identify the attempted action;
  `ability` / `idempotency_key` identify the retained command.
- `disposition` is the helper's interpretation; nested `core` contains native
  status. See [command outcomes](command-lifecycle.md).

A receipt is a copied observation retained by the helper, not a command itself.
`receipt(handle)` returns that copy or nil; `receipts(limit)` returns newest
first, with at most 16 retained independently of Core's history.
`terminal_state(core_status)` projects a native status into a helper disposition.
It maps an expired Core-history tombstone to `failed`; check `core.state` and
`core.reason` before treating that as a failed ability.

Compatibility aliases: `has_pending()` is `owns_command()`;
`last_receipts(limit)` is `receipts(limit)`.

## `combat_events`

Register destination-scoped handlers at load time. The module owns one combat
cursor and polling callback for the importing script; your script does not poll it.

```lua
local Combat = require("combat.combat_events")

Combat.on_player("damage", function(event)
  gos.log.info("Player damage", event.amount)
end)
```

| Registration | Event destination |
| --- | --- |
| `Combat.on_player(name, callback)` | Local player |
| `Combat.on_current_target(name, callback)` | Current selected target |
| `Combat.on_ally(name, callback)` | Currently resolved friendly unit other than the player |

The name matches `event.kind` or `event.action`. Delivery preserves stream order;
the module logs dropped records. The log call above illustrates delivery; for
a meter, accumulate a [bounded model](event-processing.md) instead of logging each hit.

Scopes use the world at poll time, not event-time selection or teams. The helper
does not check actor epochs. For outgoing events or history that can cross a
world-session change, read `gos.events.combat` directly, compare `source_handle`
when appropriate and apply the
[epoch check](event-processing.md#retain-actor-labels-with-their-epoch) before
resolving historical handles.
