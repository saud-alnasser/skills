# Tenure

<!--
  Installed by Tenure's configure stage. This is the repository's sole
  always-on entrypoint: every turn pays for it, including turns where no skill
  runs.

  It is committed, so *every* Claude that opens this repository loads it —
  including one with no Tenure installed. It therefore carries only what holds
  either way. Tenure's own protocol lives in `.claude/tenure.md`, which only
  Tenure's skills read.

  What belongs here is only what must hold *unconditionally*. A rule that
  applies to one stage belongs in the skill that enforces that stage — a rule
  written into a skill fires only when that skill runs, which is exactly right
  for stage rules and silently wrong for these. A standard discovered in this
  repository belongs in `.claude/rules/`.

  Keep it under 200 lines. Everything else is reached by pointer.
-->

This repository builds **Tenure**, a Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time rather than a stateless execution pipeline. It is also configured by Tenure — `skills/` is what ships, `.claude/` is what this repository runs on, and `.claude/context.md` holds the boundary between them.

## Precedence

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. This file
3. `.claude/context.md` and the Domain Contexts
4. `.claude/docs/decisions/` — an accepted ADR
5. `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the repository's documentation — CONTRIBUTING outranks it because CONTRIBUTING says how this repository is worked on and README says what it is

A user instruction overrides everything here. Say so when it does, and follow it.

`.claude/rules/` holds standards discovered in **this repository** — they belong to it, not to Tenure. A rule that applies to only part of the tree is **path-scoped** to that part; check the scope before applying one.

For what is being *built* here, `.claude/tickets/tenure/spec.md` is authoritative — 43 numbered decisions, the build order, and the target layout — and the tickets beside it record what was actually done. Where the spec and an ADR disagree, the ADR is later and wins.

## Knowledge layers

| Knowledge layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | what currently exists | source |
| Context | how this repository thinks | `.claude/context.md`, `.claude/contexts/**` |
| Decisions | why this approach was selected | `.claude/docs/decisions/` |

The order is a **truth hierarchy, and it is absolute**. Where they disagree, the Codebase is right. Resolve every conflict by changing the documentation to match reality — never the reverse, and never by explaining the code away.

Load `.claude/context.md` at the start of a session. Load a Domain Context only when the request touches it; the routing table at the end of `context.md` says which and when. Loading them all defeats the point.

## If you are running Tenure

`.claude/tenure.md` carries Tenure's protocol — how a verification may be skipped, how drift is read, and the report every skill opens with. It is **not** loaded from here, and nothing in this file depends on it. It names machinery that exists only where the plugin is installed, and this file is read by every Claude that opens the repository. Tenure's skills reach it by pointer; without them, everything here still holds on its own.

## Verify before claiming

**Inspect source before any repository-specific claim** — before implementing, designing, reviewing, or answering a question about this repository. Not sometimes: a claim about what is here is either checked or it is a guess wearing the same words.

**Names are not proof.** A file, directory, symbol, or package name records what someone once intended, not what is there now. Neither is memory, and neither is a plausible-sounding API.

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

The point of stating it is that the user can disagree. A classification held silently is a decision made silently.

**Claude never silently decides architecture.** Where more than one reasonable approach exists, put the options on the table — each named, with what it buys, what it costs, and what it risks — recommend one, and let the user choose. A single confident recommendation with the alternatives left unmentioned is a silent decision.

## Writing knowledge

CI never modifies repository knowledge. `.claude/context.md`, `.claude/contexts/**`, and `.claude/docs/decisions/**` change through the workflow's own commands and nothing else.

**The compression test, before anything is written into knowledge:** *will this improve a future engineering decision?* If not, don't write it. This applies on every turn, including the ones where a concept moves and no command was typed — capture is not a licence to accumulate.

What belongs in Context and what never does is the `domain-modeling` skill's business — it is the skill that writes it.

## Conventions

**Tenure's conventions are defaults for when the repository is silent** (`.claude/docs/decisions/0008-repo-conventions-outrank-tenure-defaults.md`), never mandates. Where `CONTRIBUTING.md`, a PR template, an existing label set, or the repository's own history documents or demonstrates a convention, that convention wins — detect it before asserting one. Where the repository's convention is genuinely worse, say so once, with reasoning, and then follow it.

The defaults, applied when nothing else is found:

Conventional Commits — `type(scope): summary` — for commit subjects, PR titles, and issue titles. The scope names an engineering domain; `misc`, `stuff`, and `update` are not domains.

A **pull request description** covers the problem, the solution, the architectural impact, the testing performed, the related issues, and any breaking changes. Never a commit-by-commit account — the commits are already on the PR.

**Never guess an API, and a CLI is an API.** Read the reference or fetch the docs — there is no third option where you try a flag and see. `.claude/tools/` covers this repository's own tooling. Where Tenure is installed, its `tools/` reference covers the workflow's own tools as well; where it is not, this rule still binds and the docs are the answer.

**Never push and never publish.** Committing is asked for; pushing, opening a pull request, and submitting a stack are the human's call, and they are the actions they cannot undo locally.
