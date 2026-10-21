# ListFiles

List immediate regular-file names with optional exact extension filtering and truncation reporting.

## Signature

```text
ListFiles(path, extension_filter)
```

## Contract and usage

### `ListFiles(path, extension_filter?)`

Alias: `gos.file.list(path, extension_filter?)`.

Returns an array of immediate regular-file names, or `nil, error`. It does not
recurse or promise sorted order. An optional exact extension such as `.lua`
filters the names. After inspecting 16,384 directory entries, a truncated scan
returns the partial array plus a warning string.

```lua
local names, error_or_warning = ListFiles(SCRIPT_PATH, ".lua")
```

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
