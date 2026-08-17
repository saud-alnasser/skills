---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: policy-rule-split
---

# refactor(policies): confirm or replace the name `artifacts`

## Outcome

The largest policy is named for what it holds, or the current name is confirmed
with a reason.

## Acceptance Criteria

- [ ] A decision recorded here: keep `artifacts`, or rename.
- [ ] If renamed, every link and the `MOVES` manifest move with it, and the
      rename itself is a declared move rather than a silent path change.

## Relevant areas

`src/policies/artifacts.md` — 175 lines absorbing the former `artifacts`,
`ownership`, and `placement` rules.

## Notes

Raised by review. `[[policies/engineering]]` says **name a file for the one thing
it holds**; this one holds three — whose a file is, where it goes, what shape it
takes — unified only by *it is an AEP artifact*. That is a real unifying idea and
the three do fire at one moment, which is why the merge was made; but it is the
weakest of the four names and the one a later reader is most likely to find
surprising.

**Renaming is not free**, which is why this is a ticket rather than a fix: the
path is in `MOVES`, in the bootstrap's routing table, and in every link that
points at it.

## Resolution — the name stays

**The cost argument above is wrong and is corrected here rather than left to
mislead.** This release is not out, so a rename would not be a second move: the
`MOVES` entries would simply point at the new name, and no tree exists that would
need migrating through the intermediate state. Renaming was cheap. The name stays
on its merits.

Those merits: the three questions the file answers — whose a file is, where it
goes, what shape it takes — are three questions about **one subject**, and that
subject is an AEP artifact. `name a file for the one thing it holds` is satisfied
by reading the one thing as the subject rather than as the number of sections.

Every alternative considered is vaguer than what it replaces. `stewardship` and
`curation` name an attitude rather than a subject. `authoring` covers writing a
file but not owning one, and would collide with this repository's own
`rules/authoring.md`, which is a different thing entirely.

**This is the weakest of the four names and it is being kept, not defended as
obvious.** If a later reader reaches for it expecting only the frontmatter
contract and is surprised to find ownership there, that reader is right and this
decision was wrong.
