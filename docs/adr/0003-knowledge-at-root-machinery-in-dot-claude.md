---
status: superseded by 0006
---

# Repository knowledge lives at the root; only agent machinery lives in .claude/

`CONTEXT.md`, `contexts/`, `docs/adr/`, `docs/designs/`, `docs/research/` and `prototypes/` sit at the repo root. `.claude/` holds `skills/` and optional path-scoped `rules/` — nothing a human needs to browse. The original spec nested all of it under `.claude/`.

Context is the team's shared engineering understanding, not agent scratch, so it belongs where a human finds it. Keeping `docs/adr/` and `.scratch/` at their existing paths also means vendored skills need no path rewrites.

## Considered Options

- **Everything under `.claude/`.** One namespace, gitignorable as a unit — but hides team knowledge and forces a rewrite of every vendored skill's paths.

## Consequences

`.claude/rules/` is deliberately left free. Its `paths:` frontmatter loads files automatically when Claude reads matching source, which is the harness-native version of demand-driven loading — but it fires on file reads, so it arrives too late for `/design`, which needs domain knowledge before it decides what to read. Rules therefore hold *instructions* scoped to paths; `contexts/` holds *knowledge*. The two are not interchangeable.
