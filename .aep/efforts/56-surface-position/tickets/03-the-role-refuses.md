---
status: resolved
blocked-by: [02]
---

# feat(protocol): the role refuses, in the policy and in the implementer's brief

## Outcome

`policies/execution` states what a run does about the role it computed, in the
place it already states what a run does about the isolation it detected. The
implementer's brief states its existing constraints as keyed on that computed
role rather than asserted as prose. An agent that has lost its brief can still
derive what it may not do.

## Acceptance Criteria

- [x] Criterion 7: six assertions. The guard locates each constraint by its own
      bold lead and requires the role **inside that lead**, so it distinguishes
      "the constraint is missing" from "the constraint is here but keyed on
      nothing". Independently re-checked at integration by reverting the brief to
      its pre-effort wording: `the brief states "**You do not integrate.**"
      without naming the role it is keyed on`. The guard rejects the exact
      sentence this repository carried before the effort, not a synthetic one.
- [x] The policy carries a four-row table, and an assertion counts its rows and
      fails on any role with an empty May or MUST NOT cell. `role: none` and
      `role: unknown` each get a paragraph-scoped assertion rather than a
      file-wide match, because "before its first write" already appears elsewhere
      in the policy and a file-wide grep would have passed on the old text alone.

**The finding worth keeping.** The builder's first fire-check was itself wrong.
It perturbed `does not integrate` to `You do not integrate` while the guard's
subject was the literal `does not integrate`, so the guard went red for the wrong
reason: it reported no constraint at all, rather than a constraint keyed on
nothing. A red result proves nothing until you confirm the perturbation removed
only what you meant. Widening the subject to `do(?:es)? not integrate` fixed both
the guard and the check of it.

## Relevant areas

`src/policies/execution.md` — the "Claiming, before dispatching" section, which
already carries the isolation rule and the "orchestrator is the only integrator"
sentence. `src/agents/implementer.md` — the Constraints list, currently "You do
not integrate", "You do not dispatch", "Never touch the main checkout".
`src/scripts/verify.mjs`.

## Constraints

- **The refusal is the skill's, not the script's.** `scope.mjs` reports and never
  exits non-zero on a role. The reasoning is in
  [[efforts/56-surface-position/plan]] under What lost, and a diff that moves the
  refusal into the script contradicts the accepted approach.
- Key on the role, never on the isolation's enforcement. The existing warning
  about enforcement describing the clone rather than the checkout still applies.
- Shipped text may not cite `specs.md` or a section number ([[rules/authoring]]).
  Where a citation was carrying a reason the prose does not state, state the
  reason.
- Every assertion added here is seen to fail first.

## Notes

**The assertion for criterion 7 is the one most likely to pass while doing
nothing.** "The constraint names what it is keyed on" can be satisfied by a regex
matching the sentence around the constraint. The required perturbation is to
delete the keying clause while leaving the constraint in place, and confirm the
assertion goes red with the right name.
