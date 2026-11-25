# gos.gtn.snapshot

Read prepared GTN availability, catalogs, views, current quotes and optional capacity data.

## Signature

```text
gos.gtn.snapshot()
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

### `gos.gtn.snapshot()`

Takes no arguments and returns the current snapshot. With no GTN context, the
result contains only `status="unavailable"`. Otherwise it includes:

| Fields | Contract |
| --- | --- |
| `status`, `reason` | Overall availability and explanatory text. Status is `pending`, `ready`, `closed`, `unavailable`, or `truncated`. Reasons are descriptive text, not an enum. |
| `revision`, `sampled_ms` | Snapshot revision and Core monotonic sampling time in milliseconds. Revisions identify observations, not server order IDs. |
| `history_contract`, `history_reason` | `history_contract=1` is present while native query attribution is ready. Otherwise `history_reason` explains why history is unavailable. |
| `open` | Current GTN interaction flag. Actions also require overall `status="ready"` and their own ready data. |
| `tab`, `mode` | Numeric client tab/search mode, separate from each view's identity and revision. A stored tab does not prove GTN is open. |
| `credits`, `credit_cap` | Optional current wallet values. Zero is a known zero; nil is unknown. |
| `max_buyout_price` | Optional current client listing-price/proceeds cap, separate from the wallet credit cap. Quoting checks the buyer unit price against it; listing creation also checks seller proceeds after the fee. Unknown cap data blocks listing quotes. |
| `buy_used`, `buy_cap`, `sell_used`, `sell_cap` | Optional current order-slot counts and limits. |
| `favorite_used`, `favorite_cap` | Optional current favorite counts and limits. |
| `can_search` | Optional read-only observation of current search admission. Sampling it does not consume admission; a later request still uses the client's own checks. |
| `can_upgrade_buy`, `can_upgrade_sell`, `can_upgrade_favorites` | Optional client upgrade availability flags. |
| `selected_item_handle` | Optional current sell selection's inventory item handle. |
| `selected_quantity` | Optional observed quantity in the current sell selection. Missing quantity is unknown, not a one-unit or full-stack assumption. |
| `selection_confirmation_known`, `selection_confirmation_required` | Whether warning/confirmation state was observed, and its value when known. The latter is omitted when unknown. |
| `filter`, `catalog` | Current API-confirmed filter and independently available discovery catalog. |
| `buy`, `sales`, `purchased`, `sold` | Independently sampled views described below. |
| `detail`, `sale` | Current purchase detail and sale quote described below. |

Tabs are buy `1`, sell `2`, purchased claims `3`, sold claims `4`, and purchase
detail `5`. Search modes include ordinary search `3`, favorites `6`, popular `7`,
and recently listed `8`; these quick modes share the buy view. Do not treat mode
numbers as request IDs or pending-state values.

`can_search=false` means the current observation is throttled and blocks a new
search submission. A missing value means unknown; it does not by itself block
the client's normal admission attempt or imply that searching is allowed. All
other readiness and argument checks still apply. Reading snapshots does not
advance the client's throttle timestamp.

#### Catalog and filters

`catalog` contains `status`, `reason`, dense arrays `categories`, `subcategories`, `slots`,
`stats`, `qualities`, `rarities`, an array of allowed `durations`, and optional
`default_duration` and `max_level`. Option rows are `{id, parent, name}`.
Subcategory `parent` is its category ID; slot `parent` is its subcategory ID.
Other options use parent zero. Match both ID and parent when selecting dependent
options. Catalog capture is bounded; use it only when `status=="ready"`.
`reason` retains the catalog failure explanation independently of later view
captures; an empty reason does not replace the status check.
An option's localized `name` can be an observed empty string. Identify options
by `id` and `parent`; an empty label does not remove a known option or replace
failed catalog data with a made-up name.

`filter` has the same keys as [`search`](../gtn.md#gosgtnsearchfilter). It records the
filter confirmed through this API's completed search; it is not an editable game
control or a guarantee of detecting every subsequent manual text-field change.

#### Views and rows

Each view always has `status` and `revision`. A ready or truncated view also has
`total`, stored `page` and `max_page`, integer `sort`, boolean `descending` and
`wrap`, `receipt_sequence`, and dense `rows`. Other statuses omit these payload
fields. Nonempty views use one-based pages. An observed empty model can retain
`page=0, max_page=0` before pagination initialization, or retain earlier page
values; Core does not replace them with display defaults. A ready empty `rows`
array is an observed empty model; it does not by itself prove that a requested
search completed. Use the command's completion evidence. Missing rows are
unavailable. A truncated view is incomplete and cannot supply actionable rows.
Pages contain at most ten rows.

Rows have the following fields:

```text
{
  handle = "gtn_item:...", row_handle = "gtn_row:...",
  prototype_handle = "item_prototype:...", order_handle = string | nil,
  catalog_key = string | nil,
  name_ready = boolean, name = string | nil,
  required_level = integer | nil, quality = integer | nil,
  max_stack = integer | nil,
  quantity = integer, unit_price = integer, claimable_credits = integer,
  favorite = boolean, in_storefront = boolean,
  original_quantity = integer | nil, sold_quantity = integer | nil,
  end_time = integer | nil, claim_expiry_ms = integer | nil,
  state = integer | nil, order_type = integer | nil,
  claim_validation = integer | nil
}
```

Buy rows group listings by item. They are not individual seller orders. Optional
metadata can arrive later; `name_ready=false` does not change the item's identity.
`required_level` is a character-level requirement, not gear rating. Quality uses
the catalog's numeric IDs. `max_stack` is item metadata and does not by itself
authorize that purchase quantity. Order state/type/validation integers are raw
client values; row eligibility is checked by Core. `end_time` is an unconverted
client time value; do not assume Unix seconds from its integer representation.
`claim_expiry_ms` is an optional client expiry observation.

Re-fetch rows after search, sort, page, session, or revision changes. Retaining
an old row table does not retain an actionable quote. `order_handle` is an
identity field; cancellation and claims take the current `row_handle`.

#### Purchase detail

`detail` includes `handle`, `prototype_handle`, `catalog_key`, `name_ready`,
`name`, `required_level`, `quality`, and `max_stack` with the item-field semantics
above, plus `status`, optional purchase `quote_handle`, `revision`,
`receipt_sequence`, `quantity`, `unit_price`, optional
raw integer `auxiliary`, and dense `tiers` and `history` arrays. Tiers are
`{price, quantity}` records, sorted by ascending price; `quantity` is their summed
supply and `unit_price` is the lowest tier price, or zero when no tiers exist.
Each array contains at most 128 records. Common item fields include optional
`catalog_key`; unavailable detail can omit its identity handles and metadata.
A usable quote requires `status="ready"` and a
current handle; a non-ready record's numbers are not a price authorization.
Detail does not include row/order handles, favorite flags, claim fields, or
other row-only fields. The numeric quote fields and both arrays are present
even while detail is unavailable; zero and empty arrays in that state do not
prove zero supply or a completed search.

History rows contain `date`, `raw0`, `raw1`, `raw2`, and `raw3`. Captured records
also expose the known price aliases `minimum=raw0`, `maximum=raw1`, and
`median=raw2`, in integer credits. These describe the individual client history
record; Core does not compute a new aggregate from the array. `raw3` and the
separate `auxiliary` value remain uninterpreted raw values. Date is an unconverted
client datetime value with unknown epoch/units; do not treat it as Unix time.

#### Sale quote

`sale` contains `status`, optional sale `quote_handle`, `revision`, optional
inventory `item_handle`, `bag_slot`, `quantity`, `buyer_price`, `seller_price`,
`tax`, `hours`, and `fee`. Buyer price, seller price, and tax are per unit; the
listing fee is for the quoted listing. Only a ready current quote authorizes
[`sell`](../gtn.md#gosgtnsellquote_handle). Core rechecks the selected full stack, bag
contents, warning state, price, duration, fee, wallet, and sale-slot capacity.
Its numeric fields remain present in non-ready records; check the status and
handle rather than treating zero values as a usable listing quote.

## Related documentation

[Full galactic trade network contract](../gtn.md)
