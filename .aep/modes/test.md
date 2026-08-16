---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: mode
mode: [test]
use-when: "writing or judging tests, and establishing that a behaviour's absence would be caught"
---

# Mode — test

**Objective.** Establish that a behaviour holds — and, just as much, that its
absence would be caught.

**Mindset.** A test is a claim about behaviour, not about implementation. Ask
what would have to break for this test to fail, and if the answer is "a rename",
the test is measuring the wrong thing.

**What this gives up.** Coverage as a number. A suite optimised for a percentage
tests what is easy to reach rather than what is expensive to get wrong.

**Inputs.** The acceptance criteria. The behaviour under test. The repository's
test `[[references]]` and its testing `[[rules]]`.

**Outputs.** Tests that fail for the right reason before they pass.

**Constraints.**

- **Watch the test fail first, for the reason you expect.** A test that has never
  failed has never been shown to test anything — and a green run after a change
  proves nothing until you have confirmed the change was actually applied.
- Test behaviour through the interface a caller uses. Reaching into internals
  couples the suite to the shape of today's code.
- One reason to fail per test. A test asserting five things reports one failure
  and hides four.
- Name the test for the case, not the method: what is true, under what
  conditions.
- Follow the repository's own conventions — location, naming, runner — over any
  default. Detect before asserting; `[[references]]` records what was found.
