---
title: feat(configure): whatever formats a repository is made to skip `.claude/`
status: resolved
blocked-by: []
part-of: aep
---

## Problem

`/configure` generates a directory of markdown into a repository whose formatter has never been told about it. Prettier, Biome, dprint, and the markdown linters reflow prose, realign tables, and renormalize list markers on files whose diffs exist to be read — so knowledge starts churning on the formatter's schedule rather than on the schedule of what the repository actually learned.

Nothing in the skill says to prevent this. `.claude/.gitignore` handles git and stops there, and the neighbouring rule says the repository's own root ignore file is left alone (ADR 0006) — read straight across, that reads as _leave the formatter alone too_, which is how the gap survives being obvious.

## Outcome

Step 4 makes the formatters this repository actually runs skip `.claude/`, using each one's own ignore mechanism as its file in `.claude/tools/` describes — the same never-guess route every other tool takes, and a missing entry is a configuration gap rather than licence to invent a filename. Step 1 collects formatting alongside build and test so there is something to act on, and step 6 validates the outcome rather than the edit.

ADR 0033 records why this is allowed to write outside `.claude/` when the ignore rule beside it deliberately is not: the mechanism belongs to the formatter, and Prettier's is a single file read from where it runs.

## Acceptance

- Step 4 instructs the run to make each detected formatter skip `.claude/`, and routes the _how_ through `.claude/tools/`.
- The instruction names no specific formatter — detection is off the repository, as every other tool derivation is.
- Step 1's read collects formatting, and step 4's tool list names the formatter among the repository's own tools.
- Step 6 validates that nothing formatting the repository reaches `.claude/`.
- ADR 0033 exists here, and the shipped instruction carries the exception's bound in its own prose rather than by citation; ADR 0006's root-ignore rule still stands and its guard stays green.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**The shipped instruction does not cite ADR 0033.** Drafted with the citation, matching the five already in `configure/SKILL.md`. Removed at the user's instruction, and the distinction is worth keeping: those five are parenthetical attribution, while a bolded _"ADR 0033 carries the exception and its bound"_ directs a reader to open a decision record their repository does not have. The bound travels in the prose instead, and the suite asserts it at both homes rather than through a cross-reference.

**Two pre-existing failures were repaired in the same commit**, at the user's direction. Both arrived in `fc49348` and neither belongs to this ticket, but this ticket cannot claim its own last criterion while the suite is red:

- The `comments say why` guard matched `\*?why\*?` and the line had been rewritten `*why*` → `_why_`. The guard was broadened to accept either marker rather than the prose being changed back — it exists to catch the directive being deleted, not to police markdown.
- The boot ceiling stood at 5,600 against a measured 5,725, the eighth always-on directive having been added without the raise. Moved to 5,800 and recorded in the ratchet comment, as that comment requires.
