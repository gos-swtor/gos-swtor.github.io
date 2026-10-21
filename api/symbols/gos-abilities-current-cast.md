# gos.abilities.current_cast

Read current cast identity and optional timing, or nil.

## Signature

```text
gos.abilities.current_cast()
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.current_cast()`

Returns the current cast/channel observation, or `nil` when its active snapshot
is unavailable:

```text
{
  ability_handle = "ability:..." | nil,
  name = string,
  has_timing = boolean,
  remaining = number | nil
}
```

`name` is `"-"` when the display name is unavailable. `remaining` is in seconds
and is present only when `has_timing=true`.

## Related documentation

[Full abilities contract](../abilities.md)
