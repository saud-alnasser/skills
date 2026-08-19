---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
---

# feat(policies): the orchestrator owns the seams, the questions, and the account

## Outcome

`policies/execution.md` states what the orchestrator owns once the last child
returns. Today it requires only that a child's claim be reconciled against what
that child actually changed, which is an honesty check. This adds the three
things a child structurally could not do, bounds the first of them, and says how
a child's recorded question reaches the human.

## Acceptance Criteria

- [ ] All three obligations are stated: the seams, the decisions a child recorded
      and stopped on, and one account of the work (criterion 11).
- [ ] The seam pass is bounded at the surfaces children's diffs share, and
      anything else the orchestrator notices returns to the frontier as a task
      rather than being taken (criterion 12).
- [ ] The bound carries its reason: a bound read off `spec.md` cannot distinguish
      reconciling a seam from rebuilding a task, and the orchestrator is the one
      agent with no reviewer above it (criterion 12).
- [ ] The account clause states **both** halves: that it describes the work rather
      than the workers, and that sub-agent structure surfaces where it changed the
      outcome. A version carrying only the first half is the failing version
      (criterion 13).
- [ ] The present-the-question clause states that the orchestrator may reshape
      wording and never substance, and that what is asked and which options are
      offered survive unchanged (criterion 14).
- [ ] Attribution is stated to name the child as the **source** of the question
      rather than the author of its wording (criterion 14).
- [ ] The existing *the answer travels verbatim* text is unchanged.
- [ ] Every existing assertion in `verify.mjs`'s `policies` section still passes,
      including the six pinned external-tracker phrases and the two pinned
      sub-agent phrases.

## Relevant areas

`src/policies/execution.md`, in and around the *Returning, and integrating* and
*Human authority is never delegated downward* sections.

## Constraints

- **Nothing under `src/agents/` changes.** A diff touching those four files has
  overshot this ticket (requirement 13).
- The rule that one child builds one whole task is untouched. None of this
  reconciliation work is delegated downward.
- Pinned phrases elsewhere in the file use `\s+` between words because the payload
  rewraps at 80 columns. Reflowing a pinned line is safe; rewording it is not.

## Notes

The account clause is where this effort's two halves meet: what the orchestrator
writes is governed text under ticket 01's policy.
