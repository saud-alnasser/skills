---
aep: 2.0.0
owner: protocol
date: 2026-08-16
use-when: "auditing what the bootstrap must contain, or porting AEP to a runtime whose entrypoint differs"
---

# Template — protocol.md

**You do not write this file.** `protocol.md` is `owner: protocol`, installed
verbatim, and replaced by every upgrade (`[[rules/ownership]]`). This template
records the shape it must hold — so an audit can check it, and so a port to
another runtime knows what the bootstrap is obliged to answer.

## Required shape

```markdown
---
aep: <release>
owner: protocol
date: <YYYY-MM-DD>
kind: protocol
use-when: "at the start of every session, before anything else"
---

# AEP — the Agentic Engineering Protocol

## What AEP is
## The primitives
## Where state is
## How to discover what matters
## The workflow
## The invariants
## Rules that load when they apply
```

Those seven sections are the contract. The bootstrap must answer: what AEP is,
what its primitives are, where state lives, how an agent selects what to read,
what the workflow is, and what holds on every turn.

## The three constraints

**It must stay cheap.** A conforming release keeps it under **8 KB**, asserted by
the verification suite. A bootstrap that costs what it saves is not a bootstrap,
and this is the file every session pays for.

**It routes; it never governs.** It is not a second rules system, a policy
database, or a replacement for rules, contexts, or specs. Governance is
`[[rules]]`, and the bootstrap points at them.

**Nothing restates it.** A runtime entrypoint — `AGENTS.md`, or a runtime's own
equivalent — **points at** this file and never summarises it. A summary in the
entrypoint is a second home, and it is the one that drifts.

## What belongs in it, and what does not

| In the bootstrap | Not in the bootstrap |
| --- | --- |
| what holds on **every** turn | anything conditional — that is a rule with a `use-when` |
| where things live | what any of them say |
| the names of the skills | how any skill works |
| the invariants an agent must never violate | the reasoning behind them |

The test for a line: **would its absence on an arbitrary turn change behaviour?**
If not, it is a rule, and it loads when its trigger fires.
