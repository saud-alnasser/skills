---
owner: repository
---

# map: substrate

## Destination

AEP 2.0: the norm corpus is one flat store of typed records the model reaches
through a tool, with only the boot tier read directly, and the taxonomy
collapsed to as few record types as the work needs. Reaching the end means a
stage spends its context on the work rather than on AEP, and a 1.x installation
migrates onto it.

## Notes

Domain: AEP's own instruction corpus — `specs.md`, `.claude/`, and the shipped
surfaces under `skills/` and `agents/`. Every session on this map invokes
`grilling` and `domain-modeling`.

Standing decisions, settled with the user before the map was cut and not
reopened without them:

- **2.0 takes the plugin dependency.** `ADR 0022` and the `specs.md` §22
  guarantee that nothing committed may assume AEP is installed are superseded
  by this effort. A repository's norms may be unreadable without running the
  framework.
- **Depth is storage, delivery, and taxonomy.** What a record *is* is open.
- **The Spine holds.** The seven stages, the modes as postures, verification at
  use, and the two-axis review survive as concepts.
- **Migration from 1.x is required**, not optional, and shapes what 2.0 may
  choose.
- **`specs.md` is amended in the same change that lands 2.0** — the user's
  standing instruction, recorded here so it survives a context reset. It is the
  canonical specification for what this repository builds (`CLAUDE.md`), so a 2.0
  that ships without amending it leaves the authority document describing 1.x.
  Known to move, from reading them against the ten proposed ADRs: **§21 Repository
  layout** (the tree gains flat `.claude/knowledge/` and loses the four generated
  `map.md` indexes, ADR 0090) and **§22 Harness binding**, whose guarantee that
  *"nothing committed requires the plugin — a reader without it follows the same
  pointers and reads the same files"* is exactly what ADR 0083 supersedes.
  Sections on record types, the knowledge lifecycle, and composition are read
  against ADRs 0084–0087 at the same time. `16` produces the list this is written
  from. **It is build work: not started early, and not a reason to enter a stage.**

**The store design is being re-examined against accumulating research, by the
user's direction.** `06` and `11` are resolved and their ADRs are `proposed`
drafts, which is what makes revision cheap — more research is planned, and the
options are compared and chosen once rather than decided on each finding as it
lands. Six findings bear on it so far, all 2026-08-13:

- `whether-an-established-agent-knowledge-store-fits` — sixteen candidates
  against the six settled criteria; nothing fits, two criteria have no candidate
  anywhere.
- `md-plus-machinery-stores-under-the-relaxed-frame` — the markdown-authoritative,
  derived-index, MCP-served pattern is convergent across at least six independent
  projects; three AEP decisions have independent confirmation; what remains novel
  is span-level declared identity and store federation.
- `whether-a-database-can-be-the-authoritative-store` — Dolt and TerminusDB solve
  versioned structured data but each needs a server and brings its own version
  control, which would split knowledge history from code history; none of the
  wanted improvements is bounded by storage anyway.
- `whether-graph-traversal-over-linked-markdown-suits-aep` — graph retrieval's
  measured wins are all multi-hop QA, where AEP's primary retrieval is a zero-hop
  filter; the usable idea is a computed closure, held open on `12`.
- `how-comparable-frameworks-built-their-knowledge-stores` — the first direct peer,
  arXiv 2602.20478: same three tiers, same `.claude/context/` layout, same
  staleness failure answered with a session-start drift detector, but the cold tier
  is an instructed pull over a hand-maintained keyword map, and its own interaction
  data gives the mis-load rate — 23% of sessions never queried it. Kiro's
  `inclusion` modes are `fires-when` shipped; ConPort's linked-items query is
  `12`'s first working reference.
- `whether-tag-entry-and-link-traversal-suits-aep` — the brain-like model (small
  classified notes, tag entry, spreading activation along links) degrades on
  **basic factual retrieval**, which is AEP's category, per HippoRAG 2's own
  abstract; A-MEM generates tags and then retrieves by embedding rather than by
  them; SA-RAG's LLM-free propagation independently names judged selection's
  failure and supports `12`'s first position.
