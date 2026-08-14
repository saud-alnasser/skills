---
owner: repository
kind: research
falsifies: []
---

# Has a framework comparable to AEP built a knowledge store, and how did it do it?

Verified against: the primary sources listed per claim, all fetched 2026-08-13 — arXiv
2602.20478v1 and its companion repository at `main`, arXiv 2602.14690 abstract page,
`kiro.dev/docs/steering`, and the ConPort and OpenSpec READMEs at `main`. Status:
answered, with one direct peer found and read to source. Open: three secondary claims
named in Limitations, including OpenSpec's star count.

Fourth framing of the store question. The three prior findings shopped for a **component**
to adopt — a store, a database, a traversal model. This one asks a different question:
which *whole systems* of AEP's kind have built one, and what did the build look like. It
is the first of the four to find a direct peer.

## Answer

**Yes — one, published, measured, and structurally almost identical to AEP. It made the
opposite retrieval choice, and its own numbers are the best available evidence for why
AEP's is right.**

[Codified Context: Infrastructure for AI Agents in a Complex
Codebase](https://arxiv.org/abs/2602.20478) (Aristidis Vasilopoulos, arXiv 2602.20478,
24 Feb 2026) reports three tiers over a 108,256-line C# system:

- **Tier 1, hot memory** — "a single Markdown file (∼660 lines) loaded automatically into
  every AI session," carrying conventions, checklists, known failure modes, and
  "orchestration protocols."
- **Tier 2** — "Nineteen agent specification files (Markdown, 115–1,233 lines each,
  ∼9,300 lines total) define domain-expert personas."
- **Tier 3, cold memory** — "34 Markdown files (∼16,250 lines ...), each documenting one
  subsystem," "queried on demand through the MCP retrieval service."

Read against AEP that is: `CLAUDE.md` plus the unconditional rules; the dispatched roles
under `agents/`; and the norm corpus behind a query. **The layout it recommends is
`.claude/context/{topic}.md` and `.claude/agents/{id}/AGENT.md`** — the directory AEP
already uses, arrived at independently. The correspondence extends to the failure it
reports: "Specification staleness was the primary failure mode," answered with "A context
drift detector (Python, session-start hook) ... injects a warning into session context
when source files change without corresponding specification updates." That is AEP's
Marker and its drift model, built separately, for the same reason.

**Where it diverges is retrieval, and this is the whole value of the finding.** Its cold
tier is pulled by the model through five tools — `list_subsystems`,
`get_files_for_subsystem`, `find_relevant_context`, `search_context_documents`,
`suggest_agent` — and the constitution merely *asks* for them: it "requires use of
`suggest_agent(task_description)` ... when exploring unfamiliar code." That is judged
selection, instructed rather than enforced, which is exactly the arrangement ADR 0075
removed and ADR 0089 designed out.

**Its own interaction data shows what that costs.** The paper reports 2,801 human
prompts, 16,522 autonomous agent turns, and 283 sessions, against "1,478 MCP retrieval
calls across 218 sessions." Computed from those figures: the knowledge base was consulted
on roughly **0.53 calls per human prompt, 0.09 per agent turn, and not at all in 65 of
283 sessions (23%)**. The tier holding 16,250 lines of subsystem specification went
untouched in almost a quarter of sessions on the codebase it describes. **That is the
mis-load rate of an instructed pull, measured in production**, and no ratio anywhere else
in this research comes as close to the question ticket `04` was settling.

**The matching underneath it is weaker still than the paper's framing suggests.** Reading
`mcp-server/server.py`, the index is a **hardcoded, manually maintained dictionary** —
`SUBSYSTEMS = {"ecs": {"name": ..., "keywords": [...], "files": [...]}}` — and
`find_relevant_context` scores it by counting keyword substrings in the task, `score += 1`
per hit and `+2` if the subsystem name appears, returning the top 5. `search_context_documents`
is line-by-line substring matching over `.claude/context/`, returning excerpts with two
lines of surrounding context. The paper concedes it: "The current implementation uses
keyword substring matching." So the tier is reached by a hand-maintained keyword map that
must be edited whenever a subsystem is added — a second staleness surface, on top of the
one the drift detector was built to catch.

