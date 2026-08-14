---
owner: repository
title: "docs(protocol): settle what stays push when everything else becomes pull"
status: resolved
blocked-by: [01]
part-of: substrate
type: grilling
---

## Question

What is the exact membership of the boot tier under 2.0?

The harness is the only push mechanism: it loads the entrypoint and the
unconditional rules before any protocol logic runs. Everything a tool serves is
pull, reached only once the model decides to reach. `ADR 0075` selects boot-tier
membership by one test — would this norm's absence on a turn cause behavioral
drift — and that test was written when the alternative was a pointer, not a tool.

Settle:

- Whether the drift test still selects the right set when the alternative is a
  tool call rather than a file read, and whether it needs restating.
- What is irreducibly push: the entry classification, verification at use, the
  no-ask rule, and the fixed-owner rule are the current members — does each
  still earn it, and does anything join them.
- How a session behaves when the tool is unavailable and only the boot tier
  loaded. Under 2.0 this is no longer a plugin-less teammate reading markdown;
  it is a live session with half a protocol, which is a worse failure than
  either 1.x state and needs a designed answer rather than an assumed one.
- Whether the path-scoped rules tier survives, given `paths:` frontmatter is a
  filesystem mechanism the harness owns and a store cannot replace.
- What the entrypoint holds when it is the only thing read directly, and whether
  the 200-line ceiling still binds.

## Answer

`01` found five delivery channels rather than two, and they differ on failure
rather than on cost: harness push (re-injected from disk at compaction, cannot
fail), MCP server instructions (≤2 KB, only once the server connects), an
`mcp_tool` hook on `UserPromptSubmit` (per user prompt, and a failure is
**non-blocking with execution continuing past it**), `` !`command` ``
preprocessing at skill invoke, and a model-chosen call.

**The always-on core stays on harness push.** It is the only channel documented
to survive compaction by re-injection and the only one that cannot fail
silently. A stdio server is never reconnected once it dies and a failed hook
does not stop anything, so a core delivered by hook could leave a session
running with no norms and nobody told — the exact failure shape this effort
exists to remove, reintroduced at the foundation.

**Accepted cost, stated rather than discovered:** the core alone keeps the
copied-file apparatus — version stamps and byte-locking — that ADR 0084
dissolved everywhere else. `09` must keep it alive for that one small set.

**The core gains two members 1.x had no need for:**

- **How to reach the store.** Nothing else can tell a session it exists. This
  cannot ride the server's 2 KB of instructions, because those arrive only once
  the server connects — a session whose server never came up would not know
  there was a store at all.
- **What to do when the store is unreachable.**

**When the store is unreachable the stage rebuilds the index and continues.**
That forces the store to have **two faces over one derived index** — an MCP
server for the fast path and a CLI for the fallback, which also gives CI a way
to query it. What died is the server, not the machine, so a stage runs the
rebuild as a derived script step and quotes its output, the shape ADR 0078
already sanctions as computed rather than judged. Stopping the stage was
rejected: it is a self-inflicted outage while every file sits readable on disk.

**The path-scoped tier survives as a pointer only.** A path-scoped rule holds
nothing but a pointer to query the store for norms whose `fires-when` is that
path; the harness keeps doing the one thing only it can, which is noticing that
a covered file was touched. **The compaction hole narrows without closing** —
`01` established that path-scoped rules are lost until a matching file is read
again, so between a compaction and the next matching read nothing fires. That
is a real remaining hole and it is not fixable from inside AEP.

**The drift test survives unchanged.** *Would this norm's absence on a turn
cause behavioral drift* still selects harness membership; after these decisions
only two things are harness-carried and the test separates them cleanly, so it
does not become a three-way channel question.

**The 200-line entrypoint ceiling still binds**, and is tighter in practice: the
core carries the classification rule, verification at use, the no-ask rule, the
fixed-owner rule, and the two new members above.

Recorded as ADR 0088.
