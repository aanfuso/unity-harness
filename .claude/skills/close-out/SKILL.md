---
name: close-out
description: End-of-session close-out for this harness. Use when the user wraps up a session, a feature or an epic, or asks to clean up, archive or update progress. Runs the clean-state checklist, archives finished features and updates progress.md.
---

# Session close-out

1. **Check git first.** Run `git status` and
   `git log --oneline -5`; the user may have committed in the
   meantime.
2. **Verify.** Run `harness/scripts/unity-check.sh`. If anything
   fails, report it; don't close out over a red build.
3. **Feature files.** In `harness/feature_list.json`:
   - move every `passing` and `dropped` entry to
     `harness/feature_archive.json`, including ones that changed
     this session (formats per `harness/docs/FEATURES.md`)
   - every `active` or `blocked` entry has its reason and next step
     in `harness/progress.md`
4. **Progress.** Add a short paragraph at the top of "Current State"
   in `harness/progress.md`: what changed, results (numbers if
   measured), open PRs awaiting review, decisions and the next
   step. Move durable decisions to "Key Decisions". Trim entries
   that no longer help a fresh session.
5. **Docs.** Update the `harness/docs/` files and plans touched by
   the work.
6. **Checklist.** Walk `harness/clean-state-checklist.md` item by
   item and say which ones you checked.
7. **Commit.** Commit only if the user asked to, as a single-line
   message (`AGENTS.md` rule 3). If the session's work is under
   review, documentation-only updates go in one commit on top of the
   last PR. Changes that belong to a specific PR go on that PR.
