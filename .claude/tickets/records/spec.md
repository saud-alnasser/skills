---
status: accepted
sources:
  - skills/configure/tools/git.md
  - skills/configure/policies/evidence.template.md
  - skills/configure/protocol.template.md
  - .claude/evidence/research/2026-08-09-reading-the-plugin-version-from-a-running-stage.md
  - .claude/tickets/agentic/issues/01-rename-the-expansion-to-agentic.md
  - scripts/verify.ps1
---

# fix(knowledge): three records that describe state they do not hold

## Problem

Three records are wrong in the same way: each describes a state of the world that
was true when it was written and has not been true since. None of them is reached
by any mechanism that would notice.

**The shipped git reference describes the marker file as holding one fact.** It
holds two — the commit, and the tree fingerprint added when the marker gained the
ability to license skipping the drift reads. The protocol file and the commit
stage both describe the pair correctly; only the tool reference was missed. It
matters more than the other two because derived tool references are pinned to
their shipped source: a repository cannot correct its own copy without the suite
reporting divergence, so the wrong sentence is the only one a configured
repository is allowed to hold.

**A research finding reads as waiting when it has been consumed.** It declares
what it falsifies, the ticket it falsified is resolved, and that ticket's comments
cite the finding by path as what lifted its block. No consumption line was
written. The obligation to write one is stated under the drift-finding heading and
phrased in terms of drift, so whether it reaches a research finding that declares
the same field is genuinely unclear — and the ambiguity is why this one was
missed.

**An effort has tickets and no spec.** The design index is generated from specs,
one row per effort, so an effort holding no spec produces no row: the index spans
fewer efforts than exist, the generation succeeds, and nothing reports it. The
effort landed long ago, which makes any spec written now a reconstruction rather
than a record.

## Goal

Each of the three records says what is true, and the two ambiguities that let
them drift — an obligation scoped to one kind of finding, and an index silently
tolerating a gap — are closed rather than worked around.

## Constraints

- **A finding's account is frozen.** The consumption line sits beside it and
  nothing about what was checked, when, or against which commit may move.
- **A spec is frozen evidence of intent.** One written after the fact is
  reconstruction, and must say so in the file rather than passing as
  contemporaneous.
- **The derivation pin is correct and stays.** The marker sentence is fixed at
  the shipped source, never by letting a derived copy diverge.
- A shipped file cites only what resolves where it is read.

## Architecture

Three independent repairs sharing no code and no ordering. Two of them also close
the ambiguity that produced them: the consumption obligation is restated in terms
of the field a finding declares rather than the kind it is, and the retrospective
spec carries a marker distinguishing reconstruction from record.

## Approach

In any order — none blocks another. Each carries its own assertion, since a
change adding a checkable claim without one is untested by construction.

The consumption repair is the only one with a design choice in it, and the choice
is already made: the obligation generalises. The cost it removes — a design run
re-deriving healed from waiting by opening whatever each finding falsified — is
identical whatever kind the finding is, so scoping it to drift was an accident of
where it was written rather than a decision.

## Acceptance criteria

- The shipped git reference describes both facts the marker holds, and a derived
  copy of it passes the divergence check unchanged.
- The consumption obligation reaches any finding that declares what it falsifies,
  and says so in terms of the field rather than the kind.
- The consumed finding carries its line, and its account is byte-identical to
  before.
- Every effort with tickets has a spec, and the design index spans all of them.
- A spec written after its effort landed is identifiable as reconstruction from
  the file itself.
- The suite fails on a shipped reference that describes the marker as one fact,
  on an effort with tickets and no spec, and on a consumed finding with no line —
  each confirmed against a deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

**The retrospective spec is read as contemporaneous.** A reconstruction that
looks like a record is worse than a missing spec, because it invites decisions to
be traced to reasoning nobody had at the time. Detection: the marker is in the
file rather than in a commit message, and an assertion checks it is present on any
spec whose effort predates it.

**Generalising the consumption obligation retroactively marks findings nobody
checked.** Widening the rule does not make old findings consumed. Detection: only
the one finding whose consumption is establishable from a resolved ticket citing
it is marked; every other finding stays unmarked, which reads as waiting and is
the safe direction.

**The marker guard matches the correction rather than the error.** A guard
written from the new sentence passes while the old one sits elsewhere in the tree.
Detection: anchor it to the subject — a description of the marker file's contents
— and confirm it fails against the original sentence before trusting it.

## Out of scope

- Auditing every other evidence finding for consumption. Only the one with
  establishable consumption is touched.
- Reconstructing specs for any effort other than the one lacking a spec today.
- Changing what the marker holds, or how it is written.