**The infrastructure ratio is the other number worth keeping**: 54 files and ~26,200 lines
of context against 108,256 lines of application code — **24.2% of the codebase**. Offered
there as evidence that context infrastructure scales with the system. It is equally an
argument for compression, which is what this effort is doing.

## What every other comparable framework did

None is a peer in the way the paper is; each answers one sub-question cleanly.

- **Amazon Kiro is the closest production analogue to `fires-when`, and it went further
  than AEP has.** Steering files sit in `.kiro/steering/` with frontmatter carrying an
  `inclusion` mode: `always` ("loaded into every Kiro interaction automatically"),
  `fileMatch` (with a `fileMatchPattern`, e.g. `"components/**/*.tsx"`), `manual`
  (`#steering-file-name`), and `auto`, where "Kiro uses the description to decide when the
  steering file is relevant" — [kiro.dev/docs/steering](https://kiro.dev/docs/steering/).
  Three of the four are deterministic and one is model-judged, which is precisely ADR
  0084's `fires-when` as a shipped feature. Two details are worth taking: **precedence is
  declared and directional** — "In case of conflicting instructions between global and
  workspace steering, Kiro will prioritize the workspace steering instructions" — and
  **the CLI degrades to loading everything**: "inclusion modes are not currently
  supported. All steering files ... are loaded automatically." That second one is the
  failure mode ADR 0088's two-faced store must not repeat.
