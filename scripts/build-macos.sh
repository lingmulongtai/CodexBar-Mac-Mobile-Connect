#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'Build the native Mac application on macOS (or use the macOS CI workflow).' >&2
  exit 2
fi
target="${1:-}"
if [[ -z "$target" ]]; then
  case "$(uname -m)" in
    arm64) target=aarch64-apple-darwin ;;
    x86_64) target=x86_64-apple-darwin ;;
    *) echo 'Unsupported Mac architecture.' >&2; exit 2 ;;
  esac
fi
case "$target" in
  aarch64-apple-darwin|x86_64-apple-darwin|universal-apple-darwin) ;;
  *) echo 'Expected a Mac target (Apple Silicon, Intel or universal).' >&2; exit 2 ;;
esac
if [[ ! -f "$root/desktop/apps/desktop-tauri/package.json" ]]; then
  echo 'Initialize the pinned source first: git submodule update --init --recursive' >&2
  exit 2
fi
cd -- "$root/desktop/apps/desktop-tauri"
pnpm install --frozen-lockfile
pnpm exec tauri build --config "$root/macos.conf.json" --target "$target" --bundles app,dmg
