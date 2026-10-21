# gos.settings.register

Register this script's settings schema at load time, never from a tick.

## Signature

```text
gos.settings.register(script_id, schema)
```

## Contract and usage

`register` and `get` raise Lua errors for invalid schemas, unknown registrations
or unavailable context. `set` returns `true, nil` for an accepted update or
`false, error` for an operational rejection. Malformed calls and unsupported
Lua value types still raise errors.

### `gos.settings.register(script_id, schema)`

Registers a settings schema while the script loads and returns its current
settings snapshot. Calling it from a tick callback raises an error.

```lua
local SCRIPT_ID = "example_rotation"

local Settings = gos.settings.register(SCRIPT_ID, {
  title = "Example Rotation",
  version = 1,
  activation = {
    mode = "hold",       -- always, hold, toggle, or manual
    label = "Rotation Key",
    default = "mouse4",
  },
  fields = {
    {
      key = "show_status",
      type = "bool",
      label = "Show status",
      tooltip = "Draw the current rotation state.",
      default = true,
    },
    {
      key = "hp_threshold",
      type = "int",
      label = "HP threshold",
      default = 50,
      min = 1,
      max = 100,
      step = 1,
    },
    {
      key = "mode",
      type = "select",
      label = "Mode",
      default = "Single target",
      options = { "Single target", "Area" },
    },
    {
      key = "accent",
      type = "color",
      label = "Accent",
      default = "#00CCFFFF",
    },
  },
})
```

Supported field types:

| Type | Lua value | Relevant schema keys |
| --- | --- | --- |
| `bool` | boolean | `default` |
| `number` | number | `default`, `min`, `max`, `step` |
| `int` | integer | `default`, `min`, `max`, `step` |
| `string` | string | `default`, `max_length` (maximum 256) |
| `select` | string | `default`, `options` (1-32 strings) |
| `hotkey` | string | `default` |
| `color` | string | `default` as `#RRGGBB` or `#RRGGBBAA` |

Every field requires `key`, `type`, `label`, and `default`. Optional `tooltip`
text appears in the settings UI. A schema can contain at most 256 fields.
`activation.default` applies only to `hold` and `toggle` modes. While enabled,
`always` and `manual` are active continuously, `hold` follows the configured
key, and `toggle` changes state on a press.

Hotkey fields and `hold`/`toggle` activation keys use an inline capture button:
click it, then press a keyboard key or mouse button. `Escape` cancels capture,
and left/right mouse buttons are ignored. Uncommon keys persist as `vk:0xNN`;
the UI displays their current keyboard-layout name. Optional activation keys
also expose a separate clear button.

Fields may also declare UI visibility gates:

```lua
{
  key = "telekinetics_option",
  type = "bool",
  label = "Telekinetics option",
  default = false,
  disciplines = { "Telekinetics" },
  requires_ability = "Telekinetic Gust",
}
```

`disciplines` matches exact display discipline names and `requires_ability`
matches a key in `gos.abilities.loadout().known`. Both gates must match when
both are present. These gates affect settings visibility only; scripts must
still validate their active loadout before using the setting.

Core shows gated rows while loadout identity is still pending or unavailable,
then hides nonmatching rows once the loadout is ready. Validated values and
activation keys persist across reloads.

## Related documentation

[Full settings contract](../settings.md)
