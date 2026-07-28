# refactor(layout): dissolve the docs level in the shipped layout

Status: ready-for-agent
Blocked by: —

## Problem

`.claude/docs/` groups four artifact kinds, of which only decisions exists in a repository that has not yet run `/design` or `/research`. It also buries Decisions one directory below Context, when `CLAUDE.md`'s own knowledge-layers table presents them as peers — so the layout Tenure installs contradicts the model it teaches, on the first page a reader sees.

## Outcome

The layout Tenure ships and installs puts decisions and designs beside Context and groups research and prototype write-ups under `evidence/`. Every shipped skill that writes to or reads from one of those locations names the new one, and a repository already running Tenure on the old layout is carried across rather than left behind.

## Acceptance

- No file under `skills/` names a `.claude/docs/` path.
- The shipped migration branch converts an existing Tenure repository's layout, preserving each decision record's number and slug.
- `/configure` still pre-creates none of these directories — each is created by whichever command first has something to put in it.
- The verifier's legacy-path table rejects the pre-change paths, and a deliberate reintroduction of one fails the build.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
