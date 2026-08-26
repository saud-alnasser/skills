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
| the pull request, carrying the approach, the tickets, and the run log | the tickets, under `.aep/efforts/<effort>/tickets/` |
| labels, as a projection of what those files say | the dependency graph, as `blocked-by` |

**A ticket is never a tracker object, and the dependency graph never leaves the
repository.** *Why: the graph is read on every scheduling pass, and a graph
living in a tracker is one an agent has to fetch, paginate, and interpret before
it can compute a frontier. Local, it is a field in a file that a script reads.
The tracker gains nothing from holding it: nobody schedules by hand.*

*Why one issue rather than one per ticket: an effort is what a human agreed to,
and it is the unit they review and merge. Fifteen issues for one change is
fifteen things to close and one thing nobody can see the shape of.*

**Where the repository has a tracker, both objects are required**, and each links
to the effort in both directions: the effort directory is named for the issue
number, and both bodies name the effort's path. A run finding a tracker and an
effort short of either object **opens what is missing and says so**.

*Why this is stated rather than left implied: having no tracker is a real posture
with its own procedure below, and an implied requirement makes that posture
reachable by not asking. A run that never looked would land in the smaller shape
with nothing to contradict it, and the effort would be half of what the protocol
describes.*

### Where there is no tracker

**The effort is a branch, and merging it is the human's.** No issue, no pull
request, no tracker call at all. The number comes from a local counter, and the
run's durable record is the repository:

| Read | To recover |
| --- | --- |
| commits on the effort branch | which tickets landed |
| ticked criteria in the ticket files | what is verified, and what verified it |
| `spec.md`'s `status:` | whether the effort closed |

The close is the same close with its second half absent: `spec.md` is stamped
`implemented` and the run stops there, because there is no draft to mark ready
and no labels to move. **The runner never merges — with a tracker or without.**

*Why this needs saying: every step that closes an effort was written against a
pull request, so a repository without one was not losing a projection, it was
losing the run's memory. It has one only because tickets are local files — the
ticks are in the repository already, and were being projected rather than
stored.*

**The tracker is read, and never mirrored into `.aep/`** — a local copy of a
tracker object is exactly the hidden database this protocol does without, and it
disagrees with the original the moment one is written and the other is not.

**A tracker write to shared data is proposed before it happens**, with exact
strings rather than a summary, because it lands in other people's workspace.

## Labels are markings, never state

**`spec.md` and `plan.md` are what the effort is. A label is a projection of
them onto the tracker**, so that somebody scanning a list sees what the files
say without opening either. **Where a label and the file disagree, the file
wins** (`[[policies/authority]]`) and the label is corrected — never the
reverse, and never by editing the file to match a label somebody changed.

A repository with no tracker has nothing to project onto, and what it does
instead is above.

### Derived, and initial

Every label AEP sets is one or the other, and the two are maintained
differently. **Getting this backwards is how an agent overwrites a human.**

| | Set | Then |
| --- | --- | --- |
| **derived** | from a file or a diff | **re-synced on every write** to the issue or the pull request |
| **initial** | once, when the effort is opened | **never updated by an agent**, and a human's change to one is never overwritten |

**Derived:** `status:` from the spec's state, `type:` from what the spec
describes, `size:` from the diff, and every flag a fact establishes.

**Initial:** `priority:`, and any flag that invites another person to act.

*Why the split rather than one rule: a derived label restates something the
repository already says, so re-syncing it can only correct drift. An initial
label states a judgement the agent is not the authority on, and re-syncing that
overwrites the human who is.*

### What projects onto what

`status:` is the family AEP requires, because it is what the effort's own state
projects onto. A repository whose vocabulary differs records the mapping in its
forge `[[references]]` rather than adding a second vocabulary beside its own.

