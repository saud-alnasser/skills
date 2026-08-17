---
aep: 2.4.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [test, implement]
report: full
use-when: "building a behaviour test-first, or pinning a bug down before fixing it"
---

# /tdd — test-driven development

A sub-skill. Reached from inside `[[skills/implement]]` and `[[skills/prototype]]`
rather than started on its own — and reached that way it is **a stage of that
turn**, opening no report of its own (`[[policies/reporting]]`). Invoked
directly, it is the turn's outermost skill and reports like any other.

**Enters `[[modes/test]]`,** returning to the calling skill's mode to write the
production code.

## Procedure

The loop:

```
RED → GREEN → REFACTOR
```

1. **RED — write one failing test.** One behaviour. Then **run it and watch it
   fail**, and read the failure message: it must fail for the reason you intend.
   *A test that has never failed has never been shown to test anything.*
2. **GREEN — write the simplest code that passes.** Simplest, not best. Resisting
   the urge to generalise here is the discipline; generalising now is how you
   build the wrong abstraction confidently.
3. **REFACTOR — improve the code with the test green.** Both the production code
   and the test. Run the suite after each step.

Repeat, one behaviour at a time.

## For a bug

1. **Write the test that reproduces it, and watch it fail.** If you cannot make
   it fail, you have not found the bug — you have found a theory about it.
2. Fix.
3. Watch it pass.
4. **Confirm the test would catch a regression**: undo the fix, see it fail
   again, redo the fix. *Why: a green suite after a change proves nothing until
   you have confirmed the change was actually applied and the test was actually
   watching.*

## Constraints

- **Never write the production code first and the test after.** A test written
  against code that already works asserts what the code does, including its bugs.
- One reason to fail per test.
- Test behaviour through the interface a caller uses. Reaching into internals
  couples the suite to today's shape. `[[skills/tdd/tests]]` has what that means
  in practice and the four ways it goes wrong; `[[skills/tdd/mocking]]` has the
  narrow exception, for things that genuinely cannot be called in a test.
- Name the test for the case: what is true, under what conditions.
- **Follow the repository's conventions** — location, naming, runner — over any
  default. `[[references]]` records how the suite is actually invoked here.
- Never weaken a test to make it pass. If a test is wrong, say why and fix it
  deliberately.

## Done when

Every behaviour in scope has a test that was watched failing, the suite passes,
and no test asserts an implementation detail.
