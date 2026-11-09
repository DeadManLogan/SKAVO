---
name: start-feature
description: Start (or resume) a roadmap feature for SKAVO. Use when the user says which feature to work on next, says "let's go for feature N", or opens a session without saying what to work on.
---

# Start a feature

1. Read `docs/progress.md`. Identify the feature:
   - If the user named one, use it.
   - If a feature is marked in progress, offer to resume it at its next task.
   - Otherwise ask which feature. Don't guess.
2. Read the docs for the systems this feature touches (see `docs/README.md`) and the relevant code. Trust the code over the docs if they disagree, and say so.
3. Check the open questions in `docs/progress.md`. Raise any that block this feature.
4. Reply with:
   - **Goal:** 1-2 sentences, ending in what the user will see when running the game.
   - **Tasks:** a short numbered list (usually 3-6). Each task ends in something checkable.
   - **Decisions:** only real ones, each with a single recommendation and a one-line reason.
5. Stop and wait for confirmation. Don't write code yet.
6. Once confirmed, add the feature's goal and task list to `docs/progress.md` under a new handoff heading marked "(in progress)", and mark it in progress in the checklist.

Then do one task per turn: write the `.gd` files, give exact editor steps for scenes, signals and settings, say how to verify it, and wait for "next". Tick each finished task off in `docs/progress.md`.

Scope guard: if a task drifts into a later roadmap feature or something out of MVP scope, say so and ask before doing it.
