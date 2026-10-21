# Unity Agent Harness

A project-agnostic harness for building a Unity game with an AI
coding agent (Claude Code, or any client that reads `AGENTS.md`).
It gives the agent a single entry point, durable state across
sessions, a definition of done, and a way to drive the open Unity
Editor through the Unity CLI: compile, run tests, enter Play mode,
capture the screen and run live C#. With those, the agent can work
autonomously between your decisions and reviews.

How the user and the agent work together with it, from intent to
documentation, is described in [docs/SDLC.md](docs/SDLC.md).
Subagents and skills worth adding over time are in
[docs/SUBAGENTS.md](docs/SUBAGENTS.md).

## Requirements

- Unity 6 or newer, with the `com.unity.pipeline` package (the
  bridge the Unity CLI uses to drive the open Editor) and
  `com.unity.test-framework`.
- The Unity CLI (`unity`) on your `PATH`.
- `git`, the GitHub CLI (`gh`), `jq` and `python3` (standard library
  only).
- Claude Code, or another agent client that reads `AGENTS.md`.

## Install into a project

1. Copy everything in this folder into the root of your Unity
   project (next to `Assets/`, `Packages/` and `ProjectSettings/`):
   `AGENTS.md`, `CLAUDE.md`, `harness/`, `docs/` and
   `.claude/skills/`. Merge with an existing `.claude/` if you have
   one.
2. Add `harness/loop-state.md` to `.gitignore`.
3. Open the project in the Unity Editor and leave it open.
4. Start Claude Code in the project root. `CLAUDE.md` points the
   agent to `AGENTS.md`, whose `SETUP` comment tells it to run the
   `harness-setup` skill. You can also start it yourself with
   `/harness-setup`.

## First run: the setup skill

`harness-setup` detects what it can and asks only for the rest:

- **Detects:** the Unity version (`ProjectSettings/ProjectVersion.txt`),
  render pipeline, Input System and UI Toolkit
  (`Packages/manifest.json`), scenes, the git remote and the default
  branch.
- **Asks:** the project name and one-line pitch, target platforms,
  the main scene and bootstrap entry point, the asset root folder,
  the epic and branch naming, the code style choices and the commit
  conventions.
- **Then:** it fills every `{{PLACEHOLDER}}`, removes the `SETUP`
  comment and checks the Unity CLI connection with a recompile.

## File map

```
AGENTS.md                      entry point: overview, hard constraints
CLAUDE.md                      points Claude Code to AGENTS.md
docs/
  SDLC.md                      the working method, intent to docs
  SUBAGENTS.md                 subagents and skills to add over time
harness/
  progress.md                  session continuity log
  feature_list.json            current work (schema: docs/FEATURES.md)
  feature_archive.json         finished or dropped work
  clean-state-checklist.md     exit checklist for every session
  loop-state.md                loop checkpoint (git-ignored)
  docs/
    UNITY_CLI.md               driving the open Editor
    FEATURES.md                feature entry schema and lifecycle
    LOOP.md                    feature loop with a human review gate
    STACKED_PRS.md             epics as stacked branches and PRs
    ARCHITECTURE.md            template: scenes, layout, key classes
    CODE_STYLE.md              template: comments, naming, format
  plans/
    README.md                  when and how to write a plan
    _TEMPLATE.md               phased plan template
  scripts/
    feature-loop.sh            update feature state, open/merge PRs
    unity-check.sh             recompile, poll, run EditMode tests
.claude/
  settings.json                read-only command allowlist
  skills/harness-setup/        first-run configuration
  skills/new-feature/          add a feature, branch, plan
  skills/close-out/            end-of-session clean state
```

## Principles

- **The repo is the memory.** Anything a fresh session needs is in
  `AGENTS.md`, `harness/progress.md` or the feature files, not in
  the conversation.
- **Verification is evidence.** A feature is `passing` when its
  `verification` field holds against the running Editor, not when
  the agent says so.
- **Humans own decisions and merges.** The agent builds, verifies,
  documents and opens PRs; the user reviews, approves and merges.
