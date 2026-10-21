# API reference

**API version: `1.0.0`**

**Source review: 2026-10-21**

Find a callable by namespace or exact name. Each page explains its parameters, return values and usage.

## Runtime

[Shared contracts and examples](runtime.md)

| Callable | Purpose |
| --- | --- |
| [`gos.on_tick`](symbols/gos-on-tick.md) | Register bounded work on the update scheduler; optional interval_ms controls cadence. |
| [`gos.time_ms`](symbols/gos-time-ms.md) | Read monotonic milliseconds for elapsed time, not wall-clock time. |

## World and units

[Shared contracts and examples](world.md)

| Callable | Purpose |
| --- | --- |
| [`gos.actor_names`](symbols/gos-actor-names.md) | Read a bounded, epoch-checked snapshot of retained actor names without live-unit lookup. |
| [`gos.target.cancel`](symbols/gos-target-cancel.md) | Cancel an owned target request only while it is still queued. |
| [`gos.target.select`](symbols/gos-target-select.md) | Request an intentional persistent selected-target change; confirm it in a later snapshot. |
| [`gos.target.status`](symbols/gos-target-status.md) | Observe an owned target-selection request without replaying it. |
| [`gos.world`](symbols/gos-world.md) | Acquire the current generation-bound world and its optional player and target. |
| [`unit:basis`](symbols/unit-basis.md) | Read the current normalized yaw basis with forward, right and up axes, or nil. |
| [`unit:combat_style`](symbols/unit-combat-style.md) | Read a stable lowercase combat-style key, or nil. |
| [`unit:discipline`](symbols/unit-discipline.md) | Read the observed display discipline, or nil. |
| [`unit:distance`](symbols/unit-distance.md) | Current distance in game-world units, or nil; multiply by 10 for metres. |
| [`unit:handle`](symbols/unit-handle.md) | Get an opaque identity that can be resolved in a fresh world; do not parse it. |
| [`unit:hp`](symbols/unit-hp.md) | Read observed health and optional percentage, or nil. |
| [`unit:is_current_target`](symbols/unit-is-current-target.md) | Test whether this current unit is the selected target. |
| [`unit:is_local_player`](symbols/unit-is-local-player.md) | Test whether this current unit is the local player. |
| [`unit:is_on_screen`](symbols/unit-is-on-screen.md) | Read whether this unit has a current on-screen observation. |
| [`unit:item_rating`](symbols/unit-item-rating.md) | Read the prepared overall equipped item rating, or nil when unavailable. |
| [`unit:name`](symbols/unit-name.md) | Read the observed display name, or nil. |
| [`unit:position`](symbols/unit-position.md) | Read game-world coordinates for this observation, or nil. |
| [`unit:reaction`](symbols/unit-reaction.md) | Read friendly, neutral, hostile or unclassified relationship. |
| [`unit:resource`](symbols/unit-resource.md) | Read observed resource, kind and optional percentage. |
| [`unit:rotation`](symbols/unit-rotation.md) | Read current character yaw in radians, or nil when its prepared pose is unavailable. |
| [`unit:screen_position`](symbols/unit-screen-position.md) | Read a current projected top, center or bottom unit anchor in pixels; return nil when unavailable. |
| [`unit:speed`](symbols/unit-speed.md) | Read available velocity magnitude, or nil. |
| [`unit:target`](symbols/unit-target.md) | Read this unit's observed target and target-observation availability. |
| [`unit:toughness`](symbols/unit-toughness.md) | Read the observed toughness label and number, or nil. |
| [`unit:type`](symbols/unit-type.md) | Read the canonical unit classification, including unknown. |
| [`unit:velocity`](symbols/unit-velocity.md) | Read available velocity in game-world coordinate units, or nil. |
| [`world:presence`](symbols/world-presence.md) | Read bounded camera-independent character-roster presence; unknown is not absence. |
| [`world:resolve`](symbols/world-resolve.md) | Resolve an opaque handle in the current world; absent units return nil. |
| [`world:units`](symbols/world-units.md) | Get currently captured units with strict AND-combined filters. |

## Effects

[Shared contracts and examples](effects.md)

| Callable | Purpose |
| --- | --- |
| [`unit:effect`](symbols/unit-effect.md) | Query a named or definition-key-matched aggregate; check readiness and completeness. |
| [`unit:effects`](symbols/unit-effects.md) | Read current effect rows and separately marked presentation-only history. |

## Input

[Shared contracts and examples](input.md)

