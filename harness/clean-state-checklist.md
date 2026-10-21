# Clean State Checklist

Run through this list before ending any session. A session is not
done until every item here is true.

- [ ] The project compiles with no console errors
      (`harness/scripts/unity-check.sh`)
- [ ] All automated tests pass
- [ ] `harness/feature_list.json` states reflect reality: no feature
      left `active` without a note in `harness/progress.md` saying
      why
- [ ] Every `passing` or `dropped` entry has moved from
      `harness/feature_list.json` to `harness/feature_archive.json`,
      including ones that changed state this session
- [ ] `harness/progress.md` records what changed, key decisions,
      blockers and the next step
- [ ] Docs touched by the change are updated (`harness/docs/`,
      plans, `AGENTS.md`)
- [ ] No stray debug code, commented-out blocks, temporary scenes or
      assets, or experiment branches left behind
- [ ] Every new asset has its `.meta` file committed with it
- [ ] `{{MAIN_SCENE}}` still opens and Play works end to end
      ({{SMOKE_PATH}})
- [ ] No open branches or PRs left over unless intentionally
      awaiting review, and noted in `harness/progress.md`;
      otherwise `harness/loop-state.md` is `idle`
