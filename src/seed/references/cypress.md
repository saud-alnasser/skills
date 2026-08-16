---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "running this repository's Cypress tests"
---

# Reference — Cypress

**This file is yours.** Installed because a Cypress configuration was detected.
Read that config for the base URL and whether anything starts the app.

## Commands

```sh
npx cypress run                          # headless — the automated form
npx cypress run --spec <path>
npx cypress run --browser chrome
npx cypress open                         # interactive GUI; never in an automated run
npx cypress verify                       # confirms the binary is installed
```

| Purpose | Command |
| --- | --- |
| e2e | `npx cypress run` |
| single spec | `npx cypress run --spec <path>` |

**The app must be serving before `run` starts** unless a script wraps it
(`start-server-and-test` is the usual one). Cypress against a dead port reports
a failed visit, which reads like a routing bug.

## Failure handling

- `cy.wait(<ms>)` is a fixed sleep and hides races. Wait on the thing —
  an alias, a request, an assertion — not on time.
- A test that passes in `open` and fails in `run` is usually viewport size or
  animation timing, both of which the GUI hides.
- Retries configured in `cypress.config` turn a flaky test green. Check whether
  a passing run used them before trusting it (`[[rules/evidence]]`).
- Never run against anything but a local or designated test environment.
