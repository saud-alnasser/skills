---
owner: repository
title: "feat(knowledge): records carry stable ids and the build refuses what it cannot address"
status: resolved
blocked-by: []
part-of: substrate
---

## Problem

A statement in the corpus cannot be cited, superseded, or checked, because it has no
identity apart from the file it sits in. Supersession is therefore written by hand at both
ends, and a claim made at one end and absent at the other is found by whoever trips on it
rather than by the build.

Nothing else in this effort can be built until a norm can be named. The row is a filter
over records, the query returns records, precedence orders records, and a finding names the
record it falsifies — all four are unbuildable against prose.

## Outcome

The store exists as a flat set of typed records, and every addressable span has a stable
short id minted by the build rather than by an author mid-session. A heading that carries
no label, a record holding more than one imperative, and a citation naming an id that does
not exist all fail the build with the offending place named.

The build also reports the corpus's instruction count without failing on it, and reports
authored size separately from generated size — so that adding a decision no longer looks
identical to a regression that re-inflated a row.

Nothing consumes the store yet. This is the expand half of a wide refactor: the new form
stands beside the old, and the old still works.

## Acceptance

- Every norm in the corpus can be cited by a stable id, and the same id resolves to the
  same span across two runs of the build.
- A citation naming an id that does not exist fails the build, and the message names the
  id and the citing file.
- A heading carrying no label fails the build, and the message names the file and the
  heading.
- A record containing more than one imperative fails the build, and the message names the
  record.
- The build reports the corpus's instruction count and completes successfully regardless of
  that number.
- The build reports authored size and generated size as separate figures, and adding a
  decision moves only the generated one.
- Ids are absent from an author's working copy until the build runs, and no stage mints one
  during a session.
- The existing corpus still loads and every stage still runs, unchanged, with the store
  present.

## Declared increments

- after the build first reports authored and generated size separately: what the authored
  figure should be bounded at, if anything — type: grilling

## Comments

**The increment is resolved: bound the authored half, leave the generated half unbounded.**
The ceiling is the summed authored size across every stage row, set at the figure measured
the first time the two halves were reported apart, and raised only with a recorded reason.

Answered against evidence already in the tree rather than by preference. The row bound
failed not because a bound is the wrong instrument but because the figure under it
conflated prose that should not grow with indexes that must — split, the authored figure
finally means what the conflated one only claimed to. This repository already runs exactly
this instrument on the skill bodies, and that ratchet's eight recorded raises are what
shows it working: every crossing was priced and justified where it happened rather than
waved through.

Summed across rows rather than one ceiling per stage, because the rows share files and
eight numbers would be eight edits recording one fact. Deliberately not extended to the
instruction count, which stays reported and unthresholded — that is the figure the spec's
own risk section accepts as unenforced, and a count is where the conflated-bound failure
would reappear.

**The type was `grilling`, which normally stops the build and holds the claim.** The user
instructed this session to carry on and not hand decisions back, which outranks the stopping
rule; recorded here because a decision taken under an override should be legible as one.

**Two placements were forced rather than chosen, and both are recorded so a later reader
does not re-litigate them.** The ledger sits at `.claude/position/ledger.json` because
`.claude/protocol.md` is framework law and states that exactly two paths sit outside that
directory, both the harness's — so a third ignore exception was not available, and the
ledger entered through the category's own test instead. And `.claude/policies/records.md`
is repository-owned rather than framework-owned: a new framework-stamped file drags in the
release machinery, which is ticket `25`'s, and ADR 0084 retires the byte-lock apparatus
this effort is expanding past anyway.
