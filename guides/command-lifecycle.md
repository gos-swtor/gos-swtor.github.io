# Commands, targets and outcomes

## Separate readiness, submission and activation

**Can it be attempted now?** `gos.abilities.can_cast` reports a current local readiness result. Pending or unavailable checks do not own a command. `wait_ms` is observed timing, not a future scheduling promise.

**Was it queued?** `gos.abilities.cast` can accept a request for asynchronous processing. Keep the returned command handle; do not repeat the submission on every tick while it is owned.

**Did it start?** Inspect command status. `acknowledged` and `activation_proven`
are start evidence. `terminal` only marks a lifecycle boundary: terminal
`submitted` does not prove activation, and retained status may gain an outcome later.

## Readiness is not queue eligibility

`can_cast()` tests current readiness. Omitted-target `cast()` requests can have different queue admission while a GCD or channel is ending. Explicit units/handles use ready-now admission, even when currently selected. See [target and readiness semantics](../api/abilities.md#target-and-readiness-semantics) before choosing a pre-cast gate.

## Keep one owner

For continuous behavior, use one [ability executor](helpers.md) at the top level
and pass it to sub-routes. Poll it from the top-level callback. A sub-route must
check that the retained `idempotency_key` identifies its own route before canceling it.
Continue polling after an activation key is released, including when cancellation fails.

The [single-action example](../examples/single-action.md) shows this structure.

## Choose the target

Pass a current unit or its opaque handle for an explicit target. An explicit cast does not persistently change the visible selected target by default. Use `gos.target.select` only for an intentional persistent selection change; confirm the later snapshot.

An explicit target defaults to `target_fallback="none"`; selecting `"selected"`
permits a failed explicit target to use the selected unit instead. When
omitting the target, omit `target_fallback` too: even `"none"` is invalid then.

## Track selection separately

`gos.target.select(unit, target_intent?)` can return an opaque third-value request handle. Poll `gos.target.status` instead of repeating submissions. `observed` confirms a matching selection snapshot; `unconfirmed` is not proof of no side effect. `gos.target.cancel` only cancels queued work, never undoes a dispatched selection. For overlay clicks, use the returned pressed entity, stable session generation and immutable intent ticket, not the current occupant of a reordered row. See the [world and target contracts](../api/world.md).

Core keeps a bounded command history. A known terminal
`expired` status with `command_history_expired` permits releasing ownership;
it carries no gameplay outcome. An unknown handle is a different result.

## Do not infer outcomes from timers

A GCD change, cooldown movement, or empty current-cast field does not identify
which command succeeded or failed. Use command status rather than a guessed
timeout. Exact fields and result codes are in the [ability reference](../api/abilities.md).
