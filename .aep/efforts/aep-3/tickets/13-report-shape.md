---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [03]
---

# feat(policies): the turn report is four slots and a ledger

## Outcome

`policies/reporting` fixes four slots at one line each, a ledger between them written for both the human and the run that wrote it, and the rule that a run stopping early names in `Next` what would clear it. The `report: full | short` contract is gone.

## Acceptance Criteria

- [ ] Criterion 26: a ten-ticket run emits exactly four slot lines plus ten ledger lines, and no slot line exceeds one line.
- [ ] Criterion 27: a run stopping on a trip-wire has a `Next` naming what would clear it.
- [ ] Requirement 38: the exemption for text a protocol agent reads is narrowed so the ledger is governed as human-readable and as machine-stable at once.
- [ ] The policy no longer defines `report:`, and no skill declares it.
- [ ] The suite’s `reporting` section asserts the slot names, their order, the one-line rule, and the ledger contract.

## Relevant areas

`src/policies/reporting.md`, `src/skills/`, and the `reporting` section of `src/scripts/verify.mjs`.

## Constraints

This governs what is stated and in what order. It names no runtime and caps no output that a skill produces between the slots.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
