# gos.gtn.search

Queue an eligible search using the current catalog and player filter state.

## Signature

```text
gos.gtn.search(filter)
```

## Contract and usage

Use `gos.gtn` with the game's GTN already open. Reads use the prepared snapshot
for the current Lua tick; they do not synchronously refresh the game. Check each
record's `status`. Missing optional values mean unknown, including prices,
capacity, and confirmation state.

Commands return a command-handle string when accepted, or `nil, reason` when
submission is refused. Acceptance is not completion. Retain the handle and use
[`gos.gtn.command`](../gtn.md#gosgtncommandcommand_handle) until it becomes terminal.
Core permits one GTN command in flight across scripts and its interface.
Incorrect argument counts and invalid typed inputs can raise Lua errors.
Integer arguments require Lua integers; a numeric string or a floating-point
number is not accepted in their place. The filter's `name` and `usable` fields
require a string and boolean respectively when supplied. Unknown filter keys are
ignored. Refusal reasons are descriptive strings, not stable error codes; use
command state and explicit fields for control flow.

Handles are opaque strings scoped to the current Core/game state. Use a current
`row_handle` for row operations, a purchase `quote_handle` for buying, and a sale
`quote_handle` for selling. Item, prototype, row, order, quote, and command handles
are distinct; do not parse them, interchange them, or restore them from a saved
file. Core revalidates ownership, revisions, inventory, price, and capacity before
dispatch. Script reload/disable cancels only its queued work; already dispatched
work can still complete.

Prices and credit amounts are integer credits, quantities are integer units,
and listing durations are integer hours. There is no automatic economic retry.
A terminal `unknown` economic command leaves its outcome unresolved and blocks
further economic submissions. Inspect the game's orders, claims, inventory, and wallet
before taking further action. There is no exported operation to acknowledge or
clear this Core block; refreshing or reopening the GTN does not clear it.
Dry-run mode rejects buying, creating/canceling a
sale, and claiming with `nil, "dry_run"`; search, favorite, and selection commands
can still affect the client.

This page documents the 1.2.0 API contract. Source review and
documentation checks do not establish activation or end-to-end game validation.

The API reads current searches, item detail/history, personal listings, and
claims; it also submits the commands documented below. It does not open the GTN,
buy slot upgrades, or provide a persistent market-history database. Upgrade flags
are observations only. Item history comes from the current detail reply. Scripts
that retain their own scan history must store it separately and use the owned
search proof described under [search history identity](../gtn.md#search-history-identity).

### `gos.gtn.search(filter)`

Queues an ordinary search and returns a command handle or `nil, reason`.
`filter` is a table with these keys:

| Key | Type and default |
| --- | --- |
| `name` | String; defaults to `""`. At most 255 UTF-8 bytes, valid UTF-8, no embedded NUL. |
| `category`, `subcategory`, `slot`, `stat` | Integer catalog IDs; each defaults to zero for no restriction. |
| `quality` | Integer catalog ID; defaults to `0` for Any. |
| `rarity` | Integer catalog ID; defaults to `1` for Any. Zero is not Any. |
| `min_level` | Integer; defaults to `1`. |
| `max_level` | Integer; when omitted, uses the current ready catalog's `max_level`. Missing maximum metadata rejects the request. |
| `usable` | Boolean; defaults to `false`. Applies to the current player. |

Use current catalog options; category/subcategory/slot relationships are checked.
Levels must satisfy `1 <= min_level <= max_level <= catalog.max_level`.
A nonempty name needs a nonnumeric space-separated token of at least three
UTF-16 code units. An empty trimmed name requires a selected category and a
selected subcategory if that category has subcategories. Advanced filters alone
do not qualify an empty-name search. An invalid nonempty name is rejected even
with a category selected. The original name is sent after eligibility checks.

The client performs its search admission check; a known false `can_search`
observation can refuse submission before dispatch. Wait for
the returned command to succeed and then read the fresh buy view. This is not
a synchronous return of rows.

```lua
local snapshot = gos.gtn.snapshot()
if snapshot.status == "ready" and snapshot.catalog.status == "ready" then
  local command_handle, reason = gos.gtn.search({ name = "Desh" })
  -- Retain command_handle and poll gos.gtn.command on later ticks.
end
```

## Related documentation

[Full galactic trade network contract](../gtn.md)