- **ConPort is the fully-committed opposite of AEP's derivation rule**, and useful for
  showing what is lost. It offers "Structured context storage using SQLite (one DB per
  workspace, automatically created)" and "replaces older file-based context management
  systems by offering a more reliable and queryable database backend" —
  [context-portal README](https://raw.githubusercontent.com/GreatScottyMac/context-portal/main/README.md).
  Its typing is genuine (`log_decision` takes `summary` required, `rationale`,
  `implementation_details`, `tags`), and it builds an explicit graph:
  `link_conport_items(source_item_type, source_item_id, target_item_type, target_item_id,
  relationship_type, description)`, read back through `get_linked_items` with a
  `relationship_type_filter` — **a declared-edge query, and prior art bearing directly on
  ticket `12`.** But the database is authoritative and markdown is an export
  (`export_conport_to_markdown`), so a norm change is not a reviewable diff — the
  inversion `06` rejected. The README addresses no precedence, conflict, or staleness.
- **OpenSpec is the spec-kit-shaped comparison the user asked about at the outset, and it
  built no store at all.** `openspec/specs/` holds current truth, `openspec/changes/<name>/`
  holds `proposal.md`, `design.md`, `tasks.md` and spec deltas, `archive/` holds completed
  work; specs are addressed by file path and by heading (`### Requirement: Theme
  selection`), agents read the files directly, and there is no index or query tool —
  [OpenSpec README](https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/README.md).
  The trade is explicit and it is the one AEP is choosing against: total readability
  without the plugin, and no answer for delivery, precedence, or scale.
- **BMAD-METHOD's answer to context size is sharding, not querying** — large PRDs and
  architecture documents split into self-contained story files that "carry rationale,
  explicit constraints, embedded tests, and links back to the source docs," with agents
  declaring required resources in YAML. Documented on the project's own site
  ([Document Sharding Guide](https://docs.bmad-method.org/how-to/shard-large-documents/));
  every characterisation above comes from third-party explainers and is **not verified at
  source**. It is worth naming because it is the alternative AEP rejected implicitly:
  pre-compose each unit of work with everything it needs, rather than filter a corpus.
- **Confucius Code Agent** contributes one idea nothing else here has: a persistent
  note-taking system with **"hindsight notes for failures"** — compilation errors, runtime
  exceptions, and abandoned strategies recorded with their resolutions, "indexed by error
  messages, stack traces, and affected components," so a recurring failure retrieves its
  known fix. Reported at 54.3% Resolve@1 on SWE-Bench-Pro — [arXiv
  2512.10398](https://arxiv.org/abs/2512.10398). That is AEP's `.claude/evidence/`
  directory with an index keyed by symptom. **Read from the abstract and secondary
  summaries only; the paper was not fetched.**

**Field-wide, this stack is rare.** The 2,853-repository survey in [Harness Engineering
for Agentic AI Coding Tools](https://arxiv.org/abs/2602.14690) (Galster et al., Feb 2026,
rev. Jun 2026) finds "Context Files dominate the configuration landscape and are often the
sole mechanism in a repository," that AGENTS.md is emerging as "an interoperable standard
across tools," and that "Few repositories adopt advanced mechanisms such as Skills and
Subagents," most Skills being "static instructions rather than executable code." AEP is
several standard deviations off that distribution, which cuts both ways: little prior art
to borrow, and little evidence that anyone has hit its problems and solved them better.

## What this changes

Nothing already decided is overturned, and two open things get evidence:

- **Ticket `04` gains an outside measurement.** The claim that an instructed pull produces
  mis-loads has, until now, been argued from AEP's own history. The Codified Context
  numbers are an independent instance: 23% of sessions never queried the cold tier, and
  9% of agent turns did. ADR 0089's push-by-preprocessing is the direct answer, and this
  is the first evidence for it that AEP did not generate itself.
- **Ticket `12` gains its first working reference.** ConPort's `link_conport_items` /
  `get_linked_items` pair is a real declared-edge store with a typed-edge filter on read.
  It returns linked items rather than a computed closure, so it sits between the two
  positions `12` states rather than settling it — but it is the nearest implementation
  found, and unlike `vault-graph` its interface is documented at source.

**The convergence count rises from three to five.** Independently reached by others and
matching decisions AEP had already taken: typed records with per-type required fields
(mdvault, ConPort → ADR 0084); a declared label bound to a heading, with broken references
warned at build (Sphinx → ADR 0085); a derived index shipped inside a package and resolved
by id (`objects.inv` → ADR 0090); **a firing condition declared in frontmatter with
deterministic and judged modes side by side (Kiro → ADR 0084's `fires-when`)**; and **a
session-start staleness detector comparing knowledge against the source it describes
(Codified Context → the Marker and verification at use)**.

What stays novel is unchanged and now sharper for having a peer that lacks both: **span-level
declared identity**, and **federation of a packaged read-only store with a writable local
one under computed precedence**. The Codified Context system has neither, and its two
reported weaknesses — staleness and a hand-maintained keyword index — are what their
absence looks like at 26,000 lines.

## Limitations

- **The retrieval-rate figures are mine, not the paper's.** 0.53 per prompt, 0.09 per
  turn, and 23% of sessions are computed from four reported totals (2,801 / 16,522 /
  1,478 / 283 / 218). The paper does not present them and may define a "session" or an
  "agent turn" in a way that changes them. It also reports no token counts and no
  context-window utilisation, so nothing here measures AEP's actual goal.
- **`server.py` was read through the fetch tool's rendering, not cloned.** The `SUBSYSTEMS`
  structure, the `score += 1` scoring, and the substring search are quoted from that
  rendering; the tool count differs between the paper (five) and the repository (seven),
  and I did not reconcile them.
- **Single case study, single author, single codebase.** Codified Context reports one C#
  system by one author with no control condition and no comparison against a repository
  without the infrastructure. Its numbers describe what happened there; they are not a
  measurement of the design.
- **Three claims rest on secondary sources.** OpenSpec's "52,100 GitHub stars as of June
  2026" came from a search summary and **could not be confirmed** — the README's badges
  render no number, and the figure is implausible enough that it should not be repeated
  without checking. BMAD-METHOD's sharding model and Confucius's hindsight notes are from
  explainers and abstracts respectively; neither project's source was read.
- **The Harness Engineering paper is cited from its abstract page.** The PDF returned
  unparseable metadata; no methodology, sampling frame, or per-mechanism adoption rate was
  checked, so "few repositories adopt Skills and Subagents" is quoted without its number.
- **Nothing was installed, run, or measured.** No server was started, no repository cloned,
  no query executed. Every claim is documentation or source as rendered on 2026-08-13.
