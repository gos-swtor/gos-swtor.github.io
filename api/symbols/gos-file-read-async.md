# gos.file.read_async

Queue a bounded binary read without blocking the Lua callback.

## Signature

```text
gos.file.read_async(path)
```

## Contract and usage

### `gos.file.read_async(path)`

Queues a binary read and returns a handle or `nil, reason`. Files larger than
256 KiB fail. Accepted operations execute in submission order, including a read
used to inspect an earlier uncertain write.

## Related documentation

[Full modules and files contract](../files.md)
