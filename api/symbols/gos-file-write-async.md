# gos.file.write_async

Queue an exclusive or append binary write on the bounded storage worker.

## Signature

```text
gos.file.write_async(bytes, path, mode)
```

## Contract and usage

### `gos.file.write_async(bytes, path, mode)`

Queues a binary write on Core's serialized storage worker and returns an opaque
handle, or `nil, reason` on refusal. No disk work runs in the Lua callback.
`xb` creates exclusively and refuses an existing file; `ab` appends. Other modes
are rejected. One request accepts at most 8 KiB; a resulting file must be at most
256 KiB. Approved sandbox roots and path restrictions also apply on the worker.
Arguments must be strings, with a path of at most 1024 bytes. Wrong counts,
types, bounds, or modes return `nil, reason` without accepting a request.

## Related documentation

[Full modules and files contract](../files.md)
