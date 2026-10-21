# Performance and bounded work

## Keep each update finite

Read one current world per callback. Prefer the player or selected target when that is all you need. Filter a unit query once and process a fixed maximum number of rows appropriate to the tool. Avoid nested all-unit scans and sorting the same unchanged data on every tick.

Use `interval_ms` for display work that does not need every update. The status
panel uses 100 ms; input edges and command polling may need every update.

## Consume new events, not old history

Retain the combat cursor, process only returned records, and cap the number of batches per callback. Each call yields at most 64 events. If `more` remains true, leave the rest for a later update. Track `dropped`; incomplete input must not look like a complete fight.

The [incoming damage example](../examples/incoming-damage.md) uses at most four batches and keeps totals rather than storing every hit. A graph needs a fixed-capacity buffer or fixed time buckets. Never grow one table for an entire session without an eviction policy.

## Prepare, then draw

Maintain a small model and render from it. Use stable short drawing IDs so an update replaces an existing element. Use retained `frame=true` drawings for current callback output, and TTL drawings for intentionally persistent markers. Do not use long TTLs to disguise stale gameplay data.

One registered callback can retain at most 192 frame commands. Core combines
at most 512 active drawing commands overall, with at most 32 callbacks retaining
frame output. A drawing is replaced only when its callback owner, target,
draw kind and ID match. These budgets are shared with other scripts.

## Avoid expensive work in ticks

Do not download, unzip, read or write files, rebuild lookup maps, emit per-event logs, or run blocking loops inside frequent callbacks. Prepare static data at load time. Log meaningful transitions with a bounded rate; store totals in memory instead of writing every observation.

Measure the tool with representative entity and event counts.