| The effort | Issue | Pull request |
| --- | --- | --- |
| the spec is being drafted | `status: backlog` | `status: backlog` |
| the spec is accepted and the tickets are cut | `status: ready` | `status: ready` |
| the runner is working | `status: in progress` | `status: in progress` |
| converge found no gap, and the spec is stamped `implemented` | `status: in review` | `status: in review` |
| merged | closed by the pull request | `status: done` |

**`size:` is computed from the diff** when the pull request goes ready for
review, against the thresholds the repository's own label descriptions state. A
size label whose thresholds live somewhere else is one nobody can check.

**A flag with no fact behind it is not set.** `breaking changes` comes from the
public-contract trip-wire, `dependencies` and `release` from the diff,
`discussion` while the spec carries open questions, `triage` on a fresh draft,
`confirmed`, `unconfirmed`, and `cant reproduce` from a diagnosis, and `wontfix`
when an effort is abandoned.

### The vocabulary is the repository's

**AEP sets every family — `status:`, `type:`, `size:`, `priority:`, `flag:` —
using labels that already exist here.** It reads the list before naming
anything, and a new label matches the separator, the casing, and the prefixing
already in use.

**Creating a label is reported, with the reason.** A label that appears in a
tracker with no explanation is one nobody can tell from a mistake.

**No label AEP sets names AEP.** A tracker is read by people who never installed
it, and a vocabulary that advertises its tooling has stopped describing the
work.

## Claiming, before dispatching

**The branch is the claim, and the parent creates every branch in the set before
dispatching anything.** A branch created after its child started is a claim made
after the race it existed to win.

**A run claims the working surface it writes through as well as the branch it is
on, and a worktree is how it holds one.** The two are not one guarantee. A branch
says which work is whose; a worktree is what stops a second run from writing
through the same tree. A run holding only the first identifies its work correctly
and can still have another run move the checkout under it between a read and a
write, which is a claim that reports itself as intact while being violated.

So **where the isolation is `checkout`, the run takes a worktree of its own
before its first write, and creates its effort branch into it.** Where the
isolation is `worktree`, the runtime already gave it one and it takes no second.
That decision is keyed on the isolation's kind and **never on its enforcement**:
enforcement describes the clone rather than this checkout, so a run keying on it
declines a surface in exactly the case that needs one.

**Releasing that claim and removing the surface are separate acts.** The run
detaches the worktree, which frees the branch at once for whoever reviews it, and
removes the directory separately. A surface kept after a failure therefore holds
no branch, and a run that died cannot lock an effort against its own resumption.

**The isolation's kind decides whether a run takes a surface. The role that
surface carries decides what the run may do once it holds one**, and the same
read reports both — computed from git and from the path of the tree, never
judged and never inferred from what the branch is called. Reporting the role
refuses nothing by itself, exactly as reporting the isolation does. What follows
from it is here.

| `role` | Read in | May | MUST NOT |
| --- | --- | --- | --- |
| `orchestrator` | the effort's own surface, or one the runtime supplied | integrate, and dispatch a child per task | integrate anywhere but the surface it holds |
| `implementer` | a ticket's surface under an effort | build the one ticket it was given, and request what it may not do itself | integrate into the effort branch, or dispatch |
| `none` | the main checkout | take a surface | write anything before it has taken one |
| `unknown` | a tree matching no row above | everything it could already do | — |

**A run computing `role: implementer` neither integrates nor dispatches.** That
is the pair a child's brief already carries, and keying it to the role is what
makes it outlive the brief: a child whose context was cleared reads where it is
standing and derives both again. **A run computing `role: orchestrator`
integrates only in the surface it holds**, which is the rule below about the only
integrator, keyed on something a run can check rather than on remembering it.

**`role: none` is not a missing answer.** It is the main checkout, and it is
exactly the state the isolation rule above requires a run to act on before its
first write: take a surface, create the effort branch into it, and the role
reads `orchestrator` because the run now holds one. A run that reads `none` and
writes anyway has skipped the claim rather than found a hole in it.

