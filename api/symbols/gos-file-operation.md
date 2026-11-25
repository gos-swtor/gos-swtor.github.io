# gos.file.operation

Poll owned background storage work and inspect its completion or failure.

## Signature

```text
gos.file.operation(handle)
```

## Contract and usage

### `gos.file.operation(handle)`

Polls an accepted operation without disk access. The result contains `state`:
`queued`, `running`, `succeeded`, or `failed`. Terminal results include:

| Field | Meaning |
| --- | --- |
| `bytes` | Bytes transferred by this operation; required for successful writes. |
| `data` | Binary read contents, including embedded zero bytes. |
| `files` | Listing entries `{name, bytes}`. |
| `truncated` | Whether the listing is incomplete. |
| `code`, `reason` | Machine-readable result and explanation: `none`, `not_found`, `file_exists`, `denied`, `too_large`, or `io_error`. |

Before completion only `state` is present. All fields in this table are emitted
for a terminal result, even when not applicable: a non-read has empty `data`, a
non-list has empty `files`, and `bytes` is the transferred-byte count rather than
the number of listed entries. An empty successful read remains valid binary data.

Handles belong to one script instance. Foreign, expired, or unknown handles return
`nil, reason`; a reloaded instance cannot poll its predecessor's handles. Queued
and running operations remain pollable, and accepted writes finish after a Lua
reload or disable. Core retains at most 64 operations and may evict terminal
results to admit work. Queue saturation refuses new submissions.

A failed accepted write may have written some or all bytes. Inspect it before
retrying; Core does not replay it. Success includes closing the file but does not
promise power-loss durability. These four functions have no global aliases.

## Related documentation

[Full modules and files contract](../files.md)
