---
owner: repository
title: "docs(evidence): settle whether retrieval actually beats an exact read"
status: resolved
blocked-by: [01, 04]
part-of: substrate
type: prototype
---

## Question

Does serving norms through a tool make a stage faster and more reliable than
loading its exact row — measured, not argued?

This is the measurement the corpus already records as missing. The discussion
`2026-08-10-the-compliant-path-costs-more-than-the-workaround` weighed several
mechanisms and every one died for lack of it: *"What is missing is not an idea
but a measurement."* 2.0 is a large bet on the answer, and nothing in this
repository has established it.

Build the cheapest thing that answers it, and delete the code:

- Take one real stage row — `/implement`'s is the largest at roughly 62 KB — and
  serve the same norms through a query path against a norm-level index.
- Compare on what actually matters: whether the settling norm is reached at all,
  how much context is spent reaching it, and how often a query misses something
  the exact row would have delivered unasked.
- Include the adversarial case deliberately: a question whose settling norm is
  phrased in vocabulary the asker would not use. That is where retrieval fails
  and an exact row does not.

The answer is a recommendation with numbers behind it, and it is allowed to be
that the query does not win — in which case 2.0's delivery half is wrong and
this map says so before a spec is written.

## Re-aimed by `04`

The comparison above is no longer the design. ADR 0089 delivers a stage's row by
`` !`command` `` preprocessing at zero model round trips and never queries it, so
retrieval is not competing with an exact read — it serves only what the row
excludes. Query-versus-read is settled by construction.

**What is unmeasured is larger than what this ticket originally asked.** Every
decision on this map rests on `.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md`,
which states plainly that **nothing was executed** and names §4 and §6 as its
least durable sections. Six ADRs now stand on documentation nobody ran. The
prototype's job is to execute the load-bearing claims and delete the code.

In dependency order — the first two decide whether 2.0 is buildable at all:

1. **Does `` !`command` `` preprocessing actually deliver?** ADR 0089's entire
   delivery half rests on it. Confirm the output reaches the model, that it runs
   before the skill content is read, and what happens when the command fails or
   is slow. Confirm what `disableSkillShellExecution: true` does to a stage.
2. **Does an `mcp_tool` hook on `UserPromptSubmit` reach context?** ADR 0088 chose
   harness push over it, so a negative result confirms that choice and a positive
   one does not reopen it — but the path-scoped pointer and the mid-turn lookup
   both assume the surrounding machinery works.
3. **What does the deferred-schema startup actually cost**, as `/context` reports
   it, against the documented claim that only names and ≤2 KB of instructions
   load.
4. **Does a >25,000-token result become a file reference**, and what does a stage
   see when it does.
5. **Does a filter-only query surface answer the excluded cases** — path-scoped
   norms, a cited cross-store norm, a mid-turn lookup — without free-text search.
6. **Does a `fires-when`-filtered row actually deliver everything a stage needs?**
   Added when ADR 0089 was amended to make the row a filter rather than a file
   list. This is now the effort's largest silent-failure surface: a norm labelled
   for the wrong stage stops arriving and nothing reports it. Assemble a real
   stage's row by filter, diff it against the file-list row it replaces, and
   examine what the filter dropped — the dropped set is the finding, and every
   member of it is either correctly excluded or a mislabelling the suite cannot
   catch. **Measure the saving at the same time**, since the token goal rests on
   it: the claim to test is roughly a third of `tickets.md` for `/implement`.
7. **What does the chunking constraint cost, and how few chunks can carry a row?**
   Added when round 4 of item 1 confirmed ADR 0089's delivery half by chunking.
   Two measurements sharing one prerequisite — rebuilt probes and a session
   boundary. **Latency at chunk count**: round 1 timed *one* command at 8 seconds
   and nothing has timed a body of several, so an eight-chunk row costs either
   seconds or a minute, *at every stage entry*. And whether **several
   ~20,000-character substitutions** deliver whole, which would halve the command
   count and is today proven one substitution at a time only. The first can still
   reopen the delivery half — a row that takes a minute to arrive is not a row
   delivered at zero cost — so it is this item's load-bearing half.

The answer is a write-up with numbers, and it is still allowed to come back
saying a mechanism does not work — in which case the ADR resting on it is
superseded before a spec is written, which is the whole reason this sits on the
map rather than after it.

## Item 4 — measured

