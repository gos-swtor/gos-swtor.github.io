# Runtime and data

Scripts run in isolated Lua environments on Core's update cadence. Register
work with `gos.on_tick`; do not create a render loop or blocking loop.

## Snapshot lifetime and identity

`GosWorld` and `GosUnit` values belong to one update generation. Retain a unit's
opaque handle when identity must survive a tick, then resolve it in a fresh
world. Across a world-session change, also check the saved
[actor epoch](event-processing.md#retain-actor-labels-with-their-epoch).

Ability, unit, effect and command handles are opaque strings: compare them or
pass them back to Core. Do not parse them or persist them across game sessions.

`nil` means an optional observation is unavailable. Check a result table's
`status` before reading its payload. Missing or pending data does not mean zero,
false, or absence.

## Units

| Values | Unit |
| --- | --- |
| Ability cooldowns, cast times, effect timers, overlay TTL | Seconds |
| `gos.time_ms()`, event `timestamp`, result `wait_ms`, effect `age_ms` | Milliseconds |
| Position, distance and velocity coordinates | Game-world coordinate scale; one world unit is ten metres |
| Health and resource percentages | 0..100 |

`unit:distance()` needs matched spatial samples for both the player and unit;
`unit:position()` needs one for that unit. Either returns `nil` when the
required sample is unavailable. Convert range thresholds once: 30 metres is
3 world units.

## Lua environment

Core embeds **Lua 5.4.8**. This is the language/runtime version, independent of a
script's `gos.settings.register(..., { version = ... })` settings version.

The global `gos` table and its child tables are read-only. Selected Lua base
functions and the table, string, math, UTF-8, and coroutine libraries are available,
with `os.clock`, `os.date`, `os.difftime`, `os.time`, and `debug.traceback`.
Coroutines are cooperative, not background threads.

Use the sandboxed `require` for modules and the [file helpers](../api/files.md)
for permitted files. Process execution, unrestricted operating-system access,
bytecode loading and native modules are unavailable. `load`, `loadfile`,
`dofile`, `rawget`, `rawset`, and `collectgarbage` are not exposed.
