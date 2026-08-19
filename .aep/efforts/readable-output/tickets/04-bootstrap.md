---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
blocked-by: [01]
---

# feat(protocol): the bootstrap says every text is written for its reader

## Outcome

The obligation reaches the agent before it writes anything. The `Every turn
reports` invariant gains a clause pointing at the widened policy, and the
governance table's trigger for that policy widens to match its new `use-when`.

## Acceptance Criteria

- [ ] The `Every turn reports` invariant carries a clause stating that text a
      human reads is written for one, and points at `[[policies/reporting]]`
      rather than restating what it says (criterion 1).
- [ ] The governance table's row for that policy states the widened trigger, and
      it agrees with the policy's own `use-when`.
- [ ] `src/protocol.md` stays at or under 8192 bytes. Measure it, do not assume:
      `wc -c < src/protocol.md`. Headroom before this ticket is 441 bytes.
- [ ] `verify.mjs`'s bootstrap section still passes, including that the invariant
      points at the contract rather than restating it, and that the bootstrap does
      not become a second home for the slot set.
- [ ] The rendering word list still finds nothing in `protocol.md`.

## Relevant areas

`src/protocol.md`, the invariants block and the governance table at the end.
`src/scripts/verify.mjs` holds `PROTOCOL_BUDGET_BYTES` and the assertions that
judge this file.

## Constraints

- **The bootstrap points, it never restates.** A copy of the reader test here is
  the second home the whole protocol argues against, and an existing assertion
  fails it.
- Both additions are measured against the budget before the release, not after.

## Notes

The budget is the reason this ticket is small and separate. Two clauses in 441
bytes leaves the next invariant with very little, which the spec records as a
technical risk.
