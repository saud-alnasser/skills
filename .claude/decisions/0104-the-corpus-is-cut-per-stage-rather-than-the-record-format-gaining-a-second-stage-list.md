---
owner: repository
status: accepted
load-when: how a stage's row is made smaller than the files it comes from, or whether a file may label its records for different stages, is in question
sources: [.claude/evidence/drift/2026-08-15-adr-0089-s-measured-saving-needs-a-per-span-label-the-format-does-not-carry.md, knowledge/tickets.md]
supersedes: []
superseded-by: []
---

# The corpus is cut per stage, rather than the record format gaining a second stage list

**A framework guide whose records serve different stages is split into files, one
per set of stages that read it, and `stages` stays a single file-level field.**
ADR 0089 records the filter's value as a measurement — *only 48.5% of
`/implement`'s row is labelled for the stage that loads it*, so *filtering drops
34.7%* — and both figures are per span. What shipped labels per file, so the filter
drops nothing inside a file: applied to a row that was already a list of files, a
file-granular filter selects the same files. The saving is real and unreached, and
this decides which way it is reached.

**Cutting the corpus needs no format change and buys the measurement outright.**
The store is flat and a file is cheap, so `tickets.md` becomes the files its stages
actually want; nothing about the record format, the build's refusals, or the
assembler moves. The correction to ADR 0089 is therefore not that its number was
wrong but that **the saving was never a property of the filter** — it is a property
of how the corpus is cut, and the filter is what makes the cut pay.

**A per-record override was rejected on the cost it adds rather than the work it
saves.** `span-stages`, on the pattern `span-sources` already sets, would keep every
guide as one authored file. It also gives a stage list two homes in one file, and a
second home is a second place to be wrong — the build would need a new refusal for
an override naming no heading, and a reader would have to check two fields to learn
which stages a record reaches. The authored-file convenience is real and it is not
worth a second source of truth about the one field delivery depends on.

**Accepting file granularity and withdrawing the number was rejected too**, because
it gives up a measured saving that costs one file split to collect, and leaves ADR
0089's token argument smaller than it was when the decision was accepted.

## Consequences

**A guide's file count stops tracking its subject and starts tracking its
audience**, which is a real loss of legibility: `tickets.md` is one concept and may
become three files. The flat store makes it survivable — a record is addressed by
id and reached by filter, so a reader never navigates to a file — but whoever splits
one owes the resulting files names that say which stages they serve, not names that
pretend to be three subjects.

**The split is per set of stages, not per stage.** A record two stages both read
belongs in one file naming both, or it would be duplicated — and a duplicated norm
is the thing the store exists to make impossible.
