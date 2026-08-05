# 14 — feat(skills): the migration converts a repository's knowledge to declared fields

Status: resolved
Blocked by: 08
Part of: mechanics

## Problem

After tickets 05 through 08 ship, a repository configured by an earlier release has decisions carrying no fields, contexts carrying a prose source line, and a routing table somebody wrote by hand. The generate step will not reach any of it: the files exist, so they are not missing, and their content is correct under the shape they were written for. A repository configured once does not run generation again on its own, so without a row here every existing AEP repository stays on the old shape indefinitely while the framework ships the new one.

The dangerous part is not the count. A load condition can be written mechanically for every file in the repository and be wrong in the way that matters — describing what the file is *about* rather than when to load it, which is precisely what the earlier routing decision rejected and what nothing mechanical detects. A migration that produces a complete, valid, subject-describing index has reintroduced the rejected shape at scale and left no trace of having done so.

## Outcome

The migration page carries a row for a repository whose knowledge predates declared fields. Recognition is by content and needs both halves, because either alone is an unfinished run rather than an older shape: the decisions directory is populated, and its files declare no fields.

The conversion adds the fields and generates the indexes from them. The existing hand-written routing table is the **input** to the load conditions rather than something discarded — its trigger sentences were written for this purpose and are carried onto the files they describe. Where a decision has no such sentence anywhere, one is written, and the page says plainly that this is judgement rather than mechanics and belongs in the plan decision by decision rather than as a count.

The page states the failure this row can produce and how to see it: a condition that says what a file is about passes every check and is wrong. That is the same reason the existing row for a term that belongs to one stage is shown term by term.

Supersession is converted from wherever it is stated today — a status line, or prose — and made symmetric. Prose that discusses supersession without claiming it is reported rather than promoted, because reading it as a claim is a guess about what an author meant.

Filenames and numbers are untouched, under the numbering rule that already governs every other move.

## Acceptance

- The migration page has a row for a repository whose decisions and contexts predate declared fields, with recognition by content stated in both halves.
- The row states that an existing routing table's trigger sentences are carried onto the files rather than discarded.
- The row states that writing a load condition is judgement, that it appears in the plan file by file, and what the wrong-but-valid outcome looks like.
- The row states that supersession is made symmetric, and that prose discussing supersession is reported rather than converted.
- The row preserves every decision's number and slug, citing the rule that already requires it rather than restating it.
- Converting a repository on the old shape produces indexes that regenerate byte-identically.
- A repository already on declared fields is recognised as current and a re-run changes nothing.
- A repository with a populated decisions directory and a half-converted set is finished rather than re-converted, and nothing is duplicated.
- The suite asserts the row exists and carries the judgement warning, with each guard confirmed to fail against a reworded restatement.
- The suite passes.
