---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: uniform-reporting
blocked-by: [04]
---

# refactor(skills): the reporting each skill invented is absorbed into the contract

## Outcome

The bespoke entry and exit narration that predates this effort either conforms
to the contract or is named in the policy as a declared extension of it. One
shape survives. Output — findings, graphs, reports the skill produces — is
untouched, and no skill acquires a check it did not perform.

## Acceptance Criteria

- [ ] `[[skills/implement]]`'s `## 0 — Position` becomes the `Standing` slot's
      content. The script still runs, on every invocation, with the same *nothing
      to report is still reported* reasoning intact.
- [ ] `[[skills/implement]]`'s close-out states that `review` and `commit` run as
      **stages of this turn** and open no report of their own.
- [ ] `[[skills/tdd]]` and `[[skills/domain]]` state that, reached from inside
      another skill, they open no report.
- [ ] `[[skills/specify]]`'s *State your understanding* keeps its full force as
      prose; its unverified half is what fills `Assuming`. The step is not
      deleted and not weakened.
- [ ] `[[skills/specify]]`'s sizing report lands in `Next`.
- [ ] **`[[skills/review]]`'s `## Correctness` and `## Standards`, and
      `[[skills/tasks]]`'s graph report, are unchanged.** They are output, not a
      preamble, and folding them into the skeleton is the failure mode of this
      ticket.
- [ ] **The set of skills invoking `position.mjs` is identical before and
      after.** Measured at ticket 04's commit: `commit`, `implement`, `install`.
      `specify` reads `position/marker.json` directly and invokes no script — a
      correction to what this ticket originally claimed.
- [ ] No skill restates the skeleton; each points at `policies/reporting.md` —
      the file ticket 01 creates — where it needs to name it.

## Relevant areas

`src/skills/implement.md` (`## 0 — Position`, `## 4 — Close out`),
`src/skills/specify.md` (steps 5 and 8), `src/skills/tdd.md`,
`src/skills/domain.md`. Read `src/skills/review.md` and `src/skills/tasks.md` to
confirm they need no change — reading them is part of the work.

## Constraints

- **The existing reporting is precedent, not competition.** `/implement`'s step 0
  exists for a stated reason. If the contract cannot express that reason, the
  contract is wrong and this returns to `[[skills/plan]]` — the step is not
  quietly weakened to fit.
- **Absorb narration, never output.** The test: would a human reading this line
  learn something about the *work*, or about *where the agent is*? The first is
  output and stays where it is.

## Notes

Acceptance criterion 9 in [[efforts/uniform-reporting/spec]] is what this ticket
discharges, and criterion 2a is the guard against the way it most plausibly goes
wrong.
