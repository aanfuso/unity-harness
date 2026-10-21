#!/usr/bin/env bash
# Compiles the project in the open Editor, waits for the result, then
# runs the EditMode tests and prints any failures.
# Usage: unity-check.sh [--no-tests]
# Exit code: 0 when everything passes, 1 on compile or test failure.
set -euo pipefail

export UNITY_NO_BANNER=1 UNITY_NO_PAGER=1
POLL_SECONDS=3
MAX_POLLS=100

until unity cmd recompile --result-only > /dev/null 2>&1; do
  echo "Editor not ready, retrying recompile..."
  sleep "$POLL_SECONDS"
done

DONE_STATUSES="completed up_to_date"
STATUS_JSON=""
STATUS=""
for _ in $(seq 1 "$MAX_POLLS"); do
  sleep "$POLL_SECONDS"
  STATUS_JSON=$(unity cmd recompile_status --result-only 2>/dev/null \
    || true)
  STATUS=$(python3 -c '
import json, sys
try:
    status = json.loads(sys.argv[1])
except ValueError:
    sys.exit()
print("failed" if status.get("failed") else status.get("status", ""))
' "$STATUS_JSON")
  if [ "$STATUS" = "failed" ] || [[ " $DONE_STATUSES " == *" $STATUS "* ]]
  then
    break
  fi
done

if [ "$STATUS" = "failed" ]; then
  echo "Compile failed:"
  echo "$STATUS_JSON"
  exit 1
fi
if [[ " $DONE_STATUSES " != *" $STATUS "* ]]; then
  echo "Compile did not finish in time (last status: $STATUS)"
  exit 1
fi
echo "Compile: ok"

if [ "${1:-}" = "--no-tests" ]; then
  exit 0
fi

unity cmd run_tests --mode EditMode --json | python3 -c '
import json, sys
result = json.load(sys.stdin)["data"]["result"]
passed = result["Summary"]["Passed"]
total = result["Summary"]["Total"]
print(f"Tests: {passed}/{total} passed")
failed = [test for test in result["Results"]
          if test["Status"] != "Passed"]
for test in failed:
    print(test["FullName"])
    print("   ", (test["Message"] or "").strip()[:600])
sys.exit(1 if failed else 0)
'