**`role: unknown` fires nothing.** Where the tree matches no known surface, every
rule keyed on the role declines and the run proceeds exactly as it would have.
*Why it fails open: a derivation that narrows on a wrong answer blocks correct
work in a tree that plainly has a role, and nothing downstream can tell that
refusal from a real one.*

A claim held elsewhere is never taken — not renamed around, not branched from,
not force-created over. Report it and move to the next task. **That now covers a
surface as well as a branch:** a worktree another run holds is not entered.

**The claim is read before the work, and it is computed rather than judged.**

```
node .aep/scripts/scope.mjs read
```

Quote what it prints. **Never infer the claim from what the branch is called:**
naming belongs to the repository (`[[rules/version-control]]`), and under a
runtime that opens a thread per branch it belongs to the runtime, which
generates one. The name is the signal that may say nothing.

| | Is |
| --- | --- |
| **the claim** | the efforts the branch's **own commits** touch |
| **the working set** | the efforts the tree is touching **now** |

**A scoped run MUST NOT write a file belonging to an effort outside its claim,
and MUST NOT take a ticket of one.** Reading is unrestricted. Source outside the
efforts is untouched by this, since changing it is what an effort exists to do.

**There are no exemptions**, and that includes a skill whose subject is the whole
tree. `[[skills/prune]]` or `[[skills/survey]]` reaching another effort's
artifact **stops and names it**; a tree-wide subject belongs on an unscoped
checkout, which is where it was always going to be run from.

*Why no exemption list: an exemption is a second mechanism deciding how strong
the first one is, and it is the copy that goes wrong. A run that has to be
somewhere else is a sentence to read; a list of who may ignore the rule is a
thing to maintain.*

**An empty claim is unscoped and takes any effort.** That is the default branch,
and it is the state an effort is opened in — the first commit fixes the claim
for every turn after it. **A claim of more than one is not an error**, and a run
that must act on a single effort, holding one and given none, **ends the turn
listing the set** rather than choosing from it.

**A named effort outside the claim stops on a dirty tree and moves to it on a
clean one.** Clean, the run **enters that effort's working surface** and
proceeds, which is plainly what was meant. Dirty, it ends the turn naming the
claim, the effort it was given, and the uncommitted paths, because moving would
carry one effort's edits onto another's branch.

**Entering a surface, rather than checking a branch out.** An effort in flight
holds its branch in a worktree, so `git switch` to it is refused, and the refusal
is the mechanism working. The run opens that worktree instead, and creates one
where the effort has none. A refusal met here is never routed around: it names
where the claim is held, and a claim held elsewhere is not taken.

**A ticket branch name MUST be unique across efforts.** Ticket ids restart per
effort, so two efforts each holding a ticket `03` would otherwise produce one
branch name for two claims, and the second run to reach it takes a claim another
already holds. **How** uniqueness is reached is the repository's to state in its
own version-control rule; **that** it holds is this policy's.

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

**The orchestrator is the only integrator, and it integrates in the surface it
holds** — its own worktree, never a checkout another run can move. Being the only
integrator says who; the surface says where, and the second is what makes the
first true. An orchestrator integrating in a shared checkout is the only
integrator right up until the moment another run switches the branch under it.

A child works in its own worktree
and never merges into the shared branch, because two children integrating
themselves produce a conflict neither of them can see.

**A surface is removed, not merely released.** Detaching frees the branch;
removing the directory is a separate act performed **from outside that
directory**, since a process cannot remove the one it stands in. A run that only
ever detaches leaves one directory per effort behind, and the next run
cannot clear it, because a directory somebody kept deliberately and one somebody
abandoned look identical from outside.

**A ticket branch is a build claim, and it is released once its work reaches the
effort branch.** It exists so git refuses a second run the same ticket, and it
holds nothing the moment the orchestrator has integrated it. Delete it there, in
the step that lands the work, never before: a branch deleted while its work is
still outside the effort branch is data loss rather than tidiness. **A parked or
failed ticket keeps its branch**, because nothing was integrated and there is
nothing to release.

