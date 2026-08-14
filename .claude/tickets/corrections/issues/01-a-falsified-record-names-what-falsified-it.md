---
owner: repository
title: "feat(knowledge): a falsified record names what falsified it"
status: resolved
blocked-by: []
part-of: corrections
---

## Problem

A finding declares `falsifies` and the record it falsifies declares nothing back, so
the correction is unreachable from the only side that needs it: a reader who opens
or queries the decision gets the decision. Supersession is checked at both ends for
exactly this reason, and this edge — the one that carries a correction to a frozen
record — is the pair that has no opposite.

The consequence is not hypothetical. Three accepted decisions are contradicted by
what shipped, all three findings are filed and indexed as waiting, and all three
ADRs read as true to anybody who opens one.

## Outcome

`falsifies` has an opposite. A record a finding falsifies declares `falsified-by`
naming it, the build fails a pair written at one end, and a query for the falsified
record returns the finding in its closure. The freeze rule names the three fields
that move after commit rather than two, and the three decisions this session
falsified declare their return edge.

## Acceptance

- A record declaring `falsifies` whose target declares no `falsified-by` naming it
  back fails the build, naming both records — and the same holds with the two
  fields exchanged.
- A `falsified-by` declared with nothing in it builds, exactly as `superseded-by: []`
  does — the ADR template ships the field empty so it is discoverable, so refusing
  an empty declaration would refuse every ADR the template produces.
- A `falsified-by` citing an id no record carries fails, exactly as every other
  declared edge does.
- A query for a falsified record returns the finding in its closure, attributed to
  `falsified-by`, and does not reach what that finding cites.
- The shipped guide states that `status`, `superseded-by`, and `falsified-by` are
  the fields that move after an ADR is committed, and states why a pointer to a
  contradicting record is not reasoning.
- ADRs 0089, 0091, and 0095 each declare `falsified-by` naming the finding that
  falsified them, in the form this repository writes edges in today.
