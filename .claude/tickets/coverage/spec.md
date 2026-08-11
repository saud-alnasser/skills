---
owner: repository
status: implemented
sources:
  - skills/configure/
  - specs.md
---

# feat(configure): the audit covers the whole protocol directory

## Problem

A field run on a configured repository showed the post-configure shape: framework-owned files correctly stamped, and everything else — domain contexts, decisions, designs, evidence, repository-discovered rules — carrying no owner declaration at all. That is what the shipped formats specify, and it leaves two states indistinguishable forever: a file that is repository-owned by design, and one that predates the owner split. The audit compounds it by checking a named list of categories rather than the tree — nothing enumerates every committed file under the protocol directory, so a file outside the named categories sits unexamined indefinitely. Meanwhile the framework's own repository stamps every such file, deviating from the law it ships: its installed decision format says five fields and no others while its own decision records carry six.

## Goal

An audit run reaches every committed file under the protocol directory: each is classified by owner and category, verified against that category's contract, and brought current — with absence of the owner declaration a repairable finding rather than a permanent default.

## Constraints

- Shipped text cites only what resolves where it is read — nothing in the shipped surfaces may reference this repository's specification or decision records.
- A migration-changelog release entry is frozen once written; the backfill is a new entry under the release shipping this effort, never an edit to an existing one.
- Framework-owned normative files state norms as checkable imperatives with a one-line why; a changed template carries the new release's stamp in the same change.
- Extension points are census-derived and the committed census found zero variation in these formats — this effort adds declared fields to formats, not extension points, and must not widen what a repository may vary.
- Every change to the shipped surfaces moves the suite in the same pass, and each new guard is confirmed to fail against a deliberate reintroduction before it is trusted.

## Architecture

Three shipped surfaces move, and one field becomes load-bearing.

The **formats** for repository-owned files — the domain context, the decision record, the evidence file, the spec, and the guidance for standards a repository discovers in its own tree — gain an explicit repository-owner declaration. The field is legitimate because the sweep acts on it: an audit asserting every governed file declares its owner is the thing that makes absence detectable.

The **audit** gains a coverage sweep as inline computed checks in configure's entrypoint, the same pattern as the existing framework-file comparison — enumerate the committed tree, read frontmatter, classify each file by owner and category, verify it against that category's contract, quote the computed output, report any file fitting no category. The per-clone set the ignore file defines is exempt. The owner-contract re-check stops being limited to four categories. Tickets are swept and verified against the tracker policy's contract but keep its declared fields — no owner, because their category's format does not name one.

The **migration changelog** gains a frozen entry under the new release: recognise a repository-owned governed file lacking the declaration by content, stamp it, touch no prose — fields sit beside frozen accounts, the same precedent as the earlier field backfill. This repository's canonical specification is amended in the same change as the decision record, and the truth that unstamped-means-repository remains the runtime reading rule while the audit enforces declaration.

## Approach

Formats first — the sweep verifies fields the formats define and the backfill repairs to the shape the formats ship, so both gate on it; they then run in parallel. Risk lives in the guard quality (a guard matching its own wording rather than the subject) and in the sweep's classification table missing a category the canonical layout names — both are checked by deliberate reintroduction and by running the audit against this repository itself, which now must pass its own sweep.

Rejected: **sweep-with-default** — no new fields, absence read as repository-owned — kept the two indistinguishable states permanent and left the flagship's stamps a standing deviation from its own shipped formats. Rejected: **a derived sweep script** — pinned and fixture-tested, but it grows three shipped surfaces plus a per-repository derivation for a check the audit can compute inline, and a mis-derived sweep is a confident wrong answer about the whole tree.

## Acceptance criteria

- Every shipped format for a repository-owned file shows the owner declaration, and the decision format's field count matches its own no-others claim.
- An audit run reports coverage of every committed file under the protocol directory, quoting computed output, and reports a file fitting no category as a finding.
- A repository configured by an earlier release, audited once, holds no governed file without an owner declaration — and no frozen prose was edited to get there.
- This repository passes its own sweep, and its installed framework copies are byte-identical to their templates.
- The suite fails when a format ships without the declaration, when the sweep is removed, or when the changelog entry for the release is absent.

## Risks

- A constant-valued field invites sediment — every governed file says `repository` unless framework-owned. Detected early by the Load-Bearing test: the sweep is the consumer, and it ships in the same effort as the field.
- The backfill touches every knowledge file in configured repositories once — a large mechanical diff a user may find alarming. The entry says exactly what it writes and what it never touches.
- The sweep's category table could drift from the canonical layout as releases add directories. The audit compares against the layout the entrypoint states, not a list restated in the sweep.

## Out of scope

- Content verification — whether a context statement is *true* stays with verification at use; the audit's reach is structural currency. The dissolved synchronization stage stays dissolved.
- New extension points or any widening of what a repository may vary in framework law.
- Owner declarations on tickets, on the entrypoint, or on anything outside the protocol directory.
- The harness's files — `settings.json` is merged not owned, and the per-clone set stays exempt.
