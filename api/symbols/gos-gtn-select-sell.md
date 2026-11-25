# gos.gtn.select_sell

Select an exact carried-bag quantity and report the resulting current selected stack while preserving game confirmation.

## Signature

```text
gos.gtn.select_sell(bag_slot, item_handle, quantity)
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

### `gos.gtn.select_sell(bag_slot, item_handle, quantity)`

Queues selection of an exact current carried-bag stack. `bag_slot` is the
physical one-based slot from `gos.inventory.bag()`, `item_handle` is that bag
row's `handle`, and `quantity` is a positive integer no greater than its known
stack quantity. Returns a command handle or `nil, reason`. A partial selection
can create a different bag stack and item handle. Core waits until it can
attribute the exact selected quantity to the current bag. Array position, GTN
row handles, and prototype handles cannot identify the bag selection.

Wait for the selection command to complete, then use its current selected-stack
fields described under [`command`](../gtn.md#gosgtncommandcommand_handle). Re-read the bag
and `snapshot.selected_item_handle`/`selected_quantity`; do not reuse the source
stack's handle after a split. Quoting uses the complete resulting selected stack.
It is blocked when warning state is unknown or the game requires confirmation.
Resolve that game prompt explicitly; this API does not automatically accept it.

## Related documentation

[Full galactic trade network contract](../gtn.md)