`.claude/evidence/prototypes/2026-08-14-what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap.md`,
2026-08-14, **Successful**, and it corrects this item's own premise.

The cap is **bytes, not tokens, and roughly 30,000 characters — about a third of the
25,000 tokens this item was written around.** A 34.6 KB result trips it. What a stage
sees is a `persisted-output` wrapper naming the size, a **2 KB preview**, and a path.

Two consequences. **A full row cannot be delivered as a tool result** — the 68.6 KB run
was sized to `/implement`'s row exactly and was withheld; the filtered row at 45,445
characters is still over. That lands on **ADR 0088's CLI fallback face**, amended, not on
ADR 0089, whose preprocessing path is not a tool result. And **the failure is loud** —
the wrapper is explicit, so a stage can tell it did not get everything. Against this
ticket's framing of silent-failure surfaces, this is not one.

The floor was not bracketed: only that ≤34.6 KB trips. `PowerShell` documents 30,000
characters, consistent.

## Item 6 — measured

`.claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`,
2026-08-14, **Partially Successful**. Items 1–5 remain open and the ticket stays
with them.

The token half of ADR 0089 is confirmed: `/implement`'s row is 69,563 characters over
69 spans, and the filter drops **34.7%** strict or **24.4%** if the six contested spans
are kept. **Only 48.5% of the row is labelled for the stage that loads it.** The
predicted "roughly a third of `tickets.md`" turns out to be exactly the generous reading
of that one file (37.9%, against 70.0% strict) — so the estimate was measuring how the
ambiguous spans get labelled, not the filter.

The compliance half is not confirmed and should stop being claimed. Norm-shaped
imperatives fall from **168 to 122** — 27.4%, against 34.7% of characters, because the
prose the filter removes is disproportionately *why* clauses rather than imperatives.
The filtered row is not below the 100–115 band `13` was opened about. Cutting the row
was measured and was not enough, which promotes `13`'s row-versus-corpus sub-question
from open to load-bearing.

Two things the design has no place for:

- **23.2% of the row is beyond any norm filter** — `context` (14.7%: `repository.md` is
  Context, not norms, with a single 7,675-char `Language` span) and `reference` (8.5%:
  the four `git.md` Marker sections `report-position.ps1` performs, which the file says
  exist for "a reader without the script"). The second is a genuine vocabulary gap — a
  norm firing only in a degraded mode — and it is ADR 0088's second face, so it belongs
  there rather than as a new axis.
- **A row entry can be 100% inert in a repository while correct at framework level** —
  all three `tools/github.md` spans drop here, because this repository declares
  `tracker: local-markdown` and `/implement` never pushes. Nothing reports it.

A first pass reported a third gap, `role:child`, and **inspecting the dropped set killed
it**: the four `sub-agents.md` spans bind the child but must be *delivered* to the
parent, which performs the requests and writes the brief. `fires-when` is a delivery
condition, not a statement of who a norm binds. No `role:` axis is proposed.

## Item 1 — measured, over three runs

`.claude/evidence/prototypes/2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md`,
**Partially Successful**, ran the three staged probes.
`.claude/evidence/prototypes/2026-08-14-what-reaches-a-stage-when-a-preprocessing-command-fails.md`,
**Successful**, ran their guarded rewrites in the fresh session the first one asked for.
`.claude/evidence/prototypes/2026-08-14-whether-a-stage-row-fits-through-preprocessing.md`,
**Successful**, put a row-sized payload through the path for the first time — its result is
below and it is the one that moves a decision. All 2026-08-14. Everything here is measured on
this harness rather than read.

**The delivery mechanism is confirmed by execution, for the first time on this map — at small
payload sizes only.** The output reaches the model, substituted in position between static
markers, before the surrounding content, at zero model round trips, and six ADRs that stood on
a research file which executed nothing now have one measurement under the load-bearing one.
Eight seconds of command latency costs nothing at one command, and nothing has timed several.
**Round 3 then measured that this does not hold for a row sent as one substitution, and round 4
that it holds when the row is sent as several** — so the sentence ADR 0089 rests on is
confirmed for what the decision actually delivers, under a constraint on how it is emitted.

Four constraints came with it, none of which supersedes the decision:

- **The shell is bash, on Windows.** `/usr/bin/bash` 5.3.15, cwd at the repository root,
  measured from inside the preprocessor. Every AEP script here is `.ps1`, so an assembler is
  invoked as `pwsh -NoProfile -File …` — reachable, one extra process, and one more thing that
  must exist on the machine. The harness also prepends the skill's base directory as a
  **Windows** path while `pwd` returns an MSYS one.