- `what-a-norm-corpus-must-look-like-to-actually-be-followed` — the first finding
  about the **consuming** end rather than the store. Instruction-following degrades
  with instruction count and the dominant error is silent omission; coherent
  topically-adjacent prose is the worst distractor class, so ADR 0089's filter is an
  accuracy saving and not only a token one; markdown stays the cheapest format that
  loses nothing. Opens one question the design has no answer for, below.

The six are compared in
[`which-substrate-design-the-six-findings-support`](../../evidence/discussions/2026-08-13-which-substrate-design-the-six-findings-support.md)
— five candidate designs scored against eight criteria the findings produced, with a
composite. **The user chose the composite on 2026-08-13.** Store-authoritative died on
one history with the code; an associative layer died on HippoRAG 2's own measurement
that graph-augmented retrieval degrades on basic factual retrieval, which is AEP's
category. What the composite adds beyond the drafted ADRs: the closure (`12`, ADR
0092), a closed `fires-when` vocabulary refusing Kiro's judged `auto` (ADR 0084,
amended), build-time edge resolution (ADR 0090, amended), and an instruction-count
bound whose instrument is open on `13`.

**The first executed evidence on this map landed 2026-08-14**, resolving item 6 of `08`:
[`does-a-fires-when-filtered-row-deliver-what-implement-needs`](../../evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md).
Every finding above it is an argument from documentation nobody ran; this one is a
measurement. It confirms ADR 0089's token half on the whole row — 34.7% of `/implement`'s
69,563 characters, with only 48.5% of the row labelled for the stage that loads it — and
**withdraws its compliance half**: imperatives fall just 27.4%, leaving 122, still inside
the band `13` was opened about. It also demonstrates the method's own value, killing a
vocabulary gap it had itself reported (`role:child`) by inspecting the dropped set that
produced it.

**Item 4 followed the same day** —
[`what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap`](../../evidence/prototypes/2026-08-14-what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap.md)
— and corrected its own premise: the cap is **bytes, roughly 30,000 characters, not
25,000 tokens**, and a stage over it gets a 2 KB preview plus a path. **A row does not
fit** — neither the 69,563-character file-list row nor the 45,445-character filtered one
— so ADR 0088's CLI fallback hands over a path rather than a row, amended there. The
failure is loud rather than silent, which is the one piece of good news.

**Item 1 followed over three runs, 2026-08-14** —
[`does-backtick-bang-preprocessing-actually-deliver`](../../evidence/prototypes/2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md),
then, in the fresh session it asked for,
[`what-reaches-a-stage-when-a-preprocessing-command-fails`](../../evidence/prototypes/2026-08-14-what-reaches-a-stage-when-a-preprocessing-command-fails.md).
The delivery mechanism **is confirmed by execution** — the substitution arrives in position,
before the content, at invoke time, at zero round trips. Four constraints came with it: the
shell is `/usr/bin/bash` on Windows, so a `.ps1` assembler is invoked through `pwsh`; an
unguarded non-zero exit aborts the whole skill and the stage receives *nothing*, its own
instructions included; **a guarded one delivers the shell's error text into the row as prose
with nothing reporting it**, which is the silent-failure surface `08` was re-aimed to hunt and
the reason the obvious fix for the first is worse than the problem; and nothing is
hot-swappable within a session. All four are recorded on ADR 0089, amended.

**Round 3 then put a row through it and the answer is no** —
[`whether-a-stage-row-fits-through-preprocessing`](../../evidence/prototypes/2026-08-14-whether-a-stage-row-fits-through-preprocessing.md).
Rounds 1 and 2 ran payloads of about 60 bytes; a row is 45,445–69,563 characters. **A
row-sized substitution is withheld**, replaced by the same `persisted-output` wrapper item 4
found on tool results — the size, a 2 KB preview, a path — with the cap bracketed at
**(10,036, 30,036] characters**. So ADR 0089's "zero model round trips" does not hold for what
it actually delivers: **the mechanism degrades into the exact read `08` was opened to compare
it against.** Reaching the proven-safe floor would take a 77.9% cut of the filtered row
against the 34.7% the whole filter buys, so shrinking into the cap is not a near miss. The
failure is loud, as item 4's was.

