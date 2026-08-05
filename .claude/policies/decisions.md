# ADR Format

Decisions are preserved as ADRs in `.claude/decisions/`, sequentially numbered: `0001-slug.md`, `0002-slug.md`, and so on.

Create the directory lazily — only when the first ADR is needed.

## Template

```md
---
status: accepted
load-when: {the condition under which a reader should open this}
sources: [{where the subject of this decision lives}]
supersedes: []
superseded-by: []
---

# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

The prose can still be a single paragraph. The value is in recording *that* a decision was made and *why* — not in filling out sections.

## Declared fields

Every ADR declares these, and they are the only frontmatter it carries. Each exists because something reads it; a field nothing acts on is deleted rather than maintained.

| Field | Holds | Read by |
| --- | --- | --- |
| `status` | `proposed \| accepted \| deprecated \| superseded` | a reader deciding whether this is live |
| `load-when` | the condition under which to open this file | the generated index |
| `sources` | where the subject of this decision lives | the generated index, and anyone navigating |
| `supersedes` | the ADRs this one replaces | the supersession graph |
| `superseded-by` | the ADRs that replace this one | the supersession graph |

**The routing mechanism is `.claude/policies/context.md`'s, and Decisions use it unchanged.** What a `load-when` has to be, why a topic fails there, and why a generated index is never hand-edited are stated in that file and deliberately not repeated here — the rule is the same rule, and a second copy is the one that goes stale. What belongs to *this* format is the supersession pair below, which routing has no equivalent of.

## The index

`.claude/decisions/map.md`, generated from the fields above, one row per ADR in numeric order:

```md
# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0007](0007-events-not-synchronous-http.md) | Ordering and Billing need to communicate | accepted | `src/ordering/` |
| [0018](0018-read-models-are-projected.md) | a query reaches for the write model | superseded | `src/db/` |
```

The status column is what makes the index answer *is this live* without opening anything, which is the question a reader of a fifty-file directory asks first.

**A stage routes through this file and opens only the ADRs it names.** Reading the directory whole is the cost the index exists to remove, and a stage that does it anyway has not been slowed down — it has stopped using the mechanism.

## Optional sections

Only include these when they add genuine value. Most ADRs won't need them.

- **`## Considered Options`** — only when the rejected alternatives are worth remembering
- **`## Consequences`** — only when non-obvious downstream effects need to be called out

Mandatory sections produce filler, and filler trains the reader to skim.

## Numbering

Scan `.claude/decisions/` for the highest existing number and increment by one.

Whenever decisions move — in from another layout, or across a change to AEP's own — **preserve each ADR's existing number and slug** rather than renumbering. Inbound references to `0007` must keep resolving, and they resolve by number, so renumbering to close a gap breaks every one of them at once.

## Supersession

An ADR is a **draft until committed** and may be edited freely while the grill refines it.

Once committed its reasoning is **frozen**. Of the declared fields only `status` and `superseded-by` move after that, and never the prose — an ADR records what was decided and why *at the time*, so rewriting it destroys the only record of the reasoning that was actually applied. `load-when` and `sources` describe the file rather than the decision, and are corrected like any other pointer when what they name moves.

A changed mind is a new file. **Supersession is written at both ends, in the same change**: the new ADR lists the old under `supersedes`, the old lists the new under `superseded-by`, and its `status` becomes `superseded`. A claim made at one end and absent at the other is a **defect**, not a stylistic preference — it is what makes the relationship readable from either side, and what lets the graph be checked at all rather than trusted.

Writing only the new end is the tempting half, because that is the file being edited. It leaves a reader who opens the old ADR with no way to learn it is dead, which is the exact reader this rule exists for.

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
