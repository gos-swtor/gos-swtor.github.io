# gos.log.write

Write one structured log message with an optional level, tag and color.

## Signature

```text
gos.log.write(entry)
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

### `gos.log.write(entry)`

For structured logging, nonempty `text` takes precedence over the `message`
alias. Supply one nonempty message:

```lua
local ok, error = gos.log.write({
  level = "info",     -- debug, info, success, warn, or error
  tag = "APL",
  text = "Queued Telekinetic Throw", -- message is an alias
  color = "cyan",
})
```

For `level`, `"ok"` aliases `"success"` and `"warning"` aliases `"warn"`.
These aliases apply to level values, not method names.
Returns `true, nil` on success or `false, error` when rejected. Optional `tag` is
limited to 24 bytes; message sanitization and the 1024-byte limit apply here too.

## Related documentation

[Full logging contract](../logging.md)
