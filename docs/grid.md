# Grid

## Cells
A cell is a `Vector2i(x, y)`, with `(0, 0)` at the top-left, `x` to the right and `y` down, the same as Godot's 2D axes. The same type is used everywhere: grid logic, click-to-cell conversion and, later, artifact positions. That avoids converting between representations.

## DigGrid (`scripts/grid/dig_grid.gd`)
The logic side of the grid. `class_name DigGrid`, `extends RefCounted`, no Node or scene dependency.

```gdscript
var grid := DigGrid.new(8, 8, 12)  # width, height, dig limit
grid.is_in_bounds(Vector2i(8, 0))  # false
grid.dig(Vector2i(0, 0))           # true
grid.dig(Vector2i(0, 0))           # false, already dug
grid.is_dug(Vector2i(0, 0))        # true
grid.digs_left()                   # 11
grid.bury(Artifact.load_all(), 10) # 10 random undug cells, each with a random artifact
grid.artifact_at(Vector2i(3, 5))   # an Artifact, or null
```

- `width`, `height`: grid size in cells.
- `dig_limit`: how many digs the run allows. See [run.md](run.md).
- `is_in_bounds(cell)`: whether a cell is inside the grid.
- `is_dug(cell)`: whether the cell has been dug.
- `digs_left() -> int`: `dig_limit - _dug.size()`. Every dug cell used exactly one dig, so there's no separate counter.
- `dig(cell) -> bool`: marks the cell dug. It returns `false` and changes nothing if no digs are left or the cell is out of bounds or already dug, so callers only react to real digs, and off-grid clicks need no separate check.

