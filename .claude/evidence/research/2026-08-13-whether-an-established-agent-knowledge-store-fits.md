---
owner: repository
kind: research
falsifies: []
---

# Does a well-established knowledge store for agents already exist that AEP could adopt rather than build?

Verified against: the primary sources listed per claim below, all fetched 2026-08-13. Versions where a project declares one: Open Knowledge Format SPEC.md at `main` declaring v0.2 (announced v0.1, 2026-06-12); MCP specification revision `2025-06-18`; Claude Code documentation at `code.claude.com/docs/en/memory` (self-dating to v2.1.217); Chroma, Astro, Cursor, Sphinx, Antora, Basic Memory, mem0, Letta, Graphiti documentation as published on 2026-08-13.

Status: **No candidate fits. The build is justified.** Open questions at the end — chiefly the `jMRI-Full` retrieval-interface specification, which I could not read, and three named leads I could not confirm.

## Answer

Nothing found meets AEP's settled requirements, and the misses are not close calls on
polish — each is a structural miss on a criterion an ADR already settled. The
landscape divides into five families, and every member fails at least three of the six
criteria.

The three nearest misses are worth naming precisely, because they are the ones a future
session will rediscover:

- **Google Cloud's Open Knowledge Format (OKF)** is the closest on *shape*: committed
  markdown, YAML frontmatter, `type` as the one always-required key, human-curated,
  no runtime or SDK. It fails on the addressable unit — a concept is a whole file and
  its identity **is its file path** — which is exactly the two things ADR 0085 rejected
  (whole files; identity that moves when the file is renamed). It also defines no
  per-type required fields, no index, and no precedence, so three more criteria have no
  answer at all.
- **jDocMunch** is the closest on *span addressing*: it splits markdown into a section
  tree by heading and addresses sections by byte offset. It fails on identity — section
  identity holds only "as long as path, heading text, and heading level are unchanged."
  A heading rename silently rebinds. That is the precise failure ADR 0085 bought its
  way out of by declaring opaque ids in frontmatter and asserting the anchor binding in
  both directions, and it is the failure that carries the fidelity floor.
- **Astro content collections** is the closest on *typing and derivation*: per-collection
  Zod schemas, entries with ids, a data store rebuilt from committed markdown at build
  time. It fails on the unit (a whole file per entry; headings are returned as render
  metadata, not addressable records), it has no precedence, and it is a website build
  system rather than anything an agent queries at turn time.

**The rejection that matters most is general-purpose vector retrieval, and the honest
version is narrower than "vector stores chunk by similarity."** Chroma's ids are
caller-supplied strings, so a caller *could* insert one record per declared span under
its declared id — the chunking is the caller's choice, not the store's. What a vector
store then supplies is a keyed blob table with metadata filters and a similarity ranker.
It supplies none of typing-by-type, span derivation, precedence, or the
never-written-to packaged store; AEP would still build all of that and additionally take
on an embedding pipeline and a second copy of every norm's text. The disqualifier is
therefore *what it does not supply*, plus the fact that it stores its own copy of the
content — which fails the derivation criterion outright. Where a retriever *does* choose
the chunks, as in markdown-vault-mcp's word-budgeted adaptive splitting, ADR 0085 rules
it out directly.

**Nothing found computes precedence over a result set, and nothing found federates a
read-only packaged store with a writable local one behind one query interface.** These
two criteria have no candidate at all, in any family. The closest prior art for each
sits outside the agent space entirely — Sphinx's intersphinx inventory for the packaged
read-only store, Antora's resource-ID coordinates for federation — and both are
documentation build systems, not queryable stores.

What this means for `06`: it answers *what to build*, not *which to adopt*. Two pieces
of prior art are worth borrowing rather than inventing, and both are named in the
findings: Sphinx's declared-label-before-a-heading model (which independently arrived at
ADR 0085's design, including warnings on broken references) and its `objects.inv`
derived inventory shipped inside a published package.

## Findings

### The criteria, and how each serious candidate scores

`C1` typed records, required fields varying by type · `C2` heading-bounded span with a
stable declared id · `C3` multiple stores behind one interface, one packaged and
never written · `C4` derived from committed markdown, rebuildable locally · `C5` index
is not the source of truth · `C6` computed precedence, or metadata enough to compute it.