| Callable | Purpose |
| --- | --- |
| [`gos.input.cursor`](symbols/gos-input-cursor.md) | Read the current cursor in render-viewport pixels without capturing input; unavailable samples omit coordinates. |
| [`gos.input.is_down`](symbols/gos-input-is-down.md) | Read whether a supported keyboard or mouse button is held. |
| [`gos.input.state`](symbols/gos-input-state.md) | Read held and edge state for a key; unrecognized keys are marked unknown. |
| [`gos.input.was_pressed`](symbols/gos-input-was-pressed.md) | Read the shared press edge for this update without consuming it. |
| [`gos.input.was_released`](symbols/gos-input-was-released.md) | Read the shared release edge for this update without consuming it. |

## Settings

[Shared contracts and examples](settings.md)

| Callable | Purpose |
| --- | --- |
| [`gos.settings.get`](symbols/gos-settings-get.md) | Read current settings, enabled/active state and field values. |
| [`gos.settings.register`](symbols/gos-settings-register.md) | Register this script's settings schema at load time, never from a tick. |
| [`gos.settings.set`](symbols/gos-settings-set.md) | Queue a validated update to one of the caller's registered fields. |

## Abilities

[Shared contracts and examples](abilities.md)

| Callable | Purpose |
| --- | --- |
| [`gos.abilities.abandon_command`](symbols/gos-abilities-abandon-command.md) | Query compatibility release eligibility without changing an in-flight command. |
| [`gos.abilities.action_slots`](symbols/gos-abilities-action-slots.md) | Read an array of observed on-bar abilities; availability is reported by loadout. |
| [`gos.abilities.can_cast`](symbols/gos-abilities-can-cast.md) | Check current readiness and supported local conditions without owning a command. |
| [`gos.abilities.cast`](symbols/gos-abilities-cast.md) | Queue one asynchronous action. Queued does not mean activated. |
| [`gos.abilities.command_status`](symbols/gos-abilities-command-status.md) | Read command lifecycle, activation evidence, cleanup and observed outcome. |
| [`gos.abilities.cooldown_duration`](symbols/gos-abilities-cooldown-duration.md) | Read observed total cooldown in seconds, or nil when unavailable. |
| [`gos.abilities.cooldown_remaining`](symbols/gos-abilities-cooldown-remaining.md) | Read observed remaining cooldown in seconds, or nil when unavailable. |
| [`gos.abilities.current_cast`](symbols/gos-abilities-current-cast.md) | Read current cast identity and optional timing, or nil. |
| [`gos.abilities.gcd_remaining`](symbols/gos-abilities-gcd-remaining.md) | Read remaining global cooldown in seconds, or nil. |
| [`gos.abilities.info`](symbols/gos-abilities-info.md) | Read one local ability row by name or opaque ability handle. |
| [`gos.abilities.is_casting_or_channeling`](symbols/gos-abilities-is-casting-or-channeling.md) | Read the current busy observation; named cast details can be independently unavailable. |
| [`gos.abilities.is_ready`](symbols/gos-abilities-is-ready.md) | Read the local ability-row readiness flag, not target-specific cast admission. |
| [`gos.abilities.loadout`](symbols/gos-abilities-loadout.md) | Read local loadout identity, known abilities and talents, and availability flags. |
| [`gos.abilities.release_command`](symbols/gos-abilities-release-command.md) | Request safe cancellation; a rejected cancellation does not release ownership. |

## Combat events

[Shared contracts and examples](events.md)

| Callable | Purpose |
| --- | --- |
| [`gos.events.casts`](symbols/gos-events-casts.md) | Read current cast/channel presentation observations, not a history stream. |
| [`gos.events.combat`](symbols/gos-events-combat.md) | Consume ordered combat events using a retained cursor, with loss and backlog reporting. |
| [`gos.events.instants`](symbols/gos-events-instants.md) | Read current instant-action observations, not a history stream. |

## Overlay

[Shared contracts and examples](overlay.md)

| Callable | Purpose |
| --- | --- |
| [`gos.overlay.draw_bar`](symbols/gos-overlay-draw-bar.md) | Draw a bounded bar at a shared screen, world or unit PointSpec. |
| [`gos.overlay.draw_circle`](symbols/gos-overlay-draw-circle.md) | Draw a screen-radius or world-radius circle at a shared PointSpec. |
| [`gos.overlay.draw_image`](symbols/gos-overlay-draw-image.md) | Draw an image at a shared screen, world or unit PointSpec. |
| [`gos.overlay.draw_line`](symbols/gos-overlay-draw-line.md) | Draw a line between independent screen, world or unit PointSpecs. |
| [`gos.overlay.draw_rect`](symbols/gos-overlay-draw-rect.md) | Draw a rectangle at a shared screen, world or unit PointSpec. |
| [`gos.overlay.draw_rectangle`](symbols/gos-overlay-draw-rectangle.md) | Alias draw_rect at a shared screen, world or unit PointSpec. |
| [`gos.overlay.draw_text`](symbols/gos-overlay-draw-text.md) | Draw text at a shared screen, world or unit PointSpec. |
| [`gos.overlay.interact`](symbols/gos-overlay-interact.md) | Refresh a screen interaction rectangle and read mouse interaction state. |
| [`gos.overlay.unit_label`](symbols/gos-overlay-unit-label.md) | Add or refresh a temporary unit-anchored label. |
| [`gos.overlay.viewport`](symbols/gos-overlay-viewport.md) | Read exact viewport dimensions only when available. |

