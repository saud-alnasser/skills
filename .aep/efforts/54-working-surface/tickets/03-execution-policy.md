---
status: resolved
blocked-by: [01]
---

# feat(policies): a run claims a working surface, not only a branch

## Outcome

"Claiming, before dispatching" says the branch is the claim, which was written
when one run per clone was the only shape. It gains the other half: a run claims
a working surface as well, and a worktree is how it holds one.

The sentence that the orchestrator is the only integrator gains the place the
integrating happens, so a run cannot satisfy it while standing in a checkout
another run is moving.

## Acceptance Criteria

- [x] `policies/execution.md` states that a run claims a working surface as well
      as a branch, and that a worktree is how it holds one (requirement 4,
      criterion 4).
- [x] It states that the run takes a worktree where the isolation is `checkout`
      and takes none where the runtime already gave it one, keyed on the kind
      rather than the enforcement (requirement 2).
- [x] Under "Returning, and integrating", the orchestrator being the only
      integrator names the run's own worktree as where that happens
      (requirement 3).
- [x] The existing rule that a claim held elsewhere is never taken is unchanged,
      and now also covers a surface (requirement 4).

## Relevant areas

`src/policies/execution.md`, sections "Claiming, before dispatching" and
"Returning, and integrating". `specs.md` section 18.1 as written by ticket 01,
which this policy restates for the run rather than re-deriving.

## Constraints

A policy is AEP's and states what MUST be done. It does not carry the
invocations: those belong to the skills and to `[[references/git]]`.

Do not restate the effort's spec here. The policy says what holds for every
effort, not what this one changes.

The claim read at the top of the section is still computed by `scope.mjs` and
quoted. This ticket adds nothing a run has to judge.

## Notes

Ordered before the two skill tickets so neither points at a line that does not
exist yet.

The policy currently says "the branch is the claim, and the parent creates every
branch in the set before dispatching anything." The addition sits with that
sentence rather than in a new section, because it is the same claim widened.
