---
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

## One claim, one place

An effort is defined by `spec.md`, what is changing and why, and by `plan.md`,
how it will be built. **Two files, and no claim in both.**

- **A requirement, an acceptance criterion, or a scope boundary lives in
  `spec.md` and is referenced from anywhere else.** A plan restating one creates
  a second place it can change, and the two diverge on the first surprise.
- **Tasks reference the spec; they MUST NOT copy large portions of it.** Every
  task traces to a requirement in `spec.md`, and `[[skills/tasks]]` fails where
  one traces to nothing: that check is what keeps the files honest, rather than
  a rule against having two of them.

*Why the check and not the ban: forbidding `plan.md` kept one claim in one file
by keeping everything in one file, which also meant a reviewer agreeing to the
problem had to read the approach to find it. The duplication was the thing worth
preventing, and it is preventable directly.*

## Return to plan

If evidence discovered during implementation or review invalidates the technical
plan:

```
stop → record evidence → [[skills/plan]] → update spec.md → update tasks → continue
```

**Never** patch the architecture in place and carry on. *Why: this is the moment
implementation becomes an uncontrolled design process, and it always arrives when
the work is nearly done and stopping is most expensive.*

This is one of the **three conditions that may stop a run and reach the human**,
and the only three:

1. evidence invalidates the technical plan, above;
2. the work touches a public contract or data at rest, whose blast radius is
   outside this repository and not recoverable by amending a commit;
3. a task contradicts `spec.md`, which means the tasks were cut wrong.

Everything else a run notices is **recorded and carried to the close, never
raised mid-run**. *Why a fixed set: a run exists so that a human intervenes at
the idea rather than at the implementation, and every condition added here moves
one decision back out of the run. These three are the ones where continuing is
worse than stopping.*

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

## What reaches the tracker, and what does not

**Exactly two objects per effort: one issue and one pull request.** AEP creates
no other tracker object — not per ticket, not per wave, not per review.

| Lives in the tracker | Lives in the repository |
| --- | --- |
| the issue, whose body is `spec.md` | `spec.md` and `plan.md` themselves |
| the pull request, carrying the approach, the tickets, and the run log | the tickets, under `efforts/<effort>/tickets/` |
| labels, as a projection of what those files say | the dependency graph, as `blocked-by` |

**A ticket is never a tracker object, and the dependency graph never leaves the
repository.** *Why: the graph is read on every scheduling pass, and a graph
living in a tracker is one an agent has to fetch, paginate, and interpret before
it can compute a frontier. Local, it is a field in a file that a script reads.
The tracker gains nothing from holding it: nobody schedules by hand.*

*Why one issue rather than one per ticket: an effort is what a human agreed to,
and it is the unit they review and merge. Fifteen issues for one change is
fifteen things to close and one thing nobody can see the shape of.*

**The tracker is read, and never mirrored into `.aep/`** — a local copy of a
tracker object is exactly the hidden database this protocol does without, and it
disagrees with the original the moment one is written and the other is not.

**A tracker write to shared data is proposed before it happens**, with exact
strings rather than a summary, because it lands in other people's workspace.

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

**The child writes the question plainly and the orchestrator presents it.** A
child records what it is asking and what the options are, under no obligation
beyond being clear; the orchestrator puts it to the human in the form
`[[policies/reporting]]` governs. The child does the work it can do, and what it
cannot do is the parent's.

- **Wording may be reshaped. Substance never is.** What is being asked, and which
  options are offered, survive unchanged. A presentation that drops an option,
  merges two, or narrows the question is a different question wearing the child's
  name.
- **Attribution names the source, not the author of the words.** The question is
  the child's and the task's; the phrasing the human reads is the orchestrator's.

*Why this runs the opposite way to the answer above: an answer carries the
human's authority and a question does not, so an answer may not be touched and a
question may not be left unreadable.*

## Returning, and integrating

A child returns one of four outcomes — **done, failed, stopped, waiting** — plus
a path to what it produced and a compressed summary. Never a pasted diff.

**What a child returns is capped**, and the cap is on the return rather than on
the work: a child may read a thousand files and must hand back something whose
size does not depend on how many. *Why: an orchestrator running a whole effort
grows by one return per task, so an uncapped return makes the orchestrator's
context a function of the work inside every task rather than of the number of
them — and it degrades silently, which is the failure that writes a confident
close over work it has forgotten.*

The orchestrator **reconciles what the child claims against what it actually
changed** before anything lands. A manifest that cannot be trusted still reads as
a check that happened.

**Each child is integrated as it returns, one at a time.** Not the batch at the
end: a conflict then arrives as one pile with no task to name it, and what gets
untangled is whichever child happened to be second. Integrated per task, a
conflict surfaces at that task's integration and is named against that task.

**The orchestrator is the only integrator.** A child works in its own worktree
and never merges into the shared branch, because two children integrating
themselves produce a conflict neither of them can see.

Because the unit is a whole task, one child failing costs exactly that task: its
siblings land, and it returns to the frontier.

## What the orchestrator owns once the last child returns

Reconciling a claim against a diff is an honesty check, and it is not the same as
making the result coherent. **Three things a child structurally could not do are
the orchestrator's**, and none of them is delegated downward.

**The seams**, where children's diffs meet: naming that drifted between them, a
helper two of them wrote, a pattern one followed and another did not.

> **The seam is the bound.** A surface two or more children touched, or a name one
> introduced and another consumed, is the orchestrator's to reconcile. Anything
> else it notices inside one child's work is **raised, not taken**, and returns to
> the frontier as a task.
>
> *Why the bound is drawn at the diffs rather than at the effort: a bound read off
> `spec.md` cannot distinguish reconciling a seam from rebuilding a task a child
> already delivered, and the orchestrator is the one agent with no reviewer above
> it.*

