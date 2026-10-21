# <Title> — Plan

Status: draft | approved <date> | done <date>. One line on which
phases are built, dropped or pending.

## Problem

What is wrong or missing, with evidence (measurements, a report, a
playtest note). Name the structural causes, not just symptoms.

## Targets

What "done" means, as numbers or observable behavior, agreed with
the user (record the date). Include what must NOT happen (for
example no regressions, no runaway cases).

## Phases

Each phase is its own `<epic>-<feature-id>` branch and PR, stacked
on the previous one (`harness/docs/STACKED_PRS.md`). Build
measurement and mechanisms first; set final numbers last.

### 1. `<feature-id>`: <short title>

- What changes, where (files, classes, assets).
- Why it comes before the next phase.
- How it is verified (tests, commands, before/after report).

### 2. `<feature-id>`: <short title>

...

### N. `<feature-id>`: conditional, only if <condition>

Experiments that may be dropped: say what result would justify
building it, and what happens otherwise.

## Verification (all phases)

- Compile and EditMode tests pass on every PR.
- Measurable phases paste before/after numbers into the PR body and
  the relevant `harness/docs/` file.
- Manual checks, if any, with exact steps.

## Open questions

Decisions still owed by the user. Remove each one once answered,
and record the answer above.
