---
owner: repository
kind: prototypes
falsifies: [.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md, .claude/tickets/substrate/map.md]
---

# What MCP schema deferral costs with a server actually connected

Executed 2026-08-14 against `03f510f`, on this session's own harness. Closes the residue of item
3 of `substrate/08` — the half
[`what-the-deferred-schema-startup-actually-costs`](2026-08-14-what-the-deferred-schema-startup-actually-costs.md)
could not reach, because that session had no MCP server connected. That account is frozen; this
is a second file rather than an amendment, and the two are read together.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Successful.** With **11 MCP tools and 38,104 bytes of schema registered and
health-checked Connected, `/context` charges 0 tokens.** The documented deferral claim is
confirmed on the surface it was written about, and round 4's ambiguous 18.3k reading resolves in
favour of *what deferral saved*.

Consumed: `.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md`,
"Item 3 — settled" — substrate/08; and `.claude/tickets/substrate/map.md`, "Notes" and
"Not yet specified" — substrate/08.

## Hypothesis

`.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md` §4 states
that tool schemas are not charged per turn by default and that with tool search on *"only tool
names and server instructions load at session start"*. Its own Limitations name §4 as the least
durable thing in the file. Item 3 is that re-verification.

Round 4 ran it and got a structurally incomplete answer. `/context` reported a
`System tools (deferred)` line of 18.3k whose arithmetic placed it inside the 23.9k tool total,
and that number admitted two readings with opposite verdicts:

- **it is what deferral saved** — the schemas that would have loaded and did not; or
- **it is what the deferred surface currently occupies** — in which case deferral is missing its
  documented behaviour by roughly 90×.

Nothing in the report separated them, and **no MCP server was connected**, so every deferred tool
measured was a harness built-in and none of it spoke to MCP deferral — the surface §4 is actually
about, and the one ADR 0088's second face would use. The residue was folded into item 2's
restart.

A server now exists to connect. Expected, if §4 holds: a large registered schema surface adding
approximately nothing to the session total.

## Method

One `/context` invocation in a session whose composition is known, with the throwaway
`substrate-probe` MCP server registered at local scope and health-checked **Connected**: **11
tools — one sentinel plus ten fat-schema tools — totalling 38,104 bytes of schema**, sized
during the previous session so the eager-versus-deferred question reads straight off the report.

Two properties make this reading answer what round 4's could not:

- **The server was sized to be visible if it were charged.** 38,104 bytes is roughly 11.7k
  tokens. Eager loading would move the session total by about 10%; deferral would move it by
  approximately nothing. The two outcomes are not close, which is what removes the ambiguity
  round 4 hit.
- **The reading is taken in a session distinct from the one that registered the server.** The
  previous session registered it mid-run by CLI, and its handoff flagged that a reading taken
  before a boundary might not reflect it. This session is a different one — different session
  directory — and the server is enumerated in both `/context` and the harness's own deferred-tool
  notice, so registration is reflected rather than assumed.

Nothing was varied. This is a single reading of one session's composition, not a controlled
comparison, and the tools were never **called** — so it measures resting cost only.

## Result

### 1 — What the report said

```
121.2k/1m tokens (12%)

System prompt:     4.1k   (0.4%)
System tools:     23.9k   (2.4%)
Custom agents:      403   (0.0%)
Memory files:      4.4k   (0.4%)
Skills:            3.6k   (0.4%)
Messages:         85.2k   (8.5%)
Free space:      878.5k  (87.8%)

MCP tools · /mcp (loaded on-demand)
└ 11 tools · 0 tokens
```

The expanded listing itemises the deferred surfaces separately from those categories:

```
MCP tools (deferred):      11.7k  (1.2%)
System tools (deferred):   18.3k  (1.8%)
```

### 2 — MCP schema deferral costs zero, measured two ways

**The harness states it directly**: `11 tools · 0 tokens`.

**And the arithmetic agrees.** The six named categories sum to 121.6k against a reported 121.2k
total — a 0.4k spread consistent with six figures each rounded to 0.1k — and 121.2k + 878.5k is
the 1m window. **There is no MCP contribution anywhere in the reconciliation.** Had the 11.7k
been charged, the total would sit near 133k.

