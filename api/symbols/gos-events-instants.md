# gos.events.instants

Read current instant-action observations, not a history stream.

## Signature

```text
gos.events.instants()
```

## Contract and usage

### `gos.events.instants()`

Returns current sanitized instant observations:

```text
{
  {
    unit_handle = "unit:..." | nil,
    ability_handle = "ability:..." | nil,
    active = false,
    name = string | nil,
    has_timing = false,
    remaining = number | nil
  }
}
```

An instant row can have an effect `remaining` timer despite `has_timing=false`; that flag describes cast/channel timing, not the presence of every kind of timer. An instant snapshot is not activation proof for a command you own.

For ordered gameplay processing, prefer `gos.events.combat`. The two snapshot
helpers are useful for simple current-frame presentation.

## Related documentation

[Full combat events contract](../events.md)
