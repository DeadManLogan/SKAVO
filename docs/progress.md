# Progress log

- [x] 1. Godot project setup
- [x] 2. Grid and dig-site scene
- [ ] 3. Tile digging (click to dig)
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
