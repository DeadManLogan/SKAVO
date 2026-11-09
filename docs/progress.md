# Progress log

- [x] 1. Godot project setup
- [ ] 2. Grid and dig-site scene (in progress: tasks 1-2 done, task 3 next)
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
- **Grid placement.** Feature 1 planned the grid on the left of the viewport with the hint and dig counter in a side panel on the right. Feature 2's goal says "centered on screen". Decide before feature 2 task 5 (main scene setup).

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
- Layout plan: the grid on the left of the viewport, the hint and dig counter in a side panel later (see open questions).
- Background color `#3b2f2a` and the Title label are placeholders and can be removed or replaced in feature 2.

**Next feature needs to know:** use the 32 px tiles and Nearest filter already configured, with placeholder colored squares and no real art. The grid logic class goes in `scripts/` as a plain GDScript class, separate from rendering.

### 2. Grid and dig-site scene (in progress)
**Goal:** running the game shows an 8x8 grid of placeholder tiles, backed by a plain GDScript grid class that knows nothing about rendering. No digging yet.

**Tasks:**
1. ~~Folders: `scenes/`, `scripts/grid/`~~ done
2. ~~`DigGrid` (RefCounted): width/height, `is_in_bounds(cell)`~~ done, committed `28e75be`
3. Tile scene (Node2D): one colored square drawn in `_draw()`, slight color variation per tile
4. DigSite scene (Node2D): creates a `DigGrid`, instantiates 64 Tiles, `cell_to_world` / `world_to_cell` helpers
5. Main scene setup: DigSite placed in the viewport (see open questions about placement)

**Decisions so far:** 32x32 tiles confirmed. Per-tile nodes instead of `TileMapLayer`, because they make the hit flash easy later and 64 nodes cost nothing. Details: [grid.md](grid.md).
