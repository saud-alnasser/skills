---
use-when: "building, testing, or checking this Rust crate or workspace"
---

# Reference — Cargo

**This file is yours.** Installed because a `Cargo.toml` was detected. Read it
for the workspace members and the feature flags — both change what every command
below actually covers.

## Commands

```sh
cargo check                      # type-check without codegen; far faster than build
cargo build                      # debug
cargo build --release            # optimised; much slower
cargo test                       # unit, integration, and doc tests
cargo test <filter>              # tests whose name contains the filter
cargo test -- --nocapture        # let tests print
cargo clippy -- -D warnings      # what CI usually runs
cargo fmt --check                # reporting; `cargo fmt` rewrites
cargo test --workspace --all-features
```

| Purpose | Command |
| --- | --- |
| build | `cargo build` |
| test | `cargo test` |
| single test | `cargo test <name>` |
| lint | `cargo clippy -- -D warnings` |
| format check | `cargo fmt --check` |

## Features and workspaces

**A bare `cargo test` in a workspace tests the current package only**, and it
tests the default feature set. A change that compiles under the defaults can
fail under `--all-features`, and CI usually runs the wider one. Check which
before reporting a suite as passing (`[[policies/engineering]]`).

## Failure handling

- A borrow-checker error is a design statement, not an obstacle. Reaching for
  `unsafe`, `clone()` everywhere, or `Rc<RefCell<_>>` to silence it changes the
  design — raise it (`[[policies/engineering]]`).
- `cargo update` moves the lockfile for dependencies nobody asked to move. Adding
  or bumping a dependency is a decision, not a mechanical step.
- A test that passes alone and fails in the suite is shared state; tests run in
  parallel threads by default. `--test-threads=1` diagnoses it.
- **Never `cargo publish`.**
