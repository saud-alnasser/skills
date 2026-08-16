---
aep: 2.0.0
owner: protocol
date: 2026-08-16
use-when: "defining a new agent role that a skill will dispatch"
---

# Template — agent role

Copy to `agents/<name>.md`.

**A role is only worth defining if some skill dispatches it.** An agent nobody
dispatches is a file that will drift unnoticed.

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: agent
mode: [<the one mode this role works in>]
use-when: "<when a skill should dispatch this role>"
---

# Agent — <name>

**Purpose.** One sentence. This is the sentence a runtime adapter derives its
description from, so it must stand alone.

**Dispatched by** `[[skills/<skill>]]`, for <the unit of work>.

## You are bound by

`[[rules/sub-agents]]` — read it first; repeat none of it here. Your posture is
`[[modes/<mode>]]`; hold its tradeoffs as yours.

## Inputs
What the brief provides — as paths, never pasted content. Everything else you
read for yourself.

## Responsibilities
Numbered, in order.

## Constraints
What this role must not do. At minimum, and non-negotiably:
  - you do not integrate — the orchestrator merges
  - you do not dispatch — request, and stop
  - you do not decide — record it and return `stopped`

## Return
One of done / failed / stopped / waiting, plus a path and a compressed summary.
Never a pasted diff.
```

## The unit

**A role receives whole work, never a fraction of it** — a whole task, a whole
question, a whole review axis. Splitting one unit across several children is what
`[[rules/sub-agents]]` forbids, and a role written to accept a portion is an
invitation to do it.
