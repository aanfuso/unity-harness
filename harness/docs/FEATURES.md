# Feature Files

`harness/feature_list.json` holds current work only.
`harness/feature_archive.json` holds finished or dropped work. Both
have the same shape:

```json
{
  "features": [
    {
      "id": "kebab-case-id",
      "type": "implementation",
      "behavior": "What it does, why, and decisions made on the way.",
      "verification": "How to prove it works: commands, tests, steps.",
      "state": "not_started"
    }
  ]
}
```

## Fields

- `id`: kebab-case, unique across both files. It names the branch
  (`<id>`, or `<epic>-<id>` inside an epic) and the plan file.
- `type`:
  - `idea`: exploratory, not designed yet; no concrete plan or
    verification
  - `bug`: a defect in existing behavior
  - `implementation`: a concrete, actionable plan ready to build
- `behavior`: the spec. Append results and decisions as they happen
  (e.g. `RESULT <date>: ...`) so the entry explains itself later.
- `verification`: what must hold before `passing`. Prefer commands
  (`unity cmd run_tests --mode EditMode`, a simulator run) over
  manual steps; when manual, give exact Play-mode steps.
- `state`: see the lifecycle below.

## Lifecycle

```
not_started -> active -> passing  -> (archive)
                     \-> blocked  -> active ...
                     \-> dropped  -> (archive)
```

- `active`: work has started; `harness/progress.md` says where it
  stands.
- `blocked`: waiting on a decision or external dependency; the
  reason is appended to `behavior`.
- `passing`: `verification` holds. Archive it in the same session.
- `dropped`: tried or reconsidered and abandoned. Record the reason
  and any numbers in `behavior`, then archive it.

## Writing conventions

- Write `feature_list.json` with UTF-8 kept as is, and
  `feature_archive.json` consistently in one style, so diffs only
  show the entries that moved (with Python:
  `json.dumps(data, indent=2, ensure_ascii=False)` and
  `json.dumps(data, indent=2)` respectively, plus a final newline).
- Update the files as the work happens, not when asked.
