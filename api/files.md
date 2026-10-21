# Modules and sandbox files

### Modules

```lua
local module = require("module_name")
local same = import("module_name")
local same_again = gos.import("module_name")
```

All three use the sandboxed module loader. Modules resolve only from approved
script roots and are cached per top-level script environment.

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
[status panel and open its Log tab](../guides/getting-started.md#install-and-run-your-first-script).
**Open Folder** opens the active-script directory. Shared modules need not be
beside a portable entry script; use `COMMON_PATH` instead of guessing a path.

Relative file paths resolve from `SCRIPT_PATH`. File operations must stay inside
the approved roots; network-share and device paths are rejected.

### File Helpers

Global helpers and their `gos.file` aliases have identical arguments and results.
An omitted error return becomes nil in a two-variable assignment.

### `FileExist(path)`

Alias: `gos.file.exists(path)`.

Returns `true` for a regular file and `false` otherwise. A rejected path returns
`false, error`; an ordinary missing file returns false without an error.

```lua
local exists, error = FileExist(CACHE_PATH .. "state.txt")
```

### `ReadFile(path)`

Alias: `gos.file.read(path)`.

Returns binary-safe file contents, or `nil, error` if the path is rejected or the
read fails.

```lua
local text, error = ReadFile(CACHE_PATH .. "state.txt")
```

### `WriteFile(text, path, mode?)`

Alias: `gos.file.write(text, path, mode?)`.

Returns `true` on success or `false, error`. Missing parent directories are
created for a valid write path. Modes `w` and `wb` truncate an existing file;
`a` and `ab` append. The default is `w`. All four modes write bytes without text
conversion. Writes are not atomic: failure can leave a truncated or partially
written file.

```lua
local ok, error = WriteFile("ready", CACHE_PATH .. "state.txt", "w")
```

### `DeleteFile(path)`

Alias: `gos.file.delete(path)`.

Removes one file or empty directory, without recursion. Returns `true` when
something was removed, false without an error when nothing was removed, or
`false, error` on failure.

### `MakeDirectory(path)`

Alias: `gos.file.mkdir(path)`.

Creates the directory and any missing parents. Returns `true` when created,
false without an error when it already exists, or `false, error` on failure.

### `ListFiles(path, extension_filter?)`

Alias: `gos.file.list(path, extension_filter?)`.

Returns an array of immediate regular-file names, or `nil, error`. It does not
recurse or promise sorted order. An optional exact extension such as `.lua`
filters the names. After inspecting 16,384 directory entries, a truncated scan
returns the partial array plus a warning string.

```lua
local names, error_or_warning = ListFiles(SCRIPT_PATH, ".lua")
```

### `DownloadFileAsync(url, path, callback?)`

Alias: `gos.file.download_async(url, path, callback?)`.

**This function blocks until the download finishes.** Call it while loading;
tick callbacks receive `false, error`. See the [download policy](#download-policy)
for accepted URLs, size limits and timeouts.

Returns `true` on success or `false, error`. The optional zero-argument callback
runs synchronously after a successful download, before the helper returns.
Callback failure returns `false, error` even though the file was already written.

### `GetFromWebOrLocal(path, url, callback?)`

Alias: `gos.file.get_from_web_or_local(path, url, callback?)`.

Ensures a regular local file exists; returns `true` or `false, error`, not file
contents. An existing file is neither version-checked nor refreshed. Read its
contents separately with `ReadFile`.

On a cache miss it performs a blocking download under the
[download policy](#download-policy). Only this download branch is rejected in a
tick, but keep the helper at load time. `url` is validated only on a cache miss;
provide a valid URL whenever that branch is possible.

The optional zero-argument callback runs synchronously after either a cache hit
or a successful download. Callback failure returns `false, error` and leaves
the local file intact.

### Download policy

Downloads accept HTTP or HTTPS, require a direct HTTP 200 response, and are
limited to 256 MiB. Redirects and authentication are not followed; stored cookies
and credentials are not sent. URLs with embedded credentials, fragments,
backslashes or control characters are rejected. Use the final public file URL.

Connection, send and receive operations use 10-second timeouts. A 30-second
transfer budget is checked between blocking operations and at completion; an
in-progress operation can extend elapsed time. Oversized or incomplete responses
fail.

### `UnzipArchive(path, target)`

Alias: `gos.file.unzip(path, target)`.

Extracts a `.zip` synchronously. Call it while loading; tick callbacks receive
`false, error`. Returns `true` only after extraction and output verification
finish, or `false, error` on failure.

Archive paths and sizes are checked before extraction. Links, duplicate output
paths, disallowed file types and paths escaping approved roots are rejected;
total extracted size is limited to 512 MiB. Failure may leave partial output
and does not restore an existing destination.
