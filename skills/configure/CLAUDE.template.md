# {Repo name}

<!--
  Installed by /configure. This is the repository's root entrypoint: every turn
  pays for it, including turns where no skill runs.

  It is committed, so *every* Claude that opens this repository loads it —
  including one with no plugin installed. It therefore carries only what holds
  either way, and it reaches everything else by pointer. Every file it points at
  is generated and committed too, so following a pointer never requires the
  plugin; only the slash commands do.

  Placement is by **loading mechanism**, not by subject:

    always-on   this file, and `.claude/rules/` with no `paths:` frontmatter
    scoped      `.claude/rules/` with `paths:` — loads when a covered file is read
    on demand   everything reached by a pointer, including `.claude/protocol.md`

  So a rule that must fire unconditionally goes in one of the first two, and
  never into a file a stage has to open to reach — that fires only when the
  stage runs, which is a silent failure rather than a loud one. What stays
  *here* rather than moving to `.claude/rules/` is what a reader needs to
  navigate: what this repository is, and where the machinery lives.

  Keep it under 200 lines.
-->

{One or two sentences: what this repository is.}

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

Load `.claude/context.md` at the start of a session. Load a Domain Context only when the request touches it; the routing table at the end of `context.md` says which and when. Loading them all defeats the point.

## How this repository operates

Two committed files answer that, and both are reached by pointer rather than loaded every turn:

- **`.claude/policies/tracker.md`** — which tracker holds the tickets, and how it is driven.
- **`.claude/policies/version-control.md`** — which version-control model applies, the branch convention, the commit discipline, and how a finished branch lands.

Both are **policy**: what this repository does. `.claude/tools/` answers the neighbouring question of how to *type* any of it, which is why it is a third directory rather than a section in either. Neither policy file depends on the plugin being installed.

## Where the workflow's machinery lives

`.claude/protocol.md` is the router: how a verification may be skipped, how drift is read, the report every stage opens with, and the table saying which guides each stage reads. It is **not** loaded from here, and nothing in this file depends on it — it is reached by pointer, so a turn that answers a question does not pay for it.

It is committed like everything else, so a reader without the plugin follows the same pointer and reads the same file. Only the slash commands need the plugin; nothing carrying a rule does.

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

What belongs in Context and what never does is settled by the format the workflow's commands write to; `.claude/context.md` is that format worked out against this repository, and reading it is how the shape is learned without the plugin.

## Conventions

**The workflow's conventions are defaults for when the repository is silent** (ADR 0008), never mandates. Where `CONTRIBUTING.md`, a PR template, an existing label set, or the repository's own history documents or demonstrates a convention, that convention wins — detect it before asserting one. Where the repository's convention is genuinely worse, say so once, with reasoning, and then follow it.

The defaults, applied when nothing else is found:

Conventional Commits — `type(scope): summary` — for commit subjects, PR titles, and issue titles. The scope names an engineering domain; `misc`, `stuff`, and `update` are not domains.

A **pull request description** covers the problem, the solution, the architectural impact, the testing performed, the related issues, and any breaking changes. Never a commit-by-commit account — the commits are already on the PR.
