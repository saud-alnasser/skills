---
owner: repository
kind: research
falsifies: []
---

# Does a brain-like retrieval model — small classified notes, entry by tag, traversal by link — suit AEP?

Verified against: arXiv 2502.12110v1 (A-MEM) and 2512.15922v1 (SA-RAG) read as HTML,
arXiv 2502.14802 (HippoRAG 2) read at its abstract page, and the `obsidian-mcp-pro`
repository page — all fetched 2026-08-13. Status: answered, and the decisive evidence
comes from the canonical brain-like system's own successor paper. Open: three papers named
in Limitations were not read.

Fifth framing of the store question, and the sharpest so far: not *graph retrieval in
general* — that was
[`whether-graph-traversal-over-linked-markdown-suits-aep`](2026-08-13-whether-graph-traversal-over-linked-markdown-suits-aep.md) —
but one specific two-phase architecture. **Small atomic markdown notes, each classified
with frontmatter metadata; a query enters the corpus through tags; retrieval then spreads
outward along links.**

## Answer

**The model is real, named, implemented, and measurably good — at the retrieval shape AEP
does not have. And this time the evidence against applying it to AEP's shape is published
by the people who built the brain-like system, about their own system.**

The architecture has a name in cognitive science and two in the literature: **spreading
activation** for the mechanism, **hippocampal indexing** for the framing. HippoRAG
(NeurIPS 2024) "synergistically orchestrates LLMs, knowledge graphs, and the Personalized
PageRank algorithm to mimic the different roles of neocortex and hippocampus in human
memory" — seeding PPR from query entities and ranking passages by propagated probability.
This is precisely entry-then-spread.

**Its successor paper is the finding.** [From RAG to Memory: Non-Parametric Continual
Learning for Large Language Models](https://arxiv.org/abs/2502.14802) (HippoRAG 2, arXiv
2502.14802) states in its abstract:

> "Recent RAG approaches augment vector embeddings with various structures like knowledge
> graphs to address some of these gaps, namely sense-making and associativity. **However,
> their performance on more basic factual memory tasks drops considerably below standard
> RAG.** We address this unintended deterioration..."

Read that against AEP. The corpus is a few hundred norms; the primary query is *"deliver
the norms whose `fires-when` is `stage:implement`"*. That is **basic factual memory** —
the exact category where the graph-augmented brain-like model was measured to degrade, by
its own authors, badly enough that fixing it was the stated purpose of a follow-up paper.
HippoRAG 2's own headline gain is "a 7% improvement in associative memory tasks," which is
the category AEP does not query in.

