---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [06]
---

# feat(tasks): a ticket that traces to no requirement fails

## Outcome

Splitting the spec from the plan removed the mechanism that kept one claim from living in two files. `/tasks` replaces it: a ticket whose criteria trace to no requirement in the spec is an error rather than a warning.

## Acceptance Criteria

- [ ] Criterion 31: `/tasks` exits non-zero on a ticket whose criteria trace to no requirement, and names the ticket.
- [ ] The check is stated in the skill as the thing that replaces the one-file rule, so a later reader can see what was traded.
- [ ] The suite asserts the check exists and the guard is broken deliberately once.

## Relevant areas

`src/skills/tasks.md`, `src/scripts/validate.mjs`, `src/scripts/verify.mjs`.

## Constraints

This catches a ticket with no requirement. It does not catch a plan that contradicts one, and the skill says so rather than implying wider coverage.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
