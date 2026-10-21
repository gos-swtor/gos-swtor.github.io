# Write your own bounded Lua module

A plain Lua ring buffer, independent of any GoS API. Save as bounded_history.lua in the shared module root and use require("bounded_history") from a script. Store copied records or handles, not generation-bound units. Do not mutate the buffer inside its each callback. This is a module, not an entry-point script to enable.

[Download the module source](code/bounded-history.lua){: download="bounded_history.lua" }
and save it as `bounded_history.lua` under the actual `COMMON_PATH` shown by the
[status panel's Log tab](../guides/getting-started.md#install-and-run-your-first-script).
Click **Reload** after adding it so entry scripts can load the module.

## Complete code

```lua
local History = {}
History.__index = History
function History.new(capacity)
  assert(type(capacity) == "number" and capacity % 1 == 0
      and capacity >= 1 and capacity <= 4096, "capacity must be 1..4096")
  return setmetatable({ capacity = capacity, count = 0, next = 1, rows = {} }, History)
end
function History:push(value)
  assert(value ~= nil, "history value cannot be nil")
  self.rows[self.next] = value
  self.next = self.next % self.capacity + 1
  self.count = math.min(self.count + 1, self.capacity)
end
function History:each(callback)
  local start = self.count == self.capacity and self.next or 1
  for offset = 0, self.count - 1 do
    callback(self.rows[(start + offset - 1) % self.capacity + 1])
  end
end
return History
```
