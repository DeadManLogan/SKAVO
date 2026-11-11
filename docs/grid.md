# Grid

## Cells
A cell is a `Vector2i(x, y)`, with `(0, 0)` at the top-left, `x` to the right and `y` down, the same as Godot's 2D axes. The same type is used everywhere: grid logic, click-to-cell conversion and, later, artifact positions. That avoids converting between representations.

## DigGrid (`scripts/grid/dig_grid.gd`)
The logic side of the grid. `class_name DigGrid`, `extends RefCounted`, no Node or scene dependency.

```gdscript
var grid := DigGrid.new(8, 8)
grid.is_in_bounds(Vector2i(7, 7))  # true
grid.is_in_bounds(Vector2i(8, 0))  # false
```

- `width`, `height`: grid size in cells.
- `is_in_bounds(cell)`: whether a cell is inside the grid. Click handling uses it to ignore clicks off the grid.

It's minimal on purpose. Per-cell state (dug/undug, buried artifact) gets added in feature 3 when digging needs it, not before. `class_name` registers it globally, so no `preload` is needed.

## Tile (`scripts/tile.gd`, `scenes/tile.tscn`)
A `Node2D` that draws one `SIZE` x `SIZE` (32x32) square in `_draw()`, from its origin to (32, 32). The node's position is the tile's top-left corner.

- `base_color` (`@export`, default `#a0805a`): placeholder dirt color, editable in the Inspector.
- In `_ready()` it scales the color's HSV value by a random factor within ±`SHADE_VARIATION` (8%), so neighboring tiles are distinguishable without outlines. It changes `v` rather than multiplying the whole `Color`, because multiplying would also change alpha.
- `_draw()` only runs once per redraw. Any later visual change needs `queue_redraw()`.
- It doesn't draw in the 2D editor view (that would need `@tool`). Use F6 to see it.

`Tile.SIZE` is the single source of truth for tile size.

## DigSite (`scripts/dig_site.gd`, `scenes/dig_site.tscn`)
A `Node2D` that owns a `DigGrid` (`GRID_SIZE` = 8x8) and spawns one Tile per cell in `_ready()`. The tiles exist only at runtime: the saved scene is just the root node, and you can see the tiles in the Remote scene tree while the game runs.

- `cell_to_local(cell) -> Vector2`: `cell * Tile.SIZE`, in DigSite's local space.
- `local_to_cell(pos) -> Vector2i`: the inverse, using `floor` so positions above or left of the grid give negative cells, which `is_in_bounds` rejects. For a mouse click: `local_to_cell(to_local(get_global_mouse_position()))`.

The helpers work in local space, not global, because DigSite is offset in Main. Moving DigSite doesn't affect them.

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
