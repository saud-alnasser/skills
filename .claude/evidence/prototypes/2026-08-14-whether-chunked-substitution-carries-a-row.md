---
owner: repository
kind: prototypes
falsifies: [.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md, .claude/tickets/substrate/map.md, .claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md]
---

# Whether several `` !`command` `` substitutions carry a stage row that one cannot

Executed 2026-08-14 against `4c2b085`, on this session's own harness — the **fourth run** of
item 1 of `substrate/08`, and the one round 3 closed by asking for.
[`does-backtick-bang-preprocessing-actually-deliver`](2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md),
[`what-reaches-a-stage-when-a-preprocessing-command-fails`](2026-08-14-what-reaches-a-stage-when-a-preprocessing-command-fails.md),
and
[`whether-a-stage-row-fits-through-preprocessing`](2026-08-14-whether-a-stage-row-fits-through-preprocessing.md)
are frozen accounts (`.claude/policies/evidence.md`, "Declared fields, and the one index"), so
this is a fourth file rather than an amendment to any of them; read the four together.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Successful** — the cap is **per substitution, not per assembled body**. Both
stage rows arrive whole and inline when the assembler emits them as several commands.
**ADR 0089's delivery half is rescued rather than superseded.**

Consumed: `.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md`,
"Item 1, round 4" and the new item 7 — substrate/08; `.claude/tickets/substrate/map.md`,
"Decisions so far" and "Not yet specified" — substrate/08; and
`.claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md`,
"the delivery half" — substrate/08.

## Hypothesis

Round 3 measured that a single substitution above roughly 30,000 characters is withheld for a
`persisted-output` wrapper — a size, a 2 KB preview, and a path — and that one of 10,036
arrives whole, bracketing the cap at (10,036, 30,036]. Both stage rows sit far outside it, so
the delivery half of ADR 0089 was falsified *for a row delivered in one substitution*.

Round 3 confined its conclusion deliberately, because one cheap question could rescue the
mechanism: **is the limit per substitution, or per assembled body?** Nothing measured
distinguished them. If it is per substitution, several commands each under the floor deliver a
row inline and the decision survives with a constraint on how the assembler emits. If it binds
the body, the delivery half needs replacing.

Two secondary questions rode the same run: narrowing round 3's bracket, and confirming the
floor had not moved between rounds.

## Method

Four throwaway skills under `.claude/skills/`. **The probe names are reused from round 3 and
carry different payloads** — a reader comparing the two accounts must not read `probe-alpha`
as the same experiment twice.

| Probe | Round 4 payload | Sized to |
| --- | --- | --- |
| `probe-alpha` | 5 substitutions of ~9,036 chars, 45,180 total | the `fires-when`-filtered row, 45,445 |
| `probe-beta` | 8 substitutions of ~9,036 chars, 72,288 total | `/implement`'s unfiltered row, 69,563 |
| `probe-gamma` | 1 substitution of 20,036 chars | the midpoint of round 3's bracket |
| `probe-delta` | 1 substitution of 10,036 chars | round 3's proven floor, unchanged — the control |

Each chunk is one command emitting a numbered payload between its own sentinel pair:

```
!`{ P=$(printf 'x%.0s' {1..94}); echo "CHUNK-n-START-nnnn"; \
    for i in {a..b}; do printf '%04d-%s\n' "$i" "$P"; done; \
    echo "CHUNK-n-END-nnnn"; }`
```

Every line is 100 characters and **numbered continuously across the whole probe** rather than
restarting per chunk — `probe-beta` runs `0001` to `0720` — so a chunk delivered short says
both that it was cut and where, and a chunk missing entirely leaves a gap in the numbering that
the surviving chunks reveal.

Three properties of the design carry the result:

- **`probe-alpha` interleaves static text between the chunks** — `GAP-1-7731` through
  `GAP-5-7731`, plus the `MARKER-BEFORE` / `MARKER-AFTER` pair round 3 used. Static text cannot
  be withheld by a substitution limiter, so a missing gap means the *body* was cut where a
  missing chunk means a *substitution* was. That is the distinction the round was run to make,
  and it is why `alpha` is the discriminating probe and `beta` only the scale test.
- **`probe-beta` was built so a per-body budget would fail partway rather than everywhere.** A
  budget spent in document order exhausts at some chunk *n*, leaving earlier chunks whole; the
  probe therefore asks which chunk first carries a wrapper, and treats that number as the
  budget's size.
- **`alpha` and `beta` are unguarded; `gamma` and `delta` carry `2>&1; echo "EXIT=$?"`.** Round
  2 measured that an unguarded non-zero exit is fail-closed and total — the model receives
  nothing at all, not even the skill's own instructions. So for the chunked probes, arrival of
  the complete body is itself proof that every command exited `0`, and no separate exit
  reporting was needed.

**The substitutions were confirmed performed rather than assumed.** From inside the context a
performed substitution is indistinguishable from text authored into the body, so this was
checked at the source before anything was recorded: `probe-beta`'s body is **2,268 bytes** and
delivered roughly 72 KB, `probe-gamma`'s is **812 bytes** for 20 KB, and every payload line is
generated by a `printf` loop that appears in the body and the payload nowhere. `gamma` and
`delta` also returned `EXIT=0`, which is their own command's echo and not authorable text.

The probes were written in the previous session and invoked in this one, so the session
boundary round 2 established as sufficient was satisfied without anything new being tested.
Each probe instructs the model **not** to reproduce the payload — only sentinels, first and
last visible line numbers, and any wrapper verbatim.

## Result

