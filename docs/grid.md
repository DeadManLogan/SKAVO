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

## Rendering (feature 2, in progress)
Planned:
- **Tile** scene (`Node2D`): draws one 32x32 colored square in `_draw()`, with a slight per-tile color variation so the grid is readable.
- **DigSite** scene (`Node2D`): owns a `DigGrid`, instantiates one Tile per cell, and provides:
  - `cell_to_world(cell) -> Vector2`: cell to the tile's local position (`cell * 32`)
  - `world_to_cell(pos) -> Vector2i`: local position to cell, which feature 3's click handling will use together with `is_in_bounds`

**Why per-tile nodes instead of `TileMapLayer`:** a node per tile makes per-tile effects (the hit flash, swapping to a dug texture) a property change on that node. 64 nodes cost nothing. `TileMapLayer` would only pay off for much larger grids.

Update this section when the Tile and DigSite scenes are built.
