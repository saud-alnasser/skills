---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
---

# refactor(docs): the README and the changelog read as governed text

## Outcome

This repository's own governed documentation conforms to the policy it ships.
`README.md` and `CHANGELOG.md` lose their em dashes. `specs.md` and `AGENTS.md`
are exempt and are not touched.

## Acceptance Criteria

- [ ] `README.md` and `CHANGELOG.md` carry no em dash. Counts before this ticket
      are 16 and 67 (criterion 10).
- [ ] `specs.md` and `AGENTS.md` are byte-identical to their state before this
      ticket. Their 166 em dashes stay (criterion 10).
- [ ] `verify.mjs`'s existing check that `CHANGELOG.md` contains a heading for the
      version of record still passes.
- [ ] No changelog entry changes what it claims a release did. This is a prose
      pass over history, not a correction of it.

## Relevant areas

`README.md` and `CHANGELOG.md` at the repository root.

## Constraints

- **The exemption is the point of the second criterion.** A sweep that walked
  every Markdown file at the root would quietly govern `specs.md`, which
  requirement 2 exempts because its reader is the agent building the protocol.
- Rewriting a released changelog entry's meaning would misstate what shipped.
  Change how it reads, never what it says.

## Notes

Independent of every other ticket: it touches no file any of them do.
