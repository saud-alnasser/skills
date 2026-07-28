# refactor(knowledge): move this repository onto the dissolved layout

Status: ready-for-agent
Blocked by: 01

## Problem

This repository is configured by Tenure, so it holds its own decisions under the grouping level ticket 01 removes. Until it moves, the repository that builds the framework demonstrates the layout the framework no longer installs — and it is the worked example people read.

## Outcome

This repository's own knowledge sits at the new locations, every inbound reference resolves, and the tree here matches what `/configure` would now produce.

## Acceptance

- This repository's decision records are reachable at their new location with every number and slug unchanged.
- No file in the repository — including the README, the always-on entrypoint, and the build tickets — names a pre-change path except where it is deliberately recording the migration.
- Every Source Pointer in Context and the Domain Contexts resolves.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
