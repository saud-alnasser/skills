---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: uniform-reporting
blocked-by: [01]
---

# feat(protocol): the bootstrap says that every turn reports

## Outcome

`src/protocol.md` carries one more invariant under **The invariants**: every
turn opens with a report and closes with a block, the unit is the turn, and the
shape is the one `policies/reporting.md` defines — the file ticket 01 creates.
It **links rather than lists**, and it fits
inside the existing byte budget.

## Acceptance Criteria

- [ ] The invariant states the turn unit and points at the policy.
- [ ] It does **not** enumerate the label set. Ticket 07 pins that set to exactly
      one payload artifact, and a list here fails that guard on the bootstrap
      itself.
- [ ] `src/protocol.md` remains at or under 8,192 bytes — the budget
      `verify.mjs` enforces — with the constant unchanged. It was 7,407 bytes
      before this ticket.
- [ ] The governance table lower in the file gains a row for the new policy, in
      the same *load when* idiom as the other four.
- [ ] The existing suite still passes: `protocol.md` answers every heading the
      suite requires, and does not become a second governance layer.

## Relevant areas

`src/protocol.md` — the `## The invariants` section, and the `## Governance that
loads when it applies` table beneath it. `src/scripts/verify.mjs` around line 348
is the budget assertion; around 372 is the required-headings assertion.

## Constraints

- **The bootstrap orients; it does not govern.** The invariant is one short
  paragraph in the register of the ones beside it — *Repository wins*,
  *Ownership is declared* — and the detail stays in the policy.
- Do not raise `PROTOCOL_BUDGET_BYTES`. If the invariant does not fit, it is too
  long, not the budget too small.

## Notes

Measured before planning: 7,407 of 8,192 bytes used, 785 free. The invariant is
expected to cost about 330.
