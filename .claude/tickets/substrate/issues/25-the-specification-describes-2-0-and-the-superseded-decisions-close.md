---
owner: repository
title: "docs(substrate): the specification describes 2.0 and the superseded decisions close"
status: resolved
blocked-by: [23, 24]
part-of: substrate
---

## Problem

The canonical specification is the authority document for what this repository builds. It
currently describes 1.x — including a guarantee that nothing committed requires the
framework to be installed, which is precisely what this effort supersedes. Shipping 2.0
without amending it leaves the authority document contradicting the tree it is authoritative
over.

Five accepted decisions are superseded by this effort and thirteen are amended. A
supersession written at one end and absent at the other is a defect rather than a
stylistic lapse: it leaves a reader who opens the old decision with no way to learn it is
dead, and that reader is the one the rule exists for.

Four generated indexes stop being committed. Deleting them is not tidying — it is the
change that makes a row bound measure only what somebody wrote.

## Outcome

The specification describes 2.0: the layout gains the flat store and loses the four
generated indexes, and the harness-binding section states the plugin dependency instead of
the guarantee it replaces. Sections on record types, the knowledge lifecycle, and
composition are read against the decisions this effort produced and amended where they
disagree.

Every superseded decision is closed at both ends in the same change.

## Acceptance

- The specification describes the store, names every record type, and no longer states that
  nothing committed requires the framework.
- A reader following the specification alone can locate every store and name every record
  type.
- Each of the five superseded decisions declares what replaced it, and each replacement
  declares what it superseded — checked by the build rather than by reading.
- No generated index is committed, and a clean checkout followed by a build produces every
  one of them.
- Adding a decision does not change the authored-size figure any row bound is measured
  against.

## Comments

**Criteria 4 and 5 were taken at specification level, on the user's explicit choice.** The four
generated indexes under this repository's own protocol directory stay committed. The Constraint in
`.claude/contexts/repository.md` bounds any check asking *does this repository hold what the
framework specifies* by the newest **cut** release, and 2.0.0 is declared and uncut — so
uncommitting them here would convert this repository ahead of the migration that is supposed to
convert it last. The change lands in the shipped build specification instead: the index regenerator
and the regenerate-and-compare check are marked retired at 2.0.0, and nothing derived is committed
under 2.0. ADR 0090 refuses a third ignore exception outside `position/` on the same ground, so
uncommitting them in place was not available without a declared deviation.

**Two changes ride this ticket that no criterion asks for, both on the user's instruction in the
build session, recorded so a later review does not re-raise them.** `.claude/rules/skills.md` is
rescoped: `scripts/verify.ps1` was deleted earlier in this effort and the rule named it five times,
so the rule now describes the suite as it is to be rebuilt — asserting that `skills/`, `agents/`,
and the configure templates adhere to the specification, and never checking this repository's own
protocol directory against anything. And `skills/configure/SCRIPTS.md` gains an `Until` column,
mirroring `Since`, because retiring a specification a 1.x repository still derives is not the same
as deleting it.

**`/implement` wrote decision records here, which `.claude/policies/knowledge.md` otherwise
reserves to `/design`.** Stated rather than assumed: the supersession set was enumerated by `16`,
the replacing ADRs say in their own frozen prose that the edges are written when 2.0's spec is
accepted, and this ticket is where `/design` assigned that work. No reasoning was authored — the
transcription is `status`, `supersedes`, and `superseded-by`.

**Two ADR body rewrites were reverted during review.** `0083` and `0084` carry paragraphs
explaining why their status was `proposed`; those were rewritten to read as past tense and then
restored, because `.claude/policies/decisions.md` is framework law and says only `status` and
`superseded-by` move after a commit, never the prose. The paragraphs were true as written, and the
status field is the record that their condition was met. `supersedes` was kept on `0083`, `0084`,
and `0090`: the effort is one commit under amendment, so those edges are written in the same change
that created the records — which is the form that policy's supersession rule asks for.

**The build's supersession check was sharpened after review found the specification overclaiming.**
It said a half-written supersession is caught because the build resolves every declared edge; edge
resolution catches a dangling target and passes an asymmetric pair, which is the defect the rule
exists for. §16 and §24 now state two checks, and `superseded-by` joins the resolved set.

**Left for a design run, found by review and outside this ticket's criteria.** `specs.md` now
describes 2.0 while ADRs `0002`, `0021`, and `0056` remain `accepted` and unsuperseded, and each
states a mechanism the amended sections replace — the generated routing table, the three tiers
selected by mechanism, one index per family. `16` classified all three as **amended** rather than
superseded and recorded that the thirteen amended and twenty-four affected decisions are re-read at
acceptance; acceptance is this ticket, and that re-read is not in its criteria. Separately, `0090`
now supersedes `0018` whole, while `0018` also ruled on evidence grouping that §21 preserves. Both
need the grill, not a build.
