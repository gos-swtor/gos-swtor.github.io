# Galactic Trade Network

Use `gos.gtn` with the game's GTN already open. Reads use the prepared snapshot
for the current Lua tick; they do not synchronously refresh the game. Check each
record's `status`. Missing optional values mean unknown, including prices,
capacity, and confirmation state.

Commands return a command-handle string when accepted, or `nil, reason` when
submission is refused. Acceptance is not completion. Retain the handle and use
[`gos.gtn.command`](#gosgtncommandcommand_handle) until it becomes terminal.
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
search proof described under [search history identity](#search-history-identity).

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

`filter` has the same keys as [`search`](#gosgtnsearchfilter). It records the
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
[`sell`](#gosgtnsellquote_handle). Core rechecks the selected full stack, bag
contents, warning state, price, duration, fee, wallet, and sale-slot capacity.
Its numeric fields remain present in non-ready records; check the status and
handle rather than treating zero values as a usable listing quote.

### Search history identity

GTN items, detail items, Bag items and Materials items expose `catalog_key` when
their catalog identity is known: `itemdef:` followed by 16 uppercase hexadecimal
digits. Equal catalog items keep the same key across processes. Distinct item
definitions remain distinct, including Refined versus Processed stabilizers.
The key identifies data and cannot authorize a trade or replace a current handle.

Owned search proof requires observation of a clean search state before the
first GTN query. Load Core before the first GTN search in a fresh game launch;
the initial Buy view may already exist provided it has not searched. A pending
query blocks another owned query. Overlapping queries, invalid replies, or lost
evidence can make attribution unavailable until a fresh game launch establishes
a clean search state. Closing/reopening GTN or switching characters does not
clear that ambiguity. `history_reason` explains this boundary; Core does not
guess from names, timestamps, or whichever results happen to be visible.
An observed unowned update can replace the current result and invalidate an
older owned proof while search attribution itself remains available. Neither
manual results nor later updates acquire an earlier command's ownership.

Completed owned searches and their owned Buy page commands can expose
`search_result` on the command. It contains `mode` (`search`, `favorites`, `popular`, `recent`),
`view_revision`, `receipt_sequence`, `heading_sync` and `local_empty`. Match its
revision and receipt to the Buy snapshot before recording. The record is retained
with the command, not reconstructed when polled. An unrelated current view has
no owned proof. Replaced or ambiguous responses cannot complete an owned search.

The game's search heading is updated using the accepted query/category or
localized quick-search label. `heading_sync` is `succeeded`, `failed` or
`unavailable`. A failed heading update rejects the command with its observed
proof and an explicit reason; it is
not an unresolved economic transaction. Refused sends do not relabel old results.

Paging and sorting operate on the existing client result set. They retain its
server receipt while changing the view revision. An owned Buy page can expose
the inherited `search_result` only to the same submitting script instance and
while its search remains attributable. Sort commands do not expose that field.
Deduplicate history by item
within a response, not by receipt alone, so new pages are retained and sorting
does not duplicate observations. Known zero Favorites instead has
`local_empty=true`, `receipt_sequence=0`, and a fresh verified empty view. It
requires no server receipt and creates no item-price observation.

### `gos.gtn.refresh()`

Queues a fresh capture of the current buy model and GTN header, and restarts
failed catalog capture through the same primary source. Takes no arguments and
returns an owned command handle or `nil, reason`. This is a non-economic command;
it does not retry a purchase, listing, cancellation, or claim.

Command success means one fresh capture returned. Catalog discovery proceeds in
bounded chunks and may still be pending afterward; use
`snapshot.catalog.status=="ready"` before ordinary search or listing quotes.
An unavailable primary catalog source remains unavailable until a later explicit
refresh or GTN becoming ready again retries it. Missing values are never replaced by
invented catalog entries or defaults.

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

### `gos.gtn.popular()`

Queues the client's popular-items search. Takes no arguments and returns a
command handle or `nil, reason`. Its completed results replace the buy view;
they do not represent full-market coverage. Search readiness/throttling applies.

### `gos.gtn.recent()`

Queues the client's recently-listed search. Takes no arguments and returns a
command handle or `nil, reason`. Wait for completion before using its fresh buy
rows. Search readiness/throttling applies.

### `gos.gtn.favorites()`

Queues the client's favorites search. Takes no arguments and returns a command
handle or `nil, reason`. Favorites use the buy view and current client entitlement
and slot limits. A favorite may remain in results without an available listing.

When the favorite count is known to be zero, the client can finish locally
without requesting server results. Core can complete the command after a fresh
ready empty buy capture in Favorites mode confirms that state. In this case
`command.receipt` can be absent and `receipt_sequence` can remain zero; neither
value alone indicates failure. Use the command's state and reason. Ordinary
searches, popular/recent queries, and nonempty Favorites still require fresh
server-result evidence for search completion.

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

### `gos.gtn.page(view, page)`

Queues a page change for one of the four view names accepted by
[`sort`](#gosgtnsortview-sort-descending). `page` is a one-based integer between
1 and that ready view's `max_page`. Returns a command handle or `nil, reason`.
Core changes the stored page and waits for the current view to reflect it.
Re-fetch row handles afterward.

### `gos.gtn.details(row_handle)`

Requests detail for a current ready buy row and returns a command handle or
`nil, reason`. Item handles and rows from other views are rejected. Wait for the
command to succeed and `snapshot.detail.status=="ready"`, then read its current
purchase `quote_handle`, price tiers, and history. The request prepares the
game's purchase-row selection before sending the native detail request. If that
selection cannot be synchronized or the row changes, the native request is not
sent. The command can already be `dispatched` with a nonzero `dispatched_ms`
while that preparation is pending; those fields alone do not prove it was sent.
The API's completion contract is the matching detail reply; it does not certify
every visual aspect of the game's window.

### `gos.gtn.favorite(row_handle)`

Toggles a current ready buy row's favorite membership. Takes exactly one current
row handle and returns a command handle or `nil, reason`; there is no desired
boolean parameter. Re-read `favorite` after completion. Repeating the command
can reverse the change. Current client eligibility, entitlement, and capacity
still apply; an immediate local checkbox change alone is not completion.

### `gos.gtn.buy(quote_handle, quantity, max_total)`

Queues a purchase from the current ready purchase quote. `quantity` is a positive
integer and `max_total` is an integer credit ceiling. Returns a command handle
or `nil, reason`. Core binds the quote to its current buy row/revision and
revalidates listed quantity, maximum stack, price tiers, wallet, and buy slots.

The current route retains the quoted unit price. It rejects a quantity that
would require a higher-priced tier and rejects integer overflow or
`quantity * unit_price > max_total`. It does not raise the price to fill an order.
Use [`command`](#gosgtncommandcommand_handle) to distinguish full success, a
partial fill, rejection, and an unknown outcome. A successful purchase creates
a purchased-order claim; collecting it is a separate
[`claim`](#gosgtnclaimrow_handle) action.

### `gos.gtn.select_sell(bag_slot, item_handle, quantity)`

Queues selection of an exact current carried-bag stack. `bag_slot` is the
physical one-based slot from `gos.inventory.bag()`, `item_handle` is that bag
row's `handle`, and `quantity` is a positive integer no greater than its known
stack quantity. Returns a command handle or `nil, reason`. A partial selection
can create a different bag stack and item handle. Core waits until it can
attribute the exact selected quantity to the current bag. Array position, GTN
row handles, and prototype handles cannot identify the bag selection.

Wait for the selection command to complete, then use its current selected-stack
fields described under [`command`](#gosgtncommandcommand_handle). Re-read the bag
and `snapshot.selected_item_handle`/`selected_quantity`; do not reuse the source
stack's handle after a split. Quoting uses the complete resulting selected stack.
It is blocked when warning state is unknown or the game requires confirmation.
Resolve that game prompt explicitly; this API does not automatically accept it.

### `gos.gtn.clear_sell()`

Queues clearing the selected sell slot. Takes no arguments and returns a
command handle or `nil, reason`. Completion requires the selection to be
observed clear. This does not cancel an existing sale order.

### `gos.gtn.quote_sell(buyer_unit_price, hours)`

Requests a current listing quote for the confirmed selected full stack.
Both arguments are positive integers; `hours` must be in the current ready
catalog's `durations`. Returns a command handle or `nil, reason`.
The client calculates seller price, buyer tax, and listing fee.
The current `max_buyout_price` cap must be known and admit the quoted unit price;
creating the listing also checks its seller proceeds after the listing fee.

Wait for completion, then inspect `snapshot.sale` and its current sale
`quote_handle`. This call does not create the listing. A changed selection,
bag contents, or required confirmation invalidates quoting. Metadata-only bag
updates do not by themselves change the selected stack's identity.
Accepting a new quote request invalidates the previous sale quote immediately;
a failed replacement quote does not restore the old one.

### `gos.gtn.sell(quote_handle)`

Queues creation of the exact current ready sale quote. Pass
`snapshot.sale.quote_handle`; purchase quotes are rejected. Returns a command
handle or `nil, reason`. Core revalidates the full selected stack, quote and bag
revisions, confirmation state, price, duration, tax, listing fee, wallet, and
sale capacity. A complete current personal-sales baseline is also required;
if it is unavailable, the refusal reason can require closing and reopening the
GTN. Completion requires a matching new server sale together with
the inventory removal and listing-fee change. Submission alone proves none of
those outcomes.

### `gos.gtn.cancel_sale(row_handle)`

Queues cancellation of a current active order from the ready `sales` view.
Returns a command handle or `nil, reason`. Use that row's `row_handle`, not its
order identity string. Completion requires the exact order to leave active
sales and its returned-item claim to be confirmed. Cancellation does not itself
collect that returned item; use a fresh claim row afterward.

### `gos.gtn.claim(row_handle)`

Queues an eligible current row from the ready `purchased` or `sold` view.
Returns a command handle or `nil, reason`. Core checks the order, current claim
validation, and inventory/wallet baselines. Completion requires matching native
claim evidence and reconciled order, inventory, and wallet changes. Item-space
or credit-cap failures must remain failures, not an assumed successful claim.

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
[search history identity](#search-history-identity). It can accompany a search
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

### `gos.gtn.cancel(command_handle)`

Cancels a retained command only while it is queued and owned by this script
instance. Returns `true` when canceled and `false` when it is unknown, foreign,
or already dispatched/terminal. An invalid handle returns `nil, reason`.
This does not undo an economic action or cancel a sale order; those are
different operations. Read [`command`](#gosgtncommandcommand_handle) afterward
when that record remains available.
