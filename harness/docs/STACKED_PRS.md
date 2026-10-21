# Epics as Stacked PRs

A multi-phase epic gets an epic branch off the mainline and one
stacked branch and PR per phase:

```
{{MAIN_BRANCH}} <- {{EPIC_BRANCH}} <- {{EPIC_BRANCH}}-phase-a <- {{EPIC_BRANCH}}-phase-b <- ...
```

- Name phase branches `{{EPIC_BRANCH}}-<feature-id>`.
- The first phase branches from the epic branch and its PR targets
  it. Each later phase branches from the previous phase's branch and
  its PR targets that branch. One PR per phase, each reviewable on
  its own.
- Push, then `gh pr create --base <previous branch>` (the loop's
  `open-pr` assumes the mainline, so don't use it here).
- Link the stack after every new PR, always with the epic as base:

  ```bash
  gh stack link --base {{EPIC_BRANCH}} <pr> <pr> <pr> ...
  ```

  Never omit `--base`.
- Each PR description has a summary, before/after numbers when the
  change is measurable, and a test plan.

## Review flow

- The user reviews the stack from the bottom up, usually after the
  whole epic is built.
- Review tweaks follow `AGENTS.md` rule 8: change, verify, show,
  then commit only after an OK.
- If an earlier phase changes, rebase the later branches onto it
  (never merge) and force-push only with explicit approval each
  time.
- Changes go into the PR they belong to (a balance tweak goes on the
  balance PR). Documentation-only follow-ups that span the whole
  epic go in one commit on top of the last PR.
- Merging into the epic branch, and landing the epic on the
  mainline, are the user's calls. The agent doesn't merge or propose
  it.

## Experiments inside an epic

Exploratory variants (tuning, alternative formulas) run on a
throwaway local branch. Record the numbers in the feature's
`behavior` and the relevant doc, revert, delete the branch and
return to the top of the stack. Only an approved result becomes a
new phase PR.
