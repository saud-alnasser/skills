---
owner: repository
status: implemented
sources:
  - specs.md
  - skills/configure/SCRIPTS.md
  - skills/configure/policies/records.template.md
  - scripts/build-knowledge-store.js
  - .claude/decisions/0099-a-stage-norm-declares-its-stages-in-a-field-of-its-own.md
  - .claude/decisions/0100-a-broken-pointer-is-a-reported-figure-and-the-build-still-repairs-nothing.md
  - .claude/decisions/0101-the-boot-tier-is-bounded-because-it-is-the-one-figure-that-multiplies.md
  - .claude/tickets/conversion/spec.md
---

# feat(spec): the store's contested shape is settled, and the conversion frontier reopens

## Problem

The `conversion` effort built the store builder and found that the documents
specifying it disagree with each other. The builder shipped seven of the eight
refusals its page names, reported figures the specification says should fail the
build, and stopped short of a check the specification requires — not because the
work was incomplete, but because taking either side would have been the build
deciding a question two normative documents answer differently.

Five disagreements were recorded with their evidence and deliberately left
standing. One of them is not a disagreement at all but a hole: **nothing anywhere
states how a `stage` norm names its stage**, and the refusal that depends on it
cannot be written. That hole is what stops `conversion/04`; two more tickets,
`05` and `09`, build on a store shape the other four questions define.

A separate debt arrived with the same effort. The shipped position report detects
the checkout's line ending at runtime, which is what a script copied byte for byte
into every repository has to do — it cannot be told a per-repository fact. An
accepted decision rejected runtime detection in terms general enough to read as a
standing prohibition, and the build stage that wrote the code may not write
decisions.

## Goal

Every document specifying the knowledge store agrees with every other, the store
builder implements what they say without reporting an unmet requirement, and the
three blocked `conversion` tickets can start.

## Constraints

- **The reasoning of an accepted decision is frozen.** Two of the questions here
  reverse one. Each is settled by a new record superseding the old at both ends,
  never by editing what was written.
- **The four boot-tier rules are `owner: framework` and byte-locked to their
  templates.** A budget over that tier constrains what the framework ships as much
  as what this repository writes, and this repository cannot shrink its way back
  under one.
- **Nothing derived is committed**, so no figure this work introduces may land as
  a checked-in baseline.
- **Every change here lands in what ships**, so it is bound by the shipped-text
  rules: no citation that resolves in only one repository, and every rule placed
  gains a guard confirmed to fire.

## Architecture

Four documents carry the store's specification, and each disagreement is a pair of
them. The settlement moves whichever one is wrong and adds the assertion that
would have caught the disagreement.

**`fires-when: every-turn` is refused, and the pages stop ranking it.** The boot
tier stays files under `.claude/rules/`, so a norm that must fire on a turn nobody
started cannot sit behind a store — nothing would fire it, and nothing would report
that it had stopped arriving. The value stays in the closed vocabulary, because
that is what lets the refusal name it specifically instead of falling through the
generic one; what goes is its place in the firing-breadth order and the fixture
case that requires such a store to build.

**A `stage` norm declares its stages in a list field of its own.** The firing
condition says which *kind*; a separate field says which stages, so a norm read by
four stages is one record rather than four. This is the only form the store query
can filter without matching inside a value, which is the loose match that query
exists to refuse. A norm declaring the kind and no list is refused, as is one
naming a stage no router row carries.

**A broken Source Pointer is a reported figure.** The build resolves edges and does
not repair pointers; what changes is that it counts the ones that no longer land
and says so, without failing. That reverses an accepted decision whose supporting
fact — a shipped fixture declaring `sources` over directories that do not exist —
belongs to a script retiring at 2.0.0.

**The boot tier is bounded and the bound fails the build.** The tier is paid on
every turn where a row is paid once, and it is entirely authored prose that should
not grow, so a threshold over it can tell regression from accumulation — which is
exactly what a threshold over a mixed total cannot do, and why the corpus's
instruction count stays reported and unthresholded.

