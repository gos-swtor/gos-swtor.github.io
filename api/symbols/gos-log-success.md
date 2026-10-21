# gos.log.success

Write a success-level message to this script's log.

## Signature

```text
gos.log.success(...)
```

## Contract and usage

## Find a script's output

Press **Insert** to open Core, select the script in **Scripts**, and open **Log**.
`print` and `gos.log.info` appear under **INFO**, including **SUCCESS** messages.
**DEBUG** is off by default; turn it on for `gos.log.debug`. Keep **ERROR** on
and clear **Search logs** when checking load or callback failures. **Reload
failed:** above the log reports a failed load/reload; a callback error disables
that callback until **Reload**.

**Save** exports the retained log and reports its path. The default filename is
the script's stem plus `.log.txt`, beside the script. **Folders > Lua log folder**
can change the destination. Saved files also include request diagnostics;
review their contents before sharing an excerpt. Messages are retained in a bounded console buffer;
do not assume every message is already saved to disk. For a complete first run,
see [Getting started](../../guides/getting-started.md#install-and-run-your-first-script).

### Log messages

```lua
print("Loaded")
gos.log.debug("State", state)
gos.log.info("Enabled")
gos.log.success("Command completed")
gos.log.warn("Event gap", dropped)
gos.log.error("Cannot continue", reason)
```

These helpers join arguments with spaces. The five `gos.log` convenience methods return boolean success. **`print(...)` logs at info level and returns no values**; do not use its return value as a success flag.

Messages are sanitized and limited to 1024 bytes; multibyte text can reach the
limit in fewer characters. Each script has its own bounded log buffer.

## Related documentation

[Full logging contract](../logging.md)
