# gos.inventory.presentation

Read prepared bag-grid geometry, item cells, identity, visibility and currentness.

## Signature

```text
gos.inventory.presentation()
```

## Contract and usage

Read the player's carried bag, equipped gear, Materials storage, and prepared
character stats during a tick. Compare observed item contributions without
equipping an item. These functions are read-only: they do not equip gear,
transfer bank/storage items, or operate companions. The separate
[GTN interface](../gtn.md) can use current carried-bag identities for sell listings.

`snapshot`, `bag`, `materials`, `equipped`, `player_stats`, and `presentation`
take no arguments; extra arguments raise a Lua error. `compare` requires exactly
two integer slot arguments. The bag/equipment/stat queries use the prepared
snapshot for the current Lua tick, rather than forcing a client refresh.
`presentation` reads an independently updated native UI publication.
Returned tables can be retained as history, but are not live views.

Bag, equipped, and Materials items with known catalog identity expose `catalog_key`:
`itemdef:` followed by 16 uppercase hexadecimal digits. This key is stable across
processes and matches the same GTN catalog item. It is descriptive data, never a
replacement for a current item or prototype handle when submitting commands.

### `gos.inventory.presentation()`

Reads prepared native bag-icon geometry in **render-viewport pixels**. It covers
the standalone inventory (`view_id=1`) and the bag embedded in the character
sheet (`view_id=2`), not equipped-slot rectangles or bank layouts. It does not
open a window, click a slot, or refresh the semantic inventory capture.

When the publication is absent or belongs to a different player/session, only
`{status="unavailable"}` is returned; even `current` is absent in that case.
For a matching owner, diagnostic identity fields are returned before readiness:

```text
{
  status = "pending" | "ready" | "unavailable", current = boolean,
  owner = "unit:...", session_generation = integer,
  revision = integer, sampled_ms = integer, age_ms = integer | nil,
  reason = "ready" | "no_window" | "other_tab" | "hidden_movie" |
    "binding_changed" | "invalid_viewport" | "cell_unavailable" | "unknown",
  binding_revision = integer, ui_sequence = integer,
  view_id = integer, cell_count = integer, failed_slot = integer | nil,
  visible = boolean | nil, viewport_width = integer | nil, viewport_height = integer | nil,
  grid_rect = {x = number, y = number, width = number, height = number} | nil,
  rows = {
    {slot = integer, handle = "item:..." | nil, empty = boolean,
     visible = boolean, hovered = boolean,
     x = number, y = number, width = number, height = number}, ...
  } | nil
}
```

`visible`, viewport dimensions, `grid_rect`, and the dense `rows` array exist
only when `status="ready"`. Rows include verified empty cells: `empty=true`
has no item `handle`. Match the physical `slot` and current semantic item
`handle` before attaching a screen-space annotation. The publication is bounded
to 512 cells, with per-cell visibility and hover observations.

Require `status="ready"`, `current=true`, and suitable window/row visibility
before using raw rectangles. Ready geometry can become stale independently of
inventory revisions; retained coordinates are never a live UI binding. In the
current implementation, `current` also requires a matching live owner/session,
valid UI binding, and a native sample no older than 100 ms. Use `age_ms` for the
native UI sample age rather than subtracting this timestamp from a different
clock. Item-bound annotations have their separate
[`gos.overlay.inventory_marker`](../overlay.md) contract.

## Related documentation

[Full inventory contract](../inventory.md)