- **Unguarded failure is fail-closed and total.** Any non-zero exit — a missing command and a
  command that exists and exits `3` behave identically — aborts the whole skill. The model
  receives *nothing*: not the markers, not the later commands, not the skill's own
  instructions. The user sees an error naming the failing pattern. The failure mode of the
  delivery path is *stage does not exist*, not *stage runs degraded*, and ADR 0088's second
  face covers an unreachable store rather than an assembler that takes its own stage offline.
- **Guarded failure is a silent-failure surface, which is the finding this ticket was
  re-aimed to hunt.** Guard the command and the row is delivered with the error text sitting
  in it as prose, in position, with the harness reporting nothing. Stderr is inlined **whether
  or not it is redirected**, and the exit code is not delivered at all — only what the command
  echoes, which the guard's own `$?` masks. So the two behaviours are a fork the assembler's
  author takes by writing or omitting a guard, and **the safer-looking branch is the unsafe
  one**.
- **Nothing is hot-swappable within a session.** A skill written mid-session is not invocable,
  and an edited body does not take; both take effect at the next session boundary, now
  measured in each direction. Commands themselves execute at **invoke time** — two probes'
  clocks sit 45 seconds apart, matching the gap between their invocations — so a row reflects
  the store as of the moment its stage is entered, bounded only by the assembler script being
  fixed at the session boundary.

**The session-listing claim this section used to carry is corrected.** It read *the harness
fixes its skill listing at session start*, written after `Unknown skill: probe-alpha` and
undercut within the same session when the probes appeared in the listing without a restart.
What is measured is narrower: **a skill is not invocable in the moments after it is written,
and the listing refreshes on its own schedule.** The session boundary is confirmed as
sufficient; it is not established as necessary.

**The probes are deleted, and `.claude/skills/` with them** — `/prototype` step 5, fired by
round 4 settling the question they were kept for.

## Item 1, round 3 — no row fits in one substitution

`.claude/evidence/prototypes/2026-08-14-whether-a-stage-row-fits-through-preprocessing.md`,
2026-08-14, **Successful**, and it is the negative result this item was kept open for.

**A row-sized substitution is withheld, not inlined.** All three row-scale payloads were
replaced by a `persisted-output` wrapper naming the size, a **2 KB preview**, and a path:
70,036 characters reported as 68.4KB, 45,036 as 44KB, 30,036 as 29.3KB, each cut after line
`0019` with `PAYLOAD-END` never arriving. 10,036 characters delivered whole and inline. **The
cap is bracketed at (10,036, 30,036] characters** and not pinned; the static markers arrived
in every case, so the body is intact and the substitution alone is replaced.

**This is the mechanism item 4 found, on the path this ticket said would not transfer by
assumption.** Same wrapper text, same 2 KB preview, same `tool-results/` destination. That the
presentations are identical is measured; that one limiter serves both paths is an inference
and is not established.

**The consequence for ADR 0089 is direct.** Its delivery half claims the row is inlined "at
zero model round trips". What a row-sized substitution actually produces is a preview and a
path, and reading that path is a `Read` — the round trip the decision exists to eliminate. The
mechanism does not fail; **it degrades into the exact read `08` was opened to compare it
against.** Both rows are outside the bracket by a wide margin: reaching the proven-safe floor
needs a 77.9% cut of the filtered row or 85.6% of the unfiltered one, against the 34.7% the
whole `fires-when` filter buys. Shrinking the corpus into the cap is not a near miss.

**The failure is loud**, as in item 4 — the wrapper is explicit and a stage can tell it did not
get its row. This is not another silent-failure surface.

**The one question that could rescue the mechanism — is the limit per substitution or per
assembled body? — was left open here and is answered by round 4, below.** Round 3 could not
distinguish them, having only ever run one substitution per body, and the conclusion was
confined to *this mechanism delivering a whole row in one substitution* for that reason.

**The session-boundary claim narrows again.** All four probes ran bodies edited earlier in the
same session with **no restart** — only a `/compact` between. An edit made mid-sequence and
invoked immediately delivered the **old** body. So a context boundary short of a session
restart is sufficient, and an edit followed directly by an invocation is not; round 2's "next
session boundary" is confirmed sufficient and falsified as necessary. It also means narrowing
the bracket cannot be done without a boundary the session cannot produce for itself.

