---
owner: repository
title: "feat(verify): the build returns as JavaScript and asserts only what ships"
status: resolved
blocked-by: []
part-of: conversion
---

## Problem

There is no build. The verification suite was deleted mid-effort, so nothing catches a
broken change to what ships — and this repository has no package manifest and no test
runner to fall back on. Two standing statements now name a file that does not exist: the
rule obliging every change to what ships to move the suite in the same pass, and the
Constraint recording that a skill's own tests are assertions in it.

The suite it replaces also has to be a different thing rather than the same thing restored.
It had grown to check this repository's own protocol directory against what the framework
specifies, which couples the two in the wrong direction: a shipped template could not
change shape until this repository was converted, and one mechanical sweep produced
sixty-two failures none of which were about a template being wrong.

Every ticket after this one changes what ships. Without a build first, they either land
unasserted or all eleven wait on a suite written at the end against work nobody can still
see.

## Outcome

The build exists again, written in the language everything executable here is now written
in, and it asserts one thing: that what ships adheres to the canonical specification. It
reads the shipped surfaces and never this repository's protocol directory.

It runs whole, or for one ticket named by effort and number, and an unknown name lists what
it knows rather than passing with nothing run. Both statements that named the old file name
the new one and are true again.

## Acceptance

- The build runs from a clean checkout with no install step beyond what the framework
  already requires, and reports pass or fail per assertion.
- Naming an unknown ticket exits non-zero and lists the ticket names it knows.
- Every assertion the build makes has its subject in what ships; no assertion reads a file
  under this repository's protocol directory.
- Removing any one shipped claim the build asserts makes exactly that assertion fail, with
  the file named — checked by reintroducing each absence, not by reading the assertion.
- The rule about changing what ships, and the Constraint about a skill's own tests, both
  name the build as it now is, and neither names a file that does not exist.

## Comments

**The build was gitignored, and review caught it before it landed.** The repository's root
ignore file carried `build/` as inherited boilerplate under *build output*; this repository
produces none, and the directory now holds the one thing that catches a broken change to
what ships. A clean checkout would have contained no build at all — which is criterion 1
failing in the one way that reads as passing locally. The entry is removed, with the reason
written where the entry was.

**The scope boundary is structural rather than asserted.** The first version checked its own
source for the string `.claude`, which a comment or a regex trips and which a raw-string
prefix test lets through as `./.claude/x`. Every filesystem call now goes through one
resolver that resolves before it judges, so the boundary cannot be crossed without deleting
it; two assertions prove the refusal fires, one per claim.

**Coverage is partial, and that is stated rather than implied.** The suite this replaces
covered efforts back to the first. Nine of the eleven assertions here transcribe standards
this repository documents; two read the canonical specification and check the shipped tree
against it — the posture set, and the stage set the router names. The Outcome's claim is
therefore true of what is asserted and not yet true of the whole shipped surface, and the
tool guide says so where a reader would otherwise infer coverage from a green run.

**Fifteen perturbations, one per claim, all fired.** Two findings came out of doing it rather
than reading the guards: the citation assertion carried two claims — an ADR number and a
section mark — so deleting either left it green, and it is now two assertions; and the ADR
pattern missed the plural `ADRs 0038, 0039`, which is live in the specification. A sixteenth
perturbation was **withdrawn as wrong rather than recorded as a gap**: swapping
`path.resolve` for `path.join` weakens nothing, because `join` normalises `./` and `..`
identically, so it was testing a distinction that does not exist.

**Three repairs ride this ticket that no criterion names.** A section reference in the
configuration skill cited `§21` of the canonical specification, which resolves in exactly
one repository and which the new guard catches. The tool guide for the suite still described
the deleted PowerShell one, and it is what a stage opens to learn the invocation. And the
README told a newcomer to run a command that no longer exists. Each is drift the change
itself created or exposed, healed where it was found.

**Frozen ADR prose was edited and reverted, for the second time in this effort.** Repairing
the Source Pointers that named the deleted suite was done with a blanket substitution, which
reached body prose in six accepted decisions. Only `status`, the supersession edges,
`load-when` and `sources` may move after a commit; the prose is restored and only the
`sources:` fields carry the new path. Recording it because the same mistake in the same
session is a pattern rather than a slip: a substitution across a decision record needs to be
scoped to the field, never to the file.

**Left for a later ticket, found by review.** The citation guard covers `skills/` and
`agents/` and not `hooks/`, which also ships — the stale ADR citation there was found by a
reviewer rather than by the build, and fixed by hand. Widening the guard belongs with the
ticket that converts the shipped scripts, since that is when `hooks/` stops being the only
executable content.
