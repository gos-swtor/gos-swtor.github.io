# Build an event-driven tool

## Choose the stream, not a snapshot

`gos.events.combat(cursor)` is the ordered event stream. The initial call with no cursor subscribes at the current head; it does not replay a whole earlier fight. Keep the returned cursor for subsequent calls. The casts and instants helpers describe current presentation snapshots and are not a historical log.

## Source and destination are different

For outgoing damage compare `event.source_handle` to the player's handle. For incoming damage compare `event.target_handle`. The optional `combat_events` module's player and target scopes match destinations. A unit may no longer resolve by the time you process an event; its captured identity is still useful for comparison, but its current health or position is unknown.

## Retain actor labels with their epoch

Use optional `source_name` and `target_name` for captured display text. Keep each
retained actor's `actor_epoch` with its handle; names are not grouping keys.
For a later label, read `gos.actor_names(handles, saved_epoch)` in bounded update
batches, including after the last combat hit. Preserve a delivered name when
metadata is no longer retained. If the epoch changes, keep the old history's
captured labels and stop enriching it from the new session. Resolving an event
handle for current health or position also requires a matching actor epoch.
See the [actor metadata contract](../api/symbols/gos-actor-names.md).

## Bound processing and disclose gaps

Each stream call returns up to 64 events with `more` and `dropped`. Use a fixed pass budget and carry the cursor forward. Do not loop until the stream is empty without a cap. A dropped count means overwritten input, not zero damage. Show that a graph or total is incomplete.

## Classify only supported evidence

Classify by the published `kind`, optional `action`, and result, rather than
ability-name substrings. An interrupted or immune action counts as damage only
when the event says damage and supplies an amount. Keep unrecognized values
unknown, or explicitly exclude them from the tool's totals.

When a tool retains data, bound both record count and age. Cache metadata outside hot processing and show the distinction between current observations and last-known presentation. See the [counter example](../examples/incoming-damage.md) and [public event schema](../api/events.md).
