---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: resolved
part-of: aep-3
---

# feat(protocol): ownership is looked up rather than declared

## Outcome

Ownership stops being a frontmatter claim and becomes a lookup. `contract.mjs` carries the directory table and a generated exact-path manifest of what the payload ships. `install.mjs` decides what to preserve and what to retire by consulting it rather than by reading `fields.owner`, and `validate.mjs` fails on a repository-authored file standing inside a protocol-owned directory.

## Acceptance Criteria

- [ ] Requirement 56: `contract.mjs` exports `PROTOCOL_DIRS`, `REPOSITORY_DIRS`, and a generated `PROTOCOL_FILES` of exact shipped paths, and the generation runs as part of building the payload rather than beside it.
- [ ] Requirement 57 / criterion 41: placing a repository-authored `.md` inside a protocol-owned directory fails `validate.mjs` by name, and the message says where the file belongs.
- [ ] Criterion 42: an upgrade into a fixture preserves every repository-owned artifact and replaces every protocol-owned one, with no artifact declaring which it is.
- [ ] `install.mjs`’s `repositoryOwned()` and `copyDir()`’s retirement check no longer read any frontmatter field.
- [ ] `contract.mjs` no longer exports `DIRECTORY_OWNERS`, and `validate.mjs`'s use of it is replaced by the stray-file check rather than deleted.
- [ ] The `manifest` section of the suite asserts the table and the manifest agree with the payload, and the guard is broken deliberately once and watched to fail with the right name.

## Relevant areas

`src/scripts/contract.mjs`, `src/scripts/install.mjs`, `src/scripts/payload.mjs`, `src/scripts/validate.mjs`, and the `manifest` section of `src/scripts/verify.mjs`.

## Constraints

This lands before anything else in the effort, because every later step consults what it builds. The tree it runs against still carries `owner:` on every artifact, so the new lookup must be correct while the old field is still present and must not read it.

## Notes

Two findings raised rather than taken, both for tickets that own the file:

- `applyMoves` in `install.mjs` still reads `fields.owner` to tell a vacated
  protocol file from a repository file the repository wrote at that name. The
  manifest names what ships now and a move source by definition does not, so the
  distinction is unrecoverable from location. Ticket 17 owns `update` and this
  goes with it.
- The seeded forge reference records a sub-issue resolution this repository has
  never followed. Ticket 14 owns it.

One thing added that the ticket did not ask for, and the reason it is in scope
rather than raised: criterion 3 removes the protection that a declared
`owner: repository` gave a file standing at a shipped path, and dropping it with
no replacement ships a silent data-loss path. `copyFile` now reports any target
whose content differs from what it is about to write. The protection is recovered
from content instead of declaration, and it is strictly wider, because it also
catches an edit to a genuinely protocol-owned file.

Boundary corrected during implementation: the four remaining enums (`KINDS`,
`MODES`, `REPORT_FORMS`, `MODELESS_SKILLS`) moved to ticket 02, because every one
of them has a live consumer in `validate.mjs` or `verify.mjs` that ticket 02
rewrites. Removing an export and its only consumers is one atomic change, and
splitting it across two tickets leaves the tree unable to validate in between.
`DIRECTORY_OWNERS` stays here because this ticket is what replaces it.

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