**Round 4 answered the question round 3 left, and it rescues the mechanism** —
[`whether-chunked-substitution-carries-a-row`](../../evidence/prototypes/2026-08-14-whether-chunked-substitution-carries-a-row.md).
**The cap is per substitution, not per assembled body**: five commands of ~9,036 characters
carried the filtered row and eight carried 72,288 — more than the unfiltered row — every chunk
whole and inline, no wrapper anywhere. Round 3 had found a limit on what *one command* may
carry and read it as a limit on the mechanism. So **ADR 0089's delivery half is confirmed with
a chunking constraint rather than superseded**, the user's call: the assembler emits N commands
each under the cap, binding at ~9,036 characters, with ~20,000 recorded as a goal and not
mandated because it is proven only as a single substitution. The bracket narrows to
**(20,036, 30,036]**. One consequence travels: chunking carries the *unfiltered* row, so
**`fires-when` buys tokens and nothing else** — no argument for it may rest on delivery.
`.claude/skills/` and its four probes are deleted, `/prototype` step 5.

**Item 3 rode the same restart** —
[`what-the-deferred-schema-startup-actually-costs`](../../evidence/prototypes/2026-08-14-what-the-deferred-schema-startup-actually-costs.md).
**AEP's boot tier is 3,475 tokens**, 0.35% of a 1m window, which settles ADR 0088's push
channel on cost; skills and agents cost a description each. The deferred-schema half is not
settled: `/context` reports a figure its own arithmetic places inside the tool total, and with
no MCP server connected nothing measured here speaks to MCP deferral. That residue shares
item 2's prerequisite.

**Items 7 and 3 closed on 2026-08-14, and `08` resolves with them** —
[`what-the-chunking-constraint-costs-at-chunk-count`](../../evidence/prototypes/2026-08-14-what-the-chunking-constraint-costs-at-chunk-count.md)
and
[`what-mcp-schema-deferral-costs-with-a-server-connected`](../../evidence/prototypes/2026-08-14-what-mcp-schema-deferral-costs-with-a-server-connected.md).

**The chunking constraint costs seconds, and ~20,000 characters is proven in combination.**
Four substitutions of 20,057 carried 80,228 characters whole. The overhead is **per command,
not per byte** — ~23 ms in-command at either chunk size, ~1.6–1.75 s per chunk boundary — so
the unfiltered row costs ~4.9 s in four chunks against ~12.4 s in eight. **Round 5 reported
112,499 ms for an eight-chunk body and round 6 re-ran the same probe at 12,449 ms**, nine times
faster; the ~1.9-minute figure is an unreproduced outlier and ADR 0089 carries the range rather
than either run. ADR 0089 is amended: the constraint now binds at ~20,000, and its cost is
measured rather than open.

**MCP schema deferral costs nothing at rest.** 11 tools and 38,104 bytes of schema, registered
and Connected, charge **0 tokens**. Item 3's residue closes and the research file's §4 is
discharged for the deferral claim. What stays unmeasured is **call-time** cost.

**The claim that item 2 decides whether 2.0 is buildable at all is withdrawn.** `08`'s own
statement of item 2 is that a negative result confirms ADR 0088's choice and a positive one does
not reopen it — non-decision-changing in both directions. What was load-bearing was that the
surrounding MCP machinery works, and item 3's run demonstrated it: the server registers,
connects, health-checks, enumerates its tools, and answers a call. Item 2's remaining question
is narrow, and ADR 0088 stands either way.

**Three residues remain, and none is a decision this map can take.** Item 1's
`disableSkillShellExecution: true` and item 2's hook both need a harness setting and a session
restart; item 5 needs the store to exist. Each is **increment-shaped rather than unanswerable**,
so each is declared as a scoped increment on the build ticket that can answer it, per
`.claude/policies/maps.md`.

