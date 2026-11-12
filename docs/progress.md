# Progress log

- [x] 1. Godot project setup
- [x] 2. Grid and dig-site scene
- [x] 3. Tile digging (click to dig)
- [ ] 4. Dig limit and run-end state
- [ ] 5. Artifact data definition (Resource)
- [ ] 6. Artifact placement (random burial)
- [ ] 7. Artifact discovery on dig
- [ ] 8. Closest-artifact hint
- [ ] 9. Found-artifact popup
- [ ] 10. Placeholder-to-final art pass
- [ ] 11. Run-end summary screen
- [ ] 12. Restart / new run

## Open questions
None.

## Handoff notes (newest last)

### 1. Godot project setup
**Built:** Godot 4.6 project `SKAVO`, Compatibility renderer, git with Godot `.gitignore` and `.gitattributes`, pushed to `github.com/DeadManLogan/SKAVO` (`main`). The project runs and shows a background and a title label.

**Settings:** viewport 640x360, window override 1280x720, stretch mode `viewport`, scale mode `integer`, default texture filter Nearest. Tile size 32x32, so the 8x8 grid is 256x256 px. Details: [project-setup.md](project-setup.md).

**Structure:**
```
res://
├── scenes/main.tscn   (Main: Node2D > Background: ColorRect, Title: Label)
├── scripts/
├── data/artifacts/
└── art/
```
`main.tscn` is the main scene. Empty folders aren't tracked by git until they contain files.

**Decisions:**
- Layout plan: the grid on the left of the viewport, the hint and dig counter in a side panel later.
- Background color `#3b2f2a` and the Title label are placeholders.

**Next feature needs to know:** use the 32 px tiles and Nearest filter already configured, with placeholder colored squares and no real art. The grid logic class goes in `scripts/` as a plain GDScript class, separate from rendering.

### 2. Grid and dig-site scene
**Built:** F5 shows an 8x8 grid of tan placeholder tiles on the left of the screen, each a slightly different shade, with the "SKAVO" title above it. The grid is backed by `DigGrid`, which has no rendering code. No interaction yet.

**Structure:**
```
scripts/grid/dig_grid.gd   DigGrid (RefCounted): width, height, is_in_bounds(cell)
scripts/tile.gd            Tile (Node2D): SIZE = 32, draws one square in _draw()
scripts/dig_site.gd        DigSite (Node2D): owns a DigGrid, spawns tiles, cell_to_local / local_to_cell
scenes/tile.tscn           Tile
scenes/dig_site.tscn       DigSite (tiles are spawned at runtime, not saved in the scene)
scenes/main.tscn           Main > Background, DigSite (52, 52), Title (52, 16)
```

**Decisions:**
- 32x32 tiles: big enough for artifact sprites to read clearly.
- One node per tile instead of `TileMapLayer`: per-tile effects (dug look, hit flash) become a change on that node, and 64 nodes cost nothing.
- Grid on the left at (52, 52), with equal left, top and bottom margins. x 308–640 (332 px) is reserved for the side panel.
- `Tile.SIZE` is the single source of truth for tile size. DigSite uses it for cell/position conversion.
- The helpers are `cell_to_local` / `local_to_cell` (DigSite-local space), not "world", because DigSite is offset from the origin.

**Next feature needs to know (3, tile digging):**
- Clicks: convert with `local_to_cell(to_local(get_global_mouse_position()))`, then check `grid.is_in_bounds(cell)`. `local_to_cell` uses floor, so clicks above or left of the grid give negative cells and fail the bounds check.
- `DigGrid` has no per-cell state yet. Dug state goes there.
- DigSite doesn't keep references to its tiles by cell yet. Digging will need that lookup to update the clicked tile.
- `Tile` picks its shade once in `_ready()`. Any visual change needs `queue_redraw()`.

### 3. Tile digging (click to dig)
**Built:** Left-clicking an undug tile digs it, and it turns dark brown (`#4a3628`). Clicking a dug tile or off the grid does nothing. The window can't shrink below 640x360.

**Structure:**
```
scripts/grid/dig_grid.gd   + is_dug(cell), dig(cell) -> bool, _dug: Dictionary[Vector2i, bool] (used as a set)
scripts/tile.gd            + dug_color (@export), set_dug(); _draw() picks dirt or dug color
scripts/dig_site.gd        + _tiles: Dictionary[Vector2i, Tile], _unhandled_input, _try_dig(cell)
scripts/main.gd            new, on Main: sets the window's min size to the viewport size
scenes/main.tscn           Main gets main.gd; Background Mouse Filter = Ignore
```

**Decisions:**
- Clicks are read in `DigSite._unhandled_input`, not with an `Area2D` per tile: one handler, and UI with Mouse Filter = Stop (the popup in feature 9) blocks digging automatically.
- The click position comes from `make_input_local(event).position`, the event's own position in DigSite space, rather than polling the mouse.
- `dig()` returns `false` for out-of-bounds or already-dug cells, so DigSite needs no bounds check of its own.
- `Tile._is_dug` only controls the look. `DigGrid` owns the dug state.
- Background is set to Mouse Filter = Ignore. A full-screen `ColorRect` defaults to Stop and swallowed every click.
- Minimum window size of 640x360: below 1x, integer scaling crops the image and clicks land a row off. Game embedding in the editor is disabled, because the embedded window ignores `min_size` (see [project-setup.md](project-setup.md)).
- No `tile_dug` signal yet, because nothing listens for it.

**Next feature needs to know (4, dig limit and run-end):**
- A successful dig happens in `DigSite._try_dig()`, when `grid.dig(cell)` returns `true`. That's where to count digs and emit a signal (for example `tile_dug(cell)`) for the dig counter UI.
- Run-end must stop digging. The simplest way is a guard in `_try_dig` (or `DigGrid` refusing to dig) once the limit is reached.
- Any new UI Control placed over the grid blocks clicks unless its Mouse Filter is Ignore. Side-panel UI (x 308–640) doesn't overlap the grid.
