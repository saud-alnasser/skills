---
status: resolved
blocked-by: [03]
---

# feat(policies): the turn report is four slots and a ledger

## Outcome

`policies/reporting` fixes four slots at one line each, a ledger between them written for both the human and the run that wrote it, and the rule that a run stopping early names in `Next` what would clear it. The `report: full | short` contract is gone.

## Acceptance Criteria

- [x] Criterion 26: a ten-ticket run emits exactly four slot lines plus ten ledger lines, and no slot line exceeds one line.
- [x] Criterion 27: a run stopping on a trip-wire has a `Next` naming what would clear it.
- [x] Requirement 38: the exemption for text a protocol agent reads is narrowed so the ledger is governed as human-readable and as machine-stable at once.
- [x] The policy no longer defines `report:`, and no skill declares it.
- [x] The suite’s `reporting` section asserts the slot names, their order, the one-line rule, and the ledger contract.

## Relevant areas

`src/policies/reporting.md`, `src/skills/`, and the `reporting` section of `src/scripts/verify.mjs`.

## Constraints

This governs what is stated and in what order. It names no runtime and caps no output that a skill produces between the slots.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

### Three slots removed, and where each went

`Request` restated what the ledger and the skill's own output already say. `Stages` was a second statement of the procedure, and the suite's `stageNames` parser existed only to check that the two agreed; both go, because a parser asserted against itself is a test of a test. `Unsettled` becomes the second half of `Next`, which is where a reader looks for what happens next and therefore the only place a remedy is read.

### A notice that instructed an upgrade to add a retired field

`NOTICES` carried a 2.4.0 entry telling readers to add `report: full` or `report: short` to their own skills. A tree crossing 2.4.0 on its way to 3.0.0 reads every notice in between, so it would have been instructed to add a field this release removes. Removed. A notice is an instruction rather than a changelog entry, and an instruction that is now wrong is worse than an absent one.

### Where the ledger is produced

The policy fixes its shape; nothing emits one yet. Ticket 11 builds the run log against this contract, and ticket 10 is what crosses enough tickets in a turn for the shape to matter.
