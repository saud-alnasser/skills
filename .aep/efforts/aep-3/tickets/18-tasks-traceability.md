---
status: resolved
blocked-by: [06]
---

# feat(tasks): a ticket that traces to no requirement fails

## Outcome

Splitting the spec from the plan removed the mechanism that kept one claim from living in two files. `/tasks` replaces it: a ticket whose criteria trace to no requirement in the spec is an error rather than a warning.

## Acceptance Criteria

- [x] Criterion 31: `/tasks` exits non-zero on a ticket whose criteria trace to no requirement, and names the ticket.
- [x] The check is stated in the skill as the thing that replaces the one-file rule, so a later reader can see what was traded.
- [x] The suite asserts the check exists and the guard is broken deliberately once.

## Relevant areas

`src/skills/tasks.md`, `src/scripts/validate.mjs`, `src/scripts/verify.mjs`.

## Constraints

This catches a ticket with no requirement. It does not catch a plan that contradicts one, and the skill says so rather than implying wider coverage.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

## Implementation notes

The check lives in `validate.mjs` and `/tasks` runs it as step 6, so criterion
31's "exits non-zero" is the script's exit rather than a claim in prose.

**A citation is checked against what the spec numbers, not merely for being
present.** `Criterion 99` against a spec with two criteria fails and quotes the
number back, because a renumbered spec leaves behind references that still look
like references. Only the ticket's `## Acceptance Criteria` section counts; a
citation in `## Notes` does not satisfy it.

**Scoped to efforts whose spec is not `implemented`.** Run unscoped, the check
failed 25 tickets across six landed efforts that predate the convention. Editing
them would rewrite the record of what was reviewed, which requirement 48 already
forbids for the migration and forbids here for the same reason. The skip is
named in the summary, because a check that silently does not fire reads exactly
like one that passed. The hole this leaves is stated in the skill: an effort
marked `implemented` mid-run stops being checked.

**One real drifter found:** `efforts/readable-output/tickets/11-help-routing.md`
cites nothing, in an effort that uses the convention throughout. Its effort had
landed as `#44` with all eleven tickets resolved while its spec still read
`status: accepted`, so the status was corrected to `implemented` and the ticket
is left as the record. Worth knowing that the ticket which traced to nothing was
the one appended last.

**Two corrections carried in the same pass**, both of them things this ticket's
own files were asserting falsely:

- `part-of` was retired by ticket 03, but `validate.mjs` still listed it as
  legal-on-a-ticket and `skills/tasks.md` still told authors to write it. Both
  removed, which is criterion 44.
- `verify.mjs`'s closing summary still said it does not check "whether each mode
  genuinely gives something up". Modes were removed in ticket 04. It now names
  the posture that replaced them.

**Fire-check**, both arms, against `efforts/aep-3/tickets/09-frontier.md`:

- citations stripped: `grep` confirmed none remained, then
  `09-frontier.md: its acceptance criteria cite no requirement or criterion of
  efforts/aep-3/spec.md`;
- citations renumbered past the end of the spec:
  `09-frontier.md: cites requirement 210, criterion 130, and the spec numbers
  none of them`.

The suite's `traceability` section covers both plus the skips, and its baseline
arm asserts a clean fixture passes, so a broken fixture cannot make the other six
arms pass by failing for an unrelated reason.