`disableSkillShellExecution: true` remains untested, as planned since round 1, and stays a
**separate, later** run: with it set nothing executes, so a size probe under it cannot tell a
cap from a suppressed mechanism. Latency stays unbracketed — round 1's single 8-second
observation is all there is.

## Item 1, round 4 — the cap is per substitution, and the delivery question closes

`.claude/evidence/prototypes/2026-08-14-whether-chunked-substitution-carries-a-row.md`,
2026-08-14, **Successful**. It answers the question round 3 was kept open for, and the answer
is the one that rescues the mechanism.

**The cap is per substitution, not per assembled body.** Five commands of about 9,036
characters carried the filtered row's worth, 45,180, and eight carried **72,288 — more than
the unfiltered row's 69,563**. Every chunk arrived whole and inline, every static gap between
them arrived, line numbering ran contiguous with no skip at any boundary, and **no wrapper,
preview, or path appeared anywhere**. The probe that would have localised a per-body budget to
the chunk where it ran out had no chunk to report, because none failed. `probe-gamma` narrowed
round 3's bracket to **(20,036, 30,036]**, and `probe-delta` re-ran round 3's control unchanged,
so the two rounds are comparable and nothing moved underneath them.

**Round 3 found a limit on what one command may carry and read it as a limit on the
mechanism** — a conflation only round 4's design could separate, since every earlier run used
one substitution per body.

**ADR 0089's delivery half is confirmed with a chunking constraint, not superseded** — the
user's call, taken with the measurement in hand. The assembler emits N commands each under the
cap, never one, stated on the ADR beside the `pwsh -NoProfile -File …` constraint. It **binds
at ~9,036 characters**, the size actually run in a multi-chunk body; **~20,000 is recorded as a
goal and deliberately not mandated**, on the user's criterion that a goal may be set but
quality not compromised.

**Two gaps this round leaves, neither of them incidental — both become item 7:**

- **The chunk size the design would prefer is not the one that was proven.** 20,036 is proven
  only as a single substitution and ~9,036 only in a multi-chunk body; a per-body effect absent
  at 72 KB of 9 KB chunks is not thereby absent at 72 KB of 20 KB chunks. The probes that would
  have measured this cheaply are deleted, so closing it now costs rebuilding them.
- **Latency at chunk count is unmeasured, and the constraint is what makes it matter.** Round
  1 timed *one* command at 8 seconds. Thirteen ran across round 4 and none was timed, so
  whether an eight-chunk row costs one command's latency or eight is the difference between
  seconds and a minute **at every stage entry**. This is the sharpest thing item 1 leaves open.

**Item 1's delivery question closes here** — does preprocessing actually deliver, answered yes
for what the decision delivers, under a constraint. What it spawned is **item 7**, which asks
what that constraint costs; the two are not the same question.

**Item 1 does not close, and saying it did was wrong.** This item asked for two confirmations,
and the second is `disableSkillShellExecution: true` — *"confirm what it does to a stage"*,
stated in the item itself and not a rider on it. It has been deferred since round 1 as a
separate run, and it is **still unrun**. Worse, the probes were deleted on the strength of the
delivery question being answered, so the cheap instrument for it is gone: with the setting on
nothing executes, and a probe under it cannot tell a cap from a suppressed mechanism, which is
why it always needed its own run. **Item 1 therefore stays open on that residue alone**, owned
here rather than parked in prose — it needs harness settings and a session restart, the same
prerequisite items 2 and 5 carry. Items 2 and 5 stay open, with item 3's deferred-schema
residue beside them, and the ticket stays open with all of it.

## Item 3 — measured in part

`.claude/evidence/prototypes/2026-08-14-what-the-deferred-schema-startup-actually-costs.md`,
2026-08-14, **Partially Successful**. It rode item 1's restart, as planned.

**Round 4 re-measured the boot tier at exactly 3,475 tokens**, unchanged with four extra skills
present, and refined the per-skill figure: the probes cost ~40–50 tokens each against the ~103
average below, so **the cost tracks description length rather than being a flat rate per
skill**. The rest of this section stands as measured.

**AEP's boot tier is 3,475 tokens** — the entrypoint plus the four unconditional rules, 0.35%
of a 1m window against 5% for the whole idle session. That is the standing cost of ADR 0088's
push channel, now a number rather than an estimate, and it does not put the decision in
question. **Skills and agents cost a description each**, about 103 and 81 tokens, so 35 skills
cost 3.6k and a growing stage surface is cheap at rest.

