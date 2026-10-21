# GetFromWebOrLocal

Ensure a local file exists, downloading only on a cache miss; returns a boolean, not contents.

## Signature

```text
GetFromWebOrLocal(path, url, callback)
```

## Contract and usage

### `GetFromWebOrLocal(path, url, callback?)`

Alias: `gos.file.get_from_web_or_local(path, url, callback?)`.

Ensures a regular local file exists; returns `true` or `false, error`, not file
contents. An existing file is neither version-checked nor refreshed. Read its
contents separately with `ReadFile`.

On a cache miss it performs a blocking download under the
[download policy](../files.md#download-policy). Only this download branch is rejected in a
tick, but keep the helper at load time. `url` is validated only on a cache miss;
provide a valid URL whenever that branch is possible.

The optional zero-argument callback runs synchronously after either a cache hit
or a successful download. Callback failure returns `false, error` and leaves
the local file intact.

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
