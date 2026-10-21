# Architecture

Keep this file current as the project grows. It is what a fresh
session reads to find its way around. Describe what exists, not
plans (plans live in `harness/plans/`).

## Scenes

- `{{MAIN_SCENE}}`: what it contains and what is created at runtime
  by `{{BOOTSTRAP_ENTRY}}`.

## Assets Layout

- `{{PROJECT_ASSET_ROOT}}/Scripts/`: runtime and editor code, by
  folder (see below)
- `{{PROJECT_ASSET_ROOT}}/Sprites/`, `Audio/`, ...: authored assets
- `Assets/Resources/`: assets loaded by path (data definitions,
  panel settings), one folder per kind
- `{{TEST_FOLDER}}`: EditMode (and PlayMode) tests

## Scripts

| Folder | Purpose |
|---|---|
| `Core/` | Game rules, ideally pure and testable without scenes |
| `Data/` | `ScriptableObject` definitions and their databases |
| `UI/` | Views; no game rules |
| `Editor/` | Editor-only tools (simulators, importers) |

## Key Classes

One line each: what it owns and who calls it.

- (none yet)

## Data Flow

How input becomes state changes and how state reaches the UI (for
example: input -> action -> pure reducer -> new immutable state ->
UI refresh).
