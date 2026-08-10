---
owner: framework
version: 1.18.0
---

# Context Format

<!-- Installed by /configure at `.claude/policies/context.md`. -->

Context is how a repository thinks, held at `.claude/contexts/` in three kinds of file — the split keeps the part every session needs out of the part most sessions never touch.

| File | Holds | Read |
| --- | --- | --- |
| `contexts/map.md` | the Routing Table, and nothing else | first, every session |
| `contexts/repository.md` | vocabulary, boundaries, and constraints that cross domains | when a term or boundary is in question |
| `contexts/<domain>.md` | one domain's own vocabulary and boundaries | when the routing table says the request touches it |

## `contexts/map.md`

- **The routing table alone — nothing else goes in this file** — a sentence of orientation there is a sentence every session pays for.
- **The table is generated from the fields each context declares, never written by hand** — the columns beyond the link are `load-when` and `sources`, rolled up from the files they describe. A generated table cannot disagree with its directory, because it is not a second statement of the directory's contents — that property replaces the audit a hand-written table needed rather than adding to it.
- **A generated file is never hand-edited** — enforced by regenerating and comparing, never requested of whoever opens it.
- **Every file under `contexts/` has exactly one row, including `repository.md` itself** — a file with no row is unreachable, and a row with no file points at nothing.
- **Rows group as: `repository.md` first, flat domains in filename order, then each Project Context as a labelled group** — filename order is the only ordering a directory supplies.
- **A group's label row carries the directory name and nothing else, its cells blank** — a directory has no frontmatter, so a value there is a claim its directory never made. A file's empty `sources` renders `—`: the dash says the file declared nothing, where a blank says nobody was asked.

```md
---
owner: repository
---

# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term, boundary, or constraint is in question | — |
| [database](database.md) | the request touches schema, migrations, or queries | `src/db/` |
| [auth](auth.md) | the request touches sessions, tokens, or permissions | `src/auth/` |
| **web** | | |
| [web/routing](web/routing.md) | the request touches navigation or URL shape | `apps/web/src/routes/` |
| [web/forms](web/forms.md) | the request touches form state or validation | `apps/web/src/forms/` |
```

## `contexts/repository.md`

Repository-wide terms, ownership, and the constraints that outlive the implementation:

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

The same shape minus anything repository-wide, with its declared fields at the top:

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

| Used | Belongs in |
| --- | --- |
| only while one workflow stage runs | that stage's guide in `.claude/policies/` |
| only by work in one domain | that domain's Context |
| across stages, or across domains | `contexts/repository.md` |

- **A term owned by a stage is defined in that stage's guide and nowhere else** — the copy that is not edited is the one that goes stale.
- **A term that fits two rows is being used in two senses: split it and name each** — that is a finding about the repository, not a filing problem.

## What gets written

- **Context is orientation, never documentation** — concepts, vocabulary, boundaries, stable constraints, Source Pointers; the compression test in `CLAUDE.md` gates every line of all three kinds. The split changes where a line goes; it does not admit a line that failed the test before.
- **Never write in code, API shapes, function names, file inventories, or implementation walkthroughs** — they rot the moment the Codebase moves, and the Codebase already answers them.
- **Be opinionated: one term per concept, the rest under `_Avoid_`** — two live words for one concept is drift with a head start.
- **A definition is one or two sentences saying what the term IS** — what it does is the Codebase's to show.
- **Only terms specific to this repository** — a general programming concept costs a row and buys nothing, however heavily it is used.
- **Boundaries state ownership and the rules that cross it** — who may write what, what is referenced by id only; a module list orients nobody.
- **Constraints are the ones that outlive the current implementation** — regulatory limits, contractual latency, platform bans; one a refactor could remove is not stable.
- **A Source Pointer is a navigation coordinate, never a claim** — `sources: [src/auth/]` means start investigating here and says nothing about what is there. Declaring it as a field moved where the pointer is written and nothing about what it means: `CLAUDE.md` has the verify-before-use rule, and `.claude/protocol.md` how to recover a broken one.
- **`load-when` states when to load the file, never what it is about** — a topic answers a question nobody asked, and it is the one field a generated table cannot check. Governs every declared load condition, Decisions included; `.claude/policies/decisions.md` points here rather than restating it.

## When a domain earns a file

- **A Domain Context exists only where a domain has its own vocabulary, principles, or ownership** — a file per source directory is sediment: a routing-table row that buys nothing.
- **A Project Context — a directory under `contexts/` — earns its directory on the same test** — domains that span the repository stay flat.
- **Structure is carried by the filesystem; the routing table carries the load conditions** — two jobs, and the table is not a second copy of the directory layout.
