# Architecture

## Folder layout
```
res://
├── scenes/          .tscn files (main, and later dig_site, tile, popups)
├── scripts/         scripts attached to scenes (rendering, input, UI)
│   ├── grid/        plain GDScript logic classes, no Node dependency
│   └── artifacts/   Artifact Resource script and its loader
├── data/artifacts/  one .tres per artifact
└── art/             PNG exports from the art repo (feature 10), artifacts in art/artifacts/
```
Only folders that contain files are tracked by git.

## Principles

### Logic is separate from rendering
Game rules (bounds, dig state, artifact positions, distances) live in classes under `scripts/grid/` that extend `RefCounted`, not `Node`. Scene scripts own a logic instance, forward input to it, and draw its state.

Why: the rules can be read and tested without running a scene, and rendering can change (placeholder squares now, Aseprite sprites later) without touching them. `RefCounted` frees itself when unreferenced and can't be added to the scene tree by mistake.

### Content is data
Artifacts are a custom `Resource` (`Artifact`: name, era, sprite, blurb) saved as `.tres` files in `data/artifacts/`. `Artifact.load_all()` loads whatever is in that folder, so adding an artifact means adding one file with zero code changes. This is what keeps post-MVP content cheap. See [artifacts.md](artifacts.md).

### Nodes talk through signals
A child emits a signal and its parent (or whoever instanced it) connects to it. Avoid `get_node("../../Something")` style lookups. Parents may call methods on their own children directly. This keeps scenes reusable and their dependencies visible in one place.

Connections are made in the editor (Node dock → Signals) and saved in the parent's scene, as `[connection]` entries in `main.tscn`. The emitter never references the listener: `DigSite` only declares and emits its signals and doesn't know `Main` exists. `emit()` is synchronous. It calls every connected handler right away, in connection order, and returns once they've all run, so the code after `emit()` sees whatever the handlers changed.

### Input: game clicks go through `_unhandled_input`
Godot delivers input in order: `_input`, then GUI (Controls), then `_unhandled_input`. Game clicks (digging) are read in `_unhandled_input`, so any Control under the mouse with **Mouse → Filter = Stop** (the default for `ColorRect`, `Panel`, `Button`) swallows the click first. That's what we want for real UI like the found-artifact popup, which then blocks digging with no extra code. Decorative Controls that cover the grid or the screen (like `Background`) must be set to **Filter = Ignore**, or clicks never reach the game.

### Simplest thing that works
No managers, autoload singletons, event buses or state machines until a feature actually needs one. Each feature adds only what it needs.

## Scene tree (current)
```
Main (Node2D)               scenes/main.tscn, main scene, scripts/main.gd (min window size, side-panel UI)
├── Background (ColorRect)  640x360, #3b2f2a placeholder, Mouse Filter = Ignore
├── DigSite (Node2D)        scenes/dig_site.tscn, at (52, 52); signals → Main
│   └── Tile x64 (Node2D)   scenes/tile.tscn, spawned at runtime
├── Title (Label)           placeholder, at (52, 16)
├── DigsLabel (Label)       at (340, 52), "Digs left: N", text set by main.gd
└── RunOverLabel (Label)    at (340, 80), "Out of digs", hidden until run_ended
```
Children draw in tree order, so Background must stay first. Screen layout: the grid takes x 52–308, and x 308–640 is the side panel (dig counter, run-over message, and the hint later). See [grid.md](grid.md) and [run.md](run.md).
