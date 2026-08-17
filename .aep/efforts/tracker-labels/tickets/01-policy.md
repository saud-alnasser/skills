---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: tracker-labels
---

# feat(policies): an external task is findable in its own tracker

## Outcome

`policies/execution.md` states the requirement that an external task's effort
membership is carried where the tracker can answer it as a query, names the one
fact, and says why that is not the mirroring the protocol forbids. The
governance layer says what MUST be true; it states no procedure.

## Acceptance Criteria

- [x] The policy requires an external task to be attributable to its effort by a
      query the tracker answers natively.
- [x] It names **one** fact — effort membership — and no others.
- [x] It excludes `status` **with its reason**: the issue's own state already
      carries open/resolved, and a second copy disagrees with it on the first
      issue closed from the tracker's UI.
- [x] It excludes the dependency **edge with its reason**: a label expresses set
      membership, and a `blocked-by-42` label has to be removed by someone when
      42 closes, which nothing in the tracker knows to do.
- [x] It states why this is not mirroring: the fact stays in the tracker,
      expressed in the tracker's own mechanism, and nothing about it is written
      into `.aep/`.
- [x] It states **native mechanism before label** as a requirement, leaving *how
      to find out what is native* to the skill note.
- [x] No procedure, no commands, no tracker named. Those are the note's and the
      references'.

## Relevant areas

`src/policies/execution.md` — beside the sub-agent and independence material,
which is where the frontier is already governed.

## Constraints

- Shipped text may not cite `specs.md` or a section number — `verify.mjs`
  asserts it over the whole payload.
- A policy states what MUST be true. The moment it states a procedure, it and
  the note at `src/skills/tasks/labels.md` become two homes for one rule.

## Notes

The reason this is governance rather than a skill: *independence is read, never
inferred* is already AEP's, and today AEP requires that discipline while giving
external-tracker repositories no means to keep it.
