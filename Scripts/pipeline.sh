#!/usr/bin/env bash
set -euo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)"

MEMORY_FILE="Documentation/MEMORY.md"
LINT_LOG="$(mktemp)"
TEST_LOG="$(mktemp)"
RUN_STATUS="failed"
TEST_TIMEOUT_SECONDS=600

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

collect_changed_files() {
  local changed
  changed="$(git diff --name-only --cached || true)"
  if [[ -z "${changed}" ]]; then
    changed="$(git diff --name-only HEAD || true)"
  fi
  printf "%s\n" "${changed}" | sed '/^$/d'
}

should_run_full_suite() {
  local changed_files="$1"

  if [[ -z "${changed_files}" ]]; then
    return 0
  fi

  if printf "%s\n" "${changed_files}" | grep -Eq '(^|/)Package\.swift$|\.swift$'; then
    return 0
  fi

  if printf "%s\n" "${changed_files}" | grep -Ev '\.(md|json)$' | grep -q '.'; then
    return 0
  fi

  return 1
}

run_with_timeout() {
  local timeout_seconds="$1"
  shift

  python3 - "$timeout_seconds" "$@" <<'PY'
import subprocess
import sys

timeout_seconds = int(sys.argv[1])
command = sys.argv[2:]

try:
    completed = subprocess.run(command, timeout=timeout_seconds)
    sys.exit(completed.returncode)
except subprocess.TimeoutExpired:
    print(
        f"Timed out after {timeout_seconds} seconds: {' '.join(command)}",
        file=sys.stderr
    )
    sys.exit(124)
PY
}

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

echo "==> Data audit (german_vocabulary.json)"
if ! swift Scripts/audit_data.swift 2>&1 | tee -a "${LINT_LOG}"; then
  echo "Data audit failed."
  exit 1
fi

CHANGED_FILES="$(collect_changed_files)"
if should_run_full_suite "${CHANGED_FILES}"; then
  RUN_MODE="full"
else
  RUN_MODE="data-integrity"
fi
echo "==> Pipeline mode: ${RUN_MODE}"

echo "==> Cleaning simulator environment"
xcrun simctl shutdown all >/dev/null 2>&1 || true
xcrun simctl erase all >/dev/null 2>&1 || true

# Prefer Xcode tests when the iOS app project exists; otherwise run `swift test` if a root Package.swift is present.
if [[ -f "Package.swift" ]] && [[ "${RUN_MODE}" == "full" ]] && [[ ! -f "LearnHappyGerman/LearnHappyGerman.xcodeproj/project.pbxproj" ]]; then
  echo "==> Running Swift tests with timeout (${TEST_TIMEOUT_SECONDS}s)"
  if ! run_with_timeout "${TEST_TIMEOUT_SECONDS}" swift test 2>&1 | tee "${TEST_LOG}"; then
    if grep -q "Timed out after" "${TEST_LOG}" 2>/dev/null; then
      echo "swift test timed out."
    else
      echo "swift test failed."
    fi
    exit 1
  fi
  RUN_STATUS="passed"
  echo "==> Quality gate passed"
  exit 0
fi

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

if [[ "${RUN_MODE}" == "data-integrity" ]]; then
  echo "==> Running Data Integrity Audit with timeout (${TEST_TIMEOUT_SECONDS}s)"
  if ! run_with_timeout "${TEST_TIMEOUT_SECONDS}" \
    xcodebuild test \
    -project "LearnHappyGerman/LearnHappyGerman.xcodeproj" \
    -scheme "LearnHappyGerman" \
    -destination "id=$destination_id" \
    -only-testing:LearnHappyGermanTests/VocabularyDataIntegrityTests 2>&1 | tee "${TEST_LOG}"; then
    if grep -q "Timed out after" "${TEST_LOG}" 2>/dev/null; then
      echo "Data Integrity Audit timed out."
    else
      echo "Data Integrity Audit failed."
    fi
    exit 1
  fi
  RUN_STATUS="passed"
  echo "==> Quality gate passed (data integrity fast-path)"
  exit 0
fi

echo "==> Running Swift tests"
if ! run_with_timeout "${TEST_TIMEOUT_SECONDS}" \
  xcodebuild test \
  -project "LearnHappyGerman/LearnHappyGerman.xcodeproj" \
  -scheme "LearnHappyGerman" \
  -destination "id=$destination_id" 2>&1 | tee "${TEST_LOG}"; then
  if grep -q "Timed out after" "${TEST_LOG}" 2>/dev/null; then
    echo "xcodebuild test timed out."
  else
    echo "xcodebuild test failed."
  fi
  exit 1
fi

RUN_STATUS="passed"
echo "==> Quality gate passed"
