---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: policy
use-when: "an effort is in progress — deriving tasks, dispatching, implementing, or reviewing"
---

# Policy — executing an effort

What governs the work between an accepted spec and a landed change, including
how it is divided across sub-agents.

## The hierarchy

```
spec.md  →  tasks  →  implementation
```

`spec.md` is the effort's source of truth. **A task that conflicts with the spec
is a defect in the task.** Stop, surface the conflict, and do not silently modify
the architecture to make the task work.

*Why: a task that quietly wins over the spec means the delivered system is
defined by whichever artifact was edited last, and nobody agreed to that one.*

## One spec file

The effort has exactly one durable definition, and it is `spec.md`.

- **NEVER create `plan.md`.** Planning extends the same file with Architecture,
  Components, Interfaces, Data Model, Technical Approach, Integration, Migration,
  Testing Strategy, Operational Considerations, Technical Risks.
- Tasks reference the spec; they MUST NOT copy large portions of it.

## Return to plan

If evidence discovered during implementation or review invalidates the technical
plan:

```
stop → record evidence → [[skills/plan]] → update spec.md → update tasks → continue
```

**Never** patch the architecture in place and carry on. *Why: this is the moment
implementation becomes an uncontrolled design process, and it always arrives when
the work is nearly done and stopping is most expensive.*

## Scope stays where it was put

- `[[skills/plan]]` and `[[skills/refine]]` MUST NOT silently expand product
  scope. Technical discovery that exposes a product-level change **stops and
  surfaces it**.
- `[[skills/implement]]` stays bounded by the effort. An improvement you notice
  that is not in the task is raised, not taken.
- Requirements nobody asked for are a review finding, exactly like requirements
  missed.

## Done means checked

A task is done when its acceptance criteria have been **verified explicitly**,
one at a time, against the running system. Not when the code looks right.

## Sub-agents: the unit is a whole task. Always.

Everything below applies only where the runtime supports sub-agents. Where it
does not, the work is serial and none of it binds.

**A task is never split across sub-agents.** One child builds one whole task
against that task's own acceptance criteria, or no child is dispatched at all.

*Why: a task divided into portions has to be divided by something — file
ownership, layer, guesswork — and every one of those is a promise the task graph
never made. The portions then have to be integrated by a parent holding partial
work from several contexts, where one child failing means nothing lands. A whole
task is the smallest unit that already has acceptance criteria, already has a
branch, and already fails alone.*

So:

- **Dispatch whole tasks, or dispatch nothing.**
- A task too large for one child is **too large**, and returns to
  `[[skills/tasks]]` to be split into real tasks with real criteria — not
  quietly divided at dispatch time.
- Findings, reviews, and research are dispatched the same way: one child, one
  whole question.

## Independence is read, never inferred

Parallelism follows **explicit independence declared in the task graph**.

```
A → B          serial: B declares blocked-by A
A ─┐
   ├→ C        A and B may run concurrently
B ─┘
```

**Never infer independence from a guess about which files will be touched.** An
edge gates work; it says nothing about files, and two independent tasks may still
collide on one path. Where isolation cannot be guaranteed, serial is correct and
cheaper than reconciling the collision.

The set of tasks to dispatch is **computed from the declared edges, not chosen**:
the frontier tasks that gate none of each other. Computing a set from a
declaration is not making one.

Parallelism MUST NOT compromise governance, the specification, repository
integrity, or acceptance criteria.

## Where the tasks are not in this repository

Tasks may live in an external tracker, and **AEP never mirrors one into `.aep/`**
— a local copy of an external ticket is exactly the hidden database this protocol
does without. So the facts the tree would otherwise have held are held **by the
tracker**, in a form the tracker can answer.

**An external task MUST be attributable to its effort by a query the tracker
answers natively** — never by listing every open issue and judging from prose.

*Why: the frontier above is computed from declared edges. An agent that cannot
ask which issues belong to this effort has no graph to read, so the rule against
inferring independence stands with nothing behind it — and the cheapest way to
satisfy it becomes working serially and saying nothing.*

**Exactly one fact is required: which effort the task belongs to.** Two others
are deliberately excluded, and both exclusions are load-bearing:

- **`status` is not carried separately.** The issue's own state already says open
  or resolved. A second copy disagrees with the first the moment somebody closes
  an issue from the tracker's own interface.
- **A dependency edge is not carried as set membership.** Belonging to a group
  and waiting on another task are different claims. A `blocked-by-42` marker has
  to be removed by somebody when 42 closes, and nothing in the tracker knows to
  do it — so it is wrong exactly when it matters.

**What the tracker already models, the tracker carries.** Where a first-class
feature answers the fact, that feature answers it, and nothing is created beside
it. What is native differs per tracker, so it is established per tracker and
never assumed.

**None of this is mirroring.** The fact stays in the tracker, expressed in the
tracker's own mechanism, read by the same people and tools that already read it.
Nothing about the task is written into `.aep/`.

## Claiming, before dispatching

**The branch is the claim, and the parent creates every branch in the set before
dispatching anything.** A branch created after its child started is a claim made
after the race it existed to win.

A claim held elsewhere is never taken — not renamed around, not branched from,
not force-created over. Report it and move to the next task.

## What a child gets, and what it does not

A child receives a **brief**: its objective, its inputs **as paths rather than
pasted content**, the task it owns, its worktree, the shape of what it returns,
its done criteria, and a cap.

- Anything a child needs from the *conversation* goes in the brief — the brief is
  the only parent-to-child channel.
- Everything else it **reads for itself**. Quoting an AEP artifact into a brief
  spends the parent's context to buy nothing; a child can read.
- A child works in an isolated worktree. **The orchestrator is the only
  integrator** — a child never merges into the main checkout.
- **One layer.** A child does not dispatch. Where it needs a capability that
  requires dispatch, it requests it, the orchestrator performs it at depth one,
  and the result returns. The menu of what a child may request is closed — a
  capability requiring dispatch, and a question for the human. *Why: an open
  channel makes every prohibition on a child advisory.*

## Human authority is never delegated downward

A sub-agent has no surface on which to ask a human, and **no agent's message is
another agent's consent.**

- A child that reaches a decision it may not make **records it and stops.** The
  orchestrator raises it.
- Work *known* to need a human decision is never assigned to a child.
- Where the orchestrator can put the question to the human, the child stops
  *pending an answer* rather than failing. The question travels attributed to the
  child and the task; **the answer travels verbatim.** An orchestrator that
  cannot relay faithfully stops the child instead of paraphrasing. *Why: a
  paraphrase is the orchestrator's answer wearing the human's authority, and the
  child cannot tell the difference.*

## Returning, and integrating

A child returns one of four outcomes — **done, failed, stopped, waiting** — plus
a path to what it produced and a compressed summary. Never a pasted diff.

The orchestrator **reconciles what the child claims against what it actually
changed** before anything lands. A manifest that cannot be trusted still reads as
a check that happened.

Because the unit is a whole task, one child failing costs exactly that task: its
siblings land, and it returns to the frontier.
