# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

Pre-implementation. The repository has no commits, no remote, no package manifest, and no source files. Its entire content is:

- `workflow.md` — the authoritative specification (untracked, ~4,600 lines)
- `skills/` — empty

There is no build, lint, test, or run tooling yet. Do not assume a toolchain exists; check for a manifest before suggesting commands.

## What this project is

`workflow.md` specifies the **Repository Engineering Workflow** — a Claude Code skill framework, authored by the user and derived from https://github.com/mattpocock/skills/tree/main/skills/engineering. The intent is to implement the spec as skill sources under `./src`, install the built output into `.claude/skills/`, then replace the user's installed mattpocock skills with this framework and migrate existing projects onto it.

`workflow.md` is the source of truth for design. Read it before changing anything in this repo. It is a specification, not documentation of shipped behavior — nothing in it is implemented yet.

## Architecture the spec defines

**Three knowledge layers, never duplicating each other:**

| Layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | What currently exists | source |
| Context | How this repository thinks | `.claude/context.md`, `.claude/contexts/*.md` |
| Decisions | Why this approach was selected | `.claude/docs/decisions/*` |

**Truth hierarchy is absolute:** Codebase → Context → Decisions. Conflicts are always resolved by changing documentation to match reality, never the reverse.

**Source pointers** (`Sources: src/auth/`) are navigation coordinates only. They say "start investigating here" — never what APIs, functions, or behavior exist. Every pointer must be verified against the repository before use, and broken pointers are recovered by searching, never by inventing a replacement path.

**Context loading is demand-driven.** Load `context.md` at startup; load domain contexts (`contexts/database.md`, etc.) only when the request touches that domain.

**Eight composable commands**, each owning one responsibility: `/configure`, `/design`, `/research`, `/prototype`, `/implement`, `/review`, `/sync`, `/commit`. Normative specs are expected at `.claude/workflows/<command>.md`.

**Three adaptive tiers** scale process with risk:
- Express — bug fixes, config, isolated refactors: Discovery → Grill → Implement → Commit (no spec; review folds into commit)
- Standard (default) — features, API additions, schema evolution: adds Specification and `/review`
- Heavyweight — architecture, migrations, security- or performance-critical: adds `/research` or `/prototype` before the spec

The user can override tier selection at any time; Claude may recommend but never decides architecture silently.

**Every markdown file carries frontmatter:** `domain` (one primary), `tags` (3–8, concepts not filenames), `version` (semver, per-document), `status` (draft/review/stable/experimental/deprecated/archived/accepted/superseded).

**Target layout** produced by `/configure`:

```
.claude/
├── workflow.md
├── claude.md
├── context.md
├── contexts/
├── workflows/
├── docs/        # designs, research, prototypes, reviews, decisions
├── prototypes/  # disposable experiment code
├── tickets/
└── skills/
```

Note `docs/prototypes/` (prototype write-ups) is distinct from `prototypes/` (throwaway experiment code).

## Conventions the spec mandates

- Conventional Commits (`type(scope): summary`) for commits, PR titles, and issue titles. Scope names the engineering domain; avoid `misc`/`stuff`/`update`.
- Context stores concepts, vocabulary, principles, constraints, relationships — never code, APIs, or implementation walkthroughs. Compression test before writing anything: "will this improve future engineering decisions?"
- CI must never modify repository knowledge (`context.md`, `contexts/*`, `docs/decisions/*`, `docs/research/*`, `docs/designs/*`). Those change only through `/sync` and `/commit`.
- `context.md` stores `last_sync_commit`; `/design` compares it against `git rev-parse HEAD` and runs a lightweight sync when the repository moved.

## Known gaps in workflow.md

Flag or resolve these when implementing rather than working around them:

- `/implement` and `/review` appear in the command table and every pipeline but have no specification sections.
- "Source Pointer Protocol" and "Repository Memory" each appear twice with differing content.
- Metadata examples in the `/sync` and `/commit` sections use `status: active`, which is not in the spec's own list of recommended status values.
- The layout nests `claude.md` inside `.claude/`, but Claude Code auto-loads `CLAUDE.md` from the repository root. Decide which file is authoritative before generating either.

## Agent skills

### Issue tracker

Issues live as markdown files under `.scratch/<feature-slug>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, using their default label strings. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
