---
owner: repository
status: accepted
sources:
  - .claude/tickets/substrate/map.md
  - .claude/decisions/0084-two-axes-admit-a-type-and-eight-systems-become-seven-across-three-stores.md
  - .claude/decisions/0085-the-file-is-authored-the-norm-is-addressed-and-the-id-carries-the-fidelity-floor.md
  - .claude/decisions/0088-the-core-stays-on-harness-push-and-the-store-has-two-faces.md
  - .claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md
  - .claude/decisions/0090-nothing-derived-is-committed-and-the-build-mints-the-ids.md
  - .claude/decisions/0091-frozen-records-get-one-id-and-the-migration-is-fixture-proven-and-resumable.md
  - .claude/evidence/prototypes/2026-08-14-what-the-chunking-constraint-costs-at-chunk-count.md
  - .claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md
  - .claude/evidence/discussions/2026-08-13-which-substrate-design-the-six-findings-support.md
  - specs.md
---

# feat(substrate): AEP 2.0 — the norm corpus becomes a store a stage queries

## Problem

A stage spends its context on AEP before it spends any on the work. The corpus is
prose files loaded whole: `/implement`'s row is 69,563 characters over 69 spans, and
**only 48.5% of it is labelled for the stage that loads it.** The rest is paid for and
ignored.

Three failures follow from the same cause — that the unit of loading is the *file*
rather than the *thing being said*.

**Nothing can address a norm.** A statement cannot be cited, superseded, or checked,
because it has no identity apart from the file it sits in. Supersession is written by
hand at both ends and a claim made at one end and absent at the other is discovered by
whoever trips on it.

**Growth is indistinguishable from regression.** A row's total conflates authored prose,
which should not grow, with generated indexes, which must. The review row crosses its
bound roughly every three decisions by ordinary accumulation, and each crossing looks
exactly like the regression the bound exists to catch. The cheapest response — ratchet
and move on — is the one that erodes the guard. There is no cut available: the growing
member is the decisions index, and judging a change against accepted decisions is what
the stage is *for*.

**Instruction count is where compliance actually degrades.** Instruction-following falls
with instruction count and the dominant error is silent omission. Cutting the row was
measured and was not enough: filtering `/implement`'s row drops 34.7% of characters but
only 27.4% of imperatives, leaving 122 — still inside the band the problem was raised
about, because what a filter removes is disproportionately the one-line *why* clauses
rather than the imperatives themselves.

## Goal

The norm corpus is one flat store of typed, addressable records. A stage receives only
the norms that fire for it, delivered before it reads anything, and reaches everything
else through a filter rather than a judgement. A 1.x installation migrates onto it
without hand-editing.

## Constraints

- **2.0 takes the plugin dependency.** The standing 1.x guarantee that nothing committed
  requires AEP to be installed is superseded by this effort. A repository's norms may be
  unreadable without running the framework. This is settled and not reopened.
- **The Spine holds.** The seven stages, the modes as postures, verification at use, and
  the two-axis review survive as concepts. Changing the stage set is a different effort
  and nothing here may assume it.
- **Migration from 1.x is required, not optional**, and shapes what 2.0 may choose. A
  design that cannot carry the existing corpus across is not a candidate.
- **The canonical specification is amended in the same change that lands 2.0.** It is the
  authority document for what this repository builds, so shipping 2.0 without amending it
  leaves that document describing 1.x. Known to move: the repository-layout section, which
  gains the flat store and loses four generated indexes, and the harness-binding section,
  whose no-plugin guarantee is exactly what this effort supersedes.
- **Delivery is bounded by measured harness limits, not assumed ones.** A single
  preprocessing substitution above roughly 30,000 characters is withheld and replaced by a
  preview and a path. The cap is per substitution rather than per assembled body, so a row
  is emitted as several commands each under it. Chunk boundaries cost ~1.6–1.75 seconds
  each and payload bytes are nearly free, so the emitted size is as large as the proven
  floor allows and the chunk count as small.
- **Nothing derived is committed.** Generated artefacts are rebuilt, never reviewed.
- **Frozen records stay frozen.** Accepted decisions, resolved tickets, and landed specs
  keep their shape; the migration gives them identity without rewriting them.

