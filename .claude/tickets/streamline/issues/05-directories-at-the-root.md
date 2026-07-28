# refactor(layout): every main directory at the root, and per-clone state in one place

Status: open
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
