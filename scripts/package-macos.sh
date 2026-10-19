#!/usr/bin/env bash
# Package only an already verified native build on the disposable CI host.
set -euo pipefail
test "$(uname -s)" = Darwin
test "${CI:-}" = true
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:?Pass the native Rust target}"
case "$target" in
  aarch64-apple-darwin) arch=arm64 ;;
  x86_64-apple-darwin) arch=x86_64 ;;
  *) exit 2 ;;
esac
version="$(node -p "require('$root/desktop/apps/desktop-tauri/package.json').version")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
app="$root/desktop/target/$target/release/bundle/macos/CodexBar + Mobile Connect.app"
source_binary="$app/Contents/MacOS/codexbar-desktop-tauri"
codesign --verify --deep --strict "$app"
lipo -verify_arch "$arch" "$source_binary"
shopt -s nullglob
dmgs=("$root/desktop/target/$target/release/bundle/dmg/"*.dmg)
((${#dmgs[@]} == 1))
mount="$(mktemp -d "${RUNNER_TEMP:?}/codexbar-dmg-XXXXXX")"
cleanup() { hdiutil detach "$mount" >/dev/null 2>&1 || true; }
trap cleanup EXIT
hdiutil attach -readonly -nobrowse -mountpoint "$mount" "${dmgs[0]}"
bundled_app="$mount/CodexBar + Mobile Connect.app"
codesign --verify --deep --strict "$bundled_app"
cmp "$source_binary" "$bundled_app/Contents/MacOS/codexbar-desktop-tauri"
cleanup
trap - EXIT
out="$root/release-assets/$arch"
mkdir -p "$out"
name="CodexBar-Mobile-Connect-$version-macOS-$arch"
cp "${dmgs[0]}" "$out/$name.dmg"
cp "$root/artifacts/$target/mobile-connect.png" "$out/$name-ui.png"
sha="$(shasum -a 256 "$out/$name.dmg" | cut -d ' ' -f1)"
source="$(git -C "$root/desktop" rev-parse HEAD)"
commit="$(git -C "$root" rev-parse HEAD)"
node - "$out/$name-build.json" "$version" "$target" "$sha" "$source" "$commit" <<'JS'
const fs = require('node:fs');
const [path, version, target, sha256, sourceCommit, commit] = process.argv.slice(2);
fs.writeFileSync(path, JSON.stringify({repository:'lingmulongtai/CodexBar-Mac-Mobile-Connect',
  version, target, commit, sourceCommit, sha256, minimumMacOS:'14.0',
  signing:'ad-hoc', developerIdSigned:false, notarized:false,
  workflowRun:process.env.GITHUB_RUN_ID}, null, 2) + '\n');
JS
(cd "$out" && shasum -a 256 "$name.dmg" "$name-ui.png" "$name-build.json" > "SHA256SUMS-$arch")
