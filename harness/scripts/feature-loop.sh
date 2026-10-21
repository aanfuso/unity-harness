#!/usr/bin/env bash
# Helpers for the feature loop (harness/docs/LOOP.md). Needs jq and gh.
# Usage:
#   feature-loop.sh update <feature-id> <state> [--note "<text>"]
#   feature-loop.sh open-pr <feature-id>
#   feature-loop.sh merge-pr <feature-id>
#
# The mainline branch comes from $MAIN_BRANCH, else origin's default
# branch, else "main".
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FEATURE_LIST="$HARNESS_DIR/feature_list.json"

main_branch() {
  if [ -n "${MAIN_BRANCH:-}" ]; then
    echo "$MAIN_BRANCH"
    return
  fi
  local remote_head
  remote_head=$(git symbolic-ref --quiet --short \
    refs/remotes/origin/HEAD 2>/dev/null || true)
  echo "${remote_head#origin/}" | grep . || echo main
}

usage() {
  echo "Usage:"
  echo "  feature-loop.sh update <feature-id> <state> [--note \"<text>\"]"
  echo "  feature-loop.sh open-pr <feature-id>"
  echo "  feature-loop.sh merge-pr <feature-id>"
  echo ""
  echo "  <state> one of: not_started, active, blocked, passing, dropped"
  echo "  --note  appended to the feature's behavior field; required"
  echo "          when <state> is blocked or dropped, optional otherwise."
  echo ""
  echo "  open-pr pushes the branch and opens a PR; it does not merge."
  echo "  merge-pr rebase-merges an already-open PR and syncs the mainline."
  echo "  Merging always requires a separate, explicit merge-pr call —"
  echo "  see harness/docs/LOOP.md's review gate. Never squash and"
  echo "  never create a merge commit — see AGENTS.md hard constraint 4."
  exit 1
}

cmd_update() {
  if [ $# -lt 2 ]; then
    usage
  fi

  local feature_id="$1"
  local state="$2"
  local note=""
  local note_provided=false
  shift 2

  while [ $# -gt 0 ]; do
    case "$1" in
      --note)
        note="$2"
        note_provided=true
        shift 2
        ;;
      *)
        echo "ERROR: Unknown flag '$1'"
        exit 1
        ;;
    esac
  done

  case "$state" in
    not_started|active|blocked|passing|dropped) ;;
    *)
      echo "ERROR: Invalid state '$state'. Must be one of: not_started, active, blocked, passing, dropped"
      exit 1
      ;;
  esac

  if { [ "$state" = "blocked" ] || [ "$state" = "dropped" ]; } \
    && [ "$note_provided" = false ]; then
    echo "ERROR: --note is required when state is '$state'"
    exit 1
  fi

  if [ ! -f "$FEATURE_LIST" ]; then
    echo "ERROR: $FEATURE_LIST not found"
    exit 1
  fi

  if ! jq -e --arg id "$feature_id" '.features[] | select(.id == $id)' "$FEATURE_LIST" > /dev/null 2>&1; then
    echo "ERROR: Feature '$feature_id' not found in feature_list.json"
    echo ""
    echo "Available features:"
    jq -r '.features[].id' "$FEATURE_LIST"
    exit 1
  fi

  local current_state
  current_state=$(jq -r --arg id "$feature_id" '.features[] | select(.id == $id) | .state' "$FEATURE_LIST")

  if [ "$note_provided" = true ]; then
    jq --arg id "$feature_id" --arg state "$state" --arg note "$note" \
      '(.features[] | select(.id == $id)) |= (.state = $state | .behavior = .behavior + " " + $note)' \
      "$FEATURE_LIST" > "$FEATURE_LIST.tmp"
  else
    jq --arg id "$feature_id" --arg state "$state" \
      '(.features[] | select(.id == $id)) |= (.state = $state)' \
      "$FEATURE_LIST" > "$FEATURE_LIST.tmp"
  fi

  mv "$FEATURE_LIST.tmp" "$FEATURE_LIST"

  echo "Updated feature: $feature_id"
  echo "  State: $current_state -> $state"
  if [ "$note_provided" = true ]; then
    echo "  Note: $note"
  fi
}

cmd_open_pr() {
  if [ $# -lt 1 ]; then
    usage
  fi

  local feature_id="$1"

  if ! command -v gh > /dev/null 2>&1; then
    echo "ERROR: gh CLI not found"
    exit 1
  fi

  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" != "$feature_id" ]; then
    echo "ERROR: expected to be on branch '$feature_id', currently on '$current_branch'"
    exit 1
  fi

  git push -u origin "$feature_id"

  gh pr create \
    --title "$feature_id" \
    --body "Automated loop feature: $feature_id. See harness/feature_list.json / harness/feature_archive.json for behavior and verification." \
    --base "$(main_branch)" \
    --head "$feature_id"

  echo "Opened PR for feature: $feature_id (awaiting review — run 'merge-pr $feature_id' once approved)"
}

cmd_merge_pr() {
  if [ $# -lt 1 ]; then
    usage
  fi

  local feature_id="$1"

  if ! command -v gh > /dev/null 2>&1; then
    echo "ERROR: gh CLI not found"
    exit 1
  fi

  gh pr merge "$feature_id" --rebase --delete-branch

  local base
  base=$(main_branch)
  git checkout "$base"
  git pull --ff-only origin "$base"

  echo "Merged feature: $feature_id ($base synced)"
}

if [ $# -lt 1 ]; then
  usage
fi

SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
  update)
    cmd_update "$@"
    ;;
  open-pr)
    cmd_open_pr "$@"
    ;;
  merge-pr)
    cmd_merge_pr "$@"
    ;;
  *)
    usage
    ;;
esac
