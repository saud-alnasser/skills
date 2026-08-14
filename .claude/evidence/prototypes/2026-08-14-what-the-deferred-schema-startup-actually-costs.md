---
owner: repository
kind: prototypes
falsifies: []
---

# What does the deferred-schema startup actually cost, as `/context` reports it?

Executed 2026-08-14 against `4c2b085`, on this session's own harness. Resolves item 3 of
`substrate/08` as far as this session can, which is not all of it. No code was written; the
experiment is one `/context` invocation, read against a session whose composition is known.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Partially Successful.** The boot tier and the skill surface are measured and
the documented order holds. The half item 3 was actually written for — what deferral costs on
an **MCP** tool surface — is not measurable here, because no MCP server is connected, and
`/context`'s own deferred figure does not reconcile with its totals.

## Hypothesis

`.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md` §4 states
that *"Tool schemas are not charged per turn by default"*, that with tool search on *"Only
tool names and server instructions load at session start"*, and that descriptions and server
instructions are hard-truncated at 2 KB each. Its own startup table is labelled representative
— MCP tool names 120 tokens, skill descriptions 450 — and its Limitations name §4 as *"the
least durable thing in this file"*, to be re-verified before anything is built on it. Item 3
is that re-verification.

Expected: a startup cost dominated by the system prompt and the boot-tier files, with names
and descriptions rather than schemas accounting for the tool and skill surfaces.

## Method

Invoke `/context` in a session with a known composition — 35 skills listed, 5 custom agents,
7 memory files, 23 tools named as deferred, **no MCP server connected** — and read the
category breakdown. The category table and the expanded per-surface listing were both taken.

Nothing was varied. This is a single reading of one session, so every figure below is a
composition measurement rather than a controlled comparison.

## Result

### 1 — What the report said

```
46k/1m tokens (5%)

System prompt:    5.1k   (0.5%)
System tools:    23.9k   (2.4%)
Custom agents:     403   (0.0%)
Memory files:      4.4k  (0.4%)
Skills:            3.6k  (0.4%)
Messages:          9.2k  (0.9%)
Free space:      953.5k  (95.4%)
```

The expanded listing adds one line that is **not** among those categories:

```
System tools (deferred):  18.3k  (1.8%)
```

### 2 — The boot tier costs about 3.5k tokens

The seven memory files, itemised by the report:

| File | Tokens |
| --- | --- |
| `~/.claude/CLAUDE.md` | 353 |
| project `CLAUDE.md` | 1,200 |
| `.claude/rules/boundary.md` | 423 |
| `.claude/rules/engineering.md` | 716 |
| `.claude/rules/placement.md` | 388 |
| `.claude/rules/precedence.md` | 395 |
| auto-memory `MEMORY.md` | 832 |

**AEP's own boot tier — the entrypoint plus the four unconditional rules — is 3,475 tokens**,
the auto-memory file being the harness's rather than AEP's. That is the price ADR 0088 pays
for keeping the core on harness push, and it is now a measured number rather than an estimate:
0.35% of a 1m window, against 5% for the whole idle session.

### 3 — Skills and agents load descriptions only, and the documented order holds

35 skills cost 3.6k tokens — **about 103 tokens each**, which is a name and a one-to-three
sentence description and cannot be a `SKILL.md` body; the four throwaway probes in this
repository are roughly 40 each and the largest built-in descriptions roughly 380. 5 custom
agents cost 403 tokens, **about 81 each**, likewise name-and-description.

The research file's representative figure was 450 tokens for skill descriptions. At 103 each
that is 4–5 skills' worth, so the *order* it asked to be trusted is right and the absolute
number simply scales with how many skills are installed. **The "full skill content loads only
when Claude uses one" claim is confirmed by composition**: 35 bodies would not fit in 3.6k.

### 4 — The deferred figure does not reconcile, and this session cannot make it

The six named categories sum to 46.6k against a reported 46k total, and 46.6k + 953.5k free
is the 1m window. **The 18.3k deferred line is therefore inside `System tools`, not additional
to it** — 76% of the reported tool surface.

That number admits two readings with opposite verdicts on item 3, and nothing in the report
separates them:

- **It is what deferral saved** — the schemas that would have loaded and did not. The
  documented claim is then confirmed handsomely.
- **It is what the deferred surface currently occupies.** 23 tool names cost on the order of
  200 tokens, so 18.3k would mean the deferral is not doing what the documentation says, by
  a factor of roughly 90.

**No MCP server is connected in this session** — `/context` reports no MCP category at all,
and `.claude/settings.local.json` enables no plugins. Every deferred tool named here is a
harness built-in. So this reading cannot speak to MCP deferral, which is the surface §4 is
about and the one ADR 0088's second face would use.

## Limitations

- **The MCP path is untested.** Item 3's question is about MCP tool schemas; this session has
  no MCP server. Re-running `/context` in a session with the store's server connected is the
  measurement, and it does not exist to connect yet.
- **The deferred line is ambiguous**, per §4 above, and one reading is a confirmation while
  the other is a refutation. Resolving it needs a second reading — the same session with tool
  search disabled, or a session whose deferred surface is known tool-by-tool.
- **Single reading, no control.** Nothing was varied, so every figure is a fact about this
  session's composition rather than about the mechanism.
- **The 2 KB truncation was not exercised.** No skill description or server instruction here
  approaches it; the largest measured is roughly 380 tokens.
- **`Messages` at 9.2k is this session's own transcript** and says nothing about startup.
- **Version-bound.** The research file already flags tool search as beta-gated and §4 as its
  least durable section; this reading is one harness build on one day.

## Conclusion

**Partially Successful.** Two things are settled and worth carrying forward. **The boot tier
is 3,475 tokens**, which is the standing cost of ADR 0088's push channel and is small enough
that the decision is not in question on cost grounds. And **skills and agents cost a
description each** — about 100 and 80 tokens — so a growing skill surface is cheap at rest,
which is what lets 2.0 contemplate more stages rather than fewer.

The half item 3 was written for is not settled, and the reason is structural rather than a
gap in the method: `/context` reports a deferred figure that its own arithmetic places inside
the tool total, and the two available readings of it disagree about whether the documented
claim holds. **With no MCP server connected, this session was never going to answer it** —
item 3 and item 2 turn out to share a prerequisite that the map records only against item 2.

Item 3 is therefore recorded as measured-in-part rather than closed, and the residue is folded
into the same restart item 2 needs. The research file's instruction to re-verify §4 before
building on it stands un-discharged.

Not promoted. No code was written.