The half the item was written for is **not** settled, and structurally so: `/context` reports
a deferred figure — 18.3k — that its own arithmetic places *inside* the 23.9k tool total, and
the two readings of it disagree about whether the documented claim holds. **No MCP server is
connected**, so every deferred tool measured is a harness built-in and none of this speaks to
MCP deferral, which is what §4 of the research file is about. Item 3's residue therefore needs
the same prerequisite as item 2, which the ticket recorded only against item 2.

## Item 3 — settled

`.claude/evidence/prototypes/2026-08-14-what-mcp-schema-deferral-costs-with-a-server-connected.md`,
2026-08-14, **Successful**. The residue above closes.

With a `substrate-probe` MCP server registered, health-checked **Connected**, and exposing **11
tools totalling 38,104 bytes of schema**, `/context` charges **0 tokens** — stated directly by
the report (`11 tools · 0 tokens`) and confirmed by arithmetic, since the six named categories
reconcile to the session total with no MCP contribution anywhere. **Deferral does what the
documentation says**, and §4's re-verification is discharged for the deferral claim.

That also fixes what *deferred* means in the report: a **would-have-cost** figure, not an
occupancy one. Round 4's ambiguous 18.3k built-in line therefore resolves to *what deferral
saved* — by inference from parallel presentation rather than by measurement, since only the MCP
line carries a charged figure to check against.

**The resting cost of an MCP tool surface is not an argument against ADR 0088's second face.**
What is unmeasured is **call-time** cost, which no run has touched and which is the figure that
would actually bind a stage using the store.

## Item 7 — measured, and it corrects round 5

`.claude/evidence/prototypes/2026-08-14-what-the-chunking-constraint-costs-at-chunk-count.md`,
2026-08-14, **Successful**, on both halves.

**Composition holds.** Four substitutions of 20,057 characters — **80,228 total** — delivered
whole in one body, every static gap present, numbering contiguous `0001`–`0800`, no wrapper. The
gap round 4 named is closed, and ADR 0089's reason for holding ~20,000 as a goal rather than a
rule is removed.

**The cost is per command, not per byte, and it is seconds.** ~23 ms in-command whatever the
chunk size, and **~1.6–1.75 s per chunk boundary**. An eight-chunk row costs ~12.4 s; a
four-chunk row ~4.9 s; `/implement`'s unfiltered row fits in **four** chunks.

**Round 5's figure did not reproduce.** The same probe ran 112,499 ms in round 5 and **12,449 ms
in round 6** — nine times apart, same machine. Round 5's own final gap, 1,491 ms, sits inside
round 6's distribution while being a 13× outlier against its other six. The ~1.9-minute cost is
recorded as an **unreproduced outlier** and does not reach ADR 0089, which is amended to carry
the range.

**A methodological rule this item earns:** a timing finding on this map is run at least twice
before it moves a decision. Round 5 moved one on a single run and was wrong by an order of
magnitude.

## What remains, and where it goes

Every item is now **settled** or **declared as a scoped increment on a build ticket**, which is
what `.claude/policies/maps.md` requires to leave a map. Items 4, 6, 7, item 1's delivery half
and item 3 are settled above. The three that are not are increment-shaped rather than
unanswerable — each needs partial code or a human at the keyboard, not more thinking:

| Residue | Why it cannot be settled here | Carried by |
| --- | --- | --- |
| item 1 — `disableSkillShellExecution: true` | needs a harness setting and a session restart | `19` |
| item 2 — does an `mcp_tool` hook reach context | needs a settings edit and a session restart | `19` |
| item 5 — does a filter-only query answer the excluded cases | needs the store to exist | `21` |

**Item 2 does not gate the effort, and the map's claim that it "decides whether 2.0 is buildable
at all" is withdrawn.** This ticket's own statement of item 2 is that *"a negative result
confirms that choice and a positive one does not reopen it"* — non-decision-changing in both
directions, because ADR 0088 already chose harness push. What was genuinely load-bearing was
that the surrounding MCP machinery works, and item 3's run demonstrated exactly that: the server
registers, connects, health-checks, enumerates 11 tools, and answers a call. What is left is the
narrow question of whether an `mcp_tool` **hook's result** reaches context, and ADR 0088 stands
either way.
