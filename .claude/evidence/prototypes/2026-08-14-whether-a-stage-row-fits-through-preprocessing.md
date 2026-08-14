---
owner: repository
kind: prototypes
falsifies: [.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md, .claude/tickets/substrate/map.md, .claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md]
---

# Whether a stage row fits through `` !`command` `` preprocessing, and where the substituted output is capped

Executed 2026-08-14 against `4c2b085`, on this session's own harness — the **third run** of item 1
of `substrate/08`, and the one round 2 closed by asking for.
[`does-backtick-bang-preprocessing-actually-deliver`](2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md)
and
[`what-reaches-a-stage-when-a-preprocessing-command-fails`](2026-08-14-what-reaches-a-stage-when-a-preprocessing-command-fails.md)
are frozen accounts (`.claude/policies/evidence.md`, "Declared fields, and the one index"), so
this is a third file rather than an amendment to either; read the three together.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Successful**, and it is the run that was expected to hurt and does — **no stage
row fits. ADR 0089's delivery half does not survive as written.**

Consumed: `.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md`,
"Item 1" — substrate/08; `.claude/tickets/substrate/map.md`, "Not yet specified"; and
`.claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md`.

## Hypothesis

Rounds 1 and 2 confirmed that preprocessing delivers, in position, before the content, at
invoke time, at zero model round trips. Both ran payloads of **about 60 bytes**. ADR 0089
delivers a stage row that measures **45,445 characters filtered and 69,563 unfiltered**
(item 6) — three orders of magnitude larger than anything ever put through the path.

Item 4 had already measured a cap of roughly **30,000 characters on tool results**, presented
as a `persisted-output` wrapper with a 2 KB preview and a file path. Preprocessing is a
different path and the ticket recorded explicitly that the cap "does not transfer by
assumption". The question is whether it transfers anyway.

Two outcomes were possible and the write-up was planned for both. If a row-sized substitution
arrives whole, ADR 0089's delivery half is confirmed end to end and item 1 closes. If it does
not, the decision resting on it is superseded before a spec is written — which the map names
as the outcome `08` exists to permit.

## Method

Four throwaway skills under `.claude/skills/`, each carrying exactly one substitution emitting
a numbered payload between two sentinels:

```
!`{ P=$(printf 'x%.0s' {1..94}); echo "PAYLOAD-START-nnnn"; \
    for i in {1..N}; do printf '%04d-%s\n' "$i" "$P"; done; \
    echo "PAYLOAD-END-nnnn"; } 2>&1; echo "EXIT=$?"`
```

Every line is 100 characters, numbered from `0001`, so a payload that arrives incomplete says
both *that* it was cut and *where*. Static `MARKER-BEFORE` / `MARKER-AFTER` sentinels bracket
the substitution, as in rounds 1 and 2, to separate a lost substitution from a lost body. The
generator was checked against bash in this repository before the run and produces the stated
sizes exactly.

**Sizes descend**, following item 4's method — a trip costs the truncation only, and the
largest is the one that matters:

| Probe | Payload | Sized to |
| --- | --- | --- |
| `probe-alpha` | 70,036 chars | `/implement`'s unfiltered row, 69,563 |
| `probe-beta` | 45,036 chars | the `fires-when`-filtered row, 45,445 |
| `probe-gamma` | 30,036 chars | item 4's tool-result cap, to see whether it transfers |
| `probe-delta` | 10,036 chars | a floor |

Each probe instructs the model **not** to reproduce the payload — only the sentinels, the
first and last visible line numbers, and any wrapper verbatim. Reporting a row-sized payload
back into the transcript is the one instruction these should not inherit from round 2.

The run was **not** preceded by a session restart. The bodies were written earlier in the same
session and a `/compact` intervened; that this delivered the new bodies at all is result 4
below, and was not planned.

## Result

**1. Every row-sized substitution is withheld, and the shape is identical at all three sizes.**

| Probe | Generated | Harness reported | `PAYLOAD-START` | `PAYLOAD-END` | Last line seen |
| --- | --- | --- | --- | --- | --- |
| `probe-alpha` | 70,036 | `Output too large (68.4KB)` | arrived | **absent** | `0019` |
| `probe-beta` | 45,036 | `Output too large (44KB)` | arrived | **absent** | `0019` |
| `probe-gamma` | 30,036 | `Output too large (29.3KB)` | arrived | **absent** | `0019` |
| `probe-delta` | 10,036 | — | arrived | **arrived** | `0100`, then `EXIT=0` |

`MARKER-BEFORE` and `MARKER-AFTER` arrived in every case, so the body itself is intact and it
is the substitution alone that is replaced. What replaces it:

