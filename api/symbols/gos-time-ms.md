# gos.time_ms

Read monotonic milliseconds for elapsed time, not wall-clock time.

## Signature

```text
gos.time_ms()
```

## Contract and usage

### `gos.time_ms()`

Returns a monotonic integer millisecond timestamp. Use it for elapsed time and
local expiry checks, not as wall-clock or game time.

```lua
local started_at = gos.time_ms()
local elapsed_ms = gos.time_ms() - started_at
```

Within an update, `gos.time_ms()` normally reflects the prepared update timestamp; repeated calls in one long callback are not a high-resolution execution profiler.

## Related documentation

[Full runtime contract](../runtime.md)
