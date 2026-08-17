---
aep: 2.2.0
owner: protocol
date: 2026-08-17
use-when: "defining a way of working, where the eight shipped modes do not fit"
---

# Template — mode

Copy to `modes/<name>.md`. **Adding a mode is rare** — the eight shipped modes
cover the activities the spine performs, and a ninth means either a genuinely new
activity or, far more often, a skill that should have entered an existing mode.

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: mode
mode: [<name>]
use-when: "<the activity this posture is for>"
---

# Mode — <name>

**Objective.** What this way of working is trying to achieve.

**Mindset.** How to reason while in it. Priorities, and what to be suspicious of.

**What this gives up.** Required. See below.

**Inputs.** What this mode reads.

**Outputs.** What it produces.

**Constraints.** What it must not do.

**Reach for.** The skills and references this mode typically pulls in.
```

## A mode that gives up nothing is not a mode

This is the whole test. A mode establishes priorities, and priorities are only
real when something loses. "Careful and thorough and fast" describes an
aspiration, not a posture — and it gives an agent nothing to trade away when the
two conflict, which is the only moment the mode was going to be useful.

State the cost plainly: *research gives up speed and the comfort of a confident
answer; prototype gives up maintainability and the code itself.*

## Mode is not workflow

A mode says **how to think**, never **what steps to run**. Steps belong to a
skill. Where a mode and a skill would be the same text, the skill is the one that
exists and the mode carries only the thinking.

And `mode:` on any other artifact is **applicability** — *this is relevant while
working that way* — never a statement that the agent is in that mode.
