# gos.import

Load a sandbox Lua module cached per top-level script environment.

## Signature

```text
gos.import(module_name)
```

## Contract and usage

### Modules

```lua
local module = require("module_name")
local same = import("module_name")
local same_again = gos.import("module_name")
```

All three use the sandboxed module loader. Modules resolve only from approved
script roots and are cached per top-level script environment.

## Related documentation

[Full modules and files contract](../files.md)