**Every decision a child recorded and stopped on.** A child has no surface on
which to ask, so the orchestrator raises it, in the form the section above fixes.

**One account of the work**, written as though one agent had done it in sequence
rather than each child's summary concatenated.

> It **describes the work rather than the workers.** Sub-agent structure surfaces
> where it changed the outcome: a child that failed, a child that stopped on a
> decision the human must make, a task that returned to the frontier. Those land
> in the slots the closing block already has.
>
> **This is not permission to suppress a failure.** A fan-out that lost a task
> changed the outcome by definition, and the reading under which the machinery is
> hidden unconditionally is the one this rejects.

That account is text a human reads, so `[[policies/reporting]]` governs how it is
written.

## The run's memory is the pull request

**The session is disposable. Nothing the run needs lives only in its context.**

A run over a whole effort outlives the session that started it. It will cross a
compaction boundary, and it may be killed and re-invoked. Neither stops it,
because everything it needs is written down as it goes.

### Where each thing lives

| What | Where it is durable |
| --- | --- |
| which tickets are done | commits on the effort branch |
| which criteria of a ticket are verified, and what verified each | **ticked checkboxes in the pull request body**, inline |
| the ledger, the converge round, review attempts per ticket, items recorded but not acted on, anything a child raised that was not a trip-wire | a **collapsed run log section** of the pull request |

**The orchestrator writes the run log as the run proceeds**, not at the end. A
record written at the end is a record that does not exist for the failure it was
meant to survive.

**A failed write to the run log is a defect to report**, named and surfaced. It
is never a silent continue: a run that carried on after losing its memory is a
run that will later write a confident close over work nobody can find.

### Ticking a criterion

**A criterion's checkbox is ticked by `[[agents/reviewer-correctness]]`**, which
already judges each requirement and each acceptance criterion against the diff.
It is ticked **at the moment it is verified**, carrying inline what verified it.

**The agent that wrote the code never ticks its own criteria.** *Why: a tick is
the claim that somebody checked, and a claim checked by its own author is the
thing the whole review axis exists to not be. It is also what makes resumption
safe — a resumed run trusts a tick without re-deriving it.*

### Resuming

A resumed run reconstructs its position from the pull request, the issue, and
the repository, **and from nothing else.** It **re-verifies nothing already
ticked, and trusts nothing that is not.**

**The tracker is read. It is never mirrored into `.aep/`.** A local copy of the
run log is exactly the hidden database this protocol does without, and it
disagrees with the original the moment one is written and the other is not.

### Compaction

**Auto-compaction is harmless and the run does not stop for it.** The summary
loses whatever it loses; the run continues correctly because the pull request
holds what it needs.

***No AEP mechanism may depend on triggering compaction.*** An agent cannot
invoke it. It is a command the human types, or a harness behaviour firing on its
own schedule and choosing its own survivors, so a design that waits for it is
waiting on something it does not control.

## Converge decides when the effort is done

**An exhausted ticket list and a satisfied spec are different claims.** Tickets
are a map of the work, drawn before the work was done, and a map that runs out
is not the territory being covered. So when no unresolved ticket remains the run
**converges**: it assesses the codebase against `spec.md` and `plan.md`, and
where the spec is unmet it appends the remaining work as tickets and carries on.

**The effort is complete when a converge round finds no gap.** Not when the
tickets run out.

### Not built, or does not work

Converge separates two findings that look identical from inside one diff:

| What converge found | What it does |
| --- | --- |
| **work that was not built** | appends tickets, and the run continues |
| **an approach that cannot satisfy a requirement** | stops on the return-to-plan trip-wire, above |

**Converge never builds around the second.** A gap that keeps reappearing
because the design cannot close it is the plan being wrong, and appending a
ticket against it buys another round of the same failure while looking like
progress. *Why this line matters more than it reads: autonomy below the plan is
what a run is for, and converge is the one stage positioned to quietly acquire
autonomy above it. `[[policies/engineering]]`'s prohibition on silently deciding
architecture is what it would be evading.*

### It appends. It never edits

**Converge MUST NOT edit `spec.md` or `plan.md`.** It writes tickets and nothing
else.

*Why: converge is the last thing running before the work is handed over, and it
is the only stage with both the whole diff in view and nobody reviewing it. A
converge that could edit the spec would be able to close every gap it found by
narrowing what the spec asked for, and the run would end green having quietly
agreed with itself. A spec that turns out to be wrong is a return-to-plan event,
which reaches the human.*

### Two rounds

**Converge runs at most twice per effort.** Converge, build the gap, converge
again. Past that the remaining gaps are named at the close and in the tracker,
and the run ends rather than grinding.

*Why two, and why not configurable: a third round finding new gaps means the plan
was wrong rather than the work incomplete, and that is the return-to-plan
trip-wire rather than more rounds. A configurable cap is a number nobody can set
correctly until a run has already gone wrong.*

### The two judgements a single diff cannot support

Both are asked once the effort is whole, because neither is visible from one
ticket:

- **Is the effort implemented?** Every acceptance criterion in `spec.md` met —
  not every ticket closed. A ticket can be resolved against a criterion nobody
  checked.
- **Did the change move a boundary, retire a concept, or falsify a
  `[[contexts]]` or a `[[references]]`?** Read the effort's diff entire, which no
  single ticket ever saw. **What it falsified is corrected in this effort**, so
  the change and the thing it contradicts never land apart. A concept nobody had
  named is a finding to report, never a licence to name it here.
