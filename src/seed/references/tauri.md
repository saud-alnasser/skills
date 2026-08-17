---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, prototype, test]
use-when: "building or running this Tauri desktop application, or changing what its frontend may call"
---

# Reference — Tauri

**This file is yours.** Installed because a Tauri configuration was detected.
Record the Tauri major version — v1 and v2 differ in the permission model and in
the plugin layout, and guidance from the wrong one applies cleanly and is wrong.

## Prerequisites

A Rust toolchain plus the platform's webview and build dependencies. **These are
per-platform**, and a build failure on a fresh machine is usually a missing
system package rather than the project.

## Commands

```sh
npx tauri dev                    # frontend dev server + the Rust shell; long-running
npx tauri build                  # release bundle — slow, and it signs where configured
npx tauri build --debug          # a bundle you can actually debug
npx tauri info                   # versions and toolchain, for diagnosing environment failures
cargo test --manifest-path src-tauri/Cargo.toml
```

| Purpose | Command |
| --- | --- |
| dev | `npm run tauri dev` |
| build | `npm run tauri build` |
| Rust tests | `cargo test --manifest-path src-tauri/Cargo.toml` |

## The boundary is the security model

The frontend is untrusted web content; the Rust side is not. Everything the
frontend may reach is what `tauri.conf.json` and the capability files allow.

**Widening a permission or an allowlist entry is an architectural decision, not
a fix.** A command that fails because the capability does not grant it is the
model working. Raise it with what it would open up; never widen a scope, add a
capability, or relax the CSP to make an error go away
(`[[policies/engineering]]`).

A `#[tauri::command]` is a public entry point reachable by any code running in
the webview. Validate its arguments there, not in the caller.

## Failure handling

- `npm run tauri build` produces installers and may invoke code signing or an
  updater endpoint. **Never run a release build unasked**, and never publish one.
- A change to Rust that appears to do nothing is usually a dev session that only
  reloaded the frontend. Restart it.
- A command that works in dev and not in the bundle is almost always a
  capability that dev configuration granted more loosely.
