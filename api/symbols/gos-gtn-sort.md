# gos.gtn.sort

Queue sorting of a ready view; descending=true requests descending order.

## Signature

```text
gos.gtn.sort(view, sort, descending)
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

### `gos.gtn.sort(view, sort, descending)`

Queues a sort for `view="buy"`, `"sales"`, `"purchased"`, or `"sold"`.
`sort` must be an integer from the table below; `descending` must be boolean.
True requests descending order. Returns a command handle or `nil, reason`.
The view must be ready and its revision still current at dispatch. Changing the
sort resets pagination through the client's normal model path.

| Sort | Meaning |
| ---: | --- |
| 1 | Time remaining |
| 2 | Unit price |
| 3 | Quantity |
| 4 | Refund price |
| 5 | Item name |
| 6 | Required character level |
| 7 | Item quality |
| 8 | Order status |
| 9 | Sold quantity |
| 10 | Original stack quantity |

Choose the sort appropriate to the view's available columns. Completion requires
the requested sort and direction to be observed in the current view.

## Related documentation

[Full galactic trade network contract](../gtn.md)
