# gos.abilities.release_command

Request safe cancellation; a rejected cancellation does not release ownership.

## Signature

```text
gos.abilities.release_command(command_handle)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.release_command(command_handle)`

Requests safe cancellation of this script instance's command and returns the command-status fields plus `ok`. A readable handle is not an ownership grant: another script's retained command returns `ok=false`, with `reason="foreign_command_owner"`, even when its status is otherwise known.
`ok=true` means the command was cancelled before dispatch or was already cancelled. It does not stop an ability that has already begun. A dispatched command that cannot be cancelled, an unknown handle, or an already-terminal non-cancelled command returns `ok=false`; inspect `known`, `terminal`, `cleanup_pending` and the outcome instead of treating every false result as an active command.

See also: [`gos.abilities.command_status(command_handle)`](../abilities.md#gosabilitiescommand_statuscommand_handle)

## Related documentation

[Full abilities contract](../abilities.md)
