# gos.events.casts

Read current cast/channel presentation observations, not a history stream.

## Signature

```text
gos.events.casts()
```

## Contract and usage

### `gos.events.casts()`

Returns current sanitized cast/channel observations:

```text
{
  {
    unit_handle = "unit:...",
    ability_handle = "ability:...",
    active = true,
    name = string | nil,
    has_timing = boolean,
    remaining = number | nil,
    position = { x = number, y = number, z = number } | nil
  }
}
```

## Related documentation

[Full combat events contract](../events.md)
