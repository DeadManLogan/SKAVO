# Artifacts

Each kind of find is one `.tres` file in `res://data/artifacts/`, an instance of the `Artifact` Resource. The game loads whatever is in that folder, so adding an artifact means adding a file, with no code changes.

## Artifact (`scripts/artifacts/artifact.gd`)
`class_name Artifact`, `extends Resource`. `class_name` registers the type, so it appears in the editor under **Create New → Resource…** and gets an Inspector form for its fields.

| Field | Type | Notes |
|---|---|---|
| `name` | `String` | Shown in the popup. Not the same as the built-in **Resource → Resource Name** further down the Inspector, which stays empty. |
| `era` | `String` | Shown as it's written, for example "Roman Empire, 1st century AD". It's a string, not start and end years, because nothing sorts or filters by date. |
| `sprite` | `Texture2D` | A 32x32 PNG from `art/artifacts/`. It's empty until the art pass (feature 10). |
| `blurb` | `String` (`@export_multiline`) | About 300 characters. See [Writing blurbs](#writing-blurbs). |

There's no `id` field. The file path is unique, and only post-MVP features (saving, the collection screen) would need anything more.

## Loading: `Artifact.load_all() -> Array[Artifact]`
This static function loads every `Artifact` in `Artifact.DIRECTORY`, sorted by file name so the order is the same on every run. Anything in the folder that isn't an `Artifact` is skipped with a warning.

It reads the folder with `ResourceLoader.list_directory()` rather than `DirAccess`. Exported builds convert `.tres` files to binary and remap their file names. `DirAccess` would see the remapped files, while `list_directory()` returns the original resource names, so the same code works in the editor and in an export.

## A definition, not a find
A `.tres` describes a kind of find. It isn't the find in a particular run. `load()` caches resources, so every reference to `denarius.tres` is the same shared object. Per-run state, such as which cell it's buried in or whether it's been found, belongs in the grid logic and is never written into the Resource. Otherwise it would leak into the next run.

## Adding an artifact
1. In the FileSystem dock, right-click `data/artifacts/` → **Create New → Resource… → Artifact**. Name the file in `snake_case`, the same as its PNG, for example `oil_lamp.tres` ↔ `oil_lamp.png`.
2. Fill in the fields in the Inspector, then save with the Inspector's save icon. Ctrl+S saves the open scene, not always a resource you're editing on its own.

The `.tres` files are small text files: a reference to the script plus the values that differ from the defaults. You can also write them by hand, by copying an existing one. A hand-written file without a `uid=` in its header still loads, and Godot writes a UID the next time it's saved in the editor. Nothing references artifacts by UID.

## Adding fields later
A `.tres` stores only the values that differ from the defaults, so adding a field, for example rarity after the MVP, doesn't break existing files. They load with the field's default value, and you set it only where it differs.

## Sprites
The art is made in a separate art repo by a pixel-art agent, from [art-brief.md](art-brief.md). That brief lists the specs: a 32x32 canvas, transparent background, no partial alpha, exported at 1x, and one PNG per artifact named the same as the `.tres`. The PNGs go into `art/artifacts/` and get assigned to each `sprite` field in feature 10. Until then, `sprite` is `null`, and the popup (feature 9) has to handle that.

## Writing blurbs
The voice is an experienced archaeologist with a sense of humor, explaining the find to a class. Use plain words, not technical ones, and keep it to about 300 characters, which fits the popup. Each blurb covers:
- what the object is
- how it was used
- one fun fact that makes the player want to look up the era

The denarius blurb is the reference.

## Current artifacts (MVP)
All 10 are from the Roman-era Mediterranean hillside: `amphora_handle`, `denarius`, `fibula`, `gaming_die`, `oil_lamp`, `sigillata_sherd`, `sling_bullet`, `strigil`, `stylus`, `unguentarium`.
