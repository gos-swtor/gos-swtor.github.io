# gos.gtn.command

Read this script instance's retained GTN command, selected-stack attribution, native receipt and uncertainty.

## Signature

```text
gos.gtn.command(command_handle)
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

### `gos.gtn.command(command_handle)`

Returns a retained command record for the same script instance, or `nil, reason`
for an invalid, expired, or foreign handle. Command history is bounded to 128
records; terminal records can expire. The result is:

```text
{
  handle = "gtn_command:...", operation = string,
  state = string, terminal = boolean, reason = string,
  submitted_ms = integer, dispatched_ms = integer, completed_ms = integer,
  receipt_sequence = integer, filled = integer, raw_result = integer | nil,
  confirmed_order_handle = string | nil,
  selection_status = "current" | "stale" | nil,
  selected_item_handle = string | nil, selected_bag_slot = integer | nil,
  selected_bag_revision = integer | nil,
  search_result = {
    mode = "search" | "favorites" | "popular" | "recent",
    view_revision = integer, receipt_sequence = integer,
    heading_sync = "succeeded" | "failed" | "unavailable",
    local_empty = boolean
  } | nil,
  receipt = {
    kind = string, sequence = integer,
    handler_returned = boolean, truncated = boolean,
    prototype_handle = string | nil, order_handle = string | nil,
    response_handle = string | nil, raw_result = integer | nil,
    requested = integer, filled = integer, extra = integer
  } | nil
}
```

`confirmed_order_handle` identifies a reconciled server order when available;
it is not a row-action argument. Selection attribution adds `selection_status`.
When it is `"current"`, `selected_item_handle`, `selected_bag_slot`, and
`selected_bag_revision` identify the attributed resulting stack in the current
ready bag. `selected_bag_revision` is the current matching bag observation's
revision. A change to bag contents, bag ownership, or session makes attribution
`"stale"` and those three fields are omitted; a metadata-only revision change
does not by itself make it stale. Attribution can remain available on a
rejected command that requires game confirmation; check `state` separately.
These fields identify an attributed bag stack, not a guarantee that it remains
in the sell slot. Also compare the current snapshot's `selected_item_handle`
and `selected_quantity` before quoting or creating a listing.

The optional `search_result` is the retained owned-view proof described under
[search history identity](../gtn.md#search-history-identity). It can accompany a search
rejected because its heading update failed; require `state="succeeded"` and
`heading_sync="succeeded"` before accepting it as a successful search.

The optional `receipt` records observed native reply evidence. Its known `kind`
values are `search_ready`, `grouped`, `single`, `detail`, `purchase`, and `claim`.
`handler_returned` reports whether that reply handler returned; it does not
replace command completion and reconciliation. `truncated` marks an incomplete
captured reply. Optional identity handles remain opaque. `requested`, `filled`,
and `extra` are kind-dependent observations; zero is not evidence that every
reply represents a zero-unit operation. `extra` remains a raw client value.

States are `queued`, `dispatched`, `awaiting_reply`, `succeeded`, `partial`,
`rejected`, `canceled`, and `unknown`. The first three are nonterminal. A
terminal `unknown` state means uncertainty, not a definite failure. `filled`
reports the observed fill where available; zero before a matching receipt does
not establish a zero fill. `raw_result` is optional native reply data; use the
command state and reason for the supported completion contract.

`operation` describes the underlying action: buying reports `purchase`,
`quote_sell` reports `quote_sale`, `sell` reports `create_sale`, and `refresh`
reports `capture`; other public
GTN command names retain their spelling. Times are Core monotonic milliseconds,
not Unix timestamps. Undispatched/uncompleted times and missing receipt
sequences can be zero. The current queue deadline is ten seconds; unresolved
work after dispatch reaches `unknown` after thirty seconds. Core does not send
an economic retry on expiry.

Keep polling from the submitting script instance. A nil record after reload or
history expiry does not establish whether an earlier dispatched purchase,
listing, cancellation, or claim changed the game.

## Related documentation

[Full galactic trade network contract](../gtn.md)
