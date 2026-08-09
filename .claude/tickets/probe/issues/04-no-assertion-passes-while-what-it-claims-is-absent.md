---
title: 'refactor(verify): no assertion passes while what it claims is absent'
status: obsolete
blocked-by: [03]
part-of: probe
---

## Problem

The sweep produces a list of assertions that pass while what they claim is gone.
Each one is a hole in the only net this repository has: the acceptance criterion
it was written for is not being checked, and the green run says it is.

A vacuous assertion is worse than a missing one. A missing assertion is a gap
somebody can notice; a vacuous one is a gap wearing the appearance of coverage,
and it costs the reader's trust in every assertion beside it.

## Outcome

Every assertion the sweep proved vacuous either checks its claim or is gone, and
which of the two happened is decided by whether the claim was worth checking —
not by which is easier to write.

Where an assertion was pinned to the phrasing of a sentence rather than to its
subject, it is re-anchored to the subject, so rewording the sentence no longer
turns the guard off. Where a loop could skip every candidate and finish green, it
cannot. Where existence stood in for content, the content is read.

Only what the sweep proved is touched. The prose pins are not a defect list, and
an assertion that survives its perturbation is left alone.

## Acceptance

- Every assertion the sweep proved vacuous now fails under the perturbation that
  exposed it, or has been removed with the reason recorded.
- No assertion was removed on judgement alone; each removal cites the run that
  showed it passing while its subject was absent.
- Re-running the sweep's perturbations finds no assertion still passing while
  what it claims is absent.
- The acceptance criteria the suite checks are unchanged — no ticket lost its
  coverage, and any that gained coverage says so.
- Assertions the sweep did not implicate are untouched, including the four
  duplicate names and the comments.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Obsolete

Nothing to repair: the sweep proved 908 assertions sound and none vacuous.

Fifteen assertions are left undecided, enumerated in the evidence record with the
reason each was unreached. Settling them was weighed and declined — it needs
perturbations this effort did not build, and building general machinery to decide
fifteen assertions costs more than the answer is worth. The record points at them
for whoever wants them later.

The blocked note below is kept as the reason this ticket existed.

## Blocked

**The input is empty, and not because the suite is clean.** This ticket repairs
what ticket 03's sweep proved vacuous. The sweep proved 908 assertions sound and
**none** vacuous, so there is nothing here to repair — and the 219 it did not
reach are undecided rather than fine.

The plan assumed a perturbation sweep could establish vacuity. It cannot. A
failure under perturbation proves an assertion is attached to something; a
survival proves only that the perturbations somebody thought to run did not reach
it, and that set turned out to be smaller than the ways an assertion can be
attached. Every revision of the count was downward — 317 to 0 — and each came
from reading one assertion rather than a total.

Deciding the remaining 219 needs perturbations this effort did not build, and
each is a design question rather than a repair:

- **creation** — five assertions claim a path does *not* exist, which only
  creating it tests
- **member addition** — a claim universal over the tree's membership holds
  vacuously on an empty tree and fails only when an uncategorised member is added
- **placed injection** — a guard reading frontmatter, or scanning one subtree,
  is unreachable by an injection appended to the end of some other file

Whether that is worth building, or whether the goal should be pursued another way
entirely, is not this ticket's to decide. It needs `/design`.
