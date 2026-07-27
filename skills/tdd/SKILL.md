---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle — consult them before and during the loop, not after.

Test names and interface vocabulary come from the project's Context — `.claude/context.md` and any Domain Context the work touches. Respect the Decisions in `.claude/docs/decisions/` covering the area you're touching.

**The command for running one test file is in `.claude/tools/`,** written by `/configure` from this repo's actual tooling. Read it — the loop runs a single file many times and the whole suite once, and guessing that command is how the loop turns into a full-suite run per cycle. If there is no entry, say so rather than trying `npm test`.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists — and survives refactors because it doesn't care about internal structure.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams — where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything — agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?"

## Test layout — read it off the repository

Where test files go is the repository's decision, not Tenure's. Look at what is already there and match it; the precedence rule is in `CLAUDE.md`. Two layouts are common, and both are fine:

```text
adjacent                separated

feature.ts              feature/
feature.test.ts             src/feature.ts
                            tests/feature.test.ts
```

Adjacent is the default for a repository with no established pattern. Move to a separated directory when the reasons are real: integration tests grow, setup becomes complex, fixtures and utilities are shared across files, or the module gets large enough that its tests crowd out its source.

**Introduce no unnecessary test structure.** A directory tree, a helpers module, or a base fixture built before anything needs it is scaffolding for tests that do not exist yet — and it is the horizontal slicing below wearing a different shape.

## Anti-patterns

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological** — the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth — a known-good literal, a worked example, the spec.
- **Horizontal slicing** — writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead — one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to `/code-review`, not the red → green implementation cycle.

---

Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
