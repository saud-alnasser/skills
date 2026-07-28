# refactor(layout): every main directory at the root, and per-clone state in one place

Status: open
Blocked by: 04
Part of: streamline

## Problem

The workflow directory mixes levels. Directories, loose knowledge files, per-clone state, and tool configuration sit side by side, so nothing about the tree says which of them is knowledge, which is machinery, and which would be wrong in another clone. A reader cannot tell the categories apart by looking.

## Outcome

The tree reads as its own map: main directories at one level, per-clone state in a directory of its own, and one file loose at the root — the router the entrypoint points at. Evidence keeps its grouping directory, because its three kinds share a property nothing else there has and the phrase about findings graduating out of evidence names a real move.

## Acceptance

- Exactly one markdown file sits loose at the workflow directory's root.
- Per-clone state lives under one directory and every reference to it resolves.
- The definition of what is per-clone still states the category and its membership test, rather than listing entries.
- Nothing committed depends on a file the ignore rules match: deleting every ignored file loses this clone a shortcut and loses no other clone any information.
- Evidence keeps one grouping directory over its three kinds.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
