# Run

A run is one attempt at the dig site: a fixed number of digs, then the run ends.

## Dig limit
`DigSite.dig_limit` (`@export`, default 12) is passed to `DigGrid.new(width, height, dig_limit)`. `DigGrid` enforces it: `digs_left()` is `dig_limit - _dug.size()`, and `dig()` returns `false` at 0. Deriving the count from the dug cells means there's no second counter to keep in sync, and the rule can be tested without a scene (see [grid.md](grid.md)). `12` appears only as the default of `dig_limit`. Everything else reads `digs_left()`. To test with more digs, change **Dig Limit** on DigSite in `main.tscn`.

## Signals
`DigSite` reports the run state and has no UI code of its own:

| Signal | Emitted | Listener |
|---|---|---|
| `artifact_found(artifact: Artifact, cell: Vector2i)` | After a successful dig on a cell with a buried artifact | `Main._on_dig_site_artifact_found` |
| `digs_left_changed(digs_left: int)` | After every successful dig, including the last | `Main._on_dig_site_digs_left_changed` |
| `run_ended` | Right after the dig that brings `digs_left()` to 0 | `Main._on_dig_site_run_ended` |

All three are emitted from `DigSite._try_dig`, in the order of the table. `artifact_found` comes first, so a find on the last dig reaches its listeners before `run_ended` does. That matters for the popup (feature 9) and the summary (feature 11). Failed digs (already dug, off-grid, no digs left) emit nothing, so `run_ended` fires exactly once per run. The connections are made in the editor and stored in `main.tscn` (see the signals section in [architecture.md](architecture.md)).

## Side-panel UI (`scripts/main.gd`)
Main owns the side-panel labels and updates them from DigSite's signals:

- `DigsLabel` at (340, 52): `"Digs left: %d"`. `_ready()` sets the initial text from `_dig_site.grid.digs_left()`. That works because Godot runs `_ready()` on children before their parent, so DigSite's grid already exists. The label's text in the scene is empty.
- `RunOverLabel` at (340, 80): `"Out of digs"`, hidden in the scene and shown on `run_ended`.
- `FoundLabel` at (340, 108), **TEMP**: `"Found: <name>"` for the latest find, set on `artifact_found`. It's empty in the scene, so nothing shows before the first find. Feature 9's popup replaces it. Remove the node and the `_found_label` code in the same step, because `$FoundLabel` fails at load if the node is gone and the code isn't.

Labels default to Mouse Filter = Ignore, and the side panel (x 308–640) doesn't overlap the grid, so neither label affects clicks.

## Balance
Two numbers set how generous a run is: `DigSite.dig_limit` (12) and `DigSite.artifacts_per_run` (10, on 64 cells). Both are `@export`, so they can be tuned in the Inspector. Digging at random finds 12 × 10/64 ≈ 1.9 artifacts per run. The closest-artifact hint (feature 8) should push that to roughly 4–6, which is the target: every run finds something, and clearing the site is rare. Both numbers stay as they are for the MVP. Tune them by playtesting once the hint works, not before, because the hint's distance metric changes how much each miss tells you.

## Later features
- **Run-end summary (11):** listens to `run_ended`. It replaces or extends `RunOverLabel`. Burials can contain duplicates, so it has to decide whether it counts finds or different kinds found.
- **Restart (12):** needs a fresh `DigGrid` (which resets the dug cells, the count and the burials together) followed by a new `bury()`, the tiles reset, and `RunOverLabel` hidden again.
