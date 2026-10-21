---
title: SWTOR Lua Script Examples - Combat Routines and Addons
description: Learn from Commando, Operative and Sage Lua combat routines, then build a status overlay, process combat events or try a single-action script.
---
# Lua examples

Learn how SWTOR Lua combat routines make healing, movement and proc decisions.
These excerpts from the official class scripts are followed by small addons
and automation examples you can run or adapt.

## Script recipes

| Class | Example | What it does |
| --- | --- | --- |
| Commando / Mercenary | [When to use Supercharge](live-commando-supercharge.md) | Time the heal reset and build the last stacks without running out of energy |
| Operative | [Cursor Holotraverse](live-operative-holotraverse.md) | Choose a destination by aiming near its body center |
| Operative / Medicine | [Kolto Probe upkeep](live-operative-probes.md) | Keep two stacks and refresh them before they expire |
| Sage / Seer | [Predict who needs healing next](live-seer-triage.md) | Estimate future health and seconds until death from incoming damage |
| Sage / Sorcerer | [Presence of Mind and proc prediction](live-sage-pom-prediction.md) | Learn Throw tick timing, check PoM stacks and track Telekinetics' Tidal Force |

Each example explains code from the class script. To run the full published
package, use the [Official Script Library route](../guides/getting-started.md).

## Small scripts

Start with the [installation walkthrough](../guides/getting-started.md#install-and-run-your-first-script).
Each sample below links to its Lua file. Single Action also requires a shared
helper; Bounded History is a module to load from an entry script.

| Sample | Use |
| --- | --- |
| [Status panel](status-panel.md) | Complete read-only entry point with settings |
| [Incoming damage](incoming-damage.md) | Bounded combat-stream reader with gap reporting |
| [Single action](single-action.md) | Hold a key to attempt one configured ability; requires `combat.ability_executor` |
| [Bounded history](bounded-history.md) | Plain Lua module independent of the game API |

See [module authoring](../guides/module-authoring.md) to turn shared logic into your own module.
