# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

Phase 1 of the build is done. Shipped under `./skills/`:

- the four vendored primitives — `grilling`, `tdd`, `codebase-design`, `domain-modeling` (ticket 01)
- `tools/` — the tool reference: `git.md`, `github.md`, `gitlab.md`, `graphite.md` (ticket 15)
- `configure/CLAUDE.template.md` — the always-on verification and healing rules (ticket 02)
- `design/` — `/design`, with `SPEC-FORMAT.md`, `TICKETS.md`, `MAP.md` behind pointers (ticket 03)
- `implement/` — `/implement`, the build stage (ticket 04)
- `code-review/` — `/code-review`, two axes plus the smell baseline behind a pointer (ticket 05)
- `commit/` — `/commit`, the transaction boundary and the Marker's only writer (ticket 06)
- `research/` and `prototype/` — the two evidence commands, with `LOGIC.md` and `UI.md` behind pointers (ticket 07)
- the on-ramps — `triage/`, `diagnosing-bugs/`, `handoff/`, `resolving-merge-conflicts/`, `improve-codebase-architecture/` — plus `configure/tracker.template.md`, the one home for tracker config (ticket 09)

**Phase 2 — the dogfood checkpoint — has not been run**, and ticket 07 was built directly rather than designed first. It remains a human-in-the-loop step: run `/design` on a real piece of work in this repo and watch what breaks.

Tickets 08, 10–14 are not built. `/configure` does not exist yet, so anything depending on it is unverified — including `.claude/tracker.md` itself, which only exists as a template. The `/implement` → `/code-review` → `/commit` chain now exists end to end, but it has only ever been executed by hand — no run has gone through it as skills.

**There is no package manifest and no test runner.** `scripts/verify.ps1` stands in for one: it asserts each ticket's mechanically-checkable acceptance criteria against `./skills`.

```
pwsh -NoProfile -File scripts/verify.ps1            # all tickets
pwsh -NoProfile -File scripts/verify.ps1 -Ticket 09 # one, two digits
```

Extend it in the same pass as any change to `./skills` — it is the only thing that catches a broken build here.

## What this project is

**Tenure** — a Claude Code skill framework derived from https://github.com/mattpocock/skills/tree/main/skills/engineering, adding a persistent repository-knowledge layer. The eventual intent is to replace the user's installed mattpocock skills with it and migrate existing projects onto it (tickets 11 and 12).

### Sources of truth, in order

1. `.scratch/tenure/spec.md` — the authoritative spec: 38 numbered decisions, the alteration checklist, the build order, the target layout.
2. `.scratch/tenure/issues/NN-*.md` — the tickets. `Status:` is `ready-for-agent` / `claimed` / `blocked` / `resolved` / `obsolete`; a `## Comments` section records deviations from the ticket.
3. `docs/adr/` — 11 ADRs. These bind: read the ones covering the area before changing it.
4. `CONTEXT.md` — the glossary. Use these terms exactly, and avoid each entry's `_Avoid_` list.

`workflow.md` is the **superseded** original specification, kept only until the framework it describes is fully built (decision 38). `.scratch/tenure/spec.md` supersedes it. Do not design from `workflow.md`.

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

**The Spine — seven commands**, each owning one stage: `/configure`, `/design`, `/implement`, `/code-review`, `/research`, `/prototype`, `/commit`. There is no `/sync` (ADR 0010). Review ships as `/code-review`, not `/review` (decision 13).

**Primitives** are the model-invoked skills the Spine composes and that own no stage: `grilling`, `tdd`, `codebase-design`, `domain-modeling`, `tools`.

**Three adaptive tiers** scale process with risk:
- Express — bug fixes, config, isolated refactors: Discovery → Grill → Implement → Commit (no spec; review folds into commit)
- Standard (default) — features, API additions, schema evolution: adds Specification and `/review`
- Heavyweight — architecture, migrations, security- or performance-critical: adds `/research` or `/prototype` before the spec

The user can override tier selection at any time; Claude may recommend but never decides architecture silently.

**Frontmatter is load-bearing only** (ADR 0002). `tags` are gone — the routing table in `context.md` replaced them, because a tag has to be read to be useful and a routing table is read once. Keep only what something acts on.

**Target layout** produced by `/configure` (ADR 0006):

```
CLAUDE.md            the sole always-on entrypoint, at the root, under 200 lines
.claude/
├── context.md       ends with the routing table
├── contexts/        Domain Contexts; directories group a Project Context
├── tools/           this repo's own tooling, discovered by /configure
├── rules/           standards discovered in this repo
├── docs/            designs, research, prototypes, decisions
├── prototypes/      disposable experiment code
├── tickets/
├── skills/
├── marker.json      machine-local, gitignored
└── .gitignore
```

Note `docs/prototypes/` (prototype write-ups) is distinct from `prototypes/` (throwaway experiment code).

**This repo is deliberately not in that state yet** (ADR 0006), so `/configure` has a genuine migration to perform when ticket 12 runs.

## Conventions the spec mandates

- Conventional Commits (`type(scope): summary`) for commits, PR titles, and issue titles. Scope names the engineering domain; avoid `misc`/`stuff`/`update`.
- Context stores concepts, vocabulary, principles, constraints, relationships — never code, APIs, or implementation walkthroughs. Compression test before writing anything: "will this improve future engineering decisions?"
- CI must never modify repository knowledge (`context.md`, `contexts/*`, `docs/decisions/*`, `docs/research/*`, `docs/designs/*`). Those change only through the workflow's own commands.
- **The Marker**, not a field in `context.md`, records what Context was last verified against: `.claude/marker.json`, machine-local and gitignored, because a commit cannot contain its own SHA (ADR 0005). Only `/commit` advances it.
- **There is no synchronization stage** (ADR 0010). Context is verified at the moment it is relied on and healed where the break is found. The full discipline is in `skills/configure/CLAUDE.template.md` — that file is the one home for these rules, and restating them elsewhere is the failure this framework exists to prevent.

## Writing skills here

The authoring standard is `writing-great-skills` (in the user's skill set, not this repo): model-invoked vs user-invoked, context load vs cognitive load, the information hierarchy, progressive disclosure, and the named failure modes — premature completion, duplication, sediment, sprawl, no-op, negation.

Two rules bite hardest in this repo:

- **A rule has exactly one home.** ADR 0007 places it: root `CLAUDE.md` for what must hold on every turn, the enforcing skill for a stage rule, `.claude/rules/` for a standard discovered in the repo. A rule that must hold unconditionally *has* to be in `CLAUDE.md` — putting it in a skill means it fires only when that skill runs, which is a silent failure. `scripts/verify.ps1` asserts single-home for the rules most likely to be restated.
- **Vendored skills keep their attribution.** Every skill derived from mattpocock/skills says so (ADR 0001).

## Agent skills

### Issue tracker

Issues live as markdown files under `.scratch/<feature-slug>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, using their default label strings. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
