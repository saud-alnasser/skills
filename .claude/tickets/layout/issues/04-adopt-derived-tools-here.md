# refactor(knowledge): derive this repository's own tool references

Status: ready-for-agent
Blocked by: 03

## Problem

This repository's `.claude/tools/` holds only its own tooling. Once the shipped tool skill is deleted, every skill working in this repository points at a directory that has no entry for the tools they most often reach for — the ones the workflow itself drives.

## Outcome

This repository's tool directory holds a derived reference for each tool it actually uses, alongside the entries it already has for its own tooling. Working here needs no file outside it.

## Acceptance

- A reference exists for each tool this repository is detected to use, and none for tools it does not.
- Every carried-over entry is byte-identical to the shipped entry it came from.
- The entries this repository already had for its own tooling survive unchanged.
- Every reference to a tool file from this repository's own knowledge resolves.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
