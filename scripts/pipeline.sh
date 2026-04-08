#!/usr/bin/env bash
set -euo pipefail

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
if ! "${SWIFTLINT_BIN}"; then
  echo "SwiftLint failed."
  exit 1
fi

echo "==> Running Swift tests"
if [[ -f "Package.swift" ]]; then
  if ! swift test; then
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
    -destination "id=$destination_id"; then
    echo "xcodebuild test failed."
    exit 1
  fi
fi

echo "==> Quality gate passed"
