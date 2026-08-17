---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test]
use-when: "running this repository's end-to-end browser tests"
---

# Reference — Playwright

**This file is yours.** Installed because a Playwright configuration was
detected. Read that config for the projects, the base URL, and whether it starts
the app itself.

## Prerequisites

```sh
npx playwright install --with-deps   # browsers; needed once per machine or image
```

If the config declares a `webServer`, Playwright starts the app itself. If it
does not, **the app must already be running** — and a suite run against nothing
fails in a way that reads like a broken selector.

## Commands

```sh
npx playwright test                      # headless, all projects
npx playwright test <path>
npx playwright test -g "<name>"
npx playwright test --project=chromium
npx playwright test --reporter=list      # readable in a terminal
npx playwright show-report               # opens a browser — interactive only
```

| Purpose | Command |
| --- | --- |
| e2e | `npx playwright test` |
| single spec | `npx playwright test <path>` |

## Verification

A run reporting **0 tests** exits zero. Check the count against what the config
should have matched.

## Failure handling

- A timeout is usually a selector that never resolves, not a slow machine.
  `--trace on` and the report say which.
- **Never add a fixed sleep to stabilise a test.** Playwright's assertions
  auto-wait; a sleep hides the race rather than removing it.
- A test that only fails in CI is usually viewport, timezone, or a missing
  browser dependency — reproduce with the CI project before changing the test.
- These tests hit a real application. Never point them at anything but a local
  or explicitly designated test environment.
