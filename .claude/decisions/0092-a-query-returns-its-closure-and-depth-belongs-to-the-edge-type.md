---
owner: repository
status: accepted
load-when: what a query returns beyond the matched record, or how far a declared edge is followed, is in question
sources: [.claude/tickets/substrate/issues/12-whether-a-query-returns-a-declared-edge-closure.md, .claude/evidence/discussions/2026-08-13-which-substrate-design-the-six-findings-support.md]
supersedes: []
superseded-by: []
---

# A query returns its closure, and depth belongs to the edge type

**A query returns the matched record together with what its declared edges reach,
computed by the store in one call.** The alternative — returning edge ids and
letting the caller fetch — makes each hop a model decision, which is judged
selection at the point ADR 0075 protects, and makes *not* following an edge
indistinguishable from there being nothing to follow.

**Depth is a property of the edge type, declared once, never a query parameter.**
A global depth is the failure both halves of the graph research converge on: too
large returns a subgraph nobody asked for, too small stops one edge short and
leaves no signal that it did — which is the silent under-return ADR 0089 bought
`a miss is a fact` to prevent. Per edge type, the answer is a fact about the
edge's meaning rather than a number somebody tuned:

| Edge | Closes | Because |
| --- | --- | --- |
| `supersedes` / `superseded-by` | fully | a superseded decision without its successor is the wrong answer, at any distance |
| `part-of` | to the effort root | the effort is the unit a ticket is read in |
| `blocked-by` | one hop | what blocks this is wanted; what blocks that is the blocker's business |
| `falsifies` | one hop | the finding's subject, not its subject's subjects |
| `sources` | not at all | provenance is followed deliberately or not at all |
| `deviates-from` | one hop | the framework norm departed from is wanted; what *it* cites is the framework's business, not the deviating repository's |

The sixth row is ADR 0095's, added when a deviation from framework law became a declared
edge rather than a prose section — the mechanism that keeps it loud once nothing is copied
and there is no installed file to diff.

**Traversal is computed, never prompted.** SA-RAG spreads activation
breadth-first over declared weights rather than asking a model to walk, and names
the reason: LLM-guided iterative retrieval "may fail due to myopic knowledge
exploration, retrieving context based on partial reasoning from previous steps."
That is ADR 0075's finding reached independently in the retrieval literature, and
it is why the store walks the graph.

**A closure is not a search.** Every edge is a declared opaque id under ADR 0085,
so the reachable set is exact and the guarantee ADR 0089 established survives:
there is no ranking, no threshold, and no result that was nearly returned.

## Considered Options

- **Edges as ids only, the caller fetches** — rejected: it reintroduces judged
  selection per hop, and an unfollowed edge looks identical to an absent one.
- **Closure to a single declared depth, global** — rejected: one number cannot be
  right for `supersedes` and `sources` at once, and being wrong is silent in both
  directions.
- **Defer entirely to the prototype** — rejected as the primary answer, since a
  closure-capable store is a different build from one returning flat rows and the
  choice cannot be deferred past the build. The measurement is still wanted:
  `substrate/08` compares closure against ids-only on real traffic, and this
  decision is revisited if it shows the closure is unused.
- **Associative retrieval — tag entry, then spreading activation** — rejected on
  measured grounds: HippoRAG 2 reports graph-augmented retrieval's "performance
  on more basic factual memory tasks drops considerably below standard RAG", and
  basic factual retrieval is what AEP does. It also cannot promise a miss is a
  fact, since what falls below an activation threshold leaves no signal.
