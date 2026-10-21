# gos.abilities.abandon_command

Query compatibility release eligibility without changing an in-flight command.

## Signature

```text
gos.abilities.abandon_command(command_handle)
```

## Contract and usage

Ability lookups accept a case-insensitive display name or an exact current
opaque `ability_handle`. Ability metadata is local-player-only.

### `gos.abilities.abandon_command(command_handle)`

Compatibility endpoint returning command-status fields plus `ok`. It does not change a command: `ok=true` requires a retained command owned by this script instance that is already terminal. Foreign, unknown, evicted, or in-flight commands return `ok=false`, including an otherwise known expired-history tombstone. It does not drop an in-flight command or bypass cleanup. New scripts should retain and resolve command ownership instead of abandoning it.

See also: [`gos.abilities.command_status(command_handle)`](../abilities.md#gosabilitiescommand_statuscommand_handle)

## Related documentation

[Full abilities contract](../abilities.md)