**The second finding is about tags specifically, and it is more surprising.** The system
closest to the description asked about — [A-MEM: Agentic Memory for LLM
Agents](https://arxiv.org/abs/2502.12110), explicitly Zettelkasten-inspired, atomic notes
with links — **generates tags on every note and then does not retrieve by them.** Each note
is `mᵢ = {cᵢ, tᵢ, Kᵢ, Gᵢ, Xᵢ, eᵢ, Lᵢ}` — content, timestamp, LLM-generated keywords,
LLM-generated **tags** `Gᵢ`, contextual description, embedding, links. But the tags are
folded into the embedding, `eᵢ = fenc[concat(cᵢ, Kᵢ, Gᵢ, Xᵢ)]`, and retrieval is plain
cosine similarity against the query embedding: `sq,ᵢ = eq·eᵢ/|eq||eᵢ|`, take top-k. **No
tag lookup, no link traversal at query time.** Its links are built the same way — top-k
cosine neighbours passed to an LLM to name the connection.

So in the flagship implementation of the architecture asked about, tags are a **feature
fed to an embedder**, not an index, and the link graph built at write time is not walked at
read time. That is worth knowing before designing around tag-entry: the reference system
tried classification and reverted to similarity.

**Third: the described system exists at file level and is tiny.** `obsidian-mcp-pro`
implements the model literally over a markdown vault — `get_tags` (with usage counts),
`search_by_tag(tag, includeContent)`, `get_backlinks(path)`, `get_outlinks(path)`,
`get_graph_neighbors(path, depth, direction)` for "notes connected within N link hops",
plus `find_orphans` and `find_broken_links`. There is **no persistent index**: it keeps an
"in-memory mtime cache" and reads the markdown directly, "without persisting note bodies to
disk." It has **28 stars**. The pattern is buildable and someone built it; nothing about it
is established or load-bearing anywhere.

## The part worth taking

**One mechanism, and it argues for what ticket `12` already put first.**

[SA-RAG](https://arxiv.org/abs/2512.15922) runs spreading activation **without an LLM in
the loop**: seeds are the top-k entity descriptions by cosine similarity, activation
propagates breadth-first as `a_j = min(1, a_j + Σ(a_i · w_ij))` with edge weights rescaled
`w' = (w−c)/(1−c)`, `c = 0.4`, "to prevent overactivation", and nodes above a threshold
`τ_a` are activated. The paper states the design reason explicitly — it spreads
activation automatically "rather than using a prompted LLM to perform the SA procedure",
because LLM-guided iterative retrieval "may fail due to **myopic knowledge exploration,
retrieving context based on partial reasoning from previous steps**."

**That is judged selection's failure mode, named in the retrieval literature, arrived at
independently.** It is the same argument ADR 0075 makes from AEP's own history, and it
is direct support for `12`'s first position: if edges are ever walked, **the store walks
them, computed, in one call** — never the model, hop by hop.

Its results are strong (MuSiQue 45%→67% correctness over naive RAG; 2WikiMultiHopQA
48%→76%) and land in exactly the place every prior graph finding landed: **multi-hop QA**,
and on "a random subset of 100 questions per benchmark" because LLM-based graph
construction is expensive.

**Two smaller things are worth taking regardless of the retrieval decision:**

- **`find_broken_links` and `find_orphans` are build-time checks AEP wants anyway.** Under
  ADR 0085 edges are declared opaque ids, and a declared id that resolves to nothing is
  detectable — that detector is the thing that makes declared edges better than wikilinks,
  and it belongs in the build alongside id minting, not in a query.
- **A-MEM's token figure is the one number in this research that measures AEP's actual
  goal**: "around 1,200-2,500 tokens versus 16,900 tokens" against MemGPT on LoCoMo. But
  the reduction comes from returning k notes instead of a whole history, which is what
  *any* selective retrieval does — a filter included. It is evidence that selection saves
  context, not that associative selection does.

## Why the model does not fit, stated once

Three reasons, in order of how hard they are to design around:

1. **Measured degradation on AEP's query category.** Above, from HippoRAG 2's abstract.
   Everything else in this finding is secondary to it.
2. **Associative entry is lossy by construction, and ADR 0089 bought the opposite.** A
   spreading-activation retrieval returns what crosses `τ_a`. What falls below it is not
   returned and **produces no signal that it existed** — the same silent shortfall `12`
   names as the cost of a badly-chosen depth. ADR 0089 chose filters precisely so that
   "there is no search, only filters, so **a miss is a fact**." Tag-entry plus threshold
   traversal cannot make that guarantee; it is the definition of a system that can quietly
   return less than the answer.
3. **AEP's tags already exist and are called `fires-when`.** A norm declares the condition
   under which it binds, and a stage's row filters on it. That *is* classified entry — with
   an exhaustive answer set instead of a ranked one. Adding a tag vocabulary on top would
   be a second, softer classification of the same records, and the softer one would be the
   one that silently under-returns.

**None of this argues against small, classified, linked markdown files.** That is what AEP
is building — ADR 0085's spans, ADR 0084's types, the declared edges of ADR 0086. The
divergence is one step: **what a query does with them.** The brain-like model activates and
spreads; AEP filters and delivers. The corpus shape is the same; the retrieval contract is
not.

## Limitations

- **HippoRAG 2's claim is read from its abstract only.** The sentence about factual-memory
  degradation is quoted verbatim, but the paper was not fetched, so which structured
  systems were measured, on which benchmarks, and by how much is **not established here**.
  The abstract asserts the direction, not the magnitude. Given this is the finding's load-
  bearing claim, a session about to act on it should read the paper.
- **HippoRAG 1's mechanism and its "up to 20% improvement" are from a search summary**, not
  from the NeurIPS paper. The PPR-from-query-entities description should be treated as
  approximately right, not quoted.
- **Three relevant papers were not read**: SYNAPSE (arXiv 2601.02744, episodic-semantic
  memory via spreading activation with lateral inhibition and temporal decay),
  Query-Aware Spreading Activation (2606.30133), and Human-Inspired Memory Architecture
  (2605.08538). All surfaced in search and all sit in the same family; none was opened.
  SYNAPSE in particular claims a hybrid that may address the factual-memory degradation.
- **A-MEM's storage substrate is unknown.** The paper names `all-minilm-l6-v2` for
  embeddings but documents no vector store, database, or file format — so "Zettelkasten-
  inspired" describes its note *structure*, and it is not established that it writes
  markdown files at all.
- **Every benchmark cited is multi-hop QA** — MuSiQue, 2WikiMultiHopQA, LoCoMo. No source
  found measures any of these architectures on a bounded-corpus exhaustive-filter workload,
  which is AEP's. The claim that AEP's retrieval is that workload remains an argument from
  its query shapes, not an observation of traffic — the same gap the prior graph finding
  recorded, still open, and only a prototype closes it.
- **Nothing was installed or run.** `obsidian-mcp-pro` was read at its repository page; its
  28-star count and in-memory-cache behaviour are as documented on 2026-08-13.
