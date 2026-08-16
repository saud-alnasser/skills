---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
mode: [implement, review, research]
use-when: "dispatching sub-agents, or running as one"
---

# Rule — sub-agents

Applies only where the runtime supports sub-agents. Where it does not, the work
is serial and nothing here binds.

## The unit is a whole task. Always.

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

Parallelism MUST NOT compromise the rules, the specification, repository
integrity, or acceptance criteria.

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
