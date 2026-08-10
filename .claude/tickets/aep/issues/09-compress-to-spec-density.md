---
owner: repository
title: refactor(skills): compress everything shipped to the specification's density
status: resolved
blocked-by: [08]
part-of: aep
---

## Problem

Rules throughout the shipped set are written as arguments defending themselves. That defence pays for itself exactly once — on a rule that would look arbitrary without it. Everywhere else it is a token cost and a thinking cost, because a defended rule invites re-evaluation instead of application. Spec §6 makes the standard explicit: directive, not argument; one clause of rationale only where the rule would read as arbitrary without it.

## Outcome

Every shipped skill, mode, guide, and template says the same things in far less text. Substance that belongs to a mode, policy, or guide is pointed at rather than restated. Attribution survives untouched — it is a license obligation, not prose.

## Acceptance

- Every stage still exists and still does what it did; both review axes, the deleted-prototype rule, and the evidence graduation path all survive.
- No claim guarded by an assertion was lost, demonstrated by the suite rather than by review.
- Rationale survives only attached to a rule that would read as arbitrary without it.
- A repository configured from the compressed templates has the same rules as one configured before, stated more briefly, and the generated entrypoint stays within its budget.
- The measured before-and-after totals are recorded in this ticket's comments when it closes.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs streamline 10–13. One ticket because the standard and the guard are now uniform; in execution it is sliced one area per context window — spine, review and evidence, configure and templates, primitives and on-ramps — with the suite green at every slice boundary.

**Slice 1, landed:** the boot tier. The entrypoint template, this repository's entrypoint, both always-on rules files, and their templates rewrote to directive density: 9,206 → 7,729 chars as loaded, ceiling ratcheted 9,500 → 7,800, suite green at 601 throughout. Two single-home guards fired mid-rewrite — the commit-scope vocabulary and the worse-convention escape were dropped as prose and caught as claims — which is the fidelity floor doing exactly its job; both were restored.

**Slice 2, landed:** the redistribution. The mode definitions moved out of the protocol file into `.claude/modes/`, one file per posture (ADR 0032; spec §21 amended, version 1.2.0-draft); the conventions defaults moved from the entrypoint into the version-control policy, leaving only the defaults-not-mandates umbrella; the Source Pointer recovery machinery moved into the router; and every skill that said "the rule is in `CLAUDE.md`" now points at the rule's actual home. Boot tier 7,729 → 4,988 chars as loaded, ceiling ratcheted 7,800 → 5,000, which was the target. The three single-home guards whose homes moved were each re-fired against a deliberate reintroduction, and all three caught it.

**Slice 3, landed:** the build spine. `/design` 9,734 → 8,028, `/implement` 16,088 → 14,329, `/commit` 8,431 → 7,736 bytes — every step, table, diagram, and guarded claim intact; what left was the trailing self-defence. Five assertions caught anchor phrases the rewrite had reworded — never-invokes, not-a-claim, not-the-tool's-default, frontier-empties, and both stall directions — and each was restored in the suite's wording. Slices land as separate commits from here on, by the user's instruction.

**Slice 4, landed:** review and the evidence stages. `/review` 9,015 → 8,639, `/research` 4,112 → 4,055, `/prototype` 6,736 → 6,516 bytes — smaller cuts than the spine because these three were already near the standard; what came out was repeated consequence-chains (the skim-teaching argument stated twice, the convergence mechanism argued twice). Two assertions caught reworded anchors — the pollution reason on the parallel launch, and the secondary-write-up rejection — both restored. Both review axes, the deleted-prototype rule, and the graduation path all survive, per the acceptance line, and the suite is the proof.

**Slice 5, landed:** configure, the migration, and the derivation guide. `configure/SKILL.md` 18,456 → 17,280, `MIGRATION.md` 13,813 → 12,956, `TOOLS.md` 4,858 → 4,740, `tickets.template.md` 10,196 → 10,081 bytes. The other policy templates and the tool references were inspected and left — invocation tables and formats already at the standard, where a trim would cost gotchas rather than argument. One assertion caught the appends-instead-of-recognising clause going missing from the migration's recognition section; restored.

**Slice 6, landed, and the ticket closes.** The primitives and on-ramps: `diagnosing-bugs` and `triage` trimmed; `tdd`, `codebase-design`, `survey`, `help`, `domain-modeling`, `grilling`, `handoff`, and `resolving-merge-conflicts` inspected and left — vocabulary references and short procedures already at the standard, several hosting single-home guard anchors. Every attribution line survives, asserted by the suite.

**Final totals.** The boot tier — the cost paid on every turn — went 9,206 → 4,988 chars as loaded, a 46% cut, with the ceiling ratcheted 9,500 → 5,000. The shipped set as a whole went 261,035 → 251,509 bytes, the smaller percentage being the point: the deep cuts landed where text is paid for unconditionally, and the vendored references whose gotchas a trim would cost were left byte-for-byte. Across all six slices the suite caught thirteen guarded claims mid-rewrite, and every one was restored — the fidelity floor the acceptance criteria named, doing its job at every boundary.
