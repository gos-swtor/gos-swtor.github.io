# gos.file.download_async

Perform a blocking load-time download; the optional callback runs synchronously.

## Signature

```text
gos.file.download_async(url, path, callback)
```

## Contract and usage

### `DownloadFileAsync(url, path, callback?)`

Alias: `gos.file.download_async(url, path, callback?)`.

**This function blocks until the download finishes.** Call it while loading;
tick callbacks receive `false, error`. See the [download policy](../files.md#download-policy)
for accepted URLs, size limits and timeouts.

Returns `true` on success or `false, error`. The optional zero-argument callback
runs synchronously after a successful download, before the helper returns.
Callback failure returns `false, error` even though the file was already written.

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

### Download policy

Downloads accept HTTP or HTTPS, require a direct HTTP 200 response, and are
limited to 256 MiB. Redirects and authentication are not followed; stored cookies
and credentials are not sent. URLs with embedded credentials, fragments,
backslashes or control characters are rejected. Use the final public file URL.

Connection, send and receive operations use 10-second timeouts. A 30-second
transfer budget is checked between blocking operations and at completion; an
in-progress operation can extend elapsed time. Oversized or incomplete responses
fail.

## Related documentation

[Full modules and files contract](../files.md)
