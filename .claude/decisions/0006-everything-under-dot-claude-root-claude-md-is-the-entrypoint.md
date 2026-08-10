---
owner: repository
status: accepted
load-when: something is proposed at the repository root rather than under .claude/
sources: [CLAUDE.md, .claude/]
supersedes: [0003]
superseded-by: []
---

# Everything lives under .claude/; root CLAUDE.md is the sole entrypoint

Supersedes `0003`, which put knowledge at the repo root.

In a repository running Tenure, `.claude/` holds the whole workflow — `context.md`, `contexts/`, `docs/decisions|designs|research|prototypes/`, `prototypes/`, `tickets/`, `skills/`, `rules/`, its own `.gitignore`, and the machine-local `marker.json`. The only file outside it is `CLAUDE.md` at the repo root, which Claude Code auto-loads and which routes to everything else.

`.claude/.gitignore` is what makes "one directory" literal — entries for `marker.json` and `prototypes/` live there rather than in the repo's root ignore file, so adding or removing Tenure touches nothing outside `.claude/` and `CLAUDE.md`.

One entrypoint, one namespace. The workflow can be added to or removed from a repository as a single directory, and nothing but `CLAUDE.md` competes for the root.

## Consequences

Reverses `0003`'s reasoning that team knowledge belongs where humans browse. The trade-off is accepted: knowledge sits one directory deeper and is invisible to tools that only look at the root.

Vendored skills need their paths rewritten — `CONTEXT.md` becomes `.claude/context.md`, `docs/adr/` becomes `.claude/docs/decisions/`, `.scratch/` becomes `.claude/tickets/`. This is the cost `0003` was avoiding, and it is paid once during vendoring.

Root `CLAUDE.md` is auto-loaded every session, so it stays under the 200-line target Claude Code recommends. It carries routing and always-on rules — never knowledge, which lives in `context.md` and loads on demand.

**This repository is deliberately not yet in that state.** Tenure is being built using mattpocock's conventions (`CONTEXT.md`, `docs/adr/`, `.scratch/`), so that running `/configure` here later performs a genuine migration with real content to convert, rather than a no-op on an empty repo.
