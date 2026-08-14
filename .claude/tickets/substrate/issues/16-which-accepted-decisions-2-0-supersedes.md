---
owner: repository
title: "docs(decisions): enumerate which accepted decisions 2.0 supersedes"
status: resolved
blocked-by: [02, 04, 05, 06]
part-of: substrate
type: task
---

## Question

Which accepted ADRs does 2.0 supersede, which are merely affected, and what does each
need? This is enumeration rather than judgement — the answer is found by reading each
accepted decision against the ten proposed ones — which is why it is a `task` and not a
`grilling`.

Graduated from the map's fog on 2026-08-14. It was held as fog because *"what `04`
through `06` add is still fog — the delivery decisions have not been taken."* They have
now: ADRs 0088, 0089, and 0090. Nothing blocks the enumeration.

Known before starting, from the map's standing decisions and the drafted ADRs:

- **`0022` — plugin independence.** Confirmed superseded by ADR 0083. `specs.md` §22
  carries the same guarantee in prose and moves with it.
- **`0032` — modes in their own directory.** Confirmed superseded: ADR 0084's `fires-when`
  field contradicts it, and 0084 says so, *"superseded at both ends when 2.0's spec is
  accepted."*
- **`0021`, `0056`, `0073`** — recorded as affected and to be read against the new model.
- **`0008`** — AEP's conventions are defaults for when the repository is silent. Read it
  against ADR 0086's computed precedence, which changes what "silent" resolves to.
- **`0075`** — judged selection removed. **Not superseded and load-bearing**: ADRs 0089
  and 0084 both cite it as the thing they are protecting. Confirm it survives intact
  rather than assuming it does.
- **`0078`, `0058`, `0059`, `0065`** — computed-over-judged, ticket ids, layout scope, and
  the release cursor. Each touches something 2.0 moves; each needs a read.

Deliver: one list, every accepted ADR classified **superseded / amended / affected but
unchanged / untouched**, with the reason on the superseded and amended rows and the
replacing ADR named. A superseded decision is edited at both ends — `supersedes` and
`superseded-by` — which ADR 0092's closure now depends on being correct, since a closure
over a broken edge returns a quietly smaller set.

## First pass — 2026-08-14

**Read in full and classified: fifteen.** The remainder were triaged from
`.claude/decisions/map.md`'s `load-when` column and are *not* individually read; that
sweep is what keeps this ticket open. Every row below marked **read** was opened.

### Superseded — the mechanism has no subject under 2.0

| ADR | By | Why |
| --- | --- | --- |
| `0022` plugin independence | `0083` | **read.** 0083 supersedes it by name; `specs.md` §22 carries the same promise in prose and moves with it |
| `0032` modes in their own directory | `0084` | 0084 states it: `fires-when` contradicts the directory, *"superseded at both ends when 2.0's spec is accepted"* |
| `0018` knowledge layers visible in the tree | `0090` | **read.** Its ruling is *"every category is a directory rather than a naming convention"* — precisely what the flat `.claude/knowledge/` with `type` as a field reverses |
| `0057` one regenerator, enforced by comparison | `0090` | **read.** 0090 names it: the indexes *"become queries and stop existing as files, taking regenerate-and-compare with them"* |
| `0071` the index prohibition is a specified step | `0090` | **read.** It enforces a prohibition on committed generated indexes; under 0090 there are none, so the subject is gone |

### Amended — the ruling survives, the mechanism moves

| ADR | Survives | Moves |
| --- | --- | --- |
| `0002` routing table, not tags | **read. Vindicated, not reversed** — *"tags describe what a file is about; the agent's question is when to load it"* is exactly `fires-when`, and is why 0084 refuses Kiro's judged `auto` | the central table becomes a query |
| `0021` three tiers by mechanism | **read.** *"Placed by how the harness selects them, not by what they are about"* generalises into `fires-when` | its stated reason for tier 3 — *"`paths:` cannot express 'when `/implement` runs'"* — **dissolves**, because `fires-when: stage:` does express it. 0088 keeps three tiers on a different footing and makes tier 2 a pointer only |
| `0053` a routing table generated from declared fields | **read. 2.0's direct ancestor.** Declared fields, no hand authorship, and *"supersession at both ends, which makes a graph that can be checked for symmetry"* — strengthened by 0090's build-time edge resolution and 0092's closure | the generated table becomes a query; *"a generated file is never hand-edited"* loses its subject |
| `0056` one index per family | **read.** *"A declared field restates the path only while the index is scoped to that path"* — generalised by 0084 making `type` a field | the per-family index goes. Its own standing contradiction about tickets is **dissolved** by 0087's tracker interface |
| `0073` owner declared, framework law varies at declared points | `owner` as a field, and the deviation discipline | the byte-lock half dissolves (0084) — except on the core, which 0088 keeps |
| `0080` a framework file declares its release | the core's stamps (0088) | per-file stamps elsewhere dissolve with copying (0084) |
| `0082` every governed file declares its owner | the declaration | the audit's coverage sweep is `15`'s to redefine |
| `0075` stage loads are exact; the core is drift-selected | **protected, not superseded** — 0084 and 0089 both cite it as the thing they preserve | *exact* stops meaning a file list and starts meaning a filter result (0089) |

### Affected — read at acceptance, not classified here

