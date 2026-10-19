#!/usr/bin/env bash
# Run only on an ephemeral native macOS CI runner, never against a user's profile.
set -euo pipefail
test "$(uname -s)" = Darwin
test "${CI:-}" = true
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root/desktop"
cargo build --locked -p codexbar --example secure_file_probe
probe="$PWD/target/debug/examples/secure_file_probe"
scratch="$(mktemp -d "${RUNNER_TEMP:?}/codexbar-keychain-XXXXXX")"

# Two fresh processes must agree on one key during first initialization.
"$probe" write "$scratch/first.json" & first=$!
"$probe" write "$scratch/second.json" & second=$!
wait "$first"
wait "$second"
"$probe" read "$scratch/first.json"
"$probe" read "$scratch/second.json"

# Reading existing ciphertext must not require a writable settings directory.
store="$HOME/Library/Application Support/CodexBar-Mac-Mobile-Connect"
test -d "$store"
trap 'chmod u+w "$store" "$store/.secure-storage.lock"' EXIT
chmod u-w "$store" "$store/.secure-storage.lock"
"$probe" read "$scratch/first.json"
chmod u+w "$store" "$store/.secure-storage.lock"
trap - EXIT
