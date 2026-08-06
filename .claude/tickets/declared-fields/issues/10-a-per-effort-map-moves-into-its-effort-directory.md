---
title: refactor(knowledge): a per-effort map moves into its effort's directory
status: resolved
blocked-by: []
part-of: declared-fields
---

## Problem

`.claude/policies/maps.md` and the shipped `maps.template.md` both put the fog map at `.claude/tickets/map.md`. The map is per effort — its title is `# map: <effort name>`, its Notes hold *"standing preferences for this effort"*, and out-of-scope work *"returns as a fresh effort"* — so a single path is one file for an artefact that comes one per effort. Two concurrently mapped efforts contend for it, and nothing in the policy states the one-at-a-time constraint that would make the path safe.

The normative layout in `specs.md` §21 names `spec.md` and `issues/NN-*.md` under each effort and does not name the map at all, which is how the mismatch survived: the policy claimed a path the specification never granted.

Ticket 07 found it by generating a design index onto the same path. That index is the right occupant of a repository-wide path and the wrong occupant of a per-effort one; ADR 0059 places both by scope.

## Outcome

A fog map lives at `.claude/tickets/<effort>/map.md`, beside the `spec.md` and `issues/` that effort already owns. `.claude/tickets/map.md` is left free for the design index ticket 07 builds.

Templates first, per ADR 0025. The specification is amended in the same change, per ADR 0029.

## Acceptance

- Both copies of the map format — shipped template and installed policy — put the map under the effort's own directory, and the suite fails if either still names the shared path for it.
- `specs.md` §21 names both the per-effort map and the repository-wide index, so a layout that named neither cannot let two artefacts arrive at one path again.
- Every skill that reaches the map by path is updated, and the suite fails on a pointer left at the old location — `/design`'s fog branch is the one that reads it.
- `MIGRATION.md` carries a row converting a map found at the old path, and the migration is exercised rather than asserted in prose.
- No fog map exists in this tree, so the conversion has nothing to move here — say so rather than manufacturing a fixture that proves the migration against a file the repository does not have. The migration's own test is the fixture `/configure` already uses.

## Coordination

**Ticket 07 is blocked on this one.** It cannot take `.claude/tickets/map.md` until the map format has vacated it, and building both in one pass would leave the moment where two artefacts claim one path inside a single commit rather than between two.

## Comments

**One acceptance criterion is not met, and it rests on something I wrote in the design run that was false.** Criterion 4 asks that the migration be *"exercised rather than asserted in prose"*, and criterion 5 defers to *"the fixture `/configure` already uses"*. **There is no such fixture.** Both review axes went looking independently and found none anywhere in the suite: the only enforcement any migration row has is a regex over `MIGRATION.md`'s own prose, which is the prose being asserted rather than the migration exercised. The row exists and is guarded; the exercise does not, and building a migration fixture is real work this ticket did not scope. Recorded rather than quietly satisfied.

**The `$legacy` table was the wrong mechanism, and review was right to reject it.** Reusing it looked elegant — it already sweeps `skills/` and already forces a conversion row. But every path in that table was **retired**, and this one was **reassigned**: ADR 0059 hands `.claude/tickets/map.md` to the design index in the same breath as it takes it from the map. A blanket ban would have forbidden the new tenant from being named anywhere shipped, and the table's label would have offered whoever tripped it the wrong replacement. The row is gone, the reason is recorded where it was, and the claim is guarded where it actually is — the map's own home, in both format copies.

**What `/review` found besides:**

- **The layout guard was wrong twice, in two different ways, and passed both times.** First it matched `contexts/map.md` rather than the tickets entry, so deleting the tickets entry left it green. The fix scoped it from `tickets/` to the closing fence — which swallows `position/` and `worktrees/`, so review filed the shared index under the directory `specs.md` itself calls *never depended on* and all four assertions still passed. The subtree is now bounded by indentation. Ordering luck is not scope, and this is the second time in one assertion.
- **A comment asserted a test that does not exist** — *"the migration's own exercise is `/configure`'s"*. Same class as the criterion above, and corrected in the same pass.
- **Nothing anchored `# map: <effort name>`.** The migration derives a map's destination from its own title, and both format copies rest their reasoning on it, yet changing the title to `# Fog map` left the whole suite green with the destination underivable. Now asserted in both copies.
- **ADR 0059's `sources` named the wrong file** — `.claude/policies/specs.md`, which says nothing about a path and defers to the tracker policy — while omitting root `specs.md`, whose §21 this change amends and which is half the decision.
- **One assertion was removed as an invented obligation.** No criterion asks the format copies to say *why* the map is per-effort; I had added the prose and then a guard enforcing it. The prose stays — the placement is non-obvious and the reason is the surprising part — but a diff that invents a requirement and then tests itself against it is how a diff stops being the one that was reviewed.

**Ticket 07's `## Blocked` note was written in the present tense about a working tree that no longer holds its partial build.** Corrected; the build was saved as a patch and cleared, because it overlapped in `scripts/verify.ps1` and every ticket on this frontier touches that file.

Seven deliberate reintroductions, each caught: both format copies returning to the shared path, the migration row deleted, the layout dropping either entry, the map title losing its effort, and review's own `position/` filing.
