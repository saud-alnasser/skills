---
status: resolved
blocked-by: [03, 10]
---

# feat(policies): the orchestrator ticks what it verified, and a child still never does

## Outcome

`policies/execution`'s ticking rule survives the move of review to the effort. The
orchestrator ticks a criterion at the moment it verifies it, carrying inline what
verified it; a dispatched child still never ticks its own. The one case given up
is named rather than left as a silent exception, and the run log stops counting
review attempts per ticket.

## Acceptance Criteria

- [x] Criterion 13: the presence half is checked against the section sliced to
      `### Ticking a criterion`, so it cannot be satisfied by text elsewhere in
      the file. Independently re-checked at integration by standing both
      sentences side by side: `the unqualified ticking rule does not survive
      beside the narrowed one` fired **alone**, `2028 passed, 4 failed` to
      `2027 passed, 5 failed`, while the presence assertion stayed green. That
      contrast is what proves the guard discriminates "present but contradictory"
      from "missing entirely", which are different defects.
- [x] The reasoning sits in the section beside the rule. One assertion requires
      all three of the wave-of-one clause, "the whole of what this section gives
      up", and the sentence that the effort review now runs over the whole effort
      branch. A separate assertion pins the surviving resumption reason on both
      its clauses, so a diff cannot take the reason out along with the rule.
- [x] The run log line now reads `the review round and what it found`, in both
      the policy's durability table and the runner's step 7. One assertion checks
      the old wording is gone from both.

## Relevant areas

`src/policies/execution.md` — the "Ticking a criterion" section, and the run log
line listing "review attempts per ticket". `src/skills/implement.md`'s step 7,
which writes that line. `src/scripts/verify.mjs`.

## Constraints

- **Narrow, do not delete.** "The agent that wrote the code never ticks its own"
  keeps its force for a dispatched child, which is where it does the most work.
  What goes is only its application to a wave of one, which
  `[[skills/implement]]` builds inline.
- **Say what compensates.** The effort review is now guaranteed to run over
  inline-built work, and that is the whole reason the narrowing is safe. Without
  the sentence, this reads as a guarantee traded for convenience.
- The resumption reason survives: a resumed run trusts a tick without re-deriving
  it, and that still requires the tick to mean somebody checked.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- Seen to fail first, in the specific form criterion 13 names: leave both
  sentences in the tree and confirm the assertion goes red.

## Notes

Blocked by 03 because both edit `policies/execution.md`. 03 adds the role rule to
the claiming section; this rewrites the ticking section and one run log line.

This is the ticket where the effort supersedes a rule the protocol states with a
reason attached. The reason is not wrong, so it is kept and its scope is reduced.
A diff that removes the reason along with the rule has done something else.
