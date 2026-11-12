# Architecture

## Folder layout
```
res://
├── scenes/          .tscn files (main, and later dig_site, tile, popups)
├── scripts/         scripts attached to scenes (rendering, input, UI)
│   └── grid/        plain GDScript logic classes, no Node dependency
├── data/artifacts/  one .tres per artifact (feature 5+)
└── art/             PNG exports from Aseprite (feature 10)
```
Only folders that contain files are tracked by git.

## Principles

### Logic is separate from rendering
Game rules (bounds, dig state, artifact positions, distances) live in classes under `scripts/grid/` that extend `RefCounted`, not `Node`. Scene scripts own a logic instance, forward input to it, and draw its state.

Why: the rules can be read and tested without running a scene, and rendering can change (placeholder squares now, Aseprite sprites later) without touching them. `RefCounted` frees itself when unreferenced and can't be added to the scene tree by mistake.

### Content is data
Artifacts will be a custom `Resource` (name, era, sprite, blurb) saved as `.tres` files in `data/artifacts/`. The game loads whatever is in that folder, so adding an artifact means adding one file with zero code changes. This is what keeps post-MVP content cheap.

### Nodes talk through signals
A child emits a signal and its parent (or whoever instanced it) connects to it. Avoid `get_node("../../Something")` style lookups. Parents may call methods on their own children directly. This keeps scenes reusable and their dependencies visible in one place.

### Input: game clicks go through `_unhandled_input`
Godot delivers input in order: `_input`, then GUI (Controls), then `_unhandled_input`. Game clicks (digging) are read in `_unhandled_input`, so any Control under the mouse with **Mouse → Filter = Stop** (the default for `ColorRect`, `Panel`, `Button`) swallows the click first. That's what we want for real UI like the found-artifact popup, which then blocks digging with no extra code. Decorative Controls that cover the grid or the screen (like `Background`) must be set to **Filter = Ignore**, or clicks never reach the game.

### Simplest thing that works
No managers, autoload singletons, event buses or state machines until a feature actually needs one. Each feature adds only what it needs.

## Scene tree (current)
```
Main (Node2D)               scenes/main.tscn, main scene, scripts/main.gd (min window size)
├── Background (ColorRect)  640x360, #3b2f2a placeholder, Mouse Filter = Ignore
├── DigSite (Node2D)        scenes/dig_site.tscn, at (52, 52)
│   └── Tile x64 (Node2D)   scenes/tile.tscn, spawned at runtime
└── Title (Label)           placeholder, at (52, 16)
```
Children draw in tree order, so Background must stay first. Screen layout: the grid takes x 52–308, and x 308–640 is reserved for the side panel (hint, dig counter). See [grid.md](grid.md).