| Candidate | C1 | C2 | C3 | C4 | C5 | C6 |
| --- | --- | --- | --- | --- | --- | --- |
| Open Knowledge Format v0.2 | partial | no | no | yes | n/a — no index | no |
| jDocMunch | partial | partial | no | yes | yes | no |
| Astro content collections | yes | no | no | yes | yes | no |
| Basic Memory | partial | no | no | no — two-way write | yes | no |
| library-mcp | no | no | no | yes | yes | no |
| mcp-server-markdown | no | partial | no | yes | n/a — no index | no |
| markdown-vault-mcp | no | no | no | yes | yes | no |
| Chroma (as substrate) | no | no | no | no — stores a copy | no | no |
| mem0 / Letta / Graphiti | partial | no | no | no | no | no |
| AGENTS.md / Cursor rules / CLAUDE.md | no | no | no | yes | n/a — no index | no |

### Family 1 — markdown-native stores served over MCP

- Basic Memory stores knowledge as markdown files with a derived index: "Just files plus a local SQLite index" — [basic-memory README](https://raw.githubusercontent.com/basicmachines-co/basic-memory/main/README.md), overview.
- Basic Memory is written by the agent, not derived from an authored corpus: "Two-way. AI and humans write to the same files; sync keeps them in step" — [basic-memory README](https://raw.githubusercontent.com/basicmachines-co/basic-memory/main/README.md), sync section. This fails the derivation criterion: the store owns content rather than deriving it.
- Basic Memory's unit is a note/entity, not a heading-bounded span, and headings carry no addressing role: "The headings '## Observations' and '## Relations' are only informative. Basic Memory will parse elements from anywhere in the Markdown" — [docs.basicmemory.com, what-is-basic-memory](https://docs.basicmemory.com/start-here/what-is-basic-memory).
- Basic Memory identifies notes by `memory://` permalinks resolving a slug or path, e.g. `memory://folder/note-title` — [docs.basicmemory.com, what-is-basic-memory](https://docs.basicmemory.com/start-here/what-is-basic-memory). Path-derived identity, not a declared opaque id.
- Basic Memory's semantics are observations and relations extracted from bracket and wikilink syntax — `[decision] Use JWT tokens for API auth`, `implements [[API Security Spec]]` — [docs.basicmemory.com, what-is-basic-memory](https://docs.basicmemory.com/start-here/what-is-basic-memory). A note is not typed the way ADR 0084 requires; type markers annotate bullets inside a note.
- library-mcp returns whole files, retrieved by tag, text, slug/URL, or date range, with a `rebuild` tool for the derived index — [library-mcp README](https://raw.githubusercontent.com/lethain/library-mcp/main/README.md), tools section. Derivation and rebuildability are right; the unit is a whole file.
- mcp-server-markdown does extract heading-bounded spans — `get_section` "Extract[s] a section by heading until the next heading of same/higher level" — but identifies them by heading text and maintains no index, doing "Full-text search across all .md files" on demand — [mcp-server-markdown README](https://raw.githubusercontent.com/ofershap/mcp-server-markdown/main/README.md), tools list. Correct span boundary, wrong identity, no store.
- jDocMunch parses documents "into a section tree keyed by heading hierarchy, stores each section's byte offsets into the original file" — [jdocmunch-mcp repository page](https://github.com/jgravelle/jdocmunch-mcp).
- jDocMunch's identity guarantee is explicitly conditional on the heading not changing: sections have "durable identities across re-indexing as long as path, heading text, and heading level are unchanged" — [jdocmunch-mcp repository page](https://github.com/jgravelle/jdocmunch-mcp). Under ADR 0085 a heading rename must fail the build rather than silently unbind; here it silently rebinds.
- markdown-vault-mcp chunks by a word budget rather than by declared span: "long sections are recursively re-split at deeper heading levels (H1 → H6) until each chunk fits a configurable word budget", default 400 words with 40 words of overlap — [markdown-vault-mcp README](https://raw.githubusercontent.com/pvliesdonk/markdown-vault-mcp/main/README.md). This is the chunks-a-retriever-chose case ADR 0085 rules out.
- markdown-vault-mcp ranks by fused similarity — "Reciprocal Rank Fusion combining FTS5 and vector results" with "Diversity-aware ranking" — [markdown-vault-mcp README](https://raw.githubusercontent.com/pvliesdonk/markdown-vault-mcp/main/README.md). Relevance ranking, not precedence over binders.

### Family 2 — specified markdown knowledge formats

- OKF is Google Cloud's "open specification that formalizes the LLM-wiki pattern into a portable, interoperable format", announced 2026-06-12 at v0.1 — [Google Cloud blog, How the Open Knowledge Format can improve data sharing](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing).
- OKF makes type first-class and required: "`type` is the only always-required key; a concept carrying just `type` is fully conformant" — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md).
- OKF defines no per-type required fields; producers choose type values and "consumers MUST tolerate unknown types gracefully, typically by treating them as generic concepts" — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md). ADR 0084 requires required fields to vary by type; OKF deliberately declines to specify that.
- OKF's addressable unit is a whole file and its identity is its path: "**Concept ID**: The path of the concept's file within the bundle, with the `.md` suffix removed" — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md). ADR 0085 chose opaque declared ids precisely so files keep readable names and can be renamed.
- OKF cross-links are file paths, not ids — absolute forms "begin[] with `/`, interpreted relative to the bundle root" or standard relative markdown paths — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md). ADR 0086's cross-store coupling is a citation by id.
- OKF specifies no index and no retrieval mechanism, leaving both to consumers — bundles are "Just markdown — readable in any editor, renderable on GitHub, indexable by any search tool" — [Google Cloud blog](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing). The only index in the ecosystem is navigational: "Auto-generated `index.md` files let an agent or human navigate the hierarchy one level at a time" — [OKF README @ main](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/README.md).
- OKF specifies no conflict or precedence rules, and requires permissiveness instead: consumers "MUST NOT reject a bundle because of: Missing optional frontmatter fields. Unknown `type` values. Unknown additional frontmatter keys" — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md). ADR 0086 needs the opposite: a computed order, and a cross-store contradiction raised loudly as a deviation.
- OKF expects agents to write concepts: "This lets your agents take on the drudgery of reading and updating their own files, while your team curates the content" — [Google Cloud blog](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing). Compatible with AEP's authoring model, but not evidence of derivation.
- OKF reserves `index.md` and `log.md`, which "MUST NOT be used for concept documents" — [OKF SPEC.md @ main, v0.2](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md). A filename collision AEP would inherit.

**Cost to adopt OKF**: low mechanically — AEP's frontmatter already carries `owner`, and a `type` key is additive. What AEP would give up is the whole of ADR 0085: span-level addressing, rename-safe opaque ids, and the fidelity floor that catches a norm dropped in a rewrite by absence. It would also give up ADR 0084's per-type required fields and ADR 0086's computed precedence, since OKF specifies neither and forbids rejecting a bundle for either. OKF is a viable *interchange* format layered under AEP's own model; it is not a store and does not claim to be.

### Family 3 — typed record systems derived from committed markdown

- Astro content collections define per-collection schemas in Zod, where "every frontmatter or data property of your collection entries must be defined using a Zod data type" — [Astro docs, Content collections](https://docs.astro.build/en/guides/content-collections/). This is the one candidate that fully satisfies C1.
- An Astro collection is loaded from committed markdown by glob and validated at build: `defineCollection({ loader: glob({ pattern: "**/*.md", base: "./src/data/blog" }), schema: z.object({ ... }) })` — [Astro docs, Content collections](https://docs.astro.build/en/guides/content-collections/). Derived, rebuildable, source stays the reviewed artifact — C4 and C5 satisfied.
- Astro's entry is a whole file with "a unique `id`" and "a `data` object with all defined properties"; headings come back only as render metadata, "a list of all rendered headings" from `render()` — [Astro docs, Content collections](https://docs.astro.build/en/guides/content-collections/). Headings are not addressable records, so C2 fails.

**Cost to adopt Astro's model**: it is a static-site build framework with no query surface at agent turn time, no multi-store federation, and no precedence. Adopting the *pattern* — declared schemas per type, compiled at build from committed markdown, never hand-edited — is free and is what AEP is already converging on; adopting the *system* would mean shipping a Node build toolchain inside a Claude Code plugin to get file-level typing AEP would then have to re-split into spans anyway.

### Family 4 — agent memory systems (the store owns its content)

- mem0 produces memories by LLM extraction from conversation: "Single-pass ADD-only extraction -- one LLM call, no UPDATE/DELETE", stored against "Hosted Qdrant vectors", retrieved by "Multi-signal retrieval -- semantic, BM25 keyword, and entity matching scored in parallel and fused" — [mem0 README @ main](https://raw.githubusercontent.com/mem0ai/mem0/main/README.md).
- Letta's MemFS is git-backed but agent-authored, not derived: "An agent's memory is part of its state, not a folder on a machine: it lives in a git repository owned by the agent", where "A memory entry's label becomes its path in the repository" and "Edits become memory once they are committed and pushed"; updates come from "background subagents to review recent conversations, consolidate lessons, and update memory" — [Letta docs, Agent SDK memory](https://docs.letta.com/agent-sdk/memory).
- Graphiti builds "a temporal graph of entities, relationships, and facts" over a third-party graph database ("Neo4j 5.26 / FalkorDB 1.1.2 / Amazon Neptune"), with "Custom Types (ontology)" as "Developer-defined entity and edge types via Pydantic models", retrieved by "Hybrid Retrieval: Combines semantic embeddings, keyword (BM25), and graph traversal" — [Graphiti README @ main](https://raw.githubusercontent.com/getzep/graphiti/main/README.md).

**Why the whole family is out, in one sentence**: each owns its content in a database it writes, and each derives records by LLM extraction rather than from a reviewed markdown artifact — so the committed file stops being the reviewed thing, and `06`'s requirement that a norm change stay a readable diff is lost at the first write. Graphiti's Pydantic entity types are a genuine C1 answer and the only one in this family; it is attached to a graph database and an extraction pipeline AEP has no use for.

### Family 5 — vector stores as a substrate

- Chroma records carry caller-supplied ids: each needs "a unique string id", and the record fields are `ids`, `documents`, `embeddings`, `metadatas`, where "You must provide either documents, embeddings, or both. metadatas are always optional" — [Chroma docs, Add data](https://docs.trychroma.com/docs/collections/add-data).
- Chroma stores its own copy of the text: with both supplied, "Chroma will store both as-is without re-embedding the documents" — [Chroma docs, Add data](https://docs.trychroma.com/docs/collections/add-data). This is the derivation failure: the store holds content rather than deriving it, and that copy needs synchronising.
- Chroma's metadata is scalar-typed only — "Metadata values can be strings, integers, floats, or booleans. Additionally, you can store arrays of these types" — [Chroma docs, Add data](https://docs.trychroma.com/docs/collections/add-data). No per-type required-field schema, so C1 is the caller's to enforce.
- Chroma retrieves by "Dense, sparse, and hybrid search", where you "Query by similarity and combine multiple search strategies", with metadata filters at query time — [Chroma docs, Introduction](https://docs.trychroma.com/docs/overview/introduction). Similarity ranking is not precedence over binders.

### Family 6 — how the incumbent agent-norm systems deliver rules

Recorded because it establishes that the *delivery* systems AEP runs alongside also fail
the criteria, and specifically that none computes precedence.

- AGENTS.md defines no schema, no ids, and no spans; precedence is by proximity: "Agents automatically read the nearest file in the directory tree, so the closest one takes precedence", and in the FAQ "The closest AGENTS.md to the edited file wins; explicit user chat prompts override everything" — [agents.md](https://agents.md/).
- Cursor rules carry a firing condition in frontmatter — `alwaysApply`, `globs`, `description` — across four modes: apply to every chat session; when a file matches a pattern; when the agent judges it relevant from the description; or when `@`-mentioned — [Cursor docs, Rules](https://cursor.com/docs/context/rules). This is the nearest thing in the wild to ADR 0084's `fires-when` field, and it is a frontmatter key on a file, not a record property in a store.
- Cursor's precedence is a fixed source order, not computed: "Rules are applied in this order: **Team Rules → Project Rules → User Rules**. All applicable rules are merged; earlier sources take precedence when guidance conflicts" — [Cursor docs, Rules](https://cursor.com/docs/context/rules). Order by origin, not by type, store, and firing breadth.
- Claude Code concatenates rather than ranking, and states the conflict outcome plainly: "All discovered files are concatenated into context rather than overriding each other", and "if two rules contradict each other, Claude may pick one arbitrarily" — [Claude Code docs, memory](https://code.claude.com/docs/en/memory). This is the failure mode ADR 0086 exists to remove, stated by the harness's own documentation.
- Claude Code's path scoping matches AEP's current mechanism — rules use "YAML frontmatter with the `paths` field" and "only apply when Claude is working with files matching the specified patterns", while "Rules without a `paths` field are loaded unconditionally" — [Claude Code docs, memory](https://code.claude.com/docs/en/memory). Confirms that today's rank-2/rank-5 split rests on a harness behaviour, which is what ADR 0086 replaces with a computed field.

### The protocol layer supplies no store

- MCP resources are identified by opaque URI and carry no sub-document addressing: "Each resource is uniquely identified by a URI", and a resource definition is `uri`, `name`, `title`, `description`, `mimeType`, `size` — [MCP specification 2025-06-18, Resources](https://modelcontextprotocol.io/specification/2025-06-18/server/resources).
- `resources/read` returns whole contents as text or blob, with no span parameter and no structural selector — [MCP specification 2025-06-18, Resources](https://modelcontextprotocol.io/specification/2025-06-18/server/resources).
- MCP's only ranking hint is an annotation, "`priority`: A number from 0.0 to 1.0 indicating the importance of this resource" — [MCP specification 2025-06-18, Resources](https://modelcontextprotocol.io/specification/2025-06-18/server/resources). A scalar hint on a resource, not a precedence computed over a result set; a server that needs ADR 0086's ordering must return its own metadata and let the caller compute it, which the protocol permits and does not provide.
- MCP defines no index, no federation across stores, and no typing beyond MIME type — [MCP specification 2025-06-18, Resources](https://modelcontextprotocol.io/specification/2025-06-18/server/resources). Custom URI schemes are allowed and "MUST be in accordance with RFC3986", which is the extension point a span-addressing scheme would use.

### Prior art worth borrowing, outside the agent space

None of these is adoptable — all are documentation or code-navigation build systems —
but each independently solved one criterion, and two of them solved it the way AEP's
ADRs already chose.

- Sphinx declares a label immediately before a section and references it by name: "If you place a label directly before a section title, you can reference to it with `` :ref:`label-name` ``" — [Sphinx docs, Cross-referencing](https://www.sphinx-doc.org/en/master/usage/referencing.html). This is ADR 0085's model — a declared id bound to a heading — arrived at independently and in production for years.
- Sphinx states the same rationale AEP's ADR 0085 gives: `:ref:` "is advised over standard reStructuredText links to sections ... because it works across files, when section headings are changed, will raise warnings if incorrect" — [Sphinx docs, Cross-referencing](https://www.sphinx-doc.org/en/master/usage/referencing.html). Survives a heading rename, and a broken reference is a build warning rather than a silent unbind.
- Sphinx ships a derived, read-only inventory inside a published package: "Each Sphinx HTML build creates a file named `objects.inv` that contains a mapping from object names to URIs relative to the HTML set's root" — [Sphinx docs, intersphinx](https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html). This is the closest working analogue found to ADR 0084's framework store — an index generated at build, distributed with the package, resolved by id, never written to by the consumer.
- Antora addresses a resource by structured coordinates — "component, version, module, family, relative path" — constructed automatically from each source file's properties, and resolves them as source-to-source references rather than URLs — [Antora docs, Resource ID](https://docs.antora.org/antora/latest/page/resource-id/). The closest analogue found to one query interface over multiple stores, including aggregation of "distributed component versions" from separate repositories.
- SCIP is explicitly a derived transmission format rather than a store: "a language-agnostic protocol for indexing source code" — [SCIP README @ main](https://raw.githubusercontent.com/sourcegraph/scip/main/README.md) — and its design states it "is a _transmission_ format for sending data from some producers to some consumers -- it is not meant as a _storage_ format for querying", with string symbol IDs chosen because "String types in mainstream languages support equality and hashing" — [SCIP DESIGN.md @ main](https://github.com/sourcegraph/scip/blob/main/docs/DESIGN.md). Confirms the pattern of an index derived from committed source that is never the source of truth.

## Limitations

**Method.** Every source above is a project's own repository, specification, or
documentation site. No aggregator, ranking site, or third-party blog is cited as
evidence; three (`mcp.so`, `mcpmarket.com`, `playbooks.com`) and several 2026 explainer
posts appeared in search results and were used only as leads to locate primary sources,
never as claims.

**A tooling caveat that qualifies every citation.** The fetch tool returns a
model-processed rendering of each page rather than raw bytes. Two pages came back
verbatim — the MCP resources specification and the Claude Code memory page — and the
rest came back as extractive summaries with the key sentences quoted. Quoted wording is
therefore reliable; the *absence* of a feature in a summarised page is weaker evidence
than its presence, because a summariser can omit. Where I record an absence as a finding
below, treat it as "not found on the page read", not "proven absent from the product".

**What I could not read.**

- `jMRI-Full`, the retrieval-interface specification jDocMunch claims to implement, is
  referenced on its repository page as "the open retrieval interface spec" but never
  defined there, and I did not locate the specification itself. If it standardises
  span addressing across MCP servers it is the single most relevant document in this
  landscape and this finding under-covers it. **This is the largest gap.**
- jDocMunch's exact section-ID derivation. The repository page states the stability
  condition (path, heading text, heading level) but not the slug format; a secondary
  search result described it as an ancestor-heading chain slug. The stability condition
  is quoted from the primary source and is sufficient to reject it; the slug format is
  not established.
- OKF's full reserved-key list and its `v0.2` provenance fields (`generated`, `verified`,
  `status`, `stale_after`, `sources`). The `type`-only requirement, concept ID rule,
  cross-link forms, and permissiveness clause are quoted from `SPEC.md`; the provenance
  fields were described by secondary sources and I read only the field *names* in the
  README fetch, not their specified semantics. **A future session evaluating OKF should
  read `SPEC.md` in full**, since a provenance layer is adjacent to AEP's Marker and
  drift model.
- The DITA 2.0 specification. It is the strongest prior art I know of for typed records
  with per-type required structures and element-level ids, and the OASIS URL I tried
  returned 404. It is XML rather than markdown and fails the derivation criterion on its
  face, so I did not spend further budget locating it — but **it is unverified here and
  named only as an unconfirmed lead**.
- mem0's and Letta's conceptual documentation pages returned thin content; the claims
  above come from the mem0 README and the Letta Agent SDK memory page instead, both of
  which were substantive. Letta's V1 storage model is not established here.
- Chroma's introduction page did not address content ownership; the ownership claim
  rests on the add-data page's statement that documents are stored as-is.

**Unconfirmed leads I did not pursue**, named so the next session does not treat their
absence as coverage: `kb-mcp`, `leona/kb`, `qmd`, `dotmd`, `knowledge-mcp`,
`codebase-memory-mcp`, `obsidian-mcp-server`, `frontmatter-mcp`, `go-mcp-server-mds`,
`rulesync`, `intellectronica/ruler`, `ai-rules-sync`, and `agent-rules-spec`. From their
search-result descriptions all sit inside families already rejected — hybrid
BM25/vector retrieval over markdown, or rule-file synchronisation with no store — but
none was read. I also did not check LanceDB, Qdrant, Weaviate, pgvector, txtai,
Cognee, LangMem, Contentlayer, Keystatic, Obsidian Dataview, LSIF, or RDF/SHACL; the
first six fall in Families 4 and 5 by construction, and the rest are file-level or
non-markdown.

**What was not attempted at all.** Nothing was installed, run, or benchmarked. No claim
here rests on observed behaviour — only on what each project documents. Cost-to-adopt
figures are qualitative; no integration was prototyped, and no measurement of index
size, query latency, or token cost was taken for any candidate. The claim that "nothing
computes precedence" is a claim about the ten candidates in the table plus the six
delivery systems, not about every knowledge store that exists.
