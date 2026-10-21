# gos.on_tick

Register bounded work on the update scheduler; optional interval_ms controls cadence.

## Signature

```text
gos.on_tick(callback, options)
```

## Contract and usage

### `gos.on_tick(callback, options?)`

Register while a script loads or from one of its active callbacks. Registration
without a loaded-script owner raises a Lua error. Reloading creates a new script
instance; old requests and click-intent tickets do not transfer to it.

Returns no values; callbacks receive no arguments. Only `interval_ms` is read
from options. Unknown keys are ignored, so a misspelling leaves the default
every-update cadence in effect.

Registers a function on Core's update scheduler. With no options it runs every
worker update. `options.interval_ms` may request a lower cadence from `0` to
`60000` milliseconds; a due callback never runs more than once per worker update.

```lua
gos.on_tick(function()
  local world = gos.world()
  if world.player then
    -- Read the current immutable snapshot here.
  end
end)
```

For visual callbacks, skipped interval ticks retain the callback's last frame-local
overlay contribution. An unhandled error disables only the failing callback and
removes that callback's frame-local contribution until scripts reload.

Callbacks should be bounded and non-blocking. The Release runtime accepts at
most 256 registered callbacks.

## Related documentation

[Full runtime contract](../runtime.md)
