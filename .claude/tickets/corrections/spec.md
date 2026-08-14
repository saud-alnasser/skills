---
owner: repository
status: implemented
sources:
  - specs.md
  - skills/configure/SCRIPTS.md
  - skills/configure/policies/records.template.md
  - scripts/build-knowledge-store.js
  - knowledge/decisions.md
  - .claude/decisions/0103-falsifies-is-written-at-both-ends-so-a-correction-is-reachable-from-what-it-corrects.md
  - .claude/decisions/0104-the-corpus-is-cut-per-stage-rather-than-the-record-format-gaining-a-second-stage-list.md
  - .claude/evidence/drift/2026-08-15-adr-0089-s-measured-saving-needs-a-per-span-label-the-format-does-not-carry.md
  - .claude/evidence/drift/2026-08-15-adr-0091-s-frozen-set-names-a-ticket-and-omits-a-finding.md
  - .claude/evidence/drift/2026-08-15-adr-0095-has-the-repository-s-build-resolving-an-edge-into-a-store-it-cannot-see.md
---

# feat(spec): a correction reaches the record it corrects, and the row's saving is collected

## Problem

Three accepted decisions are contradicted by what shipped, and none of them can be
corrected. An ADR's prose freezes on commit, so the only instrument available is a
new file retiring the old — which is the right answer for a changed mind and the
wrong one for a wrong sentence in an argument that otherwise holds. Two of the
three are exactly that: ADR 0095 has the repository's build *resolving* an edge
whose target it cannot see, and ADR 0091 lists the frozen record set as *decision,
ticket, spec* when a ticket takes no id and an evidence finding does.

The findings that record all this declare `falsifies`, and **the edge is written at
one end only**. A reader who opens or queries the falsified decision gets the
decision. That is the same failure the supersession rule already names — writing
only the new end is the tempting half — arriving in the one edge pair with no
opposite, so nothing catches it.

The third finding is not a wrong sentence. ADR 0089 records the row filter's value
as a measurement taken per span: *only 48.5% of `/implement`'s row is labelled for
the stage that loads it*, so *filtering drops 34.7%*. What shipped labels per file.
Applied to a row that was already a list of files, a file-granular filter selects
the same files — so the four framework files the router names for `/implement` come
to 29,213 characters over 95 records and **the filter drops none of them**. The
saving is not wrong; it is uncollected.

## Goal

A correction is reachable from the record it corrects, without retiring a decision
whose reasoning is live. And the row's measured saving is collected, by cutting the
corpus rather than by giving the format a second place to say which stages a record
reaches.

## Constraints

- **An ADR's reasoning stays frozen.** Only `status`, `superseded-by`, and the new
  `falsified-by` move after commit — and the third is admissible precisely because
  a pointer to a contradicting record is not reasoning.
- **The build never reads this repository's `.claude/`.** The symmetry check ships
  and is proven by fixture; what this repository writes into its own decisions is
  the demonstration, not the test.
- **A norm keeps one home.** Splitting a guide moves records between files and
  duplicates none — a record two stages read stays one record in one file naming
  both.
- **No new field carries a stage list.** ADR 0104 rejects `span-stages`; a split
  that reintroduces it under another name is the same decision reversed silently.

## Architecture

`falsifies` gains its opposite, `falsified-by`, and the pair joins the builder's
symmetric set beside supersession. Both directions resolve as ids, both fail when
one end names a record that does not name it back, and the new edge takes a depth
record closing at one hop — the finding that falsified this record is wanted, and
what *that* finding cites is the finding's business.

The corpus split is arithmetic on the store rather than a change to it. Each
framework guide whose records serve different stages becomes several files, one per
set of stages, named for the audience rather than pretending to be several
subjects. Nothing in the record format, the build's refusals, or the assembler
moves; the row figure the builder already reports is what shows the saving arriving.

## Approach

Two tickets, ordered by nothing — they touch different files and neither needs the
other. The first ships the edge and, in the same change, writes the return edge into
the three decisions the findings falsified, which is what makes the mechanism
demonstrated rather than described. The second cuts the guides and measures.

## Acceptance criteria

- A record naming a finding in `falsifies` and a record that does not name it back
  fails the build, naming both — in both directions.
- A `falsified-by` declared with nothing in it **builds**, exactly as
  `superseded-by: []` does. Written into this spec as a refusal and corrected
  while building: the ADR template ships the field empty so that it is
  discoverable, so refusing an empty declaration would refuse every ADR the
  template produces. The deviation edge is refused empty because nothing ships a
  template carrying it; this one is a sibling of supersession, not of that.
- A query for a falsified record returns the finding that falsified it in the
  closure, attributed to `falsified-by`, and reaches no further.
- The freeze rule states which three fields move after commit, and the build asserts
  that the shipped guide says so.
- ADRs 0089, 0091, and 0095 each declare `falsified-by` naming the finding that
  falsified them, and each finding still names the ADR.
- After the split, `/implement`'s row is smaller than the sum of the files its
  records come from, and the figure the builder reports moves by the amount the
  split predicts.
- No record is duplicated by the split: the store's record count is unchanged and
  every id is the one it had before.
- Every assertion added is confirmed to fail against a deliberate reintroduction of
  the fault it names.

## Risks

- **A split that renames a file unbinds every id in it.** The builder refuses a
  `spans` anchor no heading produces, not a file that moved — so a record carried
  into a new file with its `spans` entry keeps its id, and one carried without it
  is re-minted silently. Detection: the record count and the id set are asserted
  unchanged across the split, which is the only check that can see this.
- **The symmetry check fires on findings nobody has touched.** Every existing
  finding declaring `falsifies` becomes a half-written pair the moment the check
  lands. Detection: it lands with the three return edges in the same change, and
  the build is run before the commit rather than after.
- **This repository's own findings name paths, not ids**, because its knowledge is
  not in a store yet. The shipped check is proven by fixture and the local edges
  are written in the form this repository already uses; a reader who expects the
  two to be the same shape will be wrong, and the spec says so here.

## Out of scope

- `conversion/10`'s two prototype increments, and the harness measurements they
  wait on. Nothing here touches delivery.
- Converting this repository's own knowledge into a store. The local decisions stay
  files, and their edges stay paths.
- Any change to what `falsifies` means for the other four evidence kinds. The edge
  is already theirs; only its opposite is new.
