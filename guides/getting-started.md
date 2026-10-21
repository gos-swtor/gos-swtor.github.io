---
title: Install SWTOR Scripts or Write Your First Lua Script
description: Install published SWTOR packages and dependencies through the Official Script Library, or create a local Lua status panel and find its settings and logs.
---
# Your first Lua script

Choose how you want to start:

1. **Use existing scripts.** With Core running, press **Insert**, open
   **Official Script Library**, then press **Refresh**. Choose a published
   script and version and click **Install**. Core installs the package and its
   declared shared dependencies at the required versions. Enable the installed
   script in **Scripts**; shared libraries have no separate entry to enable.
   This is the normal installation route for official packages.
2. **Develop your own script.** The rest of this tutorial teaches creating and
   running your own local Lua entry script, starting with the read-only
   [status panel](../examples/status-panel.md). [Continue below](#install-and-run-your-first-script)
   for the local-file, reload and enable steps.

## Install and run your first script

With GoS:SWTOR Core already running in the game:

1. Press **Insert** to open the Core menu. The **Scripts** list on the left is
   the Lua manager used in this guide.
2. Click **Open Folder** to open the actual configured active-script directory.
   Hovering that button also shows its path. **Folders** shows the **Script
   folder** setting; it selects the parent containing `live` and `common`.
   When that setting is blank, the popup shows **Current:** for the active
   script folder's parent. Use the folder opened by **Open Folder** for entry
   scripts; a development checkout is not required.
3. [Download status-panel.lua](../examples/code/status-panel.lua){: download="status-panel.lua" }
   into that opened folder, or copy the [complete code](../examples/status-panel.md)
   into a plain-text file named `status-panel.lua` there. Check that the saved
   filename ends in `.lua`, not `.lua.txt`. Put it directly in the active folder.
4. Click **Reload** to discover the new file. It appears disabled in **Scripts**.
   Select `status-panel.lua` and click **Enable**, or tick its checkbox in the list.
   The selected script's title becomes **Example: Status Panel** after loading.
5. Open its **Overlay** tab and turn on **Show panel** (on by default). A small
   health label should appear. If the player or health snapshot is unavailable,
   it says **Health: unavailable**. This example never casts or changes targets.
6. Open the selected script's **Log** tab with **INFO** enabled. The example
   logs `SCRIPT_PATH` (its active-script directory) and `COMMON_PATH` (its actual
   shared-module root) once when loaded. Use those values when placing files.
   Do not infer the shared root from a portable script's location.

After editing a saved file, click **Reload** again. Reload recreates callbacks
and module state for enabled scripts. If you deliberately change **Script
folder** in **Folders**, **Apply & Reload** applies that setting and reloads;
it does not move your files.

## Find the script log and fix errors

Select the script, then open **Log**. Load/reload failures appear as **Reload
failed:** above the log; hovering the script's status dot also shows its status
message. Callback errors are **ERROR** entries. An unhandled error disables that
callback until scripts reload: fix the file and click **Reload**.

`print` and `gos.log.info` appear under **INFO**, which also includes **SUCCESS**.
Turn on **DEBUG** to see `gos.log.debug`; it is hidden by default. Keep **ERROR**
enabled and clear **Search logs** when looking for a missing message. The status
panel logs its roots at load time, so it need not draw anything to confirm loading.

**Save** writes the selected script's retained log and reports the saved path.
By default, `status-panel.log.txt` is saved beside `status-panel.lua`; **Folders >
Lua log folder** can configure another location. See [Logging](../api/logging.md)
for the message API. Saved files also include request diagnostics; review the
contents and personal paths before sharing an excerpt.

## Follow the update callback

Settings are registered once when the script loads. A callback is registered with `gos.on_tick`. Each callback reads a fresh world, performs bounded work, and returns. A requested interval is a scheduling cadence, not an exact timer guarantee.

Use `gos.settings.get` inside the callback to read current enablement and values.
Registration is load-time-only. The embedded runtime is **Lua 5.4.8**, with the
sandboxed libraries described in [Runtime and data](runtime.md#lua-environment).
The manager's **General > Lua Version** value is the script's registered settings
version, not the embedded Lua language version.

## Add one feature at a time

Try the [incoming damage counter](../examples/incoming-damage.md) to read combat
events. Then use the [single-action example](../examples/single-action.md) to
learn how to submit an ability and follow its [command status](command-lifecycle.md).
Single Action also needs the [shared ability-executor module](helpers.md#make-the-helper-modules-available);
the status panel needs no helper package.

## Common mistakes

A `GosUnit` belongs to one world generation. Store its handle when identity must survive a tick, then resolve it in a fresh world. An old unit object cannot be reused after its generation changes.

`nil` is unavailable, not zero. `pending` is not absent. A successful queue submission is not proof that an ability started. File and network operations do not belong in a tick callback.

## Where to look next

[Runtime and data](runtime.md) explains snapshot lifetimes and units. Continue
with [module authoring](module-authoring.md), or use the [API reference](../api/index.md)
to look up a particular call. [Forum and contributions](sharing.md) links to
support, the official scripts repository and the contribution workflow.
