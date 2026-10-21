# Suggested Subagents and Skills

Subagents and skills to add over time so the agent runs more of the
cycle in `SDLC.md` on its own. Each one packages a step we already
do by hand. Build them in priority order, and only once the manual
version has run a few times.

Subagents live in `.claude/agents/<name>.md` (frontmatter + system
prompt). Skills live in `.claude/skills/<name>/SKILL.md`. The
frontmatter below is a sketch: adjust tools and model to your setup.

General guardrails for every subagent:
- Read `AGENTS.md` first.
- Never merge, never force-push, never install anything, never touch
  `main` or the epic branch.
- Report outcomes faithfully, failures included.
- Return a concise report. Raw logs stay out of the parent context.

---

## Priority: now

### unity-verifier
- **Purpose:** prove a change works.
  - Run recompile and EditMode tests (PlayMode where they exist).
  - Optionally enter Play mode, drive a scripted flow and capture
    screenshots.
- **When:** after every implementation step, and before every PR or
  review reply.
- **Inputs:** what changed; an optional flow to exercise ("open
  settings, toggle mute"); optional capture names.
- **Outputs:**
  - compile status
  - test counts with the names and messages of any failures
  - capture paths
  - console errors
- **Tools:** Bash (Unity CLI), Read.
- **Guardrails:** read-only on source. It never fixes failures
  itself, it reports them. It always stops Play mode before exiting.

```yaml
---
name: unity-verifier
description: Recompile, run Unity tests and optionally capture Play mode; report pass/fail with details. Use after any code or asset change.
tools: Bash, Read
model: sonnet
---
```

### harness-keeper
- **Purpose:** keep the harness true.
  - Update the `feature_list.json` states.
  - Move `passing` and `dropped` entries to `feature_archive.json`
    with stable JSON formatting.
  - Prepend a paragraph to `progress.md`.
  - Run the clean-state checklist.
- **When:** at close-out, after a feature passes, after a decision
  is made, after an experiment is rejected.
- **Inputs:** a short description of what changed or was decided,
  plus numbers.
- **Outputs:** the tracking-file diff (uncommitted) and the
  checklist result.
- **Tools:** Read, Edit, Write, Bash (git status, JSON formatting).
- **Guardrails:**
  - It edits tracking files only and never commits.
  - It preserves other people's uncommitted edits to the same files.
  - It writes the JSON so the diff only shows the moved entry.

```yaml
---
name: harness-keeper
description: Update feature_list/feature_archive/progress and run the clean-state checklist after a state change or at session close-out.
tools: Read, Edit, Write, Bash
model: sonnet
---
```

### experimenter (balance or any metric)
- **Purpose:** run a set of variants against the simulator or a
  report.
  - Work on a scratch branch: run each variant on N seeds, revert,
    and return a before → after table with a verdict.
- **When:** "would X help?", tuning rounds, "try it one more time".
- **Inputs:** the variants (knob → values), seeds, run count, target
  metrics.
- **Outputs:**
  - a table of the variants on the target metrics (e.g. median, p90,
    max, endless)
  - the winner, or "none"
  - optionally, the drop recorded through harness-keeper's
    conventions
- **Tools:** Bash, Read, Edit.
- **Guardrails:**
  - Use a local branch only, with one knob per variant.
  - Revert every change and delete the branch afterwards.
  - Confirm that tests pass on the restored state.
  - Never build the winner; that is the parent's job after the user
    approves.

```yaml
---
name: experimenter
description: Run metric experiments (simulator variants) on a scratch branch, revert, and report a comparison table with a verdict.
tools: Bash, Read, Edit, Write
model: sonnet
---
```

---

## Priority: next

### review-responder
- **Purpose:** read the PR comments on a stack and draft, per
  thread:
  - what the reviewer means
  - options and a recommendation
  - a proposed diff
  - a draft reply
- **When:** the user says "read the comments".
- **Inputs:** PR numbers or a stack id.
- **Outputs:** a numbered discussion list. Nothing is changed or
  posted until the user approves.
- **Tools:** Bash (`gh api`, `gh pr view`), Read.
- **Guardrails:** read-only until approved. After approval, the
  parent (or the subagent with a second brief) applies the change,
  replies and resolves the thread.

```yaml
---
name: review-responder
description: Read PR review threads and draft explanations, options, proposed diffs and replies for user approval. Does not change code or post.
tools: Bash, Read
model: opus
---
```

### pr-stack-manager
- **Purpose:** the PR plumbing for stacked epics.
  - Create a phase branch from the top of the stack.
  - Open the PR against the right base.
  - Run `gh stack link --base <epic> ...`.
  - After a lower phase changes, rebase the upper phases onto it.
- **When:** opening a phase PR, or after review edits on a lower PR.
- **Inputs:** the epic branch, the feature id, the PR title and body.
- **Outputs:** the PR URL and the updated stack listing.
- **Tools:** Bash.
- **Guardrails:**
  - Never merge.
  - A force-push (needed after a rebase) requires the user's explicit
    approval, passed in the brief each time.
  - Always pass `--base` to `gh stack link`.

```yaml
---
name: pr-stack-manager
description: Create stacked phase branches/PRs, link the stack, and rebase upper phases after lower ones change. Never merges.
tools: Bash, Read
model: sonnet
---
```

### style-linter
- **Purpose:** catch the mechanical rule violations before review:
  - line length
  - trailing whitespace
  - final newline
  - missing `.meta` files
  - assets in forbidden folders
  - forbidden APIs (e.g. legacy input)
  - comment policy
  - naming registers
- **When:** before every commit (or as a pre-commit hook).
- **Inputs:** the staged diff or a branch range.
- **Outputs:** violations as `file:line`, plus suggested fixes.
- **Tools:** Bash, Read, Grep.
- **Guardrails:** report only; fixes need the parent's go-ahead.
  Better yet, grow the linter into a committed script so it is
  deterministic.

```yaml
---
name: style-linter
description: Check a diff against AGENTS.md hard constraints and CODE_STYLE.md; report violations with file:line.
tools: Bash, Read, Grep
model: haiku
---
```

### doc-sync-auditor
- **Purpose:** find drift between the docs and the code:
  - constants quoted in docs that differ from the code
  - tables (rosters, formulas) that no longer match the assets
  - features marked `passing` whose verification no longer holds
- **When:** before an epic's final review, or periodically.
- **Inputs:** the doc files to audit.
- **Outputs:** a list of mismatches with the doc line and the code
  location.
- **Tools:** Read, Grep, Bash (Unity CLI `eval` to read live data).
- **Guardrails:** read-only.

```yaml
---
name: doc-sync-auditor
description: Compare harness docs (formulas, tables, constants) against code and live Editor data; report drift.
tools: Read, Grep, Bash
model: sonnet
---
```

---

## Priority: later

### plan-writer
- **Purpose:** turn an approved discussion into
  `harness/plans/<epic>.md` plus `feature_list.json` entries, each
  with a behavior and a verification.
- **When:** after the user approves the direction of a new epic.
- **Guardrails:** no code. The plan goes to the user before any
  branch is cut.

### art-generator
- **Purpose:** generate placeholder or consistent-style sprites from
  a committed script.
  - Create matching `.meta` files: new guid, correct import
    settings, sprite internal IDs.
  - Wire the sprites into their assets.
  - Produce a contact sheet for review.
- **When:** new content needs art that matches the existing style.
- **Guardrails:** match the existing palette and grid. Show the
  contact sheet before committing. No installs (use what is
  available or ask).

### build-release
- **Purpose:** version bump, platform builds through the Unity CLI,
  and changelog notes.
- **Guardrails:** commit prefix conventions; never uploads to a store
  without explicit approval.

### playtester
- **Purpose:** play scripted or random sessions in Play mode through
  the CLI, capture screenshots at key moments, and flag visual or UX
  issues (overlaps, overflow, unreadable text) across a few screen
  sizes.
- **Guardrails:** report only.

---

## Skills

Skills are reusable instructions the main agent loads on demand.
Cheap to write, and they make the process consistent across sessions.

| Skill | What it does | Priority |
|---|---|---|
| `harness-setup` | First-run setup: asks for project name, engine version, platforms, render pipeline, input system, scene policy and commit conventions; fills `AGENTS.md` placeholders; creates the tracking files. | now |
| `close-out` | Runs the clean-state checklist, archives passing features, writes progress.md, lists open PRs. | now |
| `new-feature` | Creates the feature_list entry (behavior + verification), the branch (stacked if in an epic) and a plan stub. | now |
| `experiment` | The measure-first protocol: baseline on seeds, one knob at a time, revert, table, record rejected variants. | next |
| `review-round` | Reads comments, discusses by number, applies approved tweaks, verifies, waits for OK, commits, replies, resolves. | next |
| `unity-play-check` | A standard Play mode flow plus captures at 3 screen sizes. | later |

---

## Rollout order

1. Write the skills `harness-setup`, `close-out` and `new-feature`.
   They have no autonomy risk and get immediate consistency.
2. Add `unity-verifier` and `harness-keeper`. They are the two steps
   the agent repeats most.
3. Add `experimenter` once a simulator or metric report exists in
   the project.
4. Add `review-responder` and `pr-stack-manager` when stacked epics
   become routine.
5. Promote `style-linter` into a committed script or hook. Make
   `doc-sync-auditor` part of each epic's final review.

Each subagent earns its place by replacing a step we already do by
hand at least three times. Don't build one speculatively.
