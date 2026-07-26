# Context Format

Context is how this repository thinks. `.claude/context.md` is the entrypoint, loaded at the start of every session; `.claude/contexts/**` holds the Domain Contexts, loaded only when the request touches them.

## `.claude/context.md`

```md
# {Repo or system name}

{One or two sentences: what this repository is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

## Boundaries

- **Ordering owns customer intent.** Billing references orders by id and never reads their internals.
- **Nothing outside Fulfillment writes warehouse state.**

## Constraints

- Response times must stay under 200ms — partner API contract.
- No AWS: compliance.

## Domain contexts

| Context | Load when | Sources |
| --- | --- | --- |
| [database](contexts/database.md) | the request touches schema, migrations, or queries | `src/db/` |
| [auth](contexts/auth.md) | the request touches sessions, tokens, or permissions | `src/auth/` |
| **web** | | `apps/web/` |
| [web/routing](contexts/web/routing.md) | the request touches navigation or URL shape | `apps/web/src/routes/` |
| [web/forms](contexts/web/forms.md) | the request touches form state or validation | `apps/web/src/forms/` |
```

The final section is the **routing table**, and it is the mechanism that makes context loading demand-driven — without it every session pays for every domain. It is the last section so a reader who loads only the head of the file still reaches it.

Every Domain Context appears in it exactly once, with the condition for loading it and its Source Pointer. Group the rows: repo-wide domains first and flat, then each Project Context as a labelled group of its own rows.

## `.claude/contexts/**`

A Domain Context is the same shape, minus the routing table — Language, then Boundaries and Constraints where they apply, and a `Sources:` line at the top.

```md
# Database

Sources: `src/db/`, `migrations/`

Persistence for the write model. Read models are projected, never queried directly.

## Language

**Projection**:
A read-optimised table rebuilt from the event log. Always derivable; never a source of truth.
_Avoid_: view, cache, denorm
```

## What belongs, and what never does

Context is **orientation, not documentation**: concepts, vocabulary, boundaries, stable constraints, Source Pointers.

Before writing anything into it, apply the **compression test** — *will this improve a future engineering decision?* If not, don't write it. Context is not a spec, a scratch pad, or a home for implementation decisions.

**Never write in**: code, API shapes, function names, file inventories, or an implementation walkthrough. Those rot the moment the Codebase moves, and the Codebase already answers them.

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Boundaries state ownership and the rules that cross it** — who may write what, what may only be referenced by id. Not a module list.
- **Constraints are the ones that outlive the current implementation** — regulatory limits, contractual latency, platform bans. A constraint that a refactor could remove is not stable; leave it out.
- **A Source Pointer is a navigation coordinate, never a claim.** `Sources: src/auth/` means "start investigating here" — it says nothing about what is there. `CLAUDE.md` has the rules for verifying one and for recovering a broken one.

## When a domain earns a file

A Domain Context exists when a domain has **its own vocabulary, principles, or ownership** — never merely because a folder exists. A `contexts/` file per source directory is sediment; it costs a routing-table row and buys nothing.

A Project Context — a directory under `contexts/` — earns its directory on the same test. Domains that span the repository stay flat.

Structure is carried by the filesystem, not by a map file: the grouping *is* the directory layout, so there is no separate index to drift out of date. When several contexts exist, infer which one the current topic belongs to. If unclear, ask.
