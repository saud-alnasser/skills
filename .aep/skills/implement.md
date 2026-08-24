---
use-when: "a task exists and is ready to build"
---

# /implement — build the task

Builds tasks that already exist. It reads **the task, not the conversation**, so
context can be cleared between any two.

**`/implement` builds what was planned, or it stops. It never redesigns.**

**Posture.** Correctness over exploration. The interesting decisions were made
in `[[skills/plan]]`; this command executes them and reports when they turn out
to be wrong. Read before you modify, and match what surrounds the code you are
writing. **What this gives up** is creative latitude: an improvement you notice
that is not in the task is raised rather than taken, and the diff stays about
one thing.

## 0 — Position. Every invocation. No exceptions.

This is the command that turns knowledge into code, so a stale belief here
becomes a wrong edit. Run it, and quote it:

```
node .aep/scripts/position.mjs check
```

**This is what fills `Standing` in the turn's opening report**
(`[[policies/reporting]]`): the script's output, then what no script can produce
— the contexts this task touches, and every claim the source contradicted, with
what was corrected.

**Nothing to report is still reported** — a silent check is indistinguishable
from one that never ran.

A marker match licenses skipping the drift read and **nothing else**. Any
statement you are about to rely on is still checked against the source
(`[[policies/authority]]`), and anything found stale is fixed where it is found.

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

**In an external tracker the frontier comes from the recorded query**, which that
tracker's `[[references]]` holds along with what carries the effort. Read the
edges off what the query returns — never by opening every issue and judging from
its prose, which is inference wearing a reading's clothes.

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
   surface it, build nothing** (`[[policies/execution]]`).
2. Load applicable `[[policies]]` and `[[rules]]`, relevant `[[contexts]]`, required
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

   **A task is never split across sub-agents** (`[[policies/execution]]`). A task
   too large for one child is too large — it goes back to `[[skills/tasks]]`.

5. **Build**, matching the surrounding code — idiom, naming, comment density.
6. **Verify each acceptance criterion explicitly**, one at a time, and **quote
   what you ran and what it printed**. "It should work" is not verification.

## 4 — Close out

**A run that dispatched children reconciles before it reviews.**
`[[policies/execution]]` holds what the orchestrator owes once the last child
returns, under `## What the orchestrator owns once the last child returns`, and
that is where to read it.

`[[skills/review]]`, apply the fixes, then land it — **without prompting.**
Landing reviewed work is part of finishing, which is why there is no separate
command to type: by the time the work is reviewed there is nobody left to ask.

Review runs **as a stage of this turn** and opens no report of its own
(`[[policies/reporting]]`). Everything it produces still reaches the human;
only the preamble is not repeated.

### Landing it

**Confirm; do not repeat.** The tests ran, and `[[skills/review]]` ran with an
outcome against every finding — fixed, ticketed, or accepted and recorded. **A
finding still open is a blocker, never a silent pass.** A stage that did not run
is named and the run stops there, saying what would clear it: a refusal the
reader cannot act on is a wall rather than a check.

1. **Mark the task resolved, and the effort `implemented` where this was its
   last criterion** — before staging. Both are tracked, so moving them after the
   commit leaves the tree dirty the moment it lands. Only the status field moves.
2. **Regenerate the index** — `node .aep/scripts/index.mjs`. Here rather than
   earlier, because this is the last point at which the tree is known complete
   and an index regenerated before the final edit is already stale. **Never
   hand-edit one**: `validate.mjs` regenerates and compares, so a hand edit is a
   build failure that names the file.
3. **Write the message by detection.** Read `git log --oneline -30`,
   `CONTRIBUTING.md`, and any pull request template. Where the repository
   demonstrates a convention, follow it silently; `[[rules/version-control]]`
   supplies the default only where the repository is silent, **including which
   form the task reference takes**. Say what capability changed and why, and
   **never give a file-by-file account** — the diff already lists the files.
4. **Commit.** Where landing means resolving a merge or rebase conflict,
   `[[skills/implement/conflicts]]` has the discipline: a conflict is two intents,
   and recovering both is the work.
5. **Stamp the marker** — `node .aep/scripts/position.mjs stamp`. Last, once the
   commit exists, because a commit cannot contain its own hash. **An amend
   produces a new commit, so an amend re-stamps.**

Further changes amend that commit. Never push, never publish
(`[[rules/version-control]]`).

## 5 — When the effort has no unresolved task left

Two judgements that a single task's diff cannot support, so they are asked once
the effort is whole rather than at each commit.

- **Is the effort implemented?** Every acceptance criterion in `spec.md` met, not
  every ticket closed. A ticket can be resolved against a criterion nobody
  checked.
- **Did the change move a boundary, retire a concept, or falsify a `[[contexts]]`
  or a `[[references]]`?** Read the effort's diff entire, which no single task
  ever saw. **What it falsified is corrected in this effort**, so the change and
  the thing it contradicts never land apart. A concept nobody had named is a
  finding to report, never a licence to name it here.

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
