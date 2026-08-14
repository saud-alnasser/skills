# AEP

This repository builds the **Agentic Engineering Protocol (AEP)** — a Claude Code skill framework where understanding compounds over time. `skills/` and `agents/` are what ships; `.claude/` is what this repository runs on.

For what is *built* here, `specs.md` is the canonical, authoritative specification and `.claude/tickets/` records what was done. Where it and an ADR disagree, the ADR wins and the specification is amended in the same change.

## Rules that always apply

`.claude/rules/precedence.md`, `.claude/rules/engineering.md`, `.claude/rules/placement.md`, and `.claude/rules/boundary.md` are always-on and never restated here — a standard with two homes drifts at one of them. The rest of that directory is path-scoped by `paths:` frontmatter.

## Knowledge layers

| Layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | what currently exists | source |
| Context | how this repository thinks | `.claude/contexts/**` |
| Decisions | why this approach was selected | `.claude/decisions/` |

The order is absolute: where they disagree, the Codebase is right — fix the documentation, never the reverse. Load `.claude/contexts/map.md` at session start — routing only; Domain Contexts load on demand.

## Machinery

`.claude/protocol.md` is the router — the verification machinery and the stage table — reached by pointer, so a question turn never pays for it. `.claude/policies/tracker.md` says where tickets live; `.claude/policies/version-control.md` how work lands; `.claude/tools/` how to *type* it.

## Verification at use

**Never a scan. Never a phase.** A Context statement is checked against the Codebase at the point of use; scope is what the work touches. **Source Pointers are verified before use, always** — a broken one is searched for, never invented; the router has the machinery. Fix drift where you find it, in the same breath — nothing else catches a lapse.

## Which stage a request enters

A question gets an answer: load, answer, stop. A change, every turn, command or not: **state the classification** — what kind of change, how much process, and **which stage it enters** — one line, before touching anything, so the user can disagree — **then enter that stage**; how each is reached is the router's.

Top to bottom, first match wins — the four lower rows are read rather than judged:

| The request | Enters |
| --- | --- |
| it would change another repository | nothing — report, hand back |
| a question about how something works | nothing — answer, stop |
| this tree already holds a claim | the build, resuming it |
| a ticket is ready to build | the build |
| it arrived from outside — an issue, a pull request | triage |
| anything else that would change code | design |

**A loaded norm that settles a question is acted on, citing the line — never re-asked.** Asking is for genuine forks only.

## Framework law

**A record declaring `owner: framework` is followed as written — never edited, healed, or debated.** Variation enters as a `deviates-from` edge, which every build reports until it is removed. Unstamped records are the repository's, healed as ever.

## Writing knowledge

CI never modifies repository knowledge: `.claude/contexts/**` and `.claude/decisions/**` change only through the workflow's commands. Before any write, the compression test: *will this improve a future engineering decision?* If not, don't write it. What belongs in Context: `.claude/policies/context.md`.

## Conventions

**The workflow's conventions are defaults for when the repository is silent**: detect before asserting; where the repository's own is genuinely worse, say so once, then follow it. Defaults: `.claude/policies/version-control.md`.