```
<persisted-output>
Output too large (68.4KB). Full output saved to: …\tool-results\btmf04qpy.txt

Preview (first 2KB):
PAYLOAD-START-7731
0001-xxxxxxxx… (94 x's)
…
0019-xxxxxxxx…
...
</persisted-output>
```

Each reported size is the payload in KiB to one decimal — 70,036/1024 = 68.4, 45,036/1024 =
44.0, 30,036/1024 = 29.3 — so nothing was lost upstream of the measurement and the whole
payload reached the harness before being withheld from the model.

**2. The cap is bracketed but not pinned: ≤10,036 characters arrives inline, ≥30,036 does
not.** `probe-delta` delivered all 100 lines, `PAYLOAD-END-4460`, and `EXIT=0`, with no
wrapper, no notice, and no file reference. The interval between is untested — an attempt to
narrow it to 20,036 is result 4.

**3. It is the same mechanism item 4 found, on a path the ticket said would not transfer by
assumption.** The wrapper text, the 2 KB preview, and the `tool-results/` destination
directory are identical to what a tool result over the cap produces. That is measured;
*whether one limiter serves both paths* is an inference from the identical presentation and is
not established here. Either way the two brackets now compose: item 4 saw 34.6 KB trip with no
floor established, and this run puts the floor above 10,036 characters and the ceiling at or
below 30,036 for the preprocessing path.

**4. A compaction refreshes the delivered skill body; an edit alone does not.** All four
probes ran their round-3 bodies with **no session restart** — only a `/compact` between the
edit and the invocation. Then, mid-sequence, `probe-gamma` was edited from 300 lines to 200
and invoked immediately: it delivered the **old** body, heading `30,000 characters` and payload
29.3 KB, on a second spill to a second file. So a context boundary short of a session restart
is sufficient, and an edit followed directly by an invocation is not. Round 2's statement that
an edited body "takes effect at the next session boundary" is confirmed sufficient and
**falsified as necessary**.

**5. The failure is loud, which is the only good news and it is real.** The wrapper is
explicit, names the size, and hands over a path. A stage receiving one can tell it did not get
its row. Against the silent-failure surfaces `08` was re-aimed to hunt — and against round 2's
finding that a *guarded* command produces one — this is not another. It is the second loud
failure on this path, alongside the unguarded-exit case.

## Limitations

- **The cap is a bracket, not a number.** Somewhere in (10,036, 30,036]. The one attempt to
  narrow it failed for result 4's reason, and narrowing it needs a context boundary this
  session cannot produce for itself.
- **One substitution per body was tested.** Whether the limit applies per command or to the
  assembled body is **untested and decisive** — see the conclusion.
- **Bytes versus characters is not separated.** The payload is ASCII throughout, so the two
  coincide and nothing here says which the harness counts.
- **Nothing was measured about latency**, which stays where round 1 left it: a single
  8-second observation, ceiling unknown.
- **`disableSkillShellExecution: true` remains untested**, as planned since round 1 — with it
  set nothing executes, so a size probe under it cannot distinguish a cap from a suppressed
  mechanism. Cap first, then flip.

## Conclusion

**Successful**, and the result is the negative one. ADR 0089 states that preprocessing
assembles the row and inlines it "before the skill content reaches the model — zero model
round trips". Measured, a row-sized substitution is **not inlined**. What arrives is a 2 KB
preview and a path, and reading that path is a `Read` call — **the round trip the decision
exists to eliminate**. The mechanism does not fail; it degrades into precisely the exact read
that `08` was originally opened to compare it against.

Both rows are outside the bracket by a wide margin. Reaching the proven-safe floor would take
a **77.9%** cut of the filtered row or **85.6%** of the unfiltered one; the whole `fires-when`
filter, measured, buys 34.7%. Shrinking the corpus into the cap is not a near miss.

The conclusion is deliberately confined to *this mechanism delivering a whole row in one
substitution*, because one cheap, untested question could rescue it: **is the limit per
substitution or per body?** `probe-delta` proves a single ~10 KB substitution arrives whole. If
the limit is per substitution, five of them in one body deliver a 45 KB row inline and ADR 0089
survives intact; if it applies to the assembled body, it does not, and the delivery half needs
replacing. Nothing here distinguishes the two, and the probes are therefore kept for a fourth
run rather than deleted — `/prototype` step 5 fires when the question is settled, and this one
has been narrowed rather than answered.

That is a measurement, not a design position. Which way ADR 0089 moves — chunked delivery, a
row cut far past what the filter buys, accepting the spill and its round trip, or superseding
the delivery half outright — is the user's, and the map already says a superseded ADR before a
spec is written is the outcome `08` exists to permit.