- `bury(artifacts: Array[Artifact], count: int)`: buries artifacts at run start. See [Burial](#burial).
- `artifact_at(cell) -> Artifact`: the artifact buried in that cell, or `null`.

Dug cells are stored in `_dug: Dictionary[Vector2i, bool]`, used as a set: a cell is dug if it's a key. Burials are stored in `_buried: Dictionary[Vector2i, Artifact]`, keyed by the same `Vector2i`. `DigGrid` is the source of truth for dug state and burials. `class_name` registers it globally, so no `preload` is needed.

### Burial
`bury()` lists the undug cells, shuffles them with `Array.shuffle()`, and puts an artifact in each of the first `count` cells. Each cell gets its own `artifacts.pick_random()` from the full pool, so the same artifact can be buried in several cells. Every pick has an equal chance for each artifact in the pool.

- Cells are distinct: one artifact per cell at most. Shuffling and taking the first `count` never needs a retry, unlike picking random cells until a free one turns up.
- Duplicates are a design choice: a run of 10 picks from a pool of 10 averages about 6.5 different kinds. Rarity tiers (post-MVP) would replace `pick_random()` with a weighted pick, and nothing outside `bury()` changes.
- `count` is a parameter, not a `DigGrid` field. The caller decides how many artifacts a run gets, and the grid logic doesn't assume the pool size.
- If `count` is more than the free cells, it buries as many as fit and calls `push_warning()`. An empty pool buries nothing, also with a warning. Warnings show in the Debugger → Errors tab.
- It uses the global RNG, which Godot 4 seeds randomly at startup, so every run differs. No seed is passed in, because nothing needs reproducible layouts yet.
- It's separate from `_init`, so a grid can be created without artifacts.
- The `.tres` resources are shared instances (see [artifacts.md](artifacts.md)). `_buried` only holds references to them, and run state like "found" is never written into them.

## Tile (`scripts/tile.gd`, `scenes/tile.tscn`)
A `Node2D` that draws one `SIZE` x `SIZE` (32x32) square in `_draw()`, from its origin to (32, 32). The node's position is the tile's top-left corner.

- `base_color` (`@export`, default `#a0805a`): placeholder dirt color, editable in the Inspector.
- `dug_color` (`@export`, default `#4a3628`): placeholder hole color. It's flat, with no shade variation, so neighboring dug tiles read as one pit.
- In `_ready()` it scales the dirt color's HSV value by a random factor within ±`SHADE_VARIATION` (8%), so neighboring tiles are distinguishable without outlines. It changes `v` rather than multiplying the whole `Color`, because multiplying would also change alpha.
- `set_dug()`: sets `_is_dug` and calls `queue_redraw()`. `_draw()` picks the dirt or dug color at draw time, so `set_dug()` works even when it's called before `_ready()`. `_is_dug` only controls the look. `DigGrid` holds the real state.
- `_draw()` only runs once per redraw. Any later visual change needs `queue_redraw()`.
- It doesn't draw in the 2D editor view (that would need `@tool`). Use F6 to see it.

`Tile.SIZE` is the single source of truth for tile size.

## DigSite (`scripts/dig_site.gd`, `scenes/dig_site.tscn`)
A `Node2D` that owns a `DigGrid` and spawns one Tile per cell in `_ready()`. The tiles exist only at runtime: the saved scene is just the root node, and you can see the tiles in the Remote scene tree while the game runs.

`_ready()` creates the grid, buries `Artifact.load_all()` with `artifacts_per_run`, spawns the tiles and prints the burial map.

| Setting | Kind | Default | Why |
|---|---|---|---|
| `dig_limit` | `@export` | 12 | Tuning, change it in the Inspector to test. See [run.md](run.md). |
| `artifacts_per_run` | `@export` | 10 | Tuning, see [run.md](run.md#balance). |
| `GRID_SIZE` | `const` | 8x8 | The layout in `main.tscn` (grid position, side panel at x 308) assumes a 256 px grid, so changing it isn't a simple tweak. |

To change an exported value, select **DigSite** in `main.tscn` and edit it in the Inspector. The value is saved as an override in `main.tscn`, the script keeps the default, and the revert arrow restores it. Exported values are applied before `_ready()`, so the grid uses the Inspector value.

**TEMP:** `_print_burial_map()` prints the grid as `X` (buried) and `.` to the Output panel, then one `(x, y) name` line per buried cell. It's there to test discovery (feature 7) and the hint (feature 8), and gets removed after feature 8.

- `cell_to_local(cell) -> Vector2`: `cell * Tile.SIZE`, in DigSite's local space.
- `local_to_cell(pos) -> Vector2i`: the inverse, using `floor` so positions above or left of the grid give negative cells, which `is_in_bounds` rejects.
- `_tiles: Dictionary[Vector2i, Tile]`: filled in `_spawn_tiles()`, so the clicked cell's tile can be updated.

The helpers work in local space, not global, because DigSite is offset in Main. Moving DigSite doesn't affect them.

### Digging
`_unhandled_input` takes left mouse **presses** (not releases, so a click can't be dragged onto another tile). It converts the click with `local_to_cell(make_input_local(event).position)` and calls `_try_dig(cell)`. When `grid.dig(cell)` returns `true`, `_try_dig` calls `set_dug()` on the tile, emits `digs_left_changed(digs_left)`, and emits `run_ended` if that was the last dig (see [run.md](run.md)). A failed dig emits nothing.

- `make_input_local(event)` transforms the event's own position into DigSite space, including the viewport stretch. It's preferred over polling `get_local_mouse_position()` inside an input handler.
- `_unhandled_input` runs after GUI, so any Control under the mouse with Mouse Filter = Stop takes the click and nothing gets dug. That's intended for blocking UI like the popup. Decorative Controls must be set to Ignore (see [architecture.md](architecture.md)).
- Clicks only line up with the grid at 1x scale or more. `scripts/main.gd` stops the window from shrinking below 640x360 (see [project-setup.md](project-setup.md)).

In `main.tscn`, DigSite sits at (52, 52): the 256 px grid is centered vertically in the 360 px viewport, with the same 52 px margin on the left. x 308–640 is reserved for the side panel.

## Per-tile nodes vs `TileMapLayer`
Tiles are one node each, not cells in a `TileMapLayer`. Both can use the same Aseprite sprite sheet, so this is about structure, not art.

| | Per-tile nodes (chosen) | `TileMapLayer` |
|---|---|---|
| Per-tile effects (hit flash, tweens) | Change `modulate` or tween that node | Awkward: cells aren't nodes, so it needs alternative tiles or overlay nodes |
| Changing a tile's state | Set `frame` on its Sprite2D | `set_cell()` with other atlas coordinates |
| Painting a layout in the editor | No, tiles are spawned in code | Yes, but useless for a generated 8x8 grid |
| Autotiled edges (dug holes blending into the dirt around them) | Manual | Built in with terrain sets |
| Performance | Fine up to thousands of nodes | Batched, scales to huge maps |

The MVP needs per-tile effects and has 64 tiles, so nodes win. **Reconsider only if** the art pass wants autotiled dug-hole edges, or the grid grows a lot. Switching is cheap: only `tile.gd` and `DigSite._spawn_tiles()` touch rendering, and the grid logic doesn't change.

## Art plan (feature 10)
The `_draw()` square is a placeholder. In the art pass, the Tile scene gets a `Sprite2D` child that uses one sprite sheet PNG: a horizontal strip of 32x32 frames (a few undug dirt variants plus a dug frame). Set `hframes` to the frame count and choose a variant with `frame`, which replaces the random shade. From Aseprite: **File → Export Sprite Sheet**, sheet type "Horizontal Strip", no padding.
