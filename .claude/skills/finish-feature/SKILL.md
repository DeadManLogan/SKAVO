---
name: finish-feature
description: Wrap up a finished SKAVO roadmap feature by verifying it, writing the handoff into docs/progress.md, syncing docs/, and proposing the commit. Use when the user says a feature is done, asks for the handoff, or says to wrap up.
---

# Finish a feature

1. **Verify.** List the run-and-check steps for the feature (F5, what should appear, Output panel clean). If anything isn't confirmed working yet, ask the user to check before continuing.
2. **Handoff.** Replace the feature's "(in progress)" section in `docs/progress.md` with:
   - **Built:** what exists now and what the user sees when running.
   - **Structure:** files and scene trees added or changed.
   - **Decisions:** choices made and the one-line reason for each.
   - **Next feature needs to know:** anything the next roadmap feature depends on.
   Tick the feature in the checklist. Resolve or update open questions.
3. **Docs.** Update the doc for each system the feature touched, and create one for a new system (add it to the table in `docs/README.md`). Describe how it works now, not the history. Update the scene tree in `docs/architecture.md` if it changed.
4. **Commit.** Show `git status`, check that `.godot/` isn't listed and that new `.uid` files are, and propose a commit message (`Feature N: <name>`). Commit and push only when the user says so.
5. **Close.** Tell the user the next feature on the roadmap and suggest a fresh session for it.

Keep the handoff short. It's for the next session, not a changelog.