*Why this is stated rather than left to taste: a run that keeps them leaves one
branch per ticket whose every commit is already in the effort branch, and under a
stacking tool it leaves metadata describing levels nobody will review. The
effort branch is the reviewable unit, which follows from exactly one pull request
per effort above: a branch integrated rather than merged is not a level of
anything.*

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
> already delivered, and nothing reviews the orchestrator's reach until the whole
> effort is judged at the close, by which point a seam rebuilt as a task is work
> nobody asked for that has already landed.*

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
| the ledger, the converge round, the review round and what it found, items recorded but not acted on, anything a child raised that was not a trip-wire | a **collapsed run log section** of the pull request |

**The orchestrator writes the run log as the run proceeds**, not at the end. A
record written at the end is a record that does not exist for the failure it was
meant to survive.

**A failed write to the run log is a defect to report**, named and surfaced. It
is never a silent continue: a run that carried on after losing its memory is a
run that will later write a confident close over work nobody can find.

### Ticking a criterion

**The orchestrator ticks a criterion at the moment it verifies it**, carrying
inline what verified it: the command and what it printed, or the case it traced.
Never in a batch at the close. A run killed mid-ticket keeps every tick already
made and loses only the rest.

**A dispatched child never ticks its own criteria.** *Why: a tick is the claim
that somebody checked, and a claim checked by its own author is the thing the
whole review axis exists to not be. It is also what makes resumption safe, since
a resumed run trusts a tick without re-deriving it.*

**What the narrowing gives up, and what pays for it.** That rule used to bind
every author, and it cost nothing while a reviewer stood at each ticket. Review
now judges the effort once, at the close, so one case is left over: a wave of
one is built inline by `[[skills/implement]]` rather than dispatched, and the
orchestrator that verifies that ticket is the agent that wrote it. **That tick
is the author's own, and it is the whole of what this section gives up.** What
pays for it is that `[[skills/review]]` is now guaranteed to run over the whole
effort branch before anything is handed over, so inline-built work is judged by
somebody who did not write it before anyone is asked to merge it. The second
reader moves from the tick to the handover; it is not removed.

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

**Converge MUST NOT edit `spec.md` or `plan.md`.** It writes tickets, and one
field of one file: `status` on `spec.md`, at the close, when the round found no
gap.

*Why: converge is the stage that decides whether the spec is met, and a stage
that could edit the spec would be able to close every gap it found by narrowing
what was asked, and the run would end green having quietly agreed with itself.
Review runs after it and over the same whole diff, which catches a great deal,
but it judges the diff against the spec rather than auditing what the spec was
before converge touched it. A spec that turns out to be wrong is a return-to-plan event,
which reaches the human.*

*Why `status` is nonetheless converge's to write: it is the only field that
states a fact about the work rather than a requirement of it, so writing it
cannot narrow the ask — the failure the paragraph above is about. Converge is
also the only stage that ever holds the answer, since whether every criterion is
met is not visible from any single diff. Withheld, the judgement is made and
discarded, and the three artifacts that read `implemented` read a value nothing
sets.*

### Two rounds

**Converge runs at most twice per effort.** Converge, build the gap, converge
again. Past that the remaining gaps are named at the close and in the tracker,
and the run ends rather than grinding.

*Why two, and why not configurable: a third round finding new gaps means the plan
was wrong rather than the work incomplete, and that is the return-to-plan
trip-wire rather than more rounds. A configurable cap is a number nobody can set
correctly until a run has already gone wrong.*

**A ticket a review finding produced does not spend a round.** This cap counts
rounds that went looking for a gap between the spec and the work. A review
finding is not one of those, because converge has already agreed the spec is met
and the review is judging the diff rather than the ask. Counted here, the second
review round would be unreachable whenever converge found a gap once and then
found none, and a run could end not ready with no gap it could name.

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