**The probes were misplaced for four rounds, and it is recorded here rather than left implicit.**
`.claude/policies/evidence.md` is framework-owned and says throwaway prototype code goes to
`.claude/position/prototypes/`, which `.claude/.gitignore` covers. These went to
`.claude/skills/`, because the harness only finds a skill there and the probes had to *be*
skills to exercise preprocessing at all — a real constraint, but it meant throwaway code sat
committable for two sessions rather than ignored. Deleted 2026-08-14. **The deviation was the
placement, not the directory's absence from `.claude/rules/placement.md`**, which is how this
map described it until the review caught it.

Two findings from the pre-map discovery that every session here should hold:

- **A tool is pull; the boot tier is push — but the boundary has give.** The
  harness loads the entrypoint and unconditional rules before any protocol logic
  runs, and that load order is confirmed. The original *never* was false:
  `.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md`
  establishes that an `mcp_tool` hook on `UserPromptSubmit` places a tool call
  ahead of the model's decision and its result into context, and that
  `` !`command` `` preprocessing in skill content fetches records at invoke time
  without the model choosing. What survives is narrower and still load-bearing:
  **a norm that must fire on a turn the user did not start, or before servers
  have connected, cannot sit behind a tool call.**
- **A query is judged selection by construction**, and `ADR 0075` removed judged
  selection because mis-loads were the observed cause of sessions re-asking
  settled questions. Making retrieval *better* than an exact read, rather than
  merely different, is this effort's central problem.

## Decisions so far

