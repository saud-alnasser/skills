---
use-when: "writing a local task under efforts/<effort>/tickets/"
---

# Template — local task

Copy to `efforts/<effort>/tickets/<NN>-<slug>.md`, but **only where this
repository has no external tracker.** AEP never mirrors an external system.

A task is **a whole unit of work with its own acceptance criteria** — that is
also the unit a sub-agent may be given, and the reason a task is never split
across several (`[[policies/execution]]`).

```markdown
---
status: open             # open → resolved, or obsolete
blocked-by: [<task-id>, ...]   # omit when nothing gates it
---

# <type(scope): summary>

## Outcome
What is true when this is done. One paragraph.

## Acceptance Criteria
- [ ] Traceable to a criterion in [[efforts/<effort>/spec]]. Checkable.

## Relevant areas
Paths and modules this touches. Where to start reading — not a claim about what
is there.

## Constraints
Anything the implementer must respect that the spec does not already say.

## Notes
Findings accepted, decisions recorded, or anything a later reader needs.
```

**Reference the spec; never copy it.** A task restating the architecture creates
a second place it can change, and the two diverge on the first surprise.

**A task nobody could execute without asking a design question is not finished
being written.**

A task that turns out to be already done, or no longer needed, is marked
`obsolete` **with a one-line reason** — never deleted, because deleting loses the
reason it existed, and never left `open`, because it will eventually be claimed.
