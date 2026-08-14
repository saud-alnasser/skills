---
owner: repository
title: "fix(build): the build refuses a shipped file that addresses a record by location"
status: open
blocked-by: [02, 03, 04, 05]
part-of: addressing
---

## Problem

The guard this effort needs does not exist. The one that does checks where an instruction
says a run *writes* — a leading-bold bare path, or the words *installed at* — and every
reference this effort corrects is prose sending a reader to *read*, so all 248 of them pass
it today.

Without a guard the corrections are 248 edits that nothing holds. The next person to write a
sentence about the ticket format has no reason not to name a path, and the release ships
with the defect reintroduced in one place.

## Outcome

A shipped file that addresses a store record by location fails the build, naming the file and
the line, and a file exempt from the check says why it is exempt.

## Acceptance

- A shipped file addressing a store record by location fails the build, naming the file and
  the line.
- The guard's subject is the departed concept rather than one spelling of a path: a file
  naming the departed set as prose words is caught as surely as one naming a path.
- Exemptions are enumerated by filename with the reason each is exempt, and an exemption
  carrying no reason fails the build. A directory-wide skip is not an exemption.
- Reintroducing a path into any of the four surfaces this effort corrected fails the build —
  demonstrated per surface, not once.
- `.claude/rules/` references pass, and a perturbation confirms the guard is not passing them
  by failing to look.
