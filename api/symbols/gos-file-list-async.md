# gos.file.list_async

Queue a bounded directory listing with explicit completeness.

## Signature

```text
gos.file.list_async(path, extension_filter)
```

## Contract and usage

### `gos.file.list_async(path, extension_filter?)`

Queues a nonrecursive directory listing and returns a handle or `nil, reason`.
The optional filter is an exact extension such as `.tsv`. Results contain at most
128 immediate regular files. Always check `truncated == false`; reaching the
matching-file limit or inspecting 16,384 entries can leave an incomplete list.
A matching file over 256 KiB fails this bounded archive operation.
The filter must start with `.` and contain at most 32 bytes, without wildcards,
path separators, a colon, or line breaks. Arguments are strings; an omitted or
`nil` filter means no extension filter.

## Related documentation

[Full modules and files contract](../files.md)
