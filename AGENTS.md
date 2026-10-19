# Mac distribution working agreement

- This repository owns the Mac distribution of CodexBar + Mobile Connect. The shared Rust, React and encrypted peer protocol live in the pinned `desktop` submodule, sourced from `lingmulongtai/Win-CodexBar-Mobile-Connect`.
- Before development, inspect the branch, working tree and this file. Fetch the read-only upstream and review changes before updating the submodule pin. Preserve local work, protocol compatibility, saved connections and provider isolation.
- Implement shared application behavior in the shared source. Keep only Mac identity, packaging, CI and Mac-specific documentation here. Do not duplicate the peer protocol or maintain an independent copy of the frontend.
- Make meaningful atomic commits after focused checks. Review staged paths and diffs. Never rewrite shared history, force-push or commit credentials, caches, build outputs or private proof files.
- Bind GitHub writes to `lingmulongtai/CodexBar-Mac-Mobile-Connect` explicitly and read back the target first. Upstream repositories are read-only unless a particular write is authorized.
- Validate shell syntax, configuration, the pinned source and native macOS builds. Exercise encrypted server/client integration on macOS and Windows. Record the checked source SHA, CI results, artifact hashes and remaining verification limits.
- A Windows cross-check or browser mock is not evidence that a native Mac application ran. The user currently has no Mac for physical acceptance; distinguish native CI evidence from physical-device testing.
- Apple signing credentials stay in the existing GitHub secret mechanism when available. Never label an ad-hoc signed artifact as Developer ID signed or notarized. Do not bypass Gatekeeper on a user's machine.
- Report commit SHAs and purposes, executed checks, push/release state and any remaining work.
