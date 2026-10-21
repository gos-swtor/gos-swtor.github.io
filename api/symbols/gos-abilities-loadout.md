# gos.abilities.loadout

Read local loadout identity, known abilities and talents, and availability flags.

## Signature

```text
gos.abilities.loadout()
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.loadout()`

Returns the selected local loadout:

```text
{
  status = "pending" | "ready" | "unavailable",
  action_bar_available = boolean,
  action_bar_truncated = boolean,
  combat_style = string | nil,
  discipline = string | nil,
  talents_available = boolean | nil,
  known = { [ability_or_active_talent_display_name] = true } | nil
}
```

The last four fields are present only when `status == "ready"`. `known`
contains currently owned abilities and active talents. The active talent set includes both selectable choices (for example
`Force Mobility`) and automatically learned/passive progression rows (for
example `Force Shelter`). Talents remain distinct from ability metadata
internally: presence in `known` does not make a passive castable or give it an
`ability_handle`. Talent discovery is enrichment only; a transient invalid
talent snapshot never makes the owned-ability loadout unavailable.
When `talents_available=false`, missing talent names are not proof that those
talents are unselected. Action-bar availability is independent of loadout
identity; an empty or incomplete bar does not imply a player-session change.

```lua
local loadout = gos.abilities.loadout()
if loadout.status ~= "ready" then
  return
end

if loadout.combat_style == "sage" and
   loadout.discipline == "Telekinetics" and
   loadout.known["Telekinetic Gust"] then
  -- Exact current loadout match.
end
```

## Related documentation

[Full abilities contract](../abilities.md)