## Architecture

**Three stores, seven record types.** A type is admitted by write authority crossed with
post-write mutability, and by whether it binds or describes. The framework store holds
what AEP ships; the knowledge store holds what a repository knows; the tracker store holds
work. `norm` lives on both sides of the framework boundary and carries a `fires-when`
field drawn from a closed vocabulary — closed deliberately, because a judged `auto` mode
restores the mis-loading this effort exists to remove.

**The file is authored; the norm is addressed.** A record is the smallest span that is
correct alone, carried by a heading, with a short opaque id declared in frontmatter and
bound to its span by anchor. The id is what makes a norm citable, supersedable, and
checkable — it carries the fidelity floor. An unlabelled heading fails the build rather
than being silently skipped.

**One instruction per record.** A multi-imperative record fails the build, which unifies
the instruction count with the span rule: the corpus shrinks rather than the row. The
count is *reported, never thresholded* — a threshold would be the same conflated bound
that fails today, and reporting is what lets accumulation and regression be told apart.

**Delivery is push; retrieval is pull; neither substitutes for the other.** The boot tier
stays on harness push — the only channel that survives compaction and cannot fail
silently. Everything else is reached through a store with two faces, an MCP tool and a
CLI, so an unreachable store is degraded rather than fatal. The path-scoped tier survives
as a pointer only.

**A stage's row is delivered, never queried.** Preprocessing assembles it and inlines it
before the skill content reaches the model, at zero model round trips and with no
judgement. The row is *every norm whose `fires-when` matches this stage*, arriving in
computed precedence order. The assembler emits it as several commands, each under the
measured cap.

**The query serves only what the row deliberately excludes** — path-scoped norms on a
covered file, cross-store norms cited by id, and the mid-turn lookup for a question the
row does not settle. There is no free-text search, only filters over declared fields, which
is what makes a miss **a true statement about the store rather than a failed search**. A
query returns the declared-edge closure alongside the match, with depth declared per edge
type so it is a fact about what an edge means rather than a number somebody tuned.

**Precedence orders binders only, and conflicts are returned rather than resolved.** Six
ranks collapse to three. A cross-store conflict is a declared deviation; an undeclared one
within a store is a defect. Returning both with their ranks preserves the obligation that a
decision-versus-norm conflict is productive — the norm is amended in the same change —
which applying the rank and returning one record would suppress.

**Identity is minted by the build, never mid-session.** A span is authored id-less and the
build assigns before the commit lands, which is where the index regenerator already sits
and what keeps an id in the same commit as its span.

## Approach

**Expand, migrate, contract.** This is a wide refactor: every norm file gains span identity
on a single edit, so no vertical slice can land green while the old and new forms disagree.
The sequence keeps each ticket green by building the new form beside the old, moving the
corpus across, and only then deleting what nothing reads.

The riskiest part is not the store — it is **whether the delivery path survives contact
with a real corpus**, and that risk is retired first. The schema and its build come first
because everything else consumes them; the boot tier and the two faces come second because
they carry the two harness questions that no amount of reasoning can close; row assembly
comes third, against a store that already exists. The migration runs only once all three
have proven the destination is real, which is what keeps it from being a rewrite performed
blind.

Three questions are carried as **declared increments** rather than settled here, because
each needs partial code or a human at the keyboard and none is answerable by more thinking.
Two ride the delivery ticket — what disabling inline shell execution does to a stage, and
whether a hook's result reaches context — and one rides the query ticket, whether a
filter-only surface answers the excluded cases. Declaring them is not deferring the
decision; it is naming where the answer becomes reachable.

**Options considered and rejected.**

*Store-authoritative* — a database as the source of truth. Rejected: it splits knowledge
history from code history, and none of the wanted improvements turns out to be bounded by
storage anyway.

*An associative layer* — tag entry with spreading activation along links. Rejected on the
measurement that graph-augmented retrieval degrades on *basic factual retrieval*, which is
precisely this corpus's category.

