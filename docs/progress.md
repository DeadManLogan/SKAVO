# Progress log

- [x] 1. Godot project setup
- [x] 2. Grid and dig-site scene
- [x] 3. Tile digging (click to dig)
- [x] 4. Dig limit and run-end state
- [x] 5. Artifact data definition (Resource)
- [x] 6. Artifact placement (random burial)
- [ ] 7. Artifact discovery on dig
- [ ] 8. Closest-artifact hint
- [ ] 9. Found-artifact popup
- [ ] 10. Placeholder-to-final art pass
- [ ] 11. Run-end summary screen
- [ ] 12. Restart / new run

## Open questions
- Artifact sprite size: 32x32 or 64x64 (shown at 1x or 2x in the popup). Decide before the art pass (feature 10). Terrain tiles stay 32x32.

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

### 4. Dig limit and run-end state
**Built:** Each run gets 12 digs. The side panel shows "Digs left: N", which counts down with each dig. At 0, "Out of digs" appears and clicks on the grid do nothing.

**Structure:**
```
scripts/grid/dig_grid.gd   + dig_limit (3rd _init arg), digs_left(); dig() refuses at 0
scripts/dig_site.gd        + DIG_LIMIT = 12, signals digs_left_changed(digs_left: int), run_ended
scripts/main.gd            + refs to DigSite and labels, signal handlers, _show_digs_left()
scenes/main.tscn           + DigsLabel (340, 52), RunOverLabel (340, 80, hidden); both DigSite signals connected to Main
```

**Decisions:**
- The limit lives in `DigGrid`, and `digs_left()` is `dig_limit - _dug.size()`, so there's no second counter to keep in sync.
- `DigSite` emits signals and `Main` owns the labels, so DigSite stays UI-free. `run_ended` is the hook for the feature 11 summary.
- Main sets the starting counter text in `_ready()` from `grid.digs_left()`, so 12 is only written in `DIG_LIMIT`.
- Signals are connected in the editor and saved in `main.tscn`.
- The run-end display is just a label. Summary is feature 11, restart is feature 12.

**Next feature needs to know (5, artifact data):**
- Feature 5 is independent of the run state: a `Resource` script and `.tres` files in `data/artifacts/`, and no scene changes are needed.
- Later features: `_try_dig` is where a successful dig happens (discovery in 7, hint in 8). Side-panel labels start at x 340, with the counter at y 52 and the run-over message at y 80. Put the hint (8) below those.
- Restart (12) needs a fresh `DigGrid` and tiles reset, plus `RunOverLabel` hidden again.

### 5. Artifact data definition (Resource)
**Built:** an `Artifact` Resource and the 10 Roman-era artifacts as `.tres` files. At F5, the Output panel lists all 10 (name, era, `sprite: false`). There's no on-screen change.

**Structure:**
```
scripts/artifacts/artifact.gd   Artifact (Resource): name, era, sprite: Texture2D, blurb (multiline); DIRECTORY; static load_all() -> Array[Artifact]
data/artifacts/*.tres           10 artifacts: amphora_handle, denarius, fibula, gaming_die, oil_lamp,
                                sigillata_sherd, sling_bullet, strigil, stylus, unguentarium
scripts/main.gd                 + TEMP _print_artifacts() called from _ready()
docs/artifacts.md, art-brief.md new
```

**Decisions:**
- `load_all()` uses `ResourceLoader.list_directory()`, not `DirAccess`, so it keeps working in exports where `.tres` files are remapped. Results are sorted by file name, and anything that isn't an `Artifact` is skipped with a warning.
- A `.tres` is the definition of a kind of find. `load()` caches, so all references share one instance, and per-run state (cell, found) never goes in the Resource.
- `era` is a display `String`. There's no `id`, because the file path is unique. Fields added later load with their default value in existing files.
- Blurb voice: a humorous archaeologist talking to a class, about 300 characters, covering what the object is, how it was used and one fun fact.
- The art is made in a separate art repo from [art-brief.md](art-brief.md), one 32x32 PNG per artifact named the same as its `.tres`, placed in `art/artifacts/`. `sprite` stays `null` until feature 10.
- Denarius was made in the editor. The other 9 were hand-written and have no `uid=` in their header yet. Godot adds one when each is saved in the editor, and nothing references them by UID.

**Next feature needs to know (6, artifact placement):**
- `Artifact.load_all()` returns the 10 artifacts. Call it once per run and bury each in a random undug cell.
- Burial positions are per-run state. Store them in the grid logic (`scripts/grid/`), for example as a `Dictionary[Vector2i, Artifact]` alongside `_dug`. Keep them out of the Resource.
- Remove the TEMP `_print_artifacts()` from `main.gd` once placement uses `load_all()`.
- The MVP has 10 artifacts on 64 cells with 12 digs. Placement must not assume the artifact count, because content will be added later.

### 6. Artifact placement (random burial)
**Built:** Each run buries 10 artifacts in 10 different random cells. Each cell gets an independent random pick, so duplicates can happen. Nothing changes on screen. F5 prints a TEMP burial map (`X`/`.` grid plus `(x, y) name` lines) to the Output panel. Digs per run and artifacts per run can be set in the Inspector on DigSite in `main.tscn`.

**Structure:**
```
scripts/grid/dig_grid.gd   + _buried: Dictionary[Vector2i, Artifact], bury(artifacts, count), artifact_at(cell), _undug_cells()
scripts/dig_site.gd        DIG_LIMIT const -> @export dig_limit (12); + @export artifacts_per_run (10);
                           _ready() buries Artifact.load_all(); + TEMP _print_burial_map()
scripts/main.gd            - TEMP _print_artifacts()
.claude/skills/start-feature/SKILL.md   + rule: export tuning values
```
No scene changes.

**Decisions:**
- Duplicates allowed (`pick_random()` per cell): a design choice, and weighted picks for rarity later only change `bury()`.
- Distinct cells via `shuffle()` + first `count`: no retry loop.
- `count` is an argument, so `DigGrid` doesn't assume the pool size. Too many → bury what fits and `push_warning()`.
- Global RNG, no seed. `bury()` is separate from `_init`.
- Tuning values are `@export` on DigSite. `GRID_SIZE` stays `const` because the layout assumes a 256 px grid.
- Balance (12 digs, 10 artifacts) stays for the MVP, to be tuned after feature 8. See [run.md](run.md#balance).

**Next feature needs to know (7, artifact discovery):**
- After `grid.dig(cell)` returns `true` in `DigSite._try_dig`, `grid.artifact_at(cell)` tells you what was found (`null` for nothing).
- "Found" can be derived: a buried cell that's also dug. No separate found set is needed, the same way `digs_left()` comes from `_dug`. Feature 8's "unfound artifacts" are the buried cells that aren't dug.
- Emit a signal (for example `artifact_found(artifact, cell)`) for the popup in feature 9. Main or a temporary label can show it until then.
- The TEMP `_print_burial_map()` stays until feature 8 is done. Use it to find artifacts to dig while testing.
- Bump **Dig Limit** in the Inspector to test more finds per run.
