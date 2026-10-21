---
name: new-feature
description: Turn a user intent into tracked work in this harness. Use when the user describes something to build, fix or explore, or asks to add a feature, bug or idea. Creates the feature_list.json entry, and a branch and plan when the work is ready to build.
---

# New feature

1. **Clarify just enough.** Restate the intent in one or two
   sentences. Ask only questions whose answers change what gets
   built; take sensible defaults for the rest and say so.
2. **Classify** (`harness/docs/FEATURES.md`): `idea` if it isn't
   designed yet, `bug` for a defect, `implementation` when it is
   ready to build.
3. **Write the entry** in `harness/feature_list.json`:
   kebab-case `id`, `behavior` (what, why, and the decisions made
   so far), `verification` (commands or exact Play-mode steps),
   `state: "not_started"`.
4. **Ideas stop here.** Add a line to `harness/progress.md` and
   report back.
5. **Multi-PR work gets a plan.** Copy `harness/plans/_TEMPLATE.md`
   to `harness/plans/<id>.md`, fill in the problem, targets and
   phases, and discuss it with the user before building. Each phase
   becomes its own entry.
6. **Branch when building starts.** Check git state, then:
   - standalone: `git checkout -b <id>` from the freshly pulled
     mainline
   - inside an epic: `git checkout -b <epic>-<id>` from the previous
     phase's branch (`harness/docs/STACKED_PRS.md`)
   Then set `state` to `active`
   (`harness/scripts/feature-loop.sh update <id> active`).
7. **Measure first** when the work is tuning or balance: get a
   baseline with the project's simulator or tests before changing
   anything, and keep the before/after numbers for the PR.
