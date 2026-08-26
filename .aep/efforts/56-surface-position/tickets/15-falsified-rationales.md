---
status: resolved
---

# fix(protocol): the rationales this effort falsified are corrected where they stand

## Where this came from

Review round one. Four sites where this effort made a sentence false and left it
standing. The first is the worst: it is verbatim the sentence this effort's own
`spec.md` quotes as the statement of the problem.

## Outcome

No shipped file still explains a rule with a premise this effort falsified.

## Acceptance Criteria

- [x] Requirement 11 and criterion 12: the converge rationale no longer calls
      converge the only stage with the whole diff in view and nobody reviewing
      it. The rule survives with a reason the change did not falsify: converge is
      the stage that decides whether the spec is met, and a stage that could edit
      the spec could close every gap by narrowing what was asked. Pinned by a new
      assertion that requires the rule present, the false clause absent, and the
      replacement reason there.
- [x] The resuming table now reads "the review round and what it found". The
      guard was widened from two file-specific wordings to a tree-wide sweep for
      the bare phrase, because the surviving text matched neither half.
- [x] `policies/reporting`'s `implement` row now reads "the claim, the isolation,
      and the marker's answer for the surface it entered", matching the three rows
      added beside it and the table's own framing.
- [x] `review.md`'s **Done when** now reads that accepting is the only one of the
      three outcomes that is the human's, so an agent cannot read it as gating a
      ticketed finding on them.

**A guard of mine failed its own fire-check, and that is why it was worth doing.**
The first version of the run-log sweep used `[^.|]` for the gap between "run log"
and "review attempts". The runner states it in a **table row**, so the gap is full
of pipes and the pattern could never reach its own subject. The perturbation
showed it: the converge guard fired and the sweep stayed silent on text that
plainly held the phrase. Widened to `[^.]`, both fire and name their file.

## Relevant areas

`src/policies/execution.md`, the converge rationale.
`src/skills/implement.md`, the resuming table.
`src/policies/reporting.md`, the `Position` table's `implement` row.
`src/skills/review.md`, **Done when**.
`src/scripts/verify.mjs`.

## Constraints

- **Correct the reason, never delete the rule.** Each of these sentences is load
  bearing for a rule that is still right. A diff that removes the rationale along
  with its false premise has removed a reason somebody will ask for again.
- Shipped text may not cite `specs.md`. No em dash.
- Seen to fail first, and confirm each perturbation removed only its subject.
