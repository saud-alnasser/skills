# Tenure

<!--
  Installed by Tenure's configure stage. This is the repository's sole
  always-on entrypoint: every turn pays for it, including turns where no skill
  runs.

  It is committed, so *every* Claude that opens this repository loads it —
  including one with no Tenure installed. It therefore carries only what holds
  either way. Tenure's own protocol lives in `.claude/tenure.md`, which only
  Tenure's skills read.

  Placement is by **loading mechanism**, not by subject (ADR 0021). A rule in
  `.claude/rules/` with no `paths:` frontmatter is injected on every turn, the
  same as this file; one with `paths:` loads only when Claude reads a file it
  covers. A rule that governs one stage belongs in the skill enforcing that
  stage — written into a skill it fires only when that skill runs, which is
  exactly right for stage rules and silently wrong for unconditional ones.

  Keep it under 200 lines. Everything else is reached by pointer.
-->

This repository builds **Tenure**, a Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time rather than a stateless execution pipeline. It is also configured by Tenure — `skills/` is what ships, `.claude/` is what this repository runs on, and `.claude/context.md` holds the boundary between them.

## Rules that always apply

These files in `.claude/rules/` load unconditionally, alongside this one. They are not restated here, because a standard with two homes drifts at one of them:

- **`.claude/rules/precedence.md`** — which source wins when two instructions conflict.
- **`.claude/rules/engineering.md`** — verifying before claiming, never guessing an API, never pushing or publishing, and never silently deciding architecture.

Everything else in that directory is **path-scoped** and loads only when Claude reads a file it covers; the scope is in each rule's `paths:` frontmatter, not in its prose.

## Knowledge layers

| Knowledge layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | what currently exists | source |
| Context | how this repository thinks | `.claude/context.md`, `.claude/contexts/**` |
| Decisions | why this approach was selected | `.claude/decisions/` |

The order is a **truth hierarchy, and it is absolute**. Where they disagree, the Codebase is right. Resolve every conflict by changing the documentation to match reality — never the reverse, and never by explaining the code away.

Load `.claude/context.md` at the start of a session. Load a Domain Context only when the request touches it; the routing table at the end of it says which and when. Loading them all defeats the point.

## How this repository operates

Two committed files answer that, and both are reached by pointer rather than loaded every turn:

- **`.claude/tracker.md`** — which tracker holds the tickets, and how it is driven.
- **`.claude/version-control.md`** — which version-control model applies, the branch convention, the commit discipline, and how a finished branch lands.

Both are **policy**: what this repository does. `.claude/tools/` answers the neighbouring question of how to *type* any of it. Neither policy file depends on Tenure being installed.

## If you are running Tenure

`.claude/tenure.md` carries Tenure's protocol — how a verification may be skipped, how drift is read, and the report every skill opens with. It is **not** loaded from here, and nothing in this file depends on it. It names machinery that exists only where the plugin is installed, and this file is read by every Claude that opens the repository. Tenure's skills reach it by pointer; without them, everything here still holds on its own.

## Verification at use

**Never a scan. Never a phase.** There is no synchronization stage to run and nothing to reconcile up front — a startup scan would be Claude rediscovering what it already knows, and paying for it on every session.

Instead: at the moment a Context statement is about to be relied on, check it against the Codebase. Scope is whatever the work touches. Drift somewhere else is not this request's problem, and chasing it is how a check becomes a phase.

**Source Pointers are verified before use, always.** A pointer says *start investigating here* — never what APIs, functions, or behavior exist there. When a pointer is broken, recover it by searching the repository for where the concept moved. **Never invent a replacement path.** A pointer that cannot be recovered is reported as broken, not guessed at.

## Healing in place

Fix what you find, where you find it. A stale pointer is repaired in the same breath as discovering it is stale; a boundary that moved is corrected then and there. No queue, no deferred pass, no note to come back.

This discipline is **not best-effort**. There is no periodic reconciliation stage to catch a lapse, so nothing catches one except doing it.

## Requests that would change code

A question gets an answer: load what you need to answer it, and stop.

A request that would **change code** takes the cold path, on every turn, whether or not a workflow command was invoked:

1. Route, load, verify — as above.
2. **State the classification** before touching anything: what kind of change this is, and how much process it warrants. One line.

The point of stating it is that the user can disagree. A classification held silently is a decision made silently — which is the case `.claude/rules/engineering.md` covers for architecture.

## Writing knowledge

CI never modifies repository knowledge. `.claude/context.md`, `.claude/contexts/**`, and `.claude/decisions/**` change through the workflow's own commands and nothing else.

**The compression test, before anything is written into knowledge:** *will this improve a future engineering decision?* If not, don't write it. This applies on every turn, including the ones where a concept moves and no command was typed — capture is not a licence to accumulate.

What belongs in Context and what never does is the `domain-modeling` skill's business — it is the skill that writes it.

## Conventions

**Tenure's conventions are defaults for when the repository is silent** (`.claude/decisions/0008-repo-conventions-outrank-tenure-defaults.md`), never mandates. Where `CONTRIBUTING.md`, a PR template, an existing label set, or the repository's own history documents or demonstrates a convention, that convention wins — detect it before asserting one. Where the repository's convention is genuinely worse, say so once, with reasoning, and then follow it.

The defaults, applied when nothing else is found:

Conventional Commits — `type(scope): summary` — for commit subjects, PR titles, and issue titles. The scope names an engineering domain; `misc`, `stuff`, and `update` are not domains.

A **pull request description** covers the problem, the solution, the architectural impact, the testing performed, the related issues, and any breaking changes. Never a commit-by-commit account — the commits are already on the PR.