- [which record types survive the flattening](issues/02-which-record-types-survive-the-flattening.md) — a type is admitted by write authority and post-write mutability, crossed with binds-or-describes; eight systems become seven types across three stores (framework, knowledge, tracker), `norm` living on both sides of the framework boundary with a `fires-when` field. ADR 0084.
- [whether the record is the norm or the file](issues/03-whether-the-record-is-the-norm-or-the-file.md) — the file is authored, the norm is addressed; a record is the smallest span that is correct alone, carried by a heading, with short opaque ids declared in frontmatter and bound by anchor. The id carries the fidelity floor. ADR 0085.
- [how the truth order survives a flat store](issues/07-how-the-truth-order-survives-a-flat-store.md) — cross-store conflict is a declared deviation, not a rank; precedence orders binders only and is computed from type, store, and `fires-when`; a decision outranks a norm and the norm is amended. Six ranks become three. ADR 0086.
- [what the tracker store's fixed interface guarantees](issues/10-what-the-tracker-store-s-fixed-interface-guarantees.md) — read-only; the contract is what every backing answers losslessly, with an explicit `unknown` rather than a reconstruction and `unavailable` kept distinct; `map` is the tracker's, `spec` the knowledge store's. ADR 0087.
- [what a plugin-hosted tool can actually do](issues/01-what-a-plugin-hosted-tool-can-actually-do.md) — the push/pull boundary has narrow give: an `mcp_tool` hook on `UserPromptSubmit` and `` !`command` `` preprocessing both deliver without the model choosing. A tool result is charged exactly as a file read; schemas are deferred, not charged per turn. Nothing was executed.
- [whether an established agent knowledge store fits](issues/11-whether-an-established-agent-knowledge-store-fits.md) — nothing fits across sixteen candidates; two criteria have no candidate anywhere. The build is justified. Sphinx's declared-label design and `objects.inv` are prior art to borrow.
- [what stays push when everything else becomes pull](issues/05-what-stays-push-when-everything-else-becomes-pull.md) — the core stays on harness push, the only channel that survives compaction and cannot fail silently; the store gets two faces, MCP and CLI, so an unreachable store is rebuilt rather than fatal; the path-scoped tier survives as a pointer only. ADR 0088.
- [how a stage gets its set without judged selection](issues/04-how-a-stage-gets-its-set-without-judged-selection.md) — the row is a **filter over norms**, not a list of files, delivered by preprocessing at zero round trips and never queried; the query serves only what the row excludes; there is no search, only filters, so a miss is a fact. ADR 0089, amended in draft when the first answer met the speed goal but not the token goal, and again when execution confirmed the delivery half and named a fourth cost — the assembler's failure mode is a fork with no safe branch. **Its delivery half survived the row-scale test on the fourth run**: one substitution over roughly 30,000 characters is withheld for a preview and a path, but the cap is **per substitution rather than per body**, so several commands carry the whole unfiltered row inline. Amended again — confirmed with a chunking constraint binding at ~9,036 characters per command, ~20,000 a goal and not a rule, and the filter demoted to a token measure alone.
- [where the store lives and what authors it](issues/06-where-the-store-lives-and-what-authors-it.md) — nothing derived is committed, which also deletes the four generated indexes; the store is `.claude/knowledge/`, flat; the build mints ids and an unlabelled heading fails. ADR 0090.
- [whether a query returns a declared-edge closure](issues/12-whether-a-query-returns-a-declared-edge-closure.md) — the store computes the closure and returns it with the match; depth is declared per edge type rather than tuned globally, so it is a fact about what an edge means instead of a number. Chosen from the composite after all six findings were compared. ADR 0092, with `04`'s bound on `08` to check it against ids-only.
- [what the migration converts and what it refuses](issues/09-what-the-migration-converts-and-what-it-refuses.md) — every 1.x surface has a destination; frozen records get one id and are not decomposed; the migration is fixture-proven and resumable, both settled by norms already in force. ADR 0091.
- [what bounds a row's instruction count](issues/13-what-bounds-a-row-s-instruction-count.md) — the corpus shrinks rather than the row, chosen against the measurement that a row-cut leaves 122 imperatives inside the band; a record is one instruction and a multi-imperative record fails the build, unifying the count with ADR 0085's span; the count is reported, never thresholded; a row arrives in ADR 0086's computed precedence order. ADR 0093.
- [how verification at use survives the flattening](issues/14-how-verification-at-use-survives-the-flattening.md) — a Source Pointer is declared on the file and overridable per span; `falsifies` names an id so the build validates it; the Marker does not move; the edge/pointer asymmetry is kept because a pointer targets the Codebase, which has no ids. ADR 0094.
- [what `/configure` becomes when nothing is copied](issues/15-what-configure-becomes-when-nothing-is-copied.md) — it writes only `CLAUDE.md` and the harness settings and runs the migration; every check moves to the build, so the build checks and `/configure` converts; a deviation from framework law becomes a `deviates-from` edge, loud by construction. ADR 0095.
- [whether a stage may mint an id mid-session](issues/17-whether-a-stage-may-mint-an-id-mid-session.md) — neither: a span is authored id-less and `/commit` runs the build before the commit lands, which is where ADR 0057 already puts the regenerator and what keeps the id in the same commit as its span. ADR 0096.
- [which accepted decisions 2.0 supersedes](issues/16-which-accepted-decisions-2-0-supersedes.md) — all 77 classified: **5 superseded** (`0018`, `0022`, `0032`, `0057`, `0071`), 13 amended, 24 affected and re-read at acceptance, 35 untouched. `0002` is vindicated rather than reversed; `0053` is 2.0's direct ancestor; the orchestration set comes through whole. Two defects found that are not classifications — `0023` and `0085` both name something "the fidelity floor", and `0068` and `0087` give "where a spec lives" two homes. No ADR was classified from `load-when` alone.

## Not yet specified

**Empty, as of 2026-08-14 — every remaining unknown on this map is a ticket.** The last
four patches graduated once `02` through `06` had all resolved: verification at use under
the flattening (`14`), what `/configure` becomes when nothing is copied (`15`), the ADR
supersession set (`16`), and whether a stage may mint an id mid-session (`17` — reduced to
its residue by ADR 0090, which already answered the other two thirds of the patch).

An empty section here is a claim about the frontier and nothing more: the map is done when
every remaining decision is **settled**, not when every one is ticketed
(`.claude/policies/maps.md`).

**As of 2026-08-14 all seventeen tickets are resolved and the map is done.** `08` was the
last, and it closed when items 7 and 3 were measured; its three residues — item 1's
`disableSkillShellExecution`, item 2's `mcp_tool` hook, and item 5's filter-only query — are
**declared as scoped increments** on tickets `19` and `21`, which is the second way
`.claude/policies/maps.md` permits a map to be left. Every decision that could be settled by
reading, by talking, or by measuring has been.

## Leaving the map

**Exited 2026-08-14 to `/design` step 5**, with the spec at `spec.md` beside this file and the
build set beneath ticket `18`.

Two increments travel with it, and the hand-back names which tickets carry them
(`.claude/policies/maps.md`):

| Increment | Ticket |
| --- | --- |
| item 1 — what `disableSkillShellExecution: true` does to a stage; item 2 — whether an `mcp_tool` hook's result reaches context | `19` |
| item 5 — whether a filter-only query surface answers the excluded cases without free-text search | `21` |

**Nothing was settled by assumption to reach the exit.** The three residues are recorded as
open questions with a named place to be answered, not as decisions taken quietly — which is the
distinction the increment mechanism exists to preserve.

**Item 1's residue was the sub-question that could hurt, and it stopped hurting on the fourth
run.** Round 3 measured a substituted-output cap with both rows outside it and ADR 0089's
delivery half falsified as written; round 4 measured that **the cap is per substitution, not
per assembled body**, so several commands carry the whole unfiltered row inline and the
decision is confirmed with a chunking constraint. What round 3 had found was a limit on one
command, not on the mechanism. **The delivery question is settled and the probes are deleted**;
item 1 stays open on `disableSkillShellExecution: true`, which no round has run.

**What the answer surfaced is item 7 — what the chunking constraint costs** — whose latency
half can still reopen ADR 0089, since nothing has ever timed more than one command. It is
gisted in "Decisions so far" terms only; the question itself lives on
[`08`](issues/08-whether-retrieval-actually-beats-an-exact-read.md).

**The claim this section used to carry is corrected, and the correction has since narrowed
again.** It read *the harness fixes its skill listing at session start*, written after a probe
returned `Unknown skill` and undercut within the same session when the probes appeared in the
listing without a restart. Round 2 replaced it with *a new skill and an edited body take effect
at the next session boundary*; round 3 ran four edited bodies with **no restart, only a
compact**, and then an edit invoked immediately that did *not* take. Measured: **a context
boundary short of a session restart is sufficient, and an edit followed directly by an
invocation is not.** That bounds shipping a changed row assembler far less than the original
claim did — and it is why narrowing the cap needs a boundary the session cannot produce for
itself.

## Out of scope

- **The Spine's stage set and the workflow shape.** The user scoped 2.0 to
  storage, delivery, and taxonomy; changing the stages is a different effort
  and nothing here may assume it.
- **Rewriting frozen records.** Accepted ADRs, resolved tickets, and landed
  specs keep their shape, as every prior effort here has held.

## Drift found

- [x] [the suite forbids the map phase its own policy creates](../../evidence/drift/2026-08-13-the-suite-forbids-the-map-phase-its-own-policy-creates.md) — `records/03` and `axis/03` failed any effort holding tickets without a spec; healed in the same change, with the charting exemption fire-checked in three states.
- [ ] [a row bound cannot tell index growth from prose re-inflation](../../evidence/drift/2026-08-13-a-row-bound-cannot-tell-index-growth-from-prose-reinflation.md) — `/review`'s row bound is crossed every ~3 ADRs by the generated Decisions index, and the row cannot be cut because the growing member is what the stage judges against. Ratcheted as a stopgap; the structural fix is this effort's, when the index is queried rather than loaded whole. **Fired again 2026-08-14** on ADRs 0093–0096, crossing at 68,495 and ratcheted 68,000 → 70,000 — the finding predicting its own recurrence and being right is the argument for the structural fix, not for a third ratchet.