So 38,104 bytes of registered schema, itemised by the report at 11.7k tokens across ten fat tools
at ~1.2k each plus a 112-token sentinel, are **available and uncharged**. The mechanism is
visible in the session's own transcript: the deferred tools arrive as names only, with schemas
loaded on demand through `ToolSearch`.

### 3 — Round 4's ambiguity resolves, one half by measurement and one by inference

`MCP tools (deferred): 11.7k` sits beside a charged figure of **0**. That fixes what the word
*deferred* means in this report: **a would-have-cost figure, not an occupancy figure.** Round
4's first reading is the right one.

Applied to the built-in line, `System tools (deferred): 18.3k` is then what deferral saved on the
harness's own surface, and the charged 23.9k is the non-deferred built-ins alone. The arithmetic
is consistent with this and rules out the alternative that 18.3k is *additional*: adding it would
put the named sum near 140k against 121.2k reported.

**This half is an inference from parallel presentation, not a measurement.** It assumes the two
`(deferred)` lines mean the same thing because they are formatted the same way — the same class
of inference round 3 flagged when it declined to conclude that one limiter serves both the
tool-result and preprocessing paths. Only the MCP line has a charged figure beside it to check
against.

### 4 — The boot tier and per-surface figures hold at a third reading

| Surface | This reading | Item 3 / round 4 |
| --- | --- | --- |
| AEP boot tier | **3,475** | 3,475 |
| Skills | 3.6k / 36 ≈ **100 each** | ~103 each |
| Custom agents | 403 / 5 = **81 each** | ~81 each |

The boot tier is unchanged to the token across three readings taken with different skill and
tool surfaces present: 353 + 1,200 + 423 + 716 + 388 + 395, the entrypoint plus the four
unconditional rules, the auto-memory file being the harness's rather than AEP's.

## Limitations

- **Single reading, no control.** Nothing was varied. The zero is read from one session with the
  server present; no paired reading with the same session minus the server was taken, so the
  comparison is against *other* sessions rather than against this one.
- **The built-in half is inference.** Per §3 above. A direct measurement would need a reading
  with tool search disabled, which this session cannot produce for itself.
- **Resting cost only.** No MCP tool was called. What a schema costs when `ToolSearch` loads it
  on demand, and whether it stays in context afterwards, is not measured here and is the figure
  that would actually matter to a stage using the store.
- **Schema size is a server-side figure.** 38,104 bytes was measured at the server; the 11.7k
  token figure is the harness's own estimate. The ~3.3 bytes-per-token ratio is plausible for
  JSON schema but was not independently checked.
- **The tools are synthetic.** Ten fat-schema tools built to be large; a real store's tool
  surface may differ in shape, though not in a way that should change whether it is charged.
- **The 2 KB truncation was not exercised** — no server instruction here approaches it.
- **Version-bound.** The research file already flags tool search as beta-gated and §4 as its
  least durable section. This is one harness build on one day.

## Conclusion

**Successful**, and item 3's residue closes.

**§4's claim holds on the surface it was written about.** A registered, connected MCP server with
38,104 bytes of schema across 11 tools costs **0 tokens** at rest. Deferral is doing what the
documentation says, and the research file's instruction to re-verify §4 before building on it is
**discharged for the deferral claim** — not for the rest of §4, which this reading does not
touch.

Two things follow for the map. **The resting cost of an MCP tool surface is not an argument
against ADR 0088's second face** — a store served over MCP adds nothing to a session that does
not call it, so the cost question moves entirely to call time, which is unmeasured and is the
figure worth having next. And **round 4's 18.3k reading, which was recorded as admitting a
refutation, does not refute anything**; the built-in surface is deferred on the same terms, by
inference.

Item 3 asked what the deferred-schema startup actually costs. Across the two files: the boot
tier is 3,475 tokens, skills and agents cost a description each at ~100 and ~81, and **deferred
schemas cost nothing until used.** A growing stage and tool surface is cheap at rest, which is
the property 2.0 was contemplating more stages against.

Not promoted. No code was written this round; the MCP probe server is deleted with the rest.
