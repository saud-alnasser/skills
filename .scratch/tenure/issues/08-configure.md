# feat(configure): initialize or migrate a repository onto Tenure

Status: ready-for-agent
Blocked by: 02, 03, 13

## Problem

`/configure` is how a repository joins Tenure. It must handle a greenfield repo, a repo with existing AI tooling, and — the case we will actually run first — a repo already using mattpocock's conventions.

## Outcome

`./skills/configure/` — user-invoked.

**One job: make repository knowledge correct and complete.** Onboarding and auditing are not two responsibilities bolted together — they are the same job against different starting states, and a repo with no knowledge is the degenerate case of one whose knowledge is incomplete. The behaviour is chosen by what it finds, never by a flag:

| Starting state | What it does |
| --- | --- |
| No Tenure, no AI workflow | Analyse, generate `context.md` + contexts + `CLAUDE.md` |
| No Tenure, another AI workflow present | The above, plus the migration below |
| Tenure already present | Audit — prune what nothing references, validate the routing table, re-check pointers, mark specs reality already satisfies |

The audit branch exists because verification-at-use structurally cannot reach knowledge **nothing loads**: unused context is never checked, because nobody checks what they don't read.

**Detect.** Search for existing AI workflows: `.claude/`, `CLAUDE.md`, `AGENTS.md`, `docs/agents/`, `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`, `.cursor/`, `.github/copilot-instructions.md`, `.windsurf*`, `.clinerules`, `.ai/`.

**Plan, confirm, apply.** Present the full move list before touching anything; apply on approval. The mattpocock migration:

| From | To |
| --- | --- |
| `CONTEXT.md` | `.claude/context.md`, reshaped to orientation + routing table |
| `docs/adr/*` | `.claude/docs/decisions/` |
| `docs/agents/*` | folded into `CLAUDE.md` and `.claude/`, originals removed |
| `.scratch/*` | `.claude/tickets/` |

**Classify, never copy.** Existing documentation is sorted, not duplicated: implementation explanations stay in source; principles become context; historical reasoning becomes decisions; developer instructions become `CLAUDE.md`; temporary notes are discarded.

**Adopt the engineering, convert the workflow** (ADR 0008). `/configure` inherits the repository's own conventions — commit style, label vocabulary, source and test layout, human docs — rather than replacing them with Tenure's defaults. It may name a convention it thinks is worse, once, with reasoning, and then follow it.

The AI workflow layer is the exception and converts wholesale: agent instruction files, repository knowledge, agent workflow config, agent ticket stores, and the way work is done. Leaving any of it in place produces two competing workflows. Where a converted file is still referenced from `README.md`, `CONTRIBUTING.md`, or source comments, leave a pointer at the old path rather than a broken link.

**Analyse and generate.** Languages, build, test, deploy, architectural style, module boundaries, domains. Write `.claude/context.md` with the routing table, and a `contexts/*.md` only where a domain has its own vocabulary, principles, or ownership — never because a folder exists.

**Write `CLAUDE.md`** as the entrypoint from the template in ticket 13: under 200 lines, routing plus always-on rules, no knowledge. Preserve the user's existing sections. Emit repo-discovered standards as path-scoped `.claude/rules/*.md`.

**Write `.claude/tracker.md`** — which tracker this repo uses and how to drive it. GitHub when a remote points there, local markdown otherwise; ask when it's ambiguous. Triage labels fold into the same file.

**Write `.claude/tools/*.md`** — the repo's own tooling in the ticket 15 format: package manager, test runner, typechecker, linter, build, deploy. Task-to-command, with docs URLs and the condition for fetching them. This is what stops `/implement` and `tdd` guessing how to run a single test file.

**Validate.** Every Source Pointer resolves; every file in `contexts/` appears in the routing table; no implementation duplication; `.claude/.gitignore` exists covering `marker.json` and `prototypes/`, so the workflow stays self-contained and the repo's root ignore file is left alone.

## Acceptance

- Running it twice produces no duplication and reports what already exists.
- No documentation is deleted without appearing in the confirmed plan.
- Fresh repo and mattpocock-repo paths both work.
