---
version: 3.5.0
use-when: "at the start of every session, before doing anything else in a repository that has a .aep/ directory"
---

# AEP — the Agentic Engineering Protocol

The bootstrap. It orients; `[[policies]]` and `[[rules]]` govern.

## What AEP is

A **filesystem protocol** for engineering work: plain files under `.aep/`, no
runtime or database, the same for every agent. **The repository is
authoritative**; every AEP artifact describes it and loses to it.

## The primitives

| Primitive | Answers | Lives in |
| --- | --- | --- |
| **Policies** | what MUST be done — AEP's, everywhere | `policies/` |
| **Rules** | what MUST be done **here** — yours | `rules/` |
| **References** | how a tool or procedure is operated here | `references/` |
| **Contexts** | what to know about an area, and where to look | `contexts/` |
| **Efforts** | what change is being made | `.aep/efforts/<e>/` |
| **Agents** | who performs work, in what role | `agents/` |
| **Skills** | reusable capabilities | `skills/` |

An effort holds `spec.md`, `plan.md` where the approach is not obvious, its
`evidence/`, its tasks as tickets under `tickets/`, and `log.md`. Worktrees and the
position marker are mechanisms the scripts manage. Never substitute one
primitive for another. **A policy is AEP's and never edited here; a rule is
yours, may tighten or extend a policy, and never softens, contradicts, or opts
out of one.** Down the chain policies → rules → effort rules → task
constraints, each may only tighten what it sits under.

## Where state is

```
.aep/
├── protocol.md    this file
├── index.md       derived discovery index — regenerate, never edit
├── policies/      AEP's governance      rules/  yours
├── agents/  contexts/  references/  scripts/  skills/  templates/
├── friction.md    what got in the way, appended at close
├── efforts/<effort>/{spec.md, plan.md, log.md, evidence/, tickets/}
├── position/      per working tree, gitignored
├── scratch/       per working tree, gitignored
└── worktrees/     isolated checkouts, gitignored
```

New artifacts copy their shape from `templates/`.

## How to discover what matters

**Load by applicability, never by existence:** by `use-when:`, by `paths:`, and
by wiki links from what you already loaded. `index.md` lists them. Read in this
order: repository state → `index.md` → current effort → applicable policies and
rules → relevant contexts → required references → relevant evidence → task →
work.

Links between AEP files are double-bracketed, relative to `.aep/`, without the
`.md`, as in `[[policies/artifacts]]`. A filesystem path of two segments or more
carries `.aep/`; a bare area name does not. A link that does not resolve is
repaired or reported, **never invented**.

## The workflow

```
/specify → /plan? → /tasks → /implement
```

**Four commands**, and nothing else to type. `refine`, `research`, `review`, and `converge` are **stages those
four run for you**. `prototype`, `survey`, and `prune` are capabilities;
`[[skills/help]]` says which to reach for. `/specify` sets the effort's lane —
quick, standard, or full — and the lane sets the ceremony
(`[[policies/execution]]`). Every git and worktree step runs through
`node .aep/scripts/aep.mjs`; quote the `summary` it prints.

## The invariants

**Repository wins.** On conflict, trust: the human in this conversation (say
so, and follow it); the repository's source, config, tests, and build; git
history and systems it designates; `spec.md`; policies; rules; references;
contexts; evidence; derived state; your own reasoning. An artifact the source
contradicts is wrong: correct the artifact where you find it — never the source,
and never explain the contradiction away. A reference never
authorises; a context never instructs. Where the order does not settle it, put
both sides and their costs to the human.

**Claims are checked.** Read the source before any claim about this repository;
names, memory, and a plausible API are not proof, and a CLI is an API — read its
reference, never try a flag to see; an operation no reference covers is a gap,
so say so rather than invent one. Say what you verified and what you assume. Climb only as far as the
uncertainty warrants: known fact → repository → context and evidence →
`[[skills/research]]` (factual) → `[[skills/prototype]]` (technical) → grill
via `[[skills/refine]]` (product).

**Change is small and fits.** The smallest sufficient change; read all of what
you change; match its idiom; fix the root cause, or record why a workaround
exists, what else was considered, and when it goes. Obeying a rule means
letting its check fire: ask what it would catch, and keep that reachable.

**Humans decide.** Merging, releasing, and publishing are theirs. Never push,
publish, or open a pull request unasked; `[[rules/version-control]]` says
exactly what that covers. **Never silently
choose between reasonable architectures:** name each with its costs and risks,
recommend one, and let the human choose. A sub-agent at a decision it may not
make records it and stops.

**Every turn reports.** Once, from the outermost skill, in the shape
`[[policies/reporting]]` fixes.

**Ownership is where a file sits.**

| AEP's — installed verbatim, replaced by upgrades | Yours — an upgrade never touches it |
| --- | --- |
| `policies/` `skills/` `agents/` `templates/` `scripts/` | `rules/` `contexts/` `references/` `efforts/` |
| `protocol.md`, this file | `index.md`, derived and regenerated in place; `friction.md`, appended by `aep close` |

Variation is a **declared deviation** in a rule, with its reason, never an edit
to AEP's text.

**No hidden memory.** Durable knowledge lives in files: policies, rules,
contexts, evidence, specs, `log.md`, the source. Never only in a session.
Knowledge that outlives its effort graduates into a context, a rule, or a
reference; the evidence file stays as the record of how it was learned.

**Write only inside the project.** Read anywhere; write only in these zones.
Anything else is a stop: say what you wanted to write and why.

| Zone | Holds |
| --- | --- |
| the main checkout | source, config, tests, docs, `.aep/` artifacts |
| `.aep/worktrees/<effort>/…` | effort and child surfaces |
| `.aep/scratch/` | handoffs, notes, drafts — one per surface, gone with it |
| where a project tool writes, run the project's way | `node_modules/`, build output, its cache |
| the OS temp dir, through the language's temp API | never a typed path; removed before the run ends |

Never, unless the human asked in this conversation: a drive root, the home
folder, another repository, global config, or a global install.

**One repository.** Another repository may be read, never written, planned, or
run against. Work for it leaves as a write-up: what was found, what it costs,
what would close it — never an offer to do it here. Say so when you reach it.
Being told to fix something is not being told to fix it here; ask if that is
genuinely unclear. A clean position check never licenses it. This repository's
own worktrees are not another repository.

**Nothing is invented.** Where an artifact defines protocol state, use it;
where a script computes an answer, run it and quote it.

## Governance that loads when it applies

| Load when | Policy |
| --- | --- |
| an effort is in progress — tasks, implementation, converge, review | `[[policies/execution]]` |
| a wave of children is dispatched | `[[policies/execution/parallel]]` |
| `tracker:` is on and an effort opens, lands, or closes | `[[policies/tracker]]` |
| creating, changing, or removing anything under `.aep/` | `[[policies/artifacts]]` |
| writing anything a human reads, or auditing a turn's report | `[[policies/reporting]]` |

Your own rules sit beside these in `rules/`, selected the same way.
