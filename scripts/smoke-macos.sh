#!/usr/bin/env bash
set -euo pipefail
test "$(uname -s)" = Darwin
test "${CI:-}" = true
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:?Pass the native Rust target}"
case "$target" in aarch64-apple-darwin|x86_64-apple-darwin) ;; *) exit 2 ;; esac
binary="$root/desktop/target/$target/release/bundle/macos/CodexBar + Mobile Connect.app/Contents/MacOS/codexbar-desktop-tauri"
test -x "$binary"
profile="$(mktemp -d "${RUNNER_TEMP:?}/codexbar-gui-XXXXXX")"
output="$root/artifacts/$target"
mkdir -p "$output"
printf '%s' '{"enabled_providers":[],"refresh_interval_secs":0,"auto_download_updates":false,"cost_usage_enabled":false}' > "$profile/settings.json"
CODEXBAR_CONFIG="$profile/settings.json" CODEXBAR_PROOF_MODE=settings:mobileConnect \
  "$binary" > "$output/native-app.log" 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 30); do
  kill -0 "$pid"
  if grep -q 'proof-harness: transition succeeded' "$output/native-app.log"; then break; fi
  sleep 1
done
grep -q 'proof-harness: transition succeeded' "$output/native-app.log"
# Let the actual bundled WebKit surface finish rendering before capture.
sleep 3
kill -0 "$pid"
window_id="$(swift - "$pid" <<'SWIFT'
import Foundation
import CoreGraphics
let pid = Int(CommandLine.arguments[1])!
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
let owned = windows.filter { window in
    guard window[kCGWindowOwnerPID as String] as? Int == pid,
          window[kCGWindowLayer as String] as? Int == 0,
          let bounds = window[kCGWindowBounds as String] as? [String: Any],
          let width = bounds["Width"] as? NSNumber,
          let height = bounds["Height"] as? NSNumber else { return false }
    return width.doubleValue >= 320 && height.doubleValue >= 240
}
guard owned.count == 1, let id = owned.first?[kCGWindowNumber as String] as? Int else {
    fputs("Expected exactly one visible app surface\n", stderr)
    exit(1)
}
print(id)
SWIFT
)"
[[ "$window_id" =~ ^[0-9]+$ ]]
screencapture -x -l "$window_id" "$output/mobile-connect.png"
test -s "$output/mobile-connect.png"
if grep -Eq 'panicked at|segmentation fault|proof-harness:.*FAILED' "$output/native-app.log"; then exit 1; fi
shasum -a 256 "$binary" > "$output/native-app.sha256"