## Logging

[Shared contracts and examples](logging.md)

| Callable | Purpose |
| --- | --- |
| [`gos.log.debug`](symbols/gos-log-debug.md) | Write a debug-level message to this script's log. |
| [`gos.log.error`](symbols/gos-log-error.md) | Write an error-level message to this script's log. |
| [`gos.log.info`](symbols/gos-log-info.md) | Write an info-level message to this script's log. |
| [`gos.log.success`](symbols/gos-log-success.md) | Write a success-level message to this script's log. |
| [`gos.log.warn`](symbols/gos-log-warn.md) | Write a warning-level message to this script's log. |
| [`gos.log.write`](symbols/gos-log-write.md) | Write one structured log message with an optional level, tag and color. |
| [`print`](symbols/print.md) | Log at info level. Returns no values. |

## Modules and files

[Shared contracts and examples](files.md)

| Callable | Purpose |
| --- | --- |
| [`DeleteFile`](symbols/deletefile.md) | Remove one file or empty directory without recursion; false without an error means nothing was removed. |
| [`DownloadFileAsync`](symbols/downloadfileasync.md) | Perform a blocking load-time download; the optional callback runs synchronously. |
| [`FileExist`](symbols/fileexist.md) | Test for a regular file in an approved root; a missing file returns false without an error. |
| [`GetFromWebOrLocal`](symbols/getfromweborlocal.md) | Ensure a local file exists, downloading only on a cache miss; returns a boolean, not contents. |
| [`ListFiles`](symbols/listfiles.md) | List immediate regular-file names with optional exact extension filtering and truncation reporting. |
| [`MakeDirectory`](symbols/makedirectory.md) | Create approved directories; false without an error can mean they already exist. |
| [`ReadFile`](symbols/readfile.md) | Read binary-safe file contents, or nil and an error. |
| [`UnzipArchive`](symbols/unziparchive.md) | Extract a validated ZIP at load time within sandbox and size limits. |
| [`WriteFile`](symbols/writefile.md) | Write or append bytes in approved roots, creating missing parent directories. |
| [`gos.file.delete`](symbols/gos-file-delete.md) | Remove one file or empty directory without recursion; false without an error means nothing was removed. |
| [`gos.file.download_async`](symbols/gos-file-download-async.md) | Perform a blocking load-time download; the optional callback runs synchronously. |
| [`gos.file.exists`](symbols/gos-file-exists.md) | Test for a regular file in an approved root; a missing file returns false without an error. |
| [`gos.file.get_from_web_or_local`](symbols/gos-file-get-from-web-or-local.md) | Ensure a local file exists, downloading only on a cache miss; returns a boolean, not contents. |
| [`gos.file.list`](symbols/gos-file-list.md) | List immediate regular-file names with optional exact extension filtering and truncation reporting. |
| [`gos.file.mkdir`](symbols/gos-file-mkdir.md) | Create approved directories; false without an error can mean they already exist. |
| [`gos.file.read`](symbols/gos-file-read.md) | Read binary-safe file contents, or nil and an error. |
| [`gos.file.unzip`](symbols/gos-file-unzip.md) | Extract a validated ZIP at load time within sandbox and size limits. |
| [`gos.file.write`](symbols/gos-file-write.md) | Write or append bytes in approved roots, creating missing parent directories. |
| [`gos.import`](symbols/gos-import.md) | Load a sandbox Lua module cached per top-level script environment. |
| [`import`](symbols/import.md) | Load a sandbox Lua module cached per top-level script environment. |
| [`require`](symbols/require.md) | Load a sandbox Lua module cached per top-level script environment. |

## Inventory

[Shared contracts and examples](inventory.md)

| Callable | Purpose |
| --- | --- |
| [`gos.inventory.bag`](symbols/gos-inventory-bag.md) | Read occupied carried-bag slots and optional item metadata. |
| [`gos.inventory.materials`](symbols/gos-inventory-materials.md) | Read prepared Materials storage totals and available names. |
| [`gos.inventory.snapshot`](symbols/gos-inventory-snapshot.md) | Read the bag and Materials subtables from one prepared inventory snapshot. |
