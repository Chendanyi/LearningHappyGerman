#!/usr/bin/env bash
set -euo pipefail

echo "==> Running SwiftLint"
swiftlint

echo "==> Running Xcode tests"
DESTINATION_ID="$(
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

# Flatten and keep iOS runtimes only.
all_devices = []
for runtime, devices in data.get("devices", {}).items():
    if "iOS" in runtime:
        all_devices.extend(devices)

if not all_devices:
    print("ERROR: No available iOS simulator devices found.", file=sys.stderr)
    sys.exit(1)

# Prefer iPhone, then iPad, then first available.
iphones = [d for d in all_devices if "iPhone" in d.get("name", "")]
ipads = [d for d in all_devices if "iPad" in d.get("name", "")]
pool = iphones or ipads or all_devices
print(pool[0]["udid"])
PY
)"

xcodebuild test \
  -project "LearnHappyGerman/LearnHappyGerman.xcodeproj" \
  -scheme "LearnHappyGerman" \
  -destination "id=$DESTINATION_ID"

echo "==> Integrity checks passed"
