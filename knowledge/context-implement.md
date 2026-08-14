---
owner: framework
type: norm
subject: context
fires-when: stage
stages: [implement]
spans:
  - the-cross-domain-record: 4c0mqx
  - a-domain-s-own-record: qw4e3b
  - where-a-term-belongs: 5qf1rq
  - a-term-owned-by-a-stage-is-defined-once: dilmqp
  - a-term-that-fits-two-rows-is-two-terms: j9rx8q
  - context-is-orientation-never-documentation: x9wt76
  - never-write-implementation-into-context: 7cpqi9
  - one-term-per-concept: mfwi1s
  - a-definition-says-what-the-term-is: 71kfd1
  - only-terms-specific-to-this-repository: 9t6tfm
  - boundaries-state-ownership: nxbw36
  - constraints-outlive-the-implementation: q6ad1y
  - a-source-pointer-is-a-coordinate-never-a-claim: rz8pzc
  - load-when-states-when-never-what: 8qli5v
  - a-domain-earns-a-record: tyybjr
---

# Context Format

Context is how a repository thinks, held as `context` records in the knowledge store. Two kinds, and the split keeps the part every session needs out of the part most sessions never touch: one record holds the vocabulary, boundaries, and constraints that cross domains, and the rest hold one domain each. There is no third kind and no index — which records a request touches is a filter over declared fields, and a routing table that was a file is a query now.

## The cross-domain record

Repository-wide terms, ownership, and the constraints that outlive the implementation:

```md
---
owner: repository
type: context
---

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

## A domain's own record

The same shape minus anything repository-wide, with its declared fields at the top:

```md
---
owner: repository
type: context
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
| only while one workflow stage runs | that stage's own norm |
| only by work in one domain | that domain's Context |
| across stages, or across domains | the cross-domain Context |

## A term owned by a stage is defined once

- **A term owned by a stage is defined in that stage's guide and nowhere else** — the copy that is not edited is the one that goes stale.

## A term that fits two rows is two terms

- **A term that fits two rows is being used in two senses: split it and name each** — that is a finding about the repository, not a filing problem.

## Context is orientation, never documentation

- **Context is orientation, never documentation** — concepts, vocabulary, boundaries, stable constraints, Source Pointers; the compression test in `CLAUDE.md` gates every line of both kinds. The split changes where a line goes; it does not admit a line that failed the test before.

## Never write implementation into Context

- **Never write in code, API shapes, function names, file inventories, or implementation walkthroughs** — they rot the moment the Codebase moves, and the Codebase already answers them.

## One term per concept

- **Be opinionated: one term per concept, the rest under `_Avoid_`** — two live words for one concept is drift with a head start.

## A definition says what the term is

- **A definition is one or two sentences saying what the term IS** — what it does is the Codebase's to show.

## Only terms specific to this repository

- **Only terms specific to this repository** — a general programming concept costs a row and buys nothing, however heavily it is used.

## Boundaries state ownership

- **Boundaries state ownership and the rules that cross it** — who may write what, what is referenced by id only; a module list orients nobody.

## Constraints outlive the implementation

- **Constraints are the ones that outlive the current implementation** — regulatory limits, contractual latency, platform bans; one a refactor could remove is not stable.

## A Source Pointer is a coordinate, never a claim

- **A Source Pointer is a navigation coordinate, never a claim** — `sources: [src/auth/]` means start investigating here and says nothing about what is there. Declaring it as a field moved where the pointer is written and nothing about what it means: `CLAUDE.md` has the verify-before-use rule, and `.claude/protocol.md` how to recover a broken one.

## `load-when` states when, never what

- **`load-when` states when to load the file, never what it is about** — a topic answers a question nobody asked, and it is the one field a query cannot check. Governs every declared load condition, Decisions included; `decisions.md` points here rather than restating it.

## A domain earns a record

- **A Domain Context exists only where a domain has its own vocabulary, principles, or ownership** — a record per source directory is sediment: a filter match that buys nothing.
