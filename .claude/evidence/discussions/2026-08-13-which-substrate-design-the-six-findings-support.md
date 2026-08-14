---
owner: repository
kind: discussions
falsifies: []
---

# Which substrate design do the six store findings support?

Dated 2026-08-13, and never maintained. It records what was weighed across six research
findings taken between the `substrate` map being cut and the store design being reopened,
and what stayed open at the end. The findings themselves are the evidence; this is the
comparison the user asked for before choosing.

Six findings, all `.claude/evidence/research/`, all 2026-08-13:

| # | Finding | What it settled |
| --- | --- | --- |
| F1 | `whether-an-established-agent-knowledge-store-fits` | nothing adoptable across sixteen candidates; two criteria have no candidate anywhere |
| F2 | `md-plus-machinery-stores-under-the-relaxed-frame` | the markdown+derived-index+MCP pattern is convergent across six independent projects |
| F3 | `whether-a-database-can-be-the-authoritative-store` | every versioned database brings its own version control, splitting knowledge history from code history |
| F4 | `whether-graph-traversal-over-linked-markdown-suits-aep` | graph retrieval's wins are all multi-hop QA; AEP's primary retrieval is a zero-hop filter |
| F5 | `how-comparable-frameworks-built-their-knowledge-stores` | the one direct peer chose instructed pull and its own data shows 23% of sessions never queried |
| F6 | `what-a-norm-corpus-must-look-like-to-actually-be-followed` | omission is the dominant instruction-following error at density; coherent adjacent prose is the worst distractor |

## The criteria the findings produced

Not invented for this comparison — each is either a settled ADR or the direct conclusion
of a finding above. Ordered by how hard each is to trade away.

1. **One history with the code.** `.claude/policies/knowledge.md` requires a correction to
   land "in the same commit as the change, so the two never land apart." F3.
2. **A miss is a fact.** ADR 0089: no search, only filters, so nothing silently
   under-returns. F4 and the brain-like finding both show what its loss looks like.
3. **No judged selection.** ADR 0075, with F5's 23% as the first outside measurement and
   SA-RAG's "myopic knowledge exploration" as the mechanism named independently.
4. **Instruction density down** — the predictor of silent omission. F6.
5. **Characters and tokens down** — the user's stated goal.
6. **Simpler `.claude/` structure** — the user's stated goal.
7. **Build cost and novelty risk.** F1 and F2 narrow what is genuinely unprecedented to
   two things: span-level declared identity, and federation under computed precedence.
8. **Migration from 1.x** — the user's hard constraint, not negotiable.

## The candidates

**A — Filter and deliver.** The design as drafted across ADRs 0083–0091. Markdown
authoritative and committed; `.claude/knowledge/` flat; ids minted by the build; a derived
SQLite index, gitignored and rebuildable; a stage row is a *filter over norms* delivered by
preprocessing at zero round trips; queries are filters only and serve what the row
excludes; edges declared but not walked.

**B — A, plus computed edge closure.** Everything in A, and a query returns the matched
record together with what its declared edges reach, computed store-side. Ticket `12`'s
first position. ConPort's `link_conport_items` / `get_linked_items` is the working
reference (F5); SA-RAG is the argument for computing rather than prompting (F4, and the
brain-like finding).

**C — A, plus an associative layer.** Everything in A, and a second retrieval contract for
exploratory queries: tag or keyword entry, then spreading activation along links. Two
contracts, one exhaustive and one ranked.

**D — Store-authoritative.** The database holds truth; markdown is an export. ConPort's
shape, or Dolt's.

**E — Generated rows, no runtime query.** No store served at turn time. The build composes
each stage's row from single-source norms into a file; the stage reads its file. BMAD's
sharding, but generated rather than hand-maintained, so nothing duplicates.

## How they score

`++` clearly satisfied · `+` satisfied with a cost · `~` partial · `−` fails

| | A | B | C | D | E |
| --- | --- | --- | --- | --- | --- |
| 1 One history with the code | `++` | `++` | `++` | `−` | `++` |
| 2 A miss is a fact | `++` | `+` | `−` | `~` | `++` |
| 3 No judged selection | `++` | `++` | `−` | `~` | `++` |
| 4 Instruction density down | `+` | `+` | `+` | `+` | `+` |
| 5 Characters and tokens down | `++` | `+` | `+` | `+` | `++` |
| 6 Simpler `.claude/` | `++` | `++` | `+` | `+` | `~` |
| 7 Low build cost / novelty risk | `~` | `~` | `−` | `+` | `+` |
| 8 Migration from 1.x | `+` | `+` | `+` | `~` | `++` |

