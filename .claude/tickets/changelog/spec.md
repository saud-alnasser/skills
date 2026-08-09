---
status: implemented
sources:
  - skills/configure/SKILL.md
  - skills/configure/MIGRATION.md
  - .claude/protocol.md
  - .claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md
  - scripts/verify.ps1
---

# refactor(configure): dated repairs get a release, and the audit reads from a cursor

## Problem

The configuration stage carries ten repairs for shapes that specific past releases left behind, and not one of them records which release. They are spread across two shipped files with no relationship stated: three sit as bullets in the audit list, and seven sit as sections in the migration page beside conversions that are not the same kind of thing at all.

Because none carries a version, the audit cannot tell which still apply. Every run re-checks all ten against every repository, including repositories that never had the shape being repaired and repositories that were configured yesterday. Nothing can ever be retired, because retiring one means judging that no reachable repository is still in that state and no record says when the state stopped being producible.

The list also grows by one per release, in prose, and the growth is invisible: each new bullet reads like the standing checks around it. The most recent addition joined the list without its author noticing it was joining a category.

A second gap arrived with the release check. A session now reports that a repository was configured by an older release than the one running, and nothing can say what that difference consists of. The notification's only available follow-up is *run the audit and find out*, which is the question it was supposed to answer.

## Goal

The stage knows which repairs a given repository has not yet received, applies those, and skips the rest. What a repository would gain by re-configuring is a thing that can be read rather than discovered by running it.

## Constraints

- **Conversion and catch-up are different jobs and keep different homes.** One fires when detection finds a foreign or superseded shape; the other fires when a version is behind. The migration page keeps the first and the shared procedure both depend on.
- **A release entry is frozen once written.** This is what makes a hand-written file safe here where a hand-written index would not be: an index over a directory rots because the directory moves, and a shipped release cannot.
- **The reader is the stage before it is a human.** The file exists to tell the audit where to look and what to fix; being readable by a person is a welcome consequence, not the requirement it is designed against.
- **Nothing is retired in this change.** Judging that no reachable repository is still in some shape is a separate decision, and the cursor makes it unnecessary to make now.
- **Recognition stays by content.** The cursor selects which repairs to consider; each still confirms the shape is actually present before touching anything.
- **The specification is amended in the same change**, since this alters what the configuration stage does.

## Architecture

**One file owns every dated repair: `skills/configure/migration-changelog.md`**, disclosed on demand exactly as the migration page, the script specification, and the tool derivation rules already are. Grouped by release, newest first, and each release says two things — where to look, and what to repair. Where a release changed only what ships, it says so and carries no repair; that is information, not an empty row.

**`aep-version` becomes a cursor, and that is its second job.** The field the release hook compares already records which release wrote a repository's protocol. The audit reads the same field and considers only repairs from releases after it.

**The absent field means opposite things to the two readers, deliberately.** To the hook, no field is *unknown* and it stays silent, because a repository configured before the field existed must not be told it is stale on no evidence. To the audit, no field means the repository predates the field's introduction by definition, so **every repair is considered**. The two readings are consistent rather than contradictory: silence costs a notification, and skipping a repair costs a broken repository.

**The audit list keeps only standing checks.** A standing check is true of every conforming repository on every run — the routing table validates, pointers resolve, tool commands are current. A dated repair is true of repositories in one historical shape. The two read identically as bullets today, which is why one kept being mistaken for the other.

## Approach

The move comes first and the reader second, because a reader pointed at a file with nothing in it is worse than either half alone. They are separate tickets so the move can be reviewed as a move — content relocated, nothing lost — without the procedural change obscuring the diff.

Assigning a release to each of the ten is the part that can go quietly wrong. Each names the shape it repairs rather than the release that caused it, so the release has to be recovered from the Decision or the effort that introduced the shape, and a wrong assignment puts a repair on the far side of a cursor where it will never fire again. Every assignment cites what it was recovered from.

Rejected, and recorded here so it is not reproposed: adding the version grouping to the migration page instead of a new file, which leaves conversion and catch-up interleaved and keeps the ambiguity about where a new repair goes; and generating the file from a declared field on each spec, which is the mechanism this repository would normally reach for and is not available, because nothing declares which release an effort landed in and adding that field is a larger change than the one it would serve.

## Acceptance criteria

- Every dated repair the stage performs is stated in one file, grouped by the release that produced the shape it repairs.
- No dated repair remains in the audit list or in the migration page, and the suite fails if one reappears in either.
- The migration page describes what it now covers, so a reader who opens it for catch-up learns where that went rather than concluding it was dropped.
- An audit against a repository declaring a release considers only repairs from later releases.
- An audit against a repository declaring no release considers every repair.
- Each release's entry says where to look, and says explicitly when a release needs no repair.
- Every release assignment cites the Decision or effort it was recovered from.
- The current release has an entry, and the suite fails when it does not.
- The specification describes the cursor and the standing-versus-dated split.

## Risks

- **A repair is assigned to the wrong release** and lands on the far side of the cursor, where it silently never fires again. The worst failure here, because it is invisible: the audit reports success. Detected by citing the source of each assignment, and bounded by assigning the *earliest* plausible release wherever the evidence is thin — an over-eager repair costs a no-op, a skipped one costs the repository.
- **A future release adds a repair to the old place.** Both files will still exist and one of them will still be about migration. Detected by the assertion that no dated repair sits outside the changelog, which has to be written to recognise the shape of such a bullet rather than the specific ten being moved.
- **The entry becomes a summary of the Decision it points at**, which is the second home this framework exists to prevent. Bounded by the format: two lines and a reference, with the repair stated as an action rather than as reasoning.
- **The file is never read**, because the audit's instruction to read it is one line among many. Detected the first time an audit reports no findings on a repository that is visibly behind.

## Out of scope

- **Retiring any repair.** The cursor removes the need, and the judgement it requires is about repositories that cannot be inspected.
- **Backfilling releases before the earliest repair.** A release that left nothing behind needs no entry for the cursor to work.
- **Generating the file.** Recorded above as rejected, with what it would first require.
- **Any change to conversion.** The migration page's foreign-workflow and superseded-layout branches are untouched.
