#!/usr/bin/env bash
set -euo pipefail

MEMORY_FILE="MEMORY.md"
LINT_LOG="$(mktemp)"
TEST_LOG="$(mktemp)"
RUN_STATUS="failed"

append_memory_summary() {
  local test_count lint_violations stamp summary_line
  stamp="$(date '+%Y-%m-%d %H:%M:%S %z')"
  test_count="$(
    python3 - "${TEST_LOG}" <<'PY'
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8", errors="ignore").read()
print(text.count("Test case '"))
PY
  )"
  lint_violations="$(
    python3 - "${LINT_LOG}" <<'PY'
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8", errors="ignore").read()
match = re.search(r"Found\s+(\d+)\s+violations", text)
print(match.group(1) if match else "unknown")
PY
  )"

  summary_line="- [${stamp}] Pipeline ${RUN_STATUS}: ${test_count} tests, ${lint_violations} lint violations."

  {
    printf "\n### [PIPELINE-%s] Automated Pipeline Run\n\n" "$(date '+%Y%m%d-%H%M%S')"
    printf "%s\n" "${summary_line}"
  } >> "${MEMORY_FILE}"
}

cleanup() {
  append_memory_summary
  rm -f "${LINT_LOG}" "${TEST_LOG}"
}

trap cleanup EXIT

resolve_swiftlint() {
  if command -v swiftlint >/dev/null 2>&1; then
    command -v swiftlint
    return 0
  fi

  local candidates=(
    "/opt/homebrew/bin/swiftlint"
    "/usr/local/bin/swiftlint"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

SWIFTLINT_BIN="$(resolve_swiftlint || true)"

if [[ -z "${SWIFTLINT_BIN}" ]]; then
  echo "SwiftLint not found in PATH or common install locations." >&2
  exit 1
fi

echo "==> Running SwiftLint"
if ! "${SWIFTLINT_BIN}" 2>&1 | tee "${LINT_LOG}"; then
  echo "SwiftLint failed."
  exit 1
fi

echo "==> Running Swift tests"
if [[ -f "Package.swift" ]]; then
  if ! swift test 2>&1 | tee "${TEST_LOG}"; then
    echo "swift test failed."
    exit 1
  fi
else
  destination_id="$(
    python3 - <<'PY'
import json
import subprocess
import sys

out = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    text=True,
    stderr=subprocess.STDOUT,
)
data = json.loads(out)

all_devices = []
for runtime, devices in data.get("devices", {}).items():
    if "iOS" in runtime:
        all_devices.extend(devices)

if not all_devices:
    print("ERROR: No available iOS simulator devices found.", file=sys.stderr)
    sys.exit(1)

iphones = [d for d in all_devices if "iPhone" in d.get("name", "")]
ipads = [d for d in all_devices if "iPad" in d.get("name", "")]
pool = iphones or ipads or all_devices
print(pool[0]["udid"])
PY
  )"

  if ! xcodebuild test \
    -project "LearnHappyGerman/LearnHappyGerman.xcodeproj" \
    -scheme "LearnHappyGerman" \
    -destination "id=$destination_id" 2>&1 | tee "${TEST_LOG}"; then
    echo "xcodebuild test failed."
    exit 1
  fi
fi

RUN_STATUS="passed"
echo "==> Quality gate passed"