**1. Every chunk of both rows arrived whole and inline. No wrapper appeared anywhere.**

| Probe | Substitutions | Total | Sentinel pairs arrived | Line numbering | Wrapper |
| --- | --- | --- | --- | --- | --- |
| `probe-alpha` | 5 | 45,180 | 5 of 5 | `0001`–`0450`, contiguous | none |
| `probe-beta` | 8 | 72,288 | 8 of 8 | `0001`–`0720`, contiguous | none |
| `probe-gamma` | 1 | 20,036 | 1 of 1 | `0001`–`0200`, contiguous | none |
| `probe-delta` | 1 | 10,036 | 1 of 1 | `0001`–`0100`, contiguous | none |

No skip at any chunk boundary, in either chunked probe. `probe-alpha`'s five static gaps all
arrived alongside its five chunks, so nothing was cut from the body either.

**2. The cap is per substitution, not per assembled body.** `probe-beta` put **72,288
characters** through one skill body — more than twice round 3's largest withheld payload, and
larger than the 70,036 that round 3 saw replaced by a 68.4 KB wrapper. Nothing was withheld.
The per-body budget `beta` was designed to localise does not exist at row scale: there is no
chunk *n* to report, because no chunk failed.

**3. The bracket narrows to (20,036, 30,036].** `probe-gamma` delivered 20,036 characters
whole, where round 3 saw 30,036 replaced. The cap is still not pinned; the interval has halved.

**4. The floor has not moved between rounds.** `probe-delta` re-ran round 3's exact payload and
behaved identically — all 100 lines, both sentinels, `EXIT=0`, no wrapper. The two rounds are
therefore comparable, and nothing about the harness changed underneath them.

**5. The `fires-when` filter is a token measure, not a delivery necessity.** `beta` carried the
whole *unfiltered* row. Round 3's arithmetic — that reaching the proven-safe floor needed a
77.9% cut of the filtered row or 85.6% of the unfiltered one against the 34.7% the filter buys
— describes a constraint that chunking removes entirely. Whatever case the filter has now rests
on context cost alone, which item 6 already measured.

**6. AEP's boot tier has not moved: 3,475 tokens.** Measured by `/context` in the same session,
with four probe skills present: 353 + 1,200 + 423 + 716 + 388 + 395, the entrypoint plus the
four unconditional rules — identical to the figure item 3 recorded. Skills cost 3.6k across 35,
but the four probes cost roughly 40–50 tokens each against item 3's ~103 average, so **per-skill
cost tracks description length rather than being a flat rate per skill**. That refines item 3's
figure rather than contradicting it.

## Limitations

- **The chunk size the design will use is not the chunk size that was proven in combination.**
  20,036 characters is proven only as a *single* substitution, and ~9,036 only in a
  *multi-chunk* body. No run has put several 20 KB chunks in one body, and the two results do
  not compose by measurement — a per-body effect absent at 72 KB of 9 KB chunks is not thereby
  absent at 72 KB of 20 KB chunks. Anything mandating the larger size is reasoning past what
  was run.
- **No upper bound on chunk count was found, because none was sought.** Eight commands is the
  most that has been run in one body. Whether twenty or fifty behave the same is unknown.
- **Latency was not measured this round, and the gap is now load-bearing.** Round 1's single
  8-second observation of *one* command is still all there is. Thirteen commands ran across the
  four probes and none was timed, so whether an 8-chunk row costs one command's latency or
  eight is unmeasured — and at round 1's figure the difference is seconds against a minute at
  every stage entry. This is the sharpest open question the round leaves.
- **The cap remains a bracket, not a number** — (20,036, 30,036]. Narrowing it further needs a
  session boundary this session cannot produce for itself, for the reason round 3 recorded.
- **Bytes versus characters is still not separated.** The payloads are ASCII throughout, so the
  two coincide and nothing here says which the harness counts.
- **Whether one limiter serves both the tool-result and preprocessing paths is still an
  inference** from their identical presentation, as round 3 recorded. Nothing this round
  touches it.
- **`disableSkillShellExecution: true` remains untested**, as planned since round 1 — with it
  set nothing executes, so a size probe under it cannot distinguish a cap from a suppressed
  mechanism.

## Conclusion

**Successful**, and it is the positive result round 3 was kept open for. ADR 0089 claims the
row is assembled and inlined "before the skill content reaches the model — zero model round
trips". Round 3 falsified that for a row delivered in **one** substitution. Round 4 shows the
claim holds for a row delivered in **several**, at both row sizes, with no wrapper, no preview,
no path, and no round trip.

So the delivery half is **confirmed with a constraint**, not superseded: the assembler emits N
commands each under the measured floor, never one. The mechanism was never wrong about what it
delivers — round 3 found a limit on how much one command may carry, and an assembler is free to
use more than one.

**The constraint binds at ~9,036 characters per command** — five for the filtered row, eight
for the unfiltered one, which is the configuration that was actually run. **~20,000 is recorded
as a goal and deliberately not mandated**: it would halve the command count, the floor sits
above it, and it is proven only as a single substitution. Binding the design to it would ship
an inference as a constraint, and the limitation above says exactly what would have to be run
first. That is the shape of the recommendation rather than the decision itself — which way ADR
0089 moves is the user's, and was taken in the session this file was written in.

One consequence reaches further than item 1. Because chunking carries the **unfiltered** row,
the `fires-when` filter is no longer load-bearing for delivery at all: it buys context, which
item 6 measured at 34.7% strict, and nothing else. Any argument for it that rests on fitting
through the mechanism is now unsupported.
