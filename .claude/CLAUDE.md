# Project: SKAVO (working title "Dig Site")

## Who I am
I'm a software engineer building this solo in my free time. I know Godot and a bit of Unity, I have an Aseprite license, and I draw my own pixel art. Skip beginner explanations of programming concepts. Explain Godot-specific details when they matter.

## The game
A small, finishable 2D top-down archaeology game. The player digs tiles on a grid to find buried historical artifacts. Each find unlocks a short real-history blurb, with the goal of making players curious enough to look up the era afterward. The game must be complete and fun on its own at MVP, and designed so content can be added later without rewriting code.

## MVP scope (this is all of it)
- One dig site: a Roman-era Mediterranean hillside, 8x8 grid
- 10 artifacts, all the same rarity (no rarity system yet)
- Click a tile to dig it, with a dig limit of about 12 per run
- A hint after each dig: the distance to the closest unfound artifact
- A popup when an artifact is found, with its sprite, name, era and blurb
- Run-end summary and restart

## Explicitly out of scope until MVP is done
Rarity tiers, multiple terrains, tools (brush, pick, etc.), the collection screen, saving, audio, animations beyond a simple hit flash, menus, settings. If I ask for one of these mid-feature, remind me it's post-MVP and ask if I really want to switch.

## Tech
- Godot 4.6, GDScript only, no C#, no plugins unless I ask
- Compatibility renderer, 640x360 viewport, 32x32 px tiles. See [docs/project-setup.md](../docs/project-setup.md)
- Art in Aseprite, exported as PNG. Use placeholder colored squares until the art pass feature
- Artifacts are data: a custom `Resource` (name, era, sprite, blurb) saved as `.tres` files in `res://data/artifacts/`. Adding an artifact should mean adding one file, with zero code changes
- Grid logic lives in plain GDScript classes (`scripts/grid/`), separate from rendering, so the logic can be reasoned about and tested without the scene
- Communicate between nodes with signals, not hard node-path lookups where avoidable

## Feature roadmap (in order)
1. Godot project setup
2. Grid and dig-site scene
3. Tile digging (click to dig)
4. Dig limit and run-end state
5. Artifact data definition (Resource)
6. Artifact placement (random burial)
7. Artifact discovery on dig
8. Closest-artifact hint
9. Found-artifact popup
10. Placeholder-to-final art pass (terrain tiles, 10 artifacts)
11. Run-end summary screen
12. Restart / new run

Current status and handoff notes: [docs/progress.md](../docs/progress.md), imported below.

@../docs/progress.md

## How we work
- Each session is ONE feature from the roadmap. I'll tell you which. If I don't, check `docs/progress.md` and ask.
- At the start, restate the feature's goal in 1-2 sentences and propose a short task list before writing code. I'll confirm or adjust. (`/start-feature` does this.)
- Build only that feature. Don't implement later features "while we're here."
- Go one task at a time and wait for "next" before starting the following task.
- Prefer the simplest approach that works. Pick one recommendation and explain why in a sentence or two, rather than giving me a menu of options. If there's a real tradeoff, say so briefly and still recommend one.
- Write `.gd` files directly. For scenes (`.tscn`), node setup, signal connections and project settings, give me exact Godot editor steps rather than hand-editing those files, because the editor manages UIDs and node IDs. Only hand-edit them if I ask.
- Keep code readable over clever. Small functions, clear names, typed GDScript, minimal comments that explain why, not what.
- Each feature should end in a state where the game runs and I can see the result.
- At the end of the feature, write the handoff into `docs/progress.md`, update or create the relevant doc in `docs/`, and propose the commit. (`/finish-feature` does this.) Don't commit or push unless I say so.

## Docs
`docs/` explains how each part works and why it was built that way. Keep it in sync with the code: when a feature changes how something works, update its doc in the same feature. Code is the source of truth. If a doc and the code disagree, trust the code and fix the doc.
- [docs/README.md](../docs/README.md): index

## Avoid
- Over-engineering: no generic systems, managers, state machines or event buses unless the current feature needs one
- Adding features, polish or "nice to have" extras I didn't ask for
- Refactoring code from previous features unless it blocks the current one (flag it and ask first)
- Giving me multiple alternative implementations to choose from
- Long explanations. Be concise and practical
