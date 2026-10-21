# Unity CLI: Driving the Open Editor

The Unity CLI (`unity`) drives the open Editor through the
`com.unity.pipeline` package. It is what lets the agent compile,
test, play, capture and inspect the project on its own. The
`unity cmd` commands need the Editor open on this project; if it
isn't, ask the user to open it rather than spawning batchmode.

Set `UNITY_NO_BANNER=1 UNITY_NO_PAGER=1` and pass `--result-only`
(or `--json`) for compact, parseable output.

## Discover

```bash
unity list                          # every command the Editor exposes
unity cmd --query <term> --detail full
unity skill show                    # the CLI's own task guide
```

## Compile

```bash
unity cmd recompile --result-only
unity cmd recompile_status --result-only
```

Trigger, then poll `recompile_status` every few seconds until it
reports `completed`. `"failed": true` lists each error with
`file(line,col)`. If `recompile` returns a network error, the Editor
is usually mid-reload: wait and retry.

After editing assets outside the Editor (YAML `.asset` files,
images), refresh first:

```bash
unity cmd eval 'UnityEditor.AssetDatabase.Refresh(); return "ok";'
```

A recompile (domain reload) also clears static caches, such as
lazily loaded databases.

## Console

```bash
unity cmd console_status --result-only     # live counts
unity cmd console --level error --tail 50 --result-only
```

`console` returns buffered history, including errors already fixed;
`console_status` is the live state.

## Tests

```bash
unity cmd run_tests --mode EditMode
```

The summary line reports `passed/total`. To see failures, use JSON
and filter:

```bash
unity cmd run_tests --mode EditMode --json | python3 -c '
import json, sys
result = json.load(sys.stdin)["data"]["result"]
print(result["Summary"])
for test in result["Results"]:
    if test["Status"] != "Passed":
        print(test["FullName"])
        print("   ", (test["Message"] or "")[:600])'
```

`harness/scripts/unity-check.sh` wraps compile plus tests.

## Live C# (`eval`)

```bash
unity cmd eval '<C# statements ending in return ...;>' --result-only
```

- Use it for diagnostics, dumping derived data (tables, pools,
  formulas) and driving the game in Play mode.
- Fully qualify ambiguous types (`UnityEngine.Object`,
  `UnityEngine.Random`).
- Private members are reachable through reflection when a one-off
  probe needs them; don't widen visibility in code for a probe.
- **Time limit:** a call is cut after about 5 s. For long jobs
  (simulations, batch processing), make the work resumable: give it
  a time budget, return a serialized partial result, and let a shell
  script loop over chunks and merge them. Keep each chunk's result
  small (sum counters as you go) so the final call stays short.

## Play mode: acting and capturing

```bash
unity cmd editor_play
unity cmd capture_game_view --source screen --result-only
unity cmd editor_stop
```

- If the project has Run In Background off, the game won't advance
  while the Editor is unfocused. Right after `editor_play`, run
  `unity cmd eval "UnityEngine.Application.runInBackground = true;
  return 0;"`. It lasts for that Play session only; don't change the
  project setting.
- Wait for loading or splash screens to finish (check open scenes or
  a capture) before acting.
- Capture with `--source screen`. The camera source misses UI
  overlays such as UI Toolkit panels.
- Don't save captures into the repo: omit `--save_path` and decode
  the returned `base64` field into a scratch file.
- To tap UI Toolkit elements, `eval` a `PointerDownEvent` (and a
  `PointerUpEvent` for `Button.clicked`) sent to the element through
  its panel's visual tree. Record the project's working snippet in
  `harness/docs/ARCHITECTURE.md` or here once it exists.

## Builds

Headless builds spawn batchmode, so the Editor must be closed:

```bash
unity build --profile "<path to build profile asset>"
```

## Project notes

Add project-specific CLI notes here: scene loading quirks, eval
snippets for driving gameplay, simulator scripts.

{{UNITY_CLI_PROJECT_NOTES}}
