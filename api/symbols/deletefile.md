# DeleteFile

Remove one file or empty directory without recursion; false without an error means nothing was removed.

## Signature

```text
DeleteFile(path)
```

## Contract and usage

### `DeleteFile(path)`

Alias: `gos.file.delete(path)`.

Removes one file or empty directory, without recursion. Returns `true` when
something was removed, false without an error when nothing was removed, or
`false, error` on failure.

### Root Constants

Each path ends with the platform directory separator:

```text
SCRIPT_PATH
COMMON_PATH
SPRITE_PATH
FONTS_PATH
SOUNDS_PATH
CACHE_PATH
```

`SCRIPT_PATH` is the current entry script's directory; `COMMON_PATH` is the
configured shared-module root. To find their actual values, run the
[status panel and open its Log tab](../../guides/getting-started.md#install-and-run-your-first-script).
**Open Folder** opens the active-script directory. Shared modules need not be
beside a portable entry script; use `COMMON_PATH` instead of guessing a path.

Relative file paths resolve from `SCRIPT_PATH`. File operations must stay inside
the approved roots; network-share and device paths are rejected.

### File Helpers

Global helpers and their `gos.file` aliases have identical arguments and results.
An omitted error return becomes nil in a two-variable assignment.

## Related documentation

[Full modules and files contract](../files.md)
