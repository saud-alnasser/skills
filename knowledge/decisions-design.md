---
owner: framework
type: norm
subject: decisions
fires-when: stage
stages: [design]
spans:
  - template: s3vqkl
  - a-single-paragraph-is-enough: 2iku40
  - optional-sections-only-where-they-earn-it: ke2kn0
  - the-routing-mechanism-is-not-repeated-here: aabupr
  - numbering-starts-one-above-the-highest: 8hnvzk
  - a-moved-adr-keeps-its-number-and-slug: ogrii7
  - when-to-offer-an-adr: e7g0u3
  - a-convention-is-not-a-decision: 7xx6ji
---


# ADR Format

A Decision is a `decision` record in the knowledge store, its file named `0001-slug.md` onward and numbered sequentially. The whole file is one record, keyed on its title heading, because a frozen account's sections are one record's parts rather than separate statements.

## Template

```md
---
owner: repository
type: decision
status: accepted
load-when: {the condition under which a reader should open this}
sources: [{where the subject of this decision lives}]
supersedes: []
superseded-by: []
falsified-by: []
---

# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

## A single paragraph is enough

- **A single paragraph is enough** — the value is recording *that* a decision was made and *why*, never filling out sections.

## Optional sections only where they earn it

- **Optional sections only where they earn it** — `## Considered Options` when the rejected alternatives are worth remembering, `## Consequences` when downstream effects are non-obvious; mandatory sections produce filler, and filler trains the reader to skim.

## The routing mechanism is not repeated here

- **The routing mechanism is `context.md`'s, used unchanged and deliberately not repeated here** — what a `load-when` must be, why a topic fails there, and why a generated index is never hand-edited live in that file; a second copy is the one that goes stale. What belongs to *this* format is the supersession pair below, which routing has no equivalent of.

## Numbering starts one above the highest

- **Highest existing number plus one.**

## A moved ADR keeps its number and slug

- **Whenever decisions move — in from another layout, or across a change to AEP's own — preserve each ADR's existing number and slug** — inbound references to `0007` must keep resolving, and they resolve by number, so renumbering to close a gap breaks every one at once.

## When to offer an ADR

All three must hold, or it is not a Decision:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder why on earth it was done this way.
3. **The result of a real trade-off** — genuine alternatives existed and one was picked for specific reasons.

What qualifies: architectural shape; integration patterns between contexts; technology choices that carry lock-in; boundary and scope decisions — the explicit no-s as much as the yes-s; deliberate deviations from the obvious path, which stop the next engineer from "fixing" something deliberate; constraints not visible in the code; rejected alternatives whose rejection is non-obvious, which otherwise get re-proposed in six months.

## A convention is not a decision

- **A convention is not a decision** — it belongs in the skill or rule that enforces it, never here.