*The query replaces the row* — rejected: judged selection restored in full, which is the
mis-loading that caused sessions to re-ask settled questions.

*No retrieval at all, delivery only* — the smallest system, rejected because a path-scoped
pointer has no preprocessing available.

*Shrinking the row to fit one substitution* — rejected by measurement: reaching the proven
floor needs a 77.9% cut against the 34.7% the whole filter buys. Chunking removes the
constraint entirely.

*Adopting an established store* — sixteen candidates evaluated; nothing fits, and two of the
settled criteria have no candidate anywhere.

## Acceptance criteria

- A stage entering its work receives only the norms whose `fires-when` matches it, and a
  reader can tell from the delivered row which stage it was assembled for.
- Every norm in the corpus can be cited by a stable id, and citing one that does not exist
  fails the build with the id named.
- A heading that carries no label fails the build, naming the file and the heading.
- A record containing more than one imperative fails the build, naming the record.
- The build reports the corpus's instruction count and does not fail on it.
- A row bound distinguishes authored prose from generated content: adding a decision does
  not move the authored figure.
- A query for a field value that no record carries returns an empty result that is
  distinguishable from an error, and no query accepts free text.
- A query returns the declared-edge closure of its match, and the depth applied is
  attributable to the edge type rather than to a global setting.
- A conflict between a decision and a norm is returned with both records and their ranks,
  labelled as a declared deviation or an undeclared defect.
- Running the migration against a 1.x installation produces a 2.0 tree with every 1.x
  surface accounted for, and re-running it after an interruption completes rather than
  duplicating.
- An accepted decision, a resolved ticket, and a landed spec each come through the
  migration with their prose unchanged.
- With the store unreachable, a stage still starts and says that it is degraded.
- The canonical specification describes the 2.0 layout and no longer states the guarantee
  that nothing committed requires the plugin.
- A reader following the canonical specification alone can locate every store and name
  every record type.

## Risks

- **The migration silently drops a surface.** Most likely failure, and the one that is
  worst discovered late. Detection: the migration is fixture-proven, and a surface with no
  destination is an error naming it rather than a skipped file.
- **`fires-when` is a silent-failure surface.** A norm labelled for the wrong stage simply
  stops arriving, and nothing reports it. The build can assert the field is present and
  drawn from the closed vocabulary; it cannot assert the value is right. Detection: the
  migration diffs each assembled row against the file-list row it replaces, and the dropped
  set is inspected rather than trusted — the method that has already killed one false
  positive.
- **The assembler's failure mode is a fork with no safe branch.** Unguarded, any non-zero
  exit aborts the whole stage and the model receives nothing at all, its own instructions
  included; guarded, the row arrives with the shell's error text inlined as prose and
  nothing reporting it. Detection: the assembler's own design must choose deliberately and
  say which, and the choice is exercised by a failing-command fixture.
- **Harness limits move underneath the design.** Every delivery figure is one harness build
  on one machine. Detection: the measured floor is re-run as a fixture rather than recorded
  as a constant, so a moved cap fails the build instead of silently truncating a row.
- **A timing figure taken once is wrong.** This has already happened on this effort: a
  load-bearing latency measurement was off by an order of magnitude and was caught only by
  repetition. Detection: timing findings are run at least twice before they move a decision.
- **The instruction-count bound is reported rather than enforced, so nothing stops the
  corpus growing.** Accepted deliberately — a threshold is the conflated bound that fails
  today. Detection: the reported figure is trended, and the effort that raises it is the one
  that answers for it.

## Out of scope

- **The Spine's stage set and the workflow shape.** 2.0 is storage, delivery, and taxonomy.
- **Rewriting frozen records.** Accepted decisions, resolved tickets, and landed specs keep
  their prose; they gain identity, not edits.
- **Call-time cost of the store's MCP face.** Measured at rest as zero; what a schema costs
  when it is actually loaded is unmeasured and is not bounded here.
- **Pinning the preprocessing cap.** It is bracketed and the design sits below the bracket;
  narrowing it buys nothing this effort needs.
- **Federating stores across repositories.** Named as the remaining novel capability in the
  research, and deliberately not attempted.
