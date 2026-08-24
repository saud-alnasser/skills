---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [08, 11, 12, 13, 17, 18, 19]
---

# chore(dist): release AEP 3.0.0

## Outcome

The distribution is cut at 3.0.0 and this repository is reinstalled from it, which is what exercises the migration before it reaches anywhere else.

## Acceptance Criteria

- [ ] Criterion 46: the verification suite exits zero.
- [ ] `release.mjs` sets the version of record with one write and updates the baseline.
- [ ] The adapter is regenerated and is not stale.
- [ ] This repository’s installed tree is rebuilt from the distribution and validates, with every repository-owned artifact preserved.
- [ ] The changelog states what an upgrading repository has to know: the removed fields, the removed directory, the two removed skills, and the two classification mechanisms.

## Relevant areas

`src/scripts/release.mjs`, `src/scripts/adapters.mjs`, the changelog, and the installed tree.

## Constraints

Never restamp by hand. Cutting a release is one command, and the adapter is generated rather than edited.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