**D is out on criterion 1 and the reason is structural, not a close call.** Two version
control systems means knowledge and the code it governs can land apart — the exact failure
the knowledge policy exists to prevent, and a reviewer would be approving a change whose
knowledge half is invisible to the pull request (F3).

**C is out on criteria 2 and 3, and F4's own authors supply the evidence.** HippoRAG 2
reports that graph-augmented retrieval's "performance on more basic factual memory tasks
drops considerably below standard RAG" — basic factual retrieval is AEP's category.
Associative entry also cannot promise that a miss is a fact: what falls below the
activation threshold is not returned and leaves no signal. It would add a second retrieval
contract with weaker guarantees to serve queries AEP has not been shown to have.

**That leaves A, B, and E**, and the interesting result is that **E is much closer to A
than the effort has treated it.** ADR 0089 already delivers the row by preprocessing — a
command run at invoke time whose output is inlined before the model sees anything. E moves
that composition from invoke time to build time. Both produce an exhaustive row with no
model judgement; the difference is staleness (a built row can be stale, an invoke-time one
cannot) against dependency (an invoke-time row needs the tool present).

**E's real weakness is not the row — it is everything else.** The row is the majority of
the token cost but a minority of the questions. What supersedes ADR 0074, which findings
are waiting, what a ticket's edges are, what the framework store says about a repository
norm — these are the four generated indexes ADR 0090 dissolves into queries, and generated
rows answer none of them. E would keep them as committed generated files, which is the
regenerate-and-compare friction the effort is trying to remove (F5's peer hit the same wall
from the other side: its hand-maintained keyword index was a second staleness surface).

## The composite

Taking what each finding supports and nothing it does not:

- **A as the spine.** Markdown authoritative in git, flat `.claude/knowledge/`,
  build-minted ids, derived gitignored index, filters not search. F2 says this shape is
  convergent across six independent projects, so the risk is in the two novel parts only.
- **The row delivered at invoke time, not build time.** A over E, on staleness. E's
  contribution is the reminder that the row is not a query result the model asked for — it
  is composition, and it should stay that way even though a store computes it.
- **B's closure, with depth declared per edge type rather than tuned globally.** This is
  the one place the graph research earns something: a computed closure keeps criterion 3
  intact where agentic traversal destroys it, and per-edge-type depth keeps criterion 2
  intact where a global depth parameter silently stops short. `supersedes` closes fully;
  `part-of` closes to the effort; `sources` does not close at all.
- **Build-time edge validation, borrowed from `obsidian-mcp-pro`'s `find_broken_links` and
  `find_orphans`.** A declared id resolving to nothing is what makes ADR 0085's opaque ids
  better than wikilinks, and the check belongs beside id minting, not in a query.
- **Kiro's `inclusion` vocabulary for `fires-when`** — `always`, `fileMatch`, `manual`,
  `auto` — with `auto` deliberately not implemented. Shipped prior art for the field
  ADR 0084 invents, and the one mode AEP must refuse is the one Kiro judges.
- **An instruction-count bound beside the character bound** (F6). The measured predictor of
  silent omission is count; the suite bounds characters. ADR 0089's filter moves the two
  apart, so a row can pass a tightened character bound with its density untouched.

Under that composite, criterion 7's exposure narrows to exactly what F1 and F2 identified
as unprecedented — span-level declared identity, and federation under computed precedence
— plus the closure, which has one working reference.

## What stays open

Required, and genuine:

- **The choice itself is the user's and has not been made.** This document compares; it
  decides nothing. A, B, the composite, or something the comparison surfaces.
- **Ticket `12` is not settled by this.** The composite adopts closure with per-edge-type
  depth, but no measurement supports that over ids-only — SA-RAG argues against *model*
  traversal, not for closure over the alternative. `08` can measure it.
- **Whether an instruction-count bound is the right instrument at all**, or whether the
  right response to F6 is fewer norms rather than better-bounded rows. Newly on the map's
  *Not yet specified*, and untouched by any finding.
- **Nothing has been run.** Across six findings nothing was installed, no query executed,
  no token count measured on AEP's own corpus. Every claim about AEP's retrieval shape is
  an argument from its query shapes. `08` remains the only thing that closes it, and this
  comparison does not substitute for it.
- **Three primary sources were never reached** across the six: `vault-graph`, `jMRI-Full`,
  and IFScale's per-density figures. The first two bear on the closure question; the third
  bears on whether AEP's ~100-instruction rows are actually in the degradation band.
