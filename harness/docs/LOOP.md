# Feature Loop

A self-paced loop that advances features one at a time with a human
review gate. Everything in `AGENTS.md` still applies; this file adds
the loop mechanics. Start it with Claude Code's `/loop` and no
interval:

```
/loop Follow harness/docs/LOOP.md to advance features one at a time.
```

Implementation, verification, self-review and opening the PR happen
automatically. **Merging never does.** Each time a PR opens, the
loop stops and reports it. You resume it by approving the merge.

## One branch at a time

Outside an epic, exactly one feature branch exists at a time: a new
branch is cut only after the previous PR merged or the feature was
parked as `blocked`. Epics are the exception; see
`harness/docs/STACKED_PRS.md`.

## Per iteration

1. Read `harness/loop-state.md`.
   - `<id>:awaiting-review`: stop; that PR waits on the user.
   - `<id>:implementing` or `<id>:reviewing`: resume that feature.
   - `idle` or missing: `git checkout {{MAIN_BRANCH}} && git pull`,
     then pick a `not_started` or `active` feature from
     `harness/feature_list.json` (prefer `active`).
2. `git checkout -b <id>`, then
   `harness/scripts/feature-loop.sh update <id> active`, and write
   `<id>:implementing` to `harness/loop-state.md`.
3. Implement only that feature, per its `behavior`.
4. Verify: `harness/scripts/unity-check.sh`, plus the feature's own
   `verification`. Rule changes get new or updated tests.
5. Commit (single-line message, `AGENTS.md` rule 3).
6. Self-review `git diff {{MAIN_BRANCH}}...<id>` against the review
   families below; write `<id>:reviewing`. Fix what you find and
   re-verify.
7. `feature-loop.sh update <id> passing`, then archive the entry in
   `harness/feature_archive.json` and update `harness/progress.md`.
8. `feature-loop.sh open-pr <id>` and write `<id>:awaiting-review`.
9. **Stop.** Report the PR (title, URL, one-line summary) and end
   the loop. Do not merge.
10. When told to merge: `feature-loop.sh merge-pr <id>`, write
    `idle`, and continue with the next feature or report an empty
    queue.

## Blocked features

Set `blocked` with the reason (`--note`), add a line to
`harness/progress.md`, leave the branch pushed, write `idle` and
move on.

## Definition of done

- Compiles clean, all tests pass, `verification` holds.
- Feature files and `harness/progress.md` updated; entry archived.
- Docs touched by the change are current.
- No debug code, commented-out blocks or temporary assets.

## Review families

Problems recur as families, so when a change touches one, check the
sibling code in the same flow too.

| Family | Signals |
|---|---|
| State | Mutation outside the owning system; event `+=` without a matching `-=`; stale references held across frames or scenes. |
| Edge cases | Null `MonoBehaviour`/`ScriptableObject` references, empty collections, zero or negative values, unhandled enum cases. |
| Types | Silent `int`/`float` truncation, boxing, loose signatures. |
| Platform | Anything that breaks the project-specific constraints in `AGENTS.md` (input, shaders, UI styling). |
| Observability | Swallowed exceptions, fixes with no way to verify, a `verification` field that no longer matches the code. |
| Dead code | Unused members, near-duplicate classes, speculative flags. |
