# Context Format

<!--
  Installed by /configure at `.claude/policies/context.md`. Copied as-is — it
  describes the workflow, not this repository.

  Routing and vocabulary were one file until this format split them. The reason
  is cost: routing is what every session needs first and it is small, while the
  vocabulary is large and mostly irrelevant to any one request. One file meant
  the cheap half could not be read without the expensive half.
-->

Context is how this repository thinks. It lives in `.claude/contexts/` as three kinds of file, and the split exists so the part every session needs is not carried by the part most sessions do not.

| File | Holds | Read |
| --- | --- | --- |
| `contexts/map.md` | the routing table, and nothing else | first, every session |
| `contexts/repository.md` | vocabulary, boundaries, and constraints that cross domains | when a term or boundary is in question |
| `contexts/<domain>.md` | one domain's own vocabulary and boundaries | when the routing table says the request touches it |

## `contexts/map.md`

The routing table alone. It is the mechanism that makes context loading demand-driven — without it every session pays for every domain.

**It is generated from the fields each context declares, never written by hand.** The two columns beyond the link are the two fields — `load-when` and `sources` — rolled up from the files they describe. A generated table cannot disagree with its directory, because it is not a second statement of the directory's contents: a context added without fields cannot appear in a regeneration, and a row pointing at nothing cannot be produced. That is the property, and it replaces the audit that a hand-written table needed rather than adding to it. **A generated file is never hand-edited**, and the prohibition is enforced by regenerating and comparing rather than requested of whoever opens it.

```md
# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term, boundary, or constraint is in question | — |
| [database](database.md) | the request touches schema, migrations, or queries | `src/db/` |
| [auth](auth.md) | the request touches sessions, tokens, or permissions | `src/auth/` |
| **web** | | `apps/web/` |
| [web/routing](web/routing.md) | the request touches navigation or URL shape | `apps/web/src/routes/` |
| [web/forms](web/forms.md) | the request touches form state or validation | `apps/web/src/forms/` |
```

**Every file under `contexts/` has exactly one row, including `repository.md` itself.** A file with no row is unreachable; a row with no file is a pointer at nothing. Group the rows: repository-wide domains first and flat, then each Project Context as a labelled group of its own.

Nothing else goes in this file. A sentence of orientation here is a sentence every session pays for, which is the cost the split was made to remove.

## `contexts/repository.md`

What a repository-wide term means, who owns what, and which constraints outlive the current implementation.

```md
# {Repo or system name}

{One or two sentences: what this repository is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: purchase, transaction

## Boundaries

- **Ordering owns customer intent.** Billing references orders by id and never reads their internals.
- **Nothing outside Fulfillment writes warehouse state.**

## Constraints

- Response times must stay under 200ms — partner API contract.
- No AWS: compliance.
```

## `contexts/<domain>.md`

The same shape, minus anything repository-wide, and with its **declared fields** at the top.

```md
---
load-when: the request touches schema, migrations, or queries
sources: [src/db/, migrations/]
---

# Database

Persistence for the write model. Read models are projected, never queried directly.

## Language

**Projection**:
A read-optimised table rebuilt from the event log. Always derivable; never a source of truth.
_Avoid_: view, cache, denorm
```

## Where a term belongs

Name every place the term is used, then read off the answer:

| Used | Belongs in |
| --- | --- |
| only while one workflow stage runs | that stage's guide in `.claude/policies/` |
| only by work in one domain | that domain's Context |
| across stages, or across domains | `contexts/repository.md` |

**A term owned by a stage is defined in that stage's guide and nowhere else.** What a ticket's states mean belongs with the ticket format; what a branch asserts belongs with the version-control policy. Defining it in the vocabulary as well is a second home, and the copy that is not edited is the one that goes stale.

A term that seems to fit two rows is being used in two senses. Split it, and name each sense — that is a finding about the repository, not a filing problem.

## What belongs, and what never does

Context is **orientation, not documentation**: concepts, vocabulary, boundaries, stable constraints, Source Pointers.

Apply the **compression test** in `CLAUDE.md` before writing anything into any of the three. Context is not a spec, a scratch pad, or a home for implementation decisions. The split changes where a line goes; it does not admit a line that failed the test before.

**Never write in**: code, API shapes, function names, file inventories, or an implementation walkthrough. Those rot the moment the Codebase moves, and the Codebase already answers them.

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this repository.** General programming concepts — timeouts, error types, utility patterns — do not belong even where the repository uses them heavily. Before adding a term, ask whether it is unique to this repository or general; only the former belongs.
- **Boundaries state ownership and the rules that cross it** — who may write what, what may only be referenced by id. Not a module list.
- **Constraints are the ones that outlive the current implementation** — regulatory limits, contractual latency, platform bans. A constraint a refactor could remove is not stable; leave it out.
- **A Source Pointer is a navigation coordinate, never a claim.** A declared `sources: [src/auth/]` means "start investigating here" — it says nothing about what is there. Declaring it as a field moved where the pointer is written and nothing about what it means: `CLAUDE.md` has the verify-before-use rule, and `.claude/protocol.md` how to recover a broken one.
- **`load-when` states when to load the file, never what it is about.** *"the request touches sessions, tokens, or permissions"* routes; *"authentication and session handling"* is a topic, and a topic answers a question nobody asked. It is the one field a generated table cannot check, so it is read back rather than counted. This rule governs **every** declared load condition, Decisions included — `.claude/policies/decisions.md` adopts the mechanism and points here rather than restating it.

## When a domain earns a file

A Domain Context exists when a domain has **its own vocabulary, principles, or ownership** — never merely because a folder exists. A file per source directory is sediment; it costs a routing-table row and buys nothing.

A Project Context — a directory under `contexts/` — earns its directory on the same test. Domains that span the repository stay flat.

Structure is carried by the filesystem; the routing table carries reachability. Those are two jobs, and the table is not a second copy of the directory layout — it is the load conditions, which the filesystem cannot express.