`0004` and `0052` (drift model, Marker) ride ticket `14`. `0065` and `0079` (audit cursor,
the router as framework law installed verbatim) ride `15`. `0008` meets 0086's computed
precedence. `0060` and `0069` follow `0057`. `0058` meets 0087. `0031`, `0045`, `0050`,
`0059` are all `specs.md` §21 amendments and move when §21 does. `0007`, `0020`, `0028`
meet 0084's type collapse. `0055` meets the new fields in 0084 and 0085.

### One defect found, which is not a classification

**Two decisions name different things "the fidelity floor".** `0023` (**read**) says
*"`verify.ps1` is the fidelity floor"* — prose surviving compression. `0085` says *"the id
carries the fidelity floor"* — a norm surviving addressing. They are complementary
failure modes, not a contradiction, but one term in two senses is what
`.claude/policies/context.md` calls *"a finding about the repository, not a filing
problem: split it and name each."* Fix it while 0085 is still `proposed`.

**And a live interaction between `0023` and the measurement.** 0023 keeps the *why* only
where a rule would read as arbitrary without it, on the ground that an undefended rule is
*"cheap in tokens and expensive in thought"*. `08`'s item 6 measured that a `fires-when`
filter strips why-clauses faster than imperatives — 34.7% of characters against 27.4% of
imperatives. **A mechanism is now making 0023's trade, where 0023 assigned it to an
author.** Whether that is acceptable belongs to `13`.

## Second pass — the sweep, same day

The remaining forty-seven were opened and read to their ruling — the title and opening
claim, which is what decides *touched or not*. **All 77 are now classified: 5 superseded,
13 amended, 24 affected, 35 untouched.**

### Amended — the eight added by the sweep

| ADR | What moves |
| --- | --- |
| `0015` AEP ships as a plugin, installed at **local** scope | it makes installation *"personal but not global: enabled in the projects chosen for it"*. ADR 0083 makes the plugin **required**, so optionality goes and scope is no longer a free choice |
| `0019` tool references derived per repository | ADR 0084 lists `reference` among the seven types, so a tool guide becomes a record in a store. The *derivation* survives — *"derivation filters whole entries; it never summarizes"* — and the file-per-tool does not |
| `0039` a drift finding is evidence, indexed on the live map | *evidence* survives; the **index** dissolves into a query (0090) |
| `0068` where a spec lives is declared in the derived tracker policy | **a real collision.** 0068 puts the answer in the *tracker* policy; ADR 0087 rules *"`map` is the tracker's, `spec` the knowledge store's"*. Two homes for one fact, and 0087 is the one that has to say so |
| `0072` a downstream correction returns as evidence | rides `0019` — with references as records, the refresh path between plugin and repository changes shape |

### Untouched, and three of them are load-bearing here

- **`0040`** — *"a sub-agent inherits the whole `CLAUDE.md` hierarchy the parent loaded, so a
  child reaches the policy by the same pointer chain."* **This already settled the
  `role:child` question** that `08`'s item 6 answered empirically. The answer was in the
  corpus before the prototype found it, which is itself worth knowing: the first pass
  invented a vocabulary gap that an accepted decision had already closed.
- **`0029`** — every change conforms to `specs.md` or amends it **in the same change**.
  This is the decision behind the standing `specs.md` obligation on the map; it is not
  amended by 2.0, it is what *binds* 2.0.
- **`0074`** — the one-line why. Untouched as a decision, and newly interesting: see the
  `0023` interaction above.

Also untouched: `0006`, `0009`–`0013`, `0016`, `0017`, `0024`, `0026`, `0027`, `0030`,
`0034`, `0037`, `0038`, `0041`–`0044`, `0046`–`0049`, `0051`, `0061`–`0063`, `0066`,
`0070`, `0077`, `0078`. The orchestration set (`0040`–`0049`, `0077`) comes through whole,
which is the expected result — the user scoped 2.0 to storage, delivery, and taxonomy, and
orchestration is none of the three.

### Affected — twenty-four, each read against 2.0 at acceptance

`0004`, `0052`, `0067` (drift, Marker, position report) ride `14`. `0025`, `0065`, `0076`,
`0079` (templates, audit cursor, the write bound, the router as framework law) ride `15`.
`0014`, `0035`, `0036`, `0058` meet 0087's tracker interface. `0031`, `0045`, `0050`,
`0059` are `specs.md` §21 amendments and move when §21 does. `0007`, `0020`, `0028` meet
0084's type collapse. `0008` meets 0086's computed precedence. `0055` meets the new
fields. `0060`, `0069` follow `0057`. `0064`, `0081` meet the version-stamp dissolution,
and both are expected to survive because ADR 0088 keeps the core stamped.

### How this was read, stated rather than implied

Fifteen ADRs were read in full; forty-seven were read to their ruling. **No ADR was
classified from `load-when` alone.** A classification made from an opening claim can miss
a consequence buried in a later section — the sweep's known weakness, and the reason every
*affected* row above is marked for a full read at acceptance rather than treated as
settled. The five *superseded* rows and the thirteen *amended* rows are the ones this
ticket asserts.

## Evidence bearing on this

- The ten proposed decisions, `0083` through `0092`, all `status: proposed`.
- ADR 0092 and ADR 0090 — the closure is computed from declared edges and the build fails
  an unresolved one, so this enumeration is what makes supersession queryable rather than
  prose. Getting it wrong is not cosmetic.
- `.claude/policies/decisions.md` — the bar a decision must clear, and how supersession is
  recorded.
- **`specs.md` is amended in the same change**, per the map's *Not yet specified*. This
  ticket produces the list that change is written from; it does not perform it.
