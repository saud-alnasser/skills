# refactor(configure): compress onboarding, its templates, and the tool references

Status: superseded
Superseded by: aep/09 (ADR 0030)
Blocked by: 09
Part of: streamline

## Problem

Onboarding is the largest single area in the framework once its templates, migration branch, and tool references are counted. Its templates are also the one place where compression is not free of consequence: a template is what every future repository is born from, and text cut there is text no configured repository ever gets.

## Outcome

Onboarding, its templates, its migration branch, and its tool references are compressed on the same standard as the rest. The templates keep every rule they install; only the prose defending those rules is cut.

## Acceptance

- A repository configured from the compressed templates has the same rules as one configured before, stated more briefly.
- The generated entrypoint stays within its line budget.
- Every tool reference keeps its invocations, its flags, and its documentation link; only prose is cut.
- The single-file test command is still present and still derived from the repository rather than from ecosystem convention.
- The migration branch still detects and converts every layout it detected before.
- Maintainer notes are in block-level HTML comments where they are for humans only, since those are stripped before loading and therefore cost nothing.
- No claim guarded by an assertion was lost.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
