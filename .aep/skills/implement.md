---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: skill
mode: [implement]
use-when: "a task exists and is ready to build"
---

# /implement — build the task

Builds tasks that already exist. It reads **the task, not the conversation**, so
context can be cleared between any two.

**`/implement` builds what was planned, or it stops. It never redesigns.**

**Enters `[[modes/implement]]`.** Read it and hold its tradeoffs.

## 0 — Position. Every invocation. No exceptions.

This is the command that turns knowledge into code, so a stale belief here
becomes a wrong edit. Open with the report, quoted from the script:

```
node .aep/scripts/position.mjs check
```

```
Position
  marker  a3f91c2  HEAD 8b2d417   14 commits ahead
  tree    9f1d2af  live 3a1c802   tree differs

  contexts touched by this task: database
  1 claim contradicted by source:
      "migrations are transactional" — they are not. corrected.
```

**Everything above the blank line is the script's output.** Everything below is
yours, and no script can produce it. **Nothing to report is still reported** — a
silent check is indistinguishable from one that never ran.

A marker match licenses skipping the drift read and **nothing else**. Any
statement you are about to rely on is still checked against the source
(`[[rules/precedence]]`), and anything found stale is fixed where it is found.

## 1 — Take the work

```
frontier = tasks open, unblocked, unclaimed
```

| The invocation | The unit |
| --- | --- |
| **named a task** | that task, alone. Never joined by others — taking a second is choosing work you were not given |
| **named nothing** | the **set**: every frontier task that no `blocked-by` edge orders against the others |

Computing a set from declared edges is reading a declaration, not writing one.
**The set is exactly what the edges permit — never widened, never reordered.** A
task that *looks* independent is not a member unless the edges say so.

Where the tasks live is this repository's business — an external tracker, or
`efforts/<effort>/tickets/`. Read `[[references]]` rather than assuming.

If the frontier is empty, **say so rather than inventing work.** If everything
left is blocked, name what blocks it. If the invocation carried a *request*
rather than a task, go to `[[skills/specify]]` — do not hand back a command for
the human to type.

A task already done, or no longer needed, is marked `obsolete` **with a one-line
reason**. Stop there; do not manufacture work to fill it.

## 2 — Claim it

**The claim is the branch, and creating it is the first act of the run** — before
the first read of source, and long before the first edit. A claim made after the
first edit is a report of a race already lost.

```
<task-id>-<slug>            17-assignment-and-claim
```

Check both sides before creating — a local branch of that name, and the remote
(fetch first, or the answer is stale). **A claim held elsewhere is never taken:**
not renamed around, not branched from, not force-created over. Report which task,
which branch, and where the claim was seen, then move to the next.

Where the repository has its own branch convention, that one wins
(`[[rules/version-control]]`).

**Dispatching a set: create every branch first, then dispatch.** The parent holds
the whole set before any of it is worked. State the plan — which tasks, which
role, which branches — before creating anything. Stated, not gated.

## 3 — Build

1. **Read the task and the effort's `spec.md`.** Where they conflict: **stop,
   surface it, build nothing** (`[[rules/change-control]]`).
2. Load applicable `[[rules]]`, relevant `[[contexts]]`, required
   `[[references]]` — by `use-when` and `paths`, never everything.
3. **Read the code you are about to change.** All of it.
4. Choose the shape:

   | Situation | Do this |
   | --- | --- |
   | one task | build it here |
   | a set of tasks, no edges between them | dispatch `[[agents/implementer]]` — **one child per whole task**, one worktree each. `[[skills/implement/dispatch]]` is how to write the brief |
   | a set of one | build it here; a child would spend a whole context on work you are already positioned to do |
   | rules require test-first, or a bug needs pinning | `[[skills/tdd]]` |
   | the task is a bug and the cause is not known | `[[skills/implement/diagnosing]]` — build the signal before the theory |
   | technical uncertainty survives | `[[skills/prototype]]`, in a worktree |

   **A task is never split across sub-agents** (`[[rules/sub-agents]]`). A task
   too large for one child is too large — it goes back to `[[skills/tasks]]`.

5. **Build**, matching the surrounding code — idiom, naming, comment density.
6. **Verify each acceptance criterion explicitly**, one at a time, and **quote
   what you ran and what it printed**. "It should work" is not verification.

## 4 — Close out

`[[skills/review]]`, apply the fixes, then `[[skills/commit]]` — **without
prompting.** Committing reviewed work is part of finishing. Then mark the task
resolved. Further changes amend that commit; nothing is pushed.

## Constraints

- **Stay bounded by the task.** An improvement you notice is **raised, not
  taken.** The diff stays about one thing.
- **Return to plan** the moment evidence invalidates the approach: stop, record
  the evidence, `[[skills/plan]]`, update `spec.md`, update tasks, continue.
  Pushing through is how implementation becomes design — and it always arrives
  when stopping feels most expensive.
- Never push, never publish (`[[rules/version-control]]`).
- Prototype code is never promoted as-is. Rewrite what survives.

## Resuming after losing context

Read the branch you are standing on: it names the task, the task says what done
looks like, and the diff since the branch point says how far you got. **A
detached HEAD names no branch and holds no claim** — do not guess the task from
the diff; claim one properly or hand back.

## Done when

Every acceptance criterion has been checked and the check was shown, the tests
the rules require pass, nothing outside the task changed, and the task's status
reflects reality.
