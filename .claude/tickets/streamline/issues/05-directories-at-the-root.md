# refactor(layout): every main directory at the root, and per-clone state in one place

Status: resolved
Blocked by: 04
Part of: streamline

## Problem

The workflow directory a repository is given mixes levels. Directories, loose knowledge files, per-clone state, and tool configuration sit side by side, so nothing about the tree says which of them is knowledge, which is machinery, and which would be wrong in another clone. A reader cannot tell the categories apart by looking.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

A configured repository is given a tree that reads as its own map: main directories at one level, per-clone state in a directory of its own, and one file loose at the workflow directory's root — the router the entrypoint points at. Evidence keeps its grouping directory, because its three kinds share a property nothing else there has and the phrase about findings graduating out of evidence names a real move.

## Acceptance

- A freshly configured repository has exactly one markdown file loose at the workflow directory's root.
- Per-clone state is written under one directory, and everything that references it is generated pointing at the new location.
- The definition of what is per-clone still states the category and its membership test, rather than listing entries.
- The ignore rules still keep nothing shared depending on ignored state, and the anchoring that stops the throwaway-code pattern swallowing the write-ups survives the move.
- Directories are still created lazily by whichever command first has something to put in them; the new layout does not become a set of empty directories written at onboarding.
- The repository's own root ignore file is still left alone.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

### Built

The per-clone directory is `.claude/position/`, named for the term the glossary already defines rather than for a convention — `codebase-design`'s naming rule says to check what a word already means here before reusing one, and Position means exactly this.

**`settings.local.json` cannot move**, established by reading the tree rather than assumed: the harness writes it at that exact path and this workflow never touches it. It stays at the root as the one per-clone file outside `position/`, and the ignore file says why.

**The write-up hazard is removed rather than guarded.** Throwaway code and the write-ups that outlive it used to be one word apart at different depths, kept separate by a leading slash. They now sit under different parents, so the assertion checks the outcome — that no ignore entry can reach `evidence/prototypes/` — instead of asserting the anchor that used to be the only thing achieving it.

### Recurs, and belongs to ticket 09

**A `.claude/` path that this effort moves makes this repository's derived tool references diverge from their shipped sources**, because `layout/03` compares each entry by exact string equality. Updating the derived copy is not available: it would then name a path this repository does not have until ticket 16 adopts.

Resolved here by removing the Marker's path from the entry entirely — it was a second home for a fact the protocol owns, so deleting it was right independently. **That escape will not always exist.** Every remaining structural ticket that moves a path named in a tool reference hits the same wall, and the choice then is to weaken the comparison mid-effort or to introduce a knowingly wrong path. Ticket 09 re-anchors the suite and is where the general answer belongs; deciding it seven times in seven tickets is how it ends up decided differently each time.
