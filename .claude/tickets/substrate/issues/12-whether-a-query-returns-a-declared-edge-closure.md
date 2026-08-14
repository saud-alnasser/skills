---
owner: repository
title: "docs(protocol): settle whether a query returns a declared-edge closure"
status: resolved
blocked-by: []
part-of: substrate
type: grilling
---

## Question

Does a query return the matched record alone, or the matched record together with
what its declared edges reach?

Surfaced while researching whether Obsidian-style linked-markdown traversal suits
AEP. The finding was that **AEP already has a graph** — `supersedes` and
`superseded-by`, `blocked-by`, `part-of`, `falsifies`, `sources`, and cross-store
citation by id under ADR 0086 — so the question was never whether to have edges.
It is **who walks them**: the model hop by hop, or the store in one call.

Held open deliberately while research accumulated; settled once the six findings
were compared rather than on the first reading of any one of them.

The three positions, with what each costs:

- **Closure to a declared depth.** The store computes what the edges reach and
  returns it with the match. One round trip, no judgement, the same determinism
  the filter already has — an ADR arrives with what supersedes it, a norm with the
  framework norm it cites. Depth becomes a parameter someone tunes, and a bad
  depth either returns too much or stops one edge short of the answer, silently.
- **Edges as ids only.** The caller decides what to fetch, at another call each.
  Smallest response, nothing to tune — but fetching becomes a model decision,
  which is judged selection at exactly the point ADR 0075 protects, and *not*
  following an edge looks identical to there being nothing there.
- **Defer to the prototype.** `08` will be running the store and can measure
  closure against ids-only directly. Costs a late discovery: a closure-capable
  store is a different build from one returning flat rows.

## Evidence bearing on this

- `.claude/evidence/research/2026-08-13-whether-graph-traversal-over-linked-markdown-suits-aep.md`
  — graph retrieval's measured wins are real but are all multi-hop QA over an
  exploratory corpus, where AEP's primary retrieval is a zero-hop filter; agentic
  traversal is judged selection, and the sources name a model-capability threshold
  below which it degrades. `vault-graph`'s one-call closure is the nearest prior
  art and its primary source could not be reached.
- `.claude/evidence/research/2026-08-13-how-comparable-frameworks-built-their-knowledge-stores.md`
  — ConPort is the first declared-edge store found whose interface is documented at
  source: `link_conport_items` declares a typed edge between two items, and
  `get_linked_items` reads it back with a `relationship_type_filter`. It returns the
  linked items rather than a computed closure, so it **sits between the first two
  positions rather than settling between them** — the edge is stored and filtered by
  the store, but the depth is one and the caller decides whether to go further. Its
  authority model is rejected on other grounds; the edge interface is not.
- `.claude/evidence/research/2026-08-13-whether-tag-entry-and-link-traversal-suits-aep.md`
  — SA-RAG spreads activation without an LLM in the loop, and states the reason:
  LLM-guided iterative retrieval "may fail due to myopic knowledge exploration,
  retrieving context based on partial reasoning from previous steps." **That is the
  second position's cost, named independently in the retrieval literature**, and it
  is direct support for the first. The same finding sharpens the first position's
  cost: an activation threshold and a traversal depth fail the same way — what falls
  short is not returned and leaves no signal, which is what ADR 0089's *a miss is a
  fact* was bought to prevent. Whatever depth is chosen must therefore be declared
  per edge type rather than tuned globally, or the guarantee is lost.
- Wikilink-style binding is **not** the mechanism to copy: it binds by title or
  path and rebinds silently on rename, the failure ADR 0085 rejected in
  jDocMunch's heading-text identity and OKF's path-as-identity. Whatever is
  decided here, edges are declared opaque ids.

## Answer

**The store computes the closure and returns it with the match; depth is declared
per edge type, never a query parameter.** Chosen with the user from the composite
in
[`which-substrate-design-the-six-findings-support`](../../../evidence/discussions/2026-08-13-which-substrate-design-the-six-findings-support.md),
after all six findings were compared rather than on any one of them.

Both alternatives fail the same guarantee from opposite sides. Ids-only makes each
hop a model decision, and an unfollowed edge is indistinguishable from an absent
one. A single global depth is wrong for `supersedes` and `sources` simultaneously,
and being wrong is silent either way. Per edge type, depth stops being a tuned
number and becomes a fact about what the edge means — `supersedes` closes fully,
`part-of` to the effort root, `blocked-by` and `falsifies` one hop, `sources` not
at all.

The third position — defer to `08` — is not taken as the answer, because a
closure-capable store is a different build from one returning flat rows and the
choice cannot wait for the prototype. It survives as a check: `08` compares
closure against ids-only on real traffic, and ADR 0092 is revisited if the closure
turns out unused.

Recorded as ADR 0092.
