---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [04, 05, 06]
---

# feat(protocol): the bootstrap names seven primitives and states ownership once

## Outcome

The bootstrap describes what tickets 01 to 06 built: seven primitives, the ownership table, four workflow commands, and `version:` as the single release of record.

## Acceptance Criteria

- [ ] Requirement 40 / criterion 29: the primitives table has seven rows, and evidence, tasks, worktrees, and position are described where they are used rather than given rows.
- [ ] Requirement 56 / criterion 40: the bootstrap states which directories the protocol owns and which the repository owns, naming the bootstrap itself and the index individually.
- [ ] Requirement 58: the bootstrap carries `version:` and is the only file naming a release.
- [ ] The workflow line reads four commands, and the capability sentence beneath it names what is now a stage.
- [ ] The suite’s `protocol.md` section asserts the row count, the ownership table, and the version field.

## Relevant areas

`src/protocol.md` and the `protocol.md` section of `src/scripts/verify.mjs`.

## Constraints

The bootstrap describes; it does not govern. Anything that reads as a requirement belongs in a policy, and anything already in a policy is not repeated here.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
