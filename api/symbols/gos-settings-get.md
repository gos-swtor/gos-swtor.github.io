# gos.settings.get

Read current settings, enabled/active state and field values.

## Signature

```text
gos.settings.get(script_id)
```

## Contract and usage

`register` and `get` raise Lua errors for invalid schemas, unknown registrations
or unavailable context. `set` returns `true, nil` for an accepted update or
`false, error` for an operational rejection. Malformed calls and unsupported
Lua value types still raise errors.

### `gos.settings.get(script_id)`

Returns the current snapshot:

```text
{
  script_id = string,
  title = string,
  version = integer,
  enabled = boolean,
  active = boolean,
  primary = boolean,
  activation = {
    mode = "always" | "hold" | "toggle" | "manual",
    label = string,
    key = string
  },
  fields = { [field_key] = value },
  [field_key] = value
}
```

Field values are available both directly and through `fields`. `active` is
computed by Core from enablement and activation mode. Use it as the execution
gate:

```lua
gos.on_tick(function()
  Settings = gos.settings.get(SCRIPT_ID)
  if not Settings.enabled or not Settings.active then
    return
  end
end)
```

## Related documentation

[Full settings contract](../settings.md)
