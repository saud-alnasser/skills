# ADR Format

Decisions are preserved as ADRs in `.claude/decisions/`, sequentially numbered: `0001-slug.md`, `0002-slug.md`, and so on.

Create the directory lazily — only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why* — not in filling out sections.

## Optional sections

Only include these when they add genuine value. Most ADRs won't need them.

- **`status` frontmatter** (`proposed | accepted | deprecated | superseded by NNNN`) — useful when decisions are revisited
- **`## Considered Options`** — only when the rejected alternatives are worth remembering
- **`## Consequences`** — only when non-obvious downstream effects need to be called out

Mandatory sections produce filler, and filler trains the reader to skim.

## Numbering

Scan `.claude/decisions/` for the highest existing number and increment by one.

Whenever decisions move — in from another layout, or across a change to AEP's own — **preserve each ADR's existing number and slug** rather than renumbering. Inbound references to `0007` must keep resolving, and they resolve by number, so renumbering to close a gap breaks every one of them at once.

## Supersession

An ADR is a **draft until committed** and may be edited freely while the grill refines it.

Once committed its reasoning is **frozen**. Only `status: superseded by NNNN` moves after that — never the prose. An ADR records what was decided and why *at the time*; rewriting it destroys the only record of the reasoning that was actually applied.

A changed mind is a new file. The superseding ADR names what it supersedes, so the relationship reads from either end: a reader opening the old file learns immediately that it is dead, and a reader opening the new one learns what it replaced.

## When to offer an ADR

All three of these must be true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If a decision is easy to reverse, skip it — you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

A convention is not a decision. It belongs in the skill or rule that enforces it, not here.

### What qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library — just the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "We're using manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite. These stop the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it — otherwise someone will suggest GraphQL again in six months.
