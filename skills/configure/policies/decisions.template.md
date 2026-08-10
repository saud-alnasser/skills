---
owner: framework
version: 1.19.0
---

# ADR Format

<!-- Installed by /configure at `.claude/policies/decisions.md`. -->

Decisions are ADRs in `.claude/decisions/`, sequentially numbered `0001-slug.md` onward. Create the directory lazily, with the first ADR.

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

- **A single paragraph is enough** — the value is recording *that* a decision was made and *why*, never filling out sections.
- **Optional sections only where they earn it** — `## Considered Options` when the rejected alternatives are worth remembering, `## Consequences` when downstream effects are non-obvious; mandatory sections produce filler, and filler trains the reader to skim.

## Declared fields

Every ADR declares these five, and no others — a field nothing acts on is deleted rather than maintained.

| Field | Holds | Read by |
| --- | --- | --- |
| `status` | `proposed \| accepted \| deprecated \| superseded` | a reader deciding whether this is live |
| `load-when` | the condition under which to open this file | the generated index |
| `sources` | where the subject of this decision lives | the generated index, and anyone navigating |
| `supersedes` | the ADRs this one replaces | the supersession graph |
| `superseded-by` | the ADRs that replace this one | the supersession graph |

- **The routing mechanism is `.claude/policies/context.md`'s, used unchanged and deliberately not repeated here** — what a `load-when` must be, why a topic fails there, and why a generated index is never hand-edited live in that file; a second copy is the one that goes stale. What belongs to *this* format is the supersession pair below, which routing has no equivalent of.

## The index

`.claude/decisions/map.md`, generated from the fields, one row per ADR in numeric order:

```md
---
owner: repository
---

# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0007](0007-events-not-synchronous-http.md) | Ordering and Billing need to communicate | accepted | `src/ordering/` |
| [0018](0018-read-models-are-projected.md) | a query reaches for the write model | superseded | `src/db/` |
```

- **The status column answers *is this live* without opening anything** — the first question a reader of a fifty-file directory asks.
- **A stage routes through the index and opens only the ADRs it names** — reading the directory whole is the cost the index exists to remove, and doing it anyway is not being slowed down but abandoning the mechanism.

## Numbering

- **Highest existing number plus one.**
- **Whenever decisions move — in from another layout, or across a change to AEP's own — preserve each ADR's existing number and slug** — inbound references to `0007` must keep resolving, and they resolve by number, so renumbering to close a gap breaks every one at once.

## Supersession

- An ADR is a draft until committed. Once committed its reasoning is **frozen**: of the declared fields only `status` and `superseded-by` move, and never the prose — an ADR records what was decided and why *at the time*, and rewriting it destroys the only record of the reasoning actually applied. `load-when` and `sources` describe the file rather than the decision, and are corrected like any other pointer.
- **A changed mind is a new file, and supersession is written at both ends, in the same change** — the new ADR lists the old under `supersedes`; the old lists the new under `superseded-by` and its `status` becomes `superseded`. A claim made at one end and absent at the other is a **defect**, not a stylistic preference — it is what lets the graph be checked rather than trusted.
- **Writing only the new end is the tempting half, because that is the file being edited** — it leaves a reader who opens the old ADR with no way to learn it is dead, and that reader is the exact one this rule exists for.

## When to offer an ADR

All three must hold, or it is not a Decision:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder why on earth it was done this way.
3. **The result of a real trade-off** — genuine alternatives existed and one was picked for specific reasons.

- **A convention is not a decision** — it belongs in the skill or rule that enforces it, never here.

What qualifies: architectural shape; integration patterns between contexts; technology choices that carry lock-in; boundary and scope decisions — the explicit no-s as much as the yes-s; deliberate deviations from the obvious path, which stop the next engineer from "fixing" something deliberate; constraints not visible in the code; rejected alternatives whose rejection is non-obvious, which otherwise get re-proposed in six months.
