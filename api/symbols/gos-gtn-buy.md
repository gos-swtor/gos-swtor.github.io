# gos.gtn.buy

Queue a bounded purchase from the current quote; poll its command for the actual outcome.

## Signature

```text
gos.gtn.buy(quote_handle, quantity, max_total)
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

### `gos.gtn.buy(quote_handle, quantity, max_total)`

Queues a purchase from the current ready purchase quote. `quantity` is a positive
integer and `max_total` is an integer credit ceiling. Returns a command handle
or `nil, reason`. Core binds the quote to its current buy row/revision and
revalidates listed quantity, maximum stack, price tiers, wallet, and buy slots.

The current route retains the quoted unit price. It rejects a quantity that
would require a higher-priced tier and rejects integer overflow or
`quantity * unit_price > max_total`. It does not raise the price to fill an order.
Use [`command`](../gtn.md#gosgtncommandcommand_handle) to distinguish full success, a
partial fill, rejection, and an unknown outcome. A successful purchase creates
a purchased-order claim; collecting it is a separate
[`claim`](../gtn.md#gosgtnclaimrow_handle) action.

## Related documentation

[Full galactic trade network contract](../gtn.md)
