---
name: harness-setup
description: First-run setup for this Unity agent harness. Use when AGENTS.md starts with a SETUP comment or any file still contains {{PLACEHOLDER}} values, or when the user asks to configure or re-configure the harness. Detects project facts, asks only for what it can't detect, fills every placeholder and verifies the Unity CLI connection.
---

# Harness setup

Goal: turn the generic harness into this project's harness in one
short conversation. Detect first, ask second, write last.

## 1. Find the placeholders

```bash
grep -rno '{{[A-Z_]*}}' AGENTS.md CLAUDE.md harness docs \
  | sort -t: -k3 -u
```

Placeholders in use: `PROJECT_NAME`, `PROJECT_PITCH`,
`UNITY_VERSION`, `RENDER_PIPELINE`, `TARGET_PLATFORMS`,
`MAIN_SCENE`, `BOOTSTRAP_ENTRY`, `PROJECT_ASSET_ROOT`,
`TEST_FOLDER`, `MAIN_BRANCH`, `EPIC_BRANCH`, `HOW_TO_PLAY`,
`SMOKE_PATH`, `INPUT_RULE`, `SHADER_RULE`, `COMMENT_RULE`,
`NAMING_RULE`, `LINE_LENGTH`, `UI_STYLE_RULE`, `SCENE_RULE`,
`UNITY_CLI_PROJECT_NOTES`.

## 2. Detect (don't ask what the repo already says)

- `UNITY_VERSION`: `m_EditorVersion` in
  `ProjectSettings/ProjectVersion.txt`.
- `RENDER_PIPELINE`: `Packages/manifest.json`.
  `com.unity.render-pipelines.universal` means URP (check
  `Assets/**/*Renderer2D*.asset` for the 2D Renderer),
  `...high-definition` means HDRP, neither means Built-in.
- Input: `com.unity.inputsystem` in the manifest, and
  `activeInputHandler` in `ProjectSettings/ProjectSettings.asset`.
- UI: `com.unity.ugui` vs UI Toolkit usage (`*.uxml`, `*.uss`
  files).
- Test framework: `com.unity.test-framework`; existing test folders
  (`find Assets -name '*.asmdef' -path '*Tests*'`).
- Unity CLI bridge: `com.unity.pipeline` in the manifest. If it's
  missing, tell the user it's needed. Don't install it without
  their OK (`AGENTS.md` rule 6).
- Scenes: `ProjectSettings/EditorBuildSettings.asset` and
  `find Assets -name '*.unity'`.
- Git: `git remote -v`, the default branch
  (`git symbolic-ref refs/remotes/origin/HEAD`), and the current
  branch.
- An existing `AGENTS.md`/`CLAUDE.md` or docs from before the
  harness: read them and carry their rules over instead of
  overwriting them.

## 3. Ask only what's left

Use one batch of questions (AskUserQuestion when available), with
the detected or suggested value as the first option:

1. Project name and a one-line pitch.
2. Target platforms.
3. Main scene and bootstrap entry point (suggest the detected
   scene; the entry point may be "none yet").
4. Asset root folder (suggested: `Assets/App/`) and test folder
   (suggested: `Assets/App/Tests/Editor/`).
5. Branching: mainline (detected) and the epic branch prefix
   (suggested: `v2`).
6. Code style: comments policy, abbreviations rule, line length
   (suggested values are in `AGENTS.md`).
7. UI styling and scene rules, if the project has UI or scenes yet.
8. How to play in one or two lines, and the smoke path a session
   must keep working (for example "boot, start a run, reach the
   first exit").

Anything unknown yet gets a short `TBD (<what decides it>)` value
instead of staying a placeholder.

## 4. Write

- Replace every placeholder in `AGENTS.md`, `harness/` and `docs/`.
- Delete the `<!-- SETUP: ... -->` comment at the top of
  `AGENTS.md`, and the setup sentence in `CLAUDE.md`.
- Fill `harness/docs/ARCHITECTURE.md` with what exists today
  (scenes, folders, key classes found under the asset root).
- Add `harness/loop-state.md` to `.gitignore` if it isn't there.
- Rewrite `harness/progress.md` "Current State" to say the harness
  is configured, with the date.

## 5. Verify

```bash
unity cmd recompile --result-only
harness/scripts/unity-check.sh
grep -rn '{{[A-Z_]*}}' AGENTS.md CLAUDE.md harness docs || echo clean
```

If the Editor isn't reachable, ask the user to open the project in
Unity. Then report what was detected, what was asked and anything
left `TBD`. Don't commit unless the user asks to.
