---
status: resolved
blocked-by: [13]
---

# feat(implement): the run passes its session identifier when it stamps

## Outcome

`--session` ships, `sessions` ships, the assertions ship, and nothing tells a run
to pass one. The field would be empty in every repository forever, which is
exactly the risk `spec.md` names under "a field nobody fills", shipped rather
than avoided.

The runner passes the identifier its harness gave it, where it has one.

## Acceptance Criteria

- [x] `skills/implement.md`'s stamp step passes `--session` with the identifier
      the runtime supplied (requirement 6, criterion 16).
- [x] It says the identifier comes from the harness and is never invented, and
      that a runtime supplying none stamps exactly as before (requirement 6,
      criterion 16).
- [x] It says what the field is for, so a reader does not mistake a diagnostic
      for a guard (requirement 6, criterion 6).
- [x] The suite fails a shipped runner whose stamp step does not pass the
      identifier, and the assertion has been seen to fail with its subject
      removed (requirement 11, criterion 12).

## Relevant areas

`src/skills/implement.md`, the stamp step under "Landing it".
`src/scripts/position.mjs` for the flag, which is unchanged by this ticket.

## Constraints

**Optional stays optional.** A runtime that exposes no session identifier must
stamp exactly as it does today, so the instruction is conditional and the flag is
never passed empty.

AEP does not invent an identifier. `specs.md` section 20 forbids it, and an
invented one would be a second copy of nothing.

## Notes

Found by asking who calls the flag, which no assertion in this effort was asking.
The mechanism was verified end to end and never wired to a caller.
