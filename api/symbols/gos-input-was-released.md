# gos.input.was_released

Read the shared release edge for this update without consuming it.

## Signature

```text
gos.input.was_released(button)
```

## Contract and usage

### Key and button state

```lua
gos.input.is_down(button)       -- boolean
gos.input.was_pressed(button)   -- boolean for this update
gos.input.was_released(button)  -- boolean for this update
gos.input.state(button)         -- detailed table
```

`state` returns:

```text
{
  name = string,
  virtual_key = integer,
  known = boolean,
  down = boolean,
  pressed = boolean,
  released = boolean
}
```

Buttons may be a canonical name, supported alias, integer virtual-key value in
`1..255`, decimal text, hexadecimal text, or `vk:NN` text. Canonical names
include `mouse1` through `mouse5`, common navigation/modifier keys, digits,
letters, and `f1` through `f12`. Unknown string names and out-of-range integer keys return false; `state` also sets `known=false`. Unsupported argument types such as a table, boolean or nil raise a Lua argument error instead of returning an unknown-button state.

Canonical single-digit strings are keyboard keys: `"5"` means the 5 key, not virtual-key value 5. Use `"vk:5"` or integer `5` for that numeric virtual key. Canonical names and aliases are case-insensitive.

Input edges are shared snapshot values and are not consumed by reading them.

Press/release edges belong to the current update; they are not accumulated separately for a throttled callback. A callback using `interval_ms` can miss an edge between its runs. Process edge-driven actions every update, or deliberately use held-state semantics instead. `known` identifies a recognized button argument, not a guarantee that a current input sample was available.

## Related documentation

[Full input contract](../input.md)
