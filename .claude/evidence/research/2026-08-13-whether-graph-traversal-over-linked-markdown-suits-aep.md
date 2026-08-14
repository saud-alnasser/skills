---
owner: repository
kind: research
falsifies: []
---

# Is Obsidian-style linked-markdown graph traversal an established and better way for agents, and does it suit AEP?

Verified against: published benchmark summaries and project documentation fetched
2026-08-13. Status: answered, with one design implication for ADR 0089. Open: the
benchmark figures are a secondary source's summary and were not read at the paper.

## Answer

**Yes, it is established, and yes it measurably wins — at a retrieval shape AEP does not
have.**

The evidence for graph retrieval is real and specific. Graph-structured retrieval with
logical traversal is reported at **over 36% higher answer accuracy and 21% better
retrieval F1 than dense vector retrievers** on multi-hop benchmarks — MuSiQue,
2WikiMultiHopQA, HotpotQA — with subgraph retrieval statistically significantly beating
traditional RAG at one, two, and three hops. The division of labour is consistent across
sources: vectors give breadth for discovery, graphs give depth for following chains, and
the strongest 2026 systems combine both.

**Every one of those results is measured on multi-hop question answering over an
exploratory corpus.** AEP's primary retrieval is not that. "Deliver the norms that govern
this stage" is a filter on one declared field with a known answer set — `fires-when =
stage:implement`. There is no hop. Introducing traversal there would manufacture hops
where none exist, and each hop an agent takes is a model turn, which is the exact cost
ADR 0089 removed by delivering the row through preprocessing at zero round trips.

**The specific danger is that agentic traversal is judged selection.** The model decides
which links to follow, and the sources note "a model-capability threshold below which
agentic graph traversal degrades rather than helps." ADR 0075 removed judged selection
because mis-loads caused settled questions to be re-asked; ADR 0089 designed it out. A
traversal loop puts it back at the centre of the system.

The most honest field report found is [blog.fsck.com's agent-blog on a 3,300-note
vault](https://blog.fsck.com/agent-blog/2026/03/20/knowledge-graph/), written by the
agent that used it. Influence-tracing across the graph succeeded; the same run also
misattributed five of the business ideas it identified. It offers **no benchmark against
RAG or direct retrieval**, and closes by saying that whether the graph reduces reasoning
errors "or merely makes them traceable remains unanswered."

## The part worth taking

**AEP already has a graph, and the question was never whether to have one.** The edges
are declared today: `supersedes` and `superseded-by`, `blocked-by`, `part-of`,
`falsifies`, `sources`, and — under ADR 0086 — cross-store citation by id. What linked
markdown offers is not the edges but a *traversal habit* over them.

So the real fork is **who walks the edges**: the model, hop by hop, spending a turn on
each and choosing which to follow — or the query, computing a closure and returning it in
one call. Everything already settled points at the second, and there is prior art for it
in this exact space: `vault-graph` is described as returning a connected subgraph in one
call "in place of 10–15 file reads." That is not agentic traversal — it is a **computed
closure**, and it is compatible with ADR 0089's filter rather than a rival to it.

**The design implication for ADR 0089**: a query may return a matched record *together
with its declared-edge closure*, computed server-side to a declared depth. One round
trip, no judgement, deterministic — the same properties the filter already has. That
captures the whole benefit the graph literature reports for depth, without importing the
traversal loop that would reintroduce judged selection.

**On Obsidian-style `[[wikilinks]]` specifically: adopt the density, reject the
mechanism.** A wikilink binds by title or path, so a rename silently rebinds it — the
identical failure ADR 0085 rejected in jDocMunch's heading-text identity and OKF's
path-as-identity. AEP's edges should be declared opaque ids, which is what makes a broken
edge detectable rather than silent.

## Limitations

- **The benchmark numbers are a secondary source's summary.** MuSiQue,
  2WikiMultiHopQA, and HotpotQA results were read from an aggregated description, not
  from the papers, and no methodology, model, or baseline configuration was checked.
- **`vault-graph`'s one-call closure behaviour is unverified.** Its primary source could
  not be reached — the same gap recorded in the relaxed-frame finding — so the closure
  claim rests on a search summary and should be confirmed before being relied on.
- **No measurement was taken on AEP's own corpus.** The claim that AEP's retrieval is
  single-hop is an argument from its query shapes, not an observation of traffic.
