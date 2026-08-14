---
owner: repository
kind: research
falsifies: []
---

# Is there a local markdown-plus-machinery knowledge store for agents that AEP could adopt?

Verified against: project documentation and README content as published and fetched
2026-08-13. Status: no adoptable system found, and the reason has narrowed usefully.
Open: three candidates whose primary sources could not be reached, listed in
Limitations.

Companion to [`2026-08-13-whether-an-established-agent-knowledge-store-fits`](2026-08-13-whether-an-established-agent-knowledge-store-fits.md),
which asked the same question against all six settled criteria and returned sixteen
candidates. **This is a deliberately relaxed re-run** — markdown files with secondary
machinery over them, local, agent-facing — asked because a narrower frame might find
something the strict one filtered out. It did not, but it changed what the "no" means.

## Answer

**The relaxed frame finds an ecosystem, not a product.** The pattern AEP arrived at —
markdown files authoritative, a derived SQLite index, an MCP server over it — is
**convergent**: at least six independent implementations were built that way, none aware
of each other. That is the most useful result here. AEP is not inventing an odd shape;
it is assembling a shape the problem repeatedly forces.

Every candidate still fails, and the failures cluster on exactly the same two axes the
strict run identified. Nothing addresses a **heading span by a declared stable id**, and
nothing **federates a read-only packaged store with a writable local one behind one
query interface with computed precedence**.

The three that matter, none of them in the strict run's sixteen:

- **mdvault** is the closest overall and the most interesting. Markdown is
  authoritative, the SQLite index is derived and explicitly rebuildable (`mdv reindex`),
  and — the part that matters — it **enforces note types via frontmatter** with a table
  of types and their *Required Fields*, validating "notes against type schemas with
  auto-fix support." That is ADR 0084's typed-records design, arrived at independently.
  It fails on the unit (whole files), on identity (file path, with `mdv rename` updating
  references — so identity moves when the file does), and it has neither precedence nor
  federation. — [github.com/agustinvalencia/mdvault](https://github.com/agustinvalencia/mdvault)
- **TurboVault** is the closest on *addressing below the file*, and the closest thing
  found to federation. It addresses heading sections and blocks through wikilink syntax
  (`[[note#section]]`, `[[note#^block]]`), keeps markdown canonical with a rebuildable
  index, ranks with BM25 plus graph centrality, and supports **multi-vault**: "Switch
  between personal and work notes seamlessly at runtime." But switching between vaults is
  not querying across them, there is no read-only packaged tier, files remain the write
  unit, identity is path, and per-type required fields are not enforced. Section identity
  rests on heading text — the same silent-rebind failure ADR 0085 bought out.
  — [github.com/epistates/turbovault](https://github.com/epistates/turbovault)
- **mcp-memory** fails in the most instructive direction: it is OKF-backed with SQLite
  FTS5, records are typed by OKF's `concept_type` and identified by a declared `key`
  within a namespace — but **SQLite is the authoritative store and the markdown is a
  dump**: it "automatically dumps and syncs every memory to disk as a raw `.md` file."
  Files are output artifacts. That inverts the derivation criterion outright, and it is
  worth recording because a reader skimming its description would assume the opposite.
  — [github.com/fellowgeek/mcp-memory](https://github.com/fellowgeek/mcp-memory)

**Also checked and rejected:** `sqlite-memory` keeps markdown authoritative with
content-hash change detection, but chunks by token budget — `max_tokens` 512,
`overlay_tokens` 100 — which ADR 0085 rules out directly, and it has neither typing nor
federation. — [github.com/sqliteai/sqlite-memory](https://github.com/sqliteai/sqlite-memory)

## What this changes for the build

Nothing about the verdict, and something about its size. Combined with the strict run's
prior art, **three of AEP's decisions now have independent confirmation from systems
that reached them separately**: typed records with per-type required fields validated
from frontmatter (mdvault → ADR 0084), a declared label before a heading that survives a
title change with broken references warned at build time (Sphinx → ADR 0085), and a
derived index shipped inside a published package and resolved by id (`objects.inv` →
ADR 0090).

**What remains genuinely novel is two things, not the whole system**: span-level identity
that is declared rather than positional, and federation of a packaged read-only store
with a writable local one under computed precedence. Everything else AEP plans to build
has a working reference implementation somewhere.

## Limitations

- **Three primary sources could not be reached.** `vault-graph`, which the search
  summary describes as parsing headings into a SQLite+FTS5 graph, has no reachable
  repository page — its LobeHub listing returned HTTP 403 and no GitHub URL surfaced. It
  is the single most relevant unchecked candidate, since heading parsing is the axis
  everything else fails on. `engraph` and `pvliesdonk/markdown-vault-mcp` were surfaced
  and not examined; note that the strict run evaluated a *different* project of the same
  name, `agustinvalencia/markdown-vault-mcp`, so the two must not be conflated.
- **Every claim is a fetched rendering of documentation, not a read of source.** No
  repository was cloned, no server was run, and no behaviour was executed. Where a README
  and an implementation disagree, nothing here would detect it.
- **Absence is weaker evidence than presence.** A capability not mentioned in a README —
  federation, precedence — was recorded as absent. For several candidates that is a
  reasonable inference from a feature list; for none of them is it a verified negative.
- **The search was English-language and GitHub/PyPI-centric**, run through one search
  tool on one day. A store distributed some other way would not have surfaced.