**Supersession is checked for symmetry**, which edge resolution does not imply: a
`superseded-by` pointing at a record that exists resolves perfectly well while that
record says nothing back.

## Approach

The four tickets run in order rather than in parallel, and the reason is recent
evidence rather than tidiness. All four append an assertion group at the same
anchor in the build and edit the same two pages; the last effort to fan out across
that file produced a merge in which both sides ended mid-function and one ticket's
edits could be dropped without any tool reporting it. Serialising costs wall-clock
and buys back a class of silent loss.

The stage-naming ticket goes first because it is the only one that unblocks
anything, and because it is the largest change to the record format — every later
ticket writes fixtures against a format it settles.

**Options considered and rejected.**

- **Rank `every-turn` instead of refusing it**, deleting the refusal rather than
  the breadth entry. Smaller edit and no fixture rewrite. Rejected: a norm in the
  store with nothing to fire it stops arriving silently, which is the failure the
  refusal was written against.
- **A colon qualifier carrying a comma list**, `fires-when: stage:implement,commit`.
  Extends the form the corpus already writes and is a one-line change. Rejected:
  asking which norms fire at a given stage then means matching inside a field
  value, and a loose match is how a miss stops being a fact.
- **One stage per norm**, repeating the record. Simplest to check. Rejected: it
  arrives at conversion scale, and a policy read by four stages becomes four copies
  of one rule.
- **Amend the specification to make the boot tier report-only.** One consistent
  treatment across all three figures. Rejected: it amends the canonical
  specification to match an implementation, and leaves the only figure that
  multiplies per turn unbounded.
- **Fail the boot budget against a committed baseline** rather than an absolute
  number. Catches regression with nobody choosing a figure. Rejected: it commits a
  derived value, and the baseline becomes the file people edit to go green.
- **Scope the pointer decision rather than supersede it.** Leaves the older record
  live. Rejected: its clause is part of what it decided, not a rejected option, so
  a reader would have to traverse two records to get one answer.

## Acceptance criteria

- No two of the four specifying documents disagree about what the store builder
  refuses, ranks, reports, or fails on.
- A norm declaring a firing kind of `stage` and naming no stage fails the build,
  named with its file and id.
- A norm naming its stages is returned by a filter on that field alone, with no
  substring matching.
- A store containing a norm whose firing condition is `every-turn` fails the
  build, named with its file and id.
- A run over a store whose boot tier exceeds the budget fails, and one under it
  reports the figure and exits zero.
- A supersession claimed at one end and absent at the other fails the build,
  naming both records.
- A pointer that no longer resolves is counted and named, and the run exits zero.
- Every assertion added is confirmed to fail against a deliberate reintroduction
  of the fault it names.
- `conversion/04`, `05`, and `09` can each be started against a store shape no
  document contests.

## Risks

- **A perturbation that routes into a sibling branch proves nothing and reads as a
  pass.** This happened twice in the last effort, on this same script. Detection:
  every fire-check restores the code *as it stood before the fix*, not a plausible
  break chosen from the implementation.
- **The boot budget fires on a framework release this repository cannot answer**,
  because the four rules are byte-locked. Detection: the figure is reported on
  every run, so the margin is visible long before the bound is crossed.
- **Superseding two decisions in one effort risks losing a clause that was still
  live.** Detection: the symmetry check this effort adds is run against the
  decisions store before the effort closes.
- **The stages field lands in a format `conversion/04` then converts twenty-one
  templates against.** Getting it wrong is expensive downstream rather than here.
  Detection: 04 is blocked on this effort, so the format is exercised by this
  effort's own fixtures first.

## Out of scope

- **Converting anything to the new format.** `conversion/04` does that; this
  effort settles what the format is.
- **The live defect in `.claude/scripts/report-position.ps1`**, where the first
  drift path loses its first character. This repository converts last, and the
  shipped port is already correct.
- **The remaining shipped scripts** — the store query, the row assembler, the
  index regenerator. They are `conversion`'s.
- **Whether the boot tier should be smaller.** This effort bounds it; shrinking it
  is a framework change with its own reasoning.
