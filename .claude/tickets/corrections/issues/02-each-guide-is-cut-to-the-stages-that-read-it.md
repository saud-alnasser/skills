---
owner: repository
title: "feat(knowledge): each guide is cut to the stages that read it"
status: resolved
blocked-by: []
part-of: corrections
---

## Problem

The row filter's measured saving is uncollected. `stages` is a file-level field, so
the filter's granularity is the file — and applied to a row that was already a list
of files, it selects the same files and drops nothing inside any of them. The four
framework guides the router names for `/implement` come to 29,213 characters over
95 records, and every one of those records is labelled for `implement`.

The saving is not wrong and it is not free: it is bought by cutting the corpus, and
nobody has cut it.

## Outcome

Each framework guide whose records serve different stages is several files, one per
set of stages that read it, named for the audience rather than pretending to be
several subjects. A stage's row is smaller than the files its records came from, by
an amount the split predicts. No record moves house without its id, and none is
duplicated.

## Acceptance

- No file in the framework store holds records whose stages differ from its own,
  because none can — but after the split, no file's `stages` names a stage that
  fewer than all of its records serve, checked by reading each record against the
  guide it came from.
- `/implement`'s row is smaller than the sum of the files its records come from, and
  the builder's reported figure moves by the amount the split predicts, stated
  before the split rather than read off it afterwards.
- The store's record count is unchanged and every id is the one it carried before,
  so a citation written against the old layout still resolves.
- No record appears in two files. A record two stages read is one record in one file
  naming both.
- No new field carries a stage list, and no file-naming convention smuggles one back
  in — a name that has to be parsed to learn which stages a file serves is the
  rejected option under another spelling.
- Each resulting file's name says which stages it serves rather than claiming a
  subject it does not own.
