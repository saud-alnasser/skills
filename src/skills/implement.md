---
use-when: "a task exists and is ready to build"
---

# /implement — carry the effort to a finished stack

Builds tickets that already exist, wave after wave, until the effort is done.
It reads **the ticket, not the conversation**, so context can be cleared between
any two — and it is written on the assumption that it will be, because a run
over a whole effort outlives the session that started it.

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
node .aep/scripts/scope.mjs read
```

The scope says which efforts this branch claims and what isolation is in force.
A non-empty claim confines the run to the efforts it names
(`[[policies/execution]]`).

**Position takes two reads and this step is only the first of them.** The other
is the marker check, and it runs at **step 2, once the surface has been
entered.** Neither half can sit where the other one does:

| The read | Sits | Because |
| --- | --- | --- |
| the scope | **here** | the isolation it prints is what decides whether step 2 takes a surface at all, so a run that read it later would be keying that decision on an answer it did not have yet |
| the marker | **step 2** | a marker is per working tree and describes the tree it sits in, so the one to read is the one the run will stamp on the way out |

**Do not merge them back into one step.** Read together here, the run would
report drift for the checkout it is about to leave and then stamp a different
file, and the two acts read as one guarantee while being quietly two markers.

**This is what fills `Position` in the turn report**
(`[[policies/reporting]]`). The claim and the isolation go in `Position` beside
the marker's answer from step 2, and beside them goes what no script can
produce — the contexts this task touches, and every claim the source
contradicted, with what was corrected.

**Two questions, two answers, reported together and never merged.**

## 1 — Take the effort

```
node .aep/scripts/frontier.mjs <effort>
```

**The unit of an invocation is the effort, not the wave.** The run schedules from
the frontier, builds it, and schedules again, until converge finds no gap or a
trip-wire fires. **An exhausted ticket list is not the end of the run** — tickets
exhausted and the spec satisfied are different claims, and only the second one
ends it.

| The invocation | The unit |
| --- | --- |
| **named a ticket** | that ticket, alone, and the run ends there. Taking a second is choosing work you were not given |
| **named an effort, or nothing** | the whole effort, wave after wave |

**Where the invocation named nothing, the effort is the claim read at step 0.**
An empty claim takes any effort (`[[policies/execution]]`), so an unscoped run is
unchanged from what it has always been: the effort is whichever the invocation
named, and an invocation naming none against an empty claim has nothing to
schedule from and ends the turn saying so. A claim of more than one, with no
effort named, ends the turn listing the set rather than picking from it.

**A named effort outside the claim stops on a dirty tree and moves to it on a
clean one** (`[[policies/execution]]`). Clean: **enter that effort's surface** at
step 2 and carry on, which is plainly what was meant. Dirty: end the turn naming
the claim, the effort you were given, and the uncommitted paths — moving would
carry one effort's edits onto another's branch.

**Enter the surface; do not check the branch out.** An effort in flight holds its
branch in a worktree, so `git switch` to it is refused, and that refusal is the
guard working rather than an obstacle. Open the worktree instead.

**The frontier is read, never judged.** `frontier.mjs` prints what is ready, what
is blocked and on what, and what is parked; the run quotes it rather than holding
the graph. A ticket that *looks* independent is not in the wave unless the edges
say so.

**When the frontier is empty and unresolved tickets remain, the blocking work is
what to build.** An edge names a ticket, that ticket is somewhere, and finding it
is reading the graph rather than inventing work. When nothing unresolved remains
at all — `frontier.mjs` exiting 1 — **go to step 5 and converge.** That is never
the end of the run by itself.

**The tickets are files under `efforts/<effort>/tickets/`, and the graph is read
from them** (`[[policies/execution]]`). The tracker holds the effort's issue and
its pull request, and neither carries a ticket — so scheduling never waits on a
fetch, and there is no query to get wrong.

If the invocation carried a *request* rather than an effort, go to
`[[skills/specify]]` — do not hand back a command for the human to type. A ticket
already done, or no longer needed, is marked `obsolete` **with a one-line
reason**; that satisfies the edges that named it, and the run continues.

## 2 — Claim it

**The claim is the branch and the surface, and taking both is the first act of
the run** — before the first read of source, and long before the first edit. A
claim made after the first edit is a report of a race already lost.

**Enter the run's own worktree before anything else** (`[[policies/execution]]`).
Read the isolation step 0 already printed, and key on its **kind**, never on its
enforcement:

| The isolation says | Do |
| --- | --- |
| `checkout` | enter `.aep/worktrees/<effort>/_run`, creating it from the effort branch where it does not exist |
| `worktree` | the runtime gave you a surface already. **Take no second one**, work here, and say in `Position` which surface that is |

**A worktree this effort already has is re-entered, never duplicated.** A run
that stopped or died left one, and a second surface for one effort is two places
its branch could be worked from. **Where that tree is dirty, end the turn naming
the uncommitted paths** — the same answer as a named effort outside the claim on
a dirty tree, and for the same reason: you cannot tell whose edits those are.

### Check the marker, in the surface you just entered

The second half of step 0, and it runs here rather than there:

```
node .aep/scripts/position.mjs check
```

It says whether this tree moved since a run last looked at it. **A marker
belongs to the surface it sits in**, so the one in the checkout you were invoked
in answers nothing about this one. Checked there and stamped here, the run would
quote drift for a tree it was about to leave and stamp a tree it never compared:
the answer would be true of nowhere, and nothing about it would look wrong.

Where the isolation said `worktree` no second surface was taken, so the two
orders name one file and the difference is invisible. **The order is written for
the `checkout` case**, which is the one that has two.

**Nothing to report is still reported** — a silent check is indistinguishable
from one that never ran.

A marker match licenses skipping the drift read and **nothing else**. Any
statement you are about to rely on is still checked against the source
(`[[policies/authority]]`), and anything found stale is fixed where it is found.

### Then the branch

```
effort branch      <effort>                     aep-3
ticket branch      <effort>/<ticket-id>-<slug>  aep-3/17-assignment-and-claim
```

The effort branch is created once and every wave lands on it, **in the run's own
worktree and never in a shared checkout**. **Children in a wave branch from the
effort branch's current tip, and the next wave branches from the new tip** — so
each wave sees everything the waves before it landed, and no child is working
against a tree three tickets stale.

Check both sides before creating — a local branch of that name, and the remote
(fetch first, or the answer is stale). **A claim held elsewhere is never taken:**
not renamed around, not branched from, not force-created over. Report which
ticket, which branch, and where the claim was seen, then move to the next.

Where the repository has its own branch convention, that one wins
(`[[rules/version-control]]`).

**Dispatching a wave: create every branch first, then dispatch.** The parent
holds the whole wave before any of it is worked. State the plan — which tickets,
which role, which branches — before creating anything. Stated, not gated.

## 3 — Build the wave

1. **Read the ticket and the effort's `spec.md`.** Where they conflict: **stop,
   surface it, build nothing** (`[[policies/execution]]`).
2. Load applicable `[[policies]]` and `[[rules]]`, relevant `[[contexts]]`, required
   `[[references]]` — by `use-when` and `paths`, never everything.
3. **Read the code you are about to change.** All of it.
4. Choose the shape:

   | Situation | Do this |
   | --- | --- |
   | a wave of two or more | dispatch `[[agents/implementer]]` — **one child per whole ticket**, one worktree each. `[[skills/implement/dispatch]]` is how to write the brief |
   | a wave of one | build it here; a child would spend a whole context on work you are already positioned to do |
   | rules require test-first, or a bug needs pinning | `[[skills/tdd]]` |
   | the ticket is a bug and the cause is not known | `[[skills/implement/diagnosing]]` — build the signal before the theory |
   | technical uncertainty survives | `[[skills/prototype]]`, in a worktree |

   **A child's surface is created under the main checkout's `.aep/worktrees/`,
   never relative to the surface you are standing in.** Give the path from the
   main checkout, or git resolves it against your own working directory and
   nests the child inside your surface. **The path is what decides the role**
   (`[[policies/execution]]`), so a child that lands anywhere else computes the
   role of wherever it landed. Nested, it reads `unknown` and refuses nothing;
   outside `.aep/worktrees/` altogether it reads as the surface a runtime
   supplied, whose occupant is an orchestrator, and it will believe it may
   integrate and dispatch.

   **A ticket is never split across sub-agents** (`[[policies/execution]]`). A
   ticket too large for one child is too large — it goes back to
   `[[skills/tasks]]`.

5. **Build**, matching the surrounding code — idiom, naming, comment density.
6. **Verify each acceptance criterion explicitly**, one at a time, and **quote
   what you ran and what it printed**. "It should work" is not verification.

## 4 — Integrate, land, repeat

**Integrate each child as it returns**, one at a time, into the effort branch
**inside the run's own worktree** (`[[policies/execution]]`). Never in the
checkout the run was invoked from: a `cherry-pick` or a `reset` there resolves
the branch name at write time, so it lands wherever another run last left `HEAD`,
and a clean `git status` read a moment earlier does not make that safe.

Not all of them at the end: a conflict then arrives as one pile with no ticket to
name it, and the second child's work is what gets untangled by whoever is least
able to. Integrated per ticket, **a conflict surfaces at that ticket's
integration and is named against that ticket**.
`[[skills/implement/conflicts]]` has the discipline.

`[[policies/execution]]` holds what the orchestrator owes once the last child
returns, under `## What the orchestrator owns once the last child returns`.

Then land it — **without prompting.** Landing is part of finishing, which is why
there is no separate command to type: by the time a wave is integrated there is
nobody left to ask.

**No review runs here.** It runs once at the close, over the effort branch, after
converge finds no gap — step 5, and nowhere else in this run. A reviewer holding
one ticket's diff cannot see a defect that lives between two of them, and it is
the effort branch a human is asked to merge, so that is the unit judged. Nothing
reaches a human unjudged in the meantime: the branch these commits land on is the
run's own, and its pull request is still a draft.

### Landing it

**Confirm; do not repeat.** The tests the rules require ran, and every acceptance
criterion was verified with what verified it quoted. A stage that did not run is
named and the run stops there, saying what would clear it: a refusal the reader
cannot act on is a wall rather than a check.

1. **Mark the ticket resolved** before staging. It is tracked, so moving it after
   the commit leaves the tree dirty the moment the commit lands.

   **Every criterion is ticked, or the ticket is not resolved.** `resolved` is
   the claim the work is done and the ticks are the evidence for it, so a box
   left open is that claim with its evidence removed, and `validate.mjs` fails
   the ticket by name. **The way out is never to tick it**: a criterion that
   cannot be met parks the ticket unresolved with what blocked it, or marks
   it `obsolete` where the spec moved on.
2. **Regenerate the index** — `node .aep/scripts/index.mjs`. Here rather than
   earlier, because this is the last point at which the tree is known complete
   and an index regenerated before the final edit is already stale. **Never
   hand-edit one**: `validate.mjs` regenerates and compares, so a hand edit is a
   build failure that names the file.
3. **Write the message by detection.** Read `git log --oneline -30`,
   `CONTRIBUTING.md`, and any pull request template. Where the repository
   demonstrates a convention, follow it silently; `[[rules/version-control]]`
   supplies the default only where the repository is silent, **including which
   form the ticket reference takes**. Say what capability changed and why, and
   **never give a file-by-file account** — the diff already lists the files.
4. **Commit — one commit per ticket, with no exception for a ticket that
   produced no diff.** A ticket that verifies something is already true lands an
   **empty commit** whose message carries what was checked and what it printed.
   The evidence is then in the history a bisect reads, and the ledger line looks
   like every other one. A ticket that quietly lands nothing is a ticket nobody
   can tell was done.
5. **Release the ticket branch and the worktree holding it.** Its work is on the
   effort branch now, so the claim it held is spent and both hold nothing. Remove
   the worktree, delete the branch, and drop any stacking metadata with them
   (`[[policies/execution]]`). **Only after the commit has landed** — releasing
   one whose work is still outside the effort branch is data loss. **A parked or
   failed ticket keeps both**, since nothing was integrated.

   The directory goes with the branch. Releasing one and leaving the other is how
   a clone fills with worktrees whose branches no longer exist.
6. **Stamp the marker** — `node .aep/scripts/position.mjs stamp --session <id>`,
   passing **the identifier your harness gave this session**. Last, once the
   commit exists, because a commit cannot contain its own hash. **An amend
   produces a new commit, so an amend re-stamps.**

   **Never invent one.** Where the runtime exposes no session identifier, drop
   the flag and stamp as before; everything else is unaffected
   (`[[policies/execution]]`).

   What it buys is one thing: a second identifier against one marker says two
   agents are sharing a checkout. **It is a diagnostic and nothing reads it to
   decide** — an identifier carries no liveness, so a run gating on one would
   block on the leavings of every abnormal exit.

Further changes amend that commit.

7. **Write the run log**, in the pull request, before taking the next ticket.
   The ledger line for this ticket, the converge round, the review round and
   what it found, items recorded but not acted on, and anything a child raised
   that was not a trip-wire (`[[policies/execution]]`). **A failed write is
   reported, never continued past** — the run has just lost its memory and
   does not know it yet.

8. **Re-sync the derived labels** on both objects: `status:` from where the
   effort now stands, `type:` from what the spec describes, and every flag the
   diff establishes — `flag: dependencies` where a dependency manifest or a
   lockfile moved, `flag: release` where what a release publishes moved,
   `flag: breaking changes` where the public-contract trip-wire fired.
   **`priority:` is not among them** (`[[policies/execution]]`): it was set when
   the effort opened, and re-deriving it overwrites a human.

**Then schedule again.** Back to step 1, against the tip this wave just made.

## 5 — Converge

**No unresolved ticket left is not the end of the run.** Tickets were a map of
the work drawn before the work was done, and a map running out is not the
territory being covered. Converge is where the two claims are separated
(`[[policies/execution]]`).

Read the effort's **whole diff** — which no single ticket ever saw — against
`spec.md` and `plan.md`, and answer three things:

1. **Is every acceptance criterion in `spec.md` met?** Not: is every ticket
   closed. A ticket can be resolved against a criterion nobody checked.
2. **Did the change move a boundary, retire a concept, or falsify a
   `[[contexts]]` or a `[[references]]`?** What it falsified is corrected **in
   this effort**, so the change and the thing it contradicts never land apart. A
   concept nobody had named is a finding to report, never a licence to name it
   here.
3. **For each gap: was it not built, or does the approach not work?**

| The gap is | Do this |
| --- | --- |
| **work nobody built** | append tickets for it, and go back to step 1. That is round two |
| **an approach that cannot satisfy the requirement** | **stop.** Return-to-plan, the first trip-wire. Never append a ticket against it |

**Converge appends tickets. It never edits `spec.md` or `plan.md`.** A converge
that could edit the spec would close every gap it found by narrowing what was
asked, and the run would end green having agreed with itself.

**One field is the exception, and it is one field by name: `status` on
`spec.md`,** written at the close below and nowhere else. Every other part of a
spec is what was asked for; `status` is the only one stating a fact about the
work rather than a requirement of it, and the fact is the answer converge has
just given. **Never read this as permission to touch the frontmatter** — a
requirement is not narrowed by recording that it was met.

### At most twice

Converge, build the gap, converge again. **A third round is not run.** Name the
remaining gaps at the close and in the pull request, leave the pull request **not
ready**, and end.

*Why two: a third round finding new gaps means the plan was wrong rather than the
work incomplete, and that is the trip-wire above rather than more rounds.*

**A ticket a review finding produced does not spend a converge round.** The cap
counts rounds that went looking for a gap between the spec and the work, and a
review finding is not one of those: converge already agreed the spec was met.
Counted against the cap, the second review round below becomes unreachable on
the ordinary path, where converge found a gap once and then found none, and the
run would end not ready with no gaps it could name.

### When a round finds no gap

**The reviewers run here, and here only.** Converge has just said the effort
satisfies the spec, and the effort branch now carries the whole diff a human is
asked to merge. Go to `[[skills/review]]` with that branch as the subject and the
effort's `spec.md` as what was asked for.

Review runs **as a stage of this turn** and opens no report of its own
(`[[policies/reporting]]`). Everything it produces still reaches the human; only
the preamble is not repeated. Moving when it runs did not make it a turn.

**Correcting what it finds costs nothing extra, because nothing has left the
run's reach.** The effort branch is held in the run's own surface, its pull
request is a draft, and `main` is untouched, so every commit in the effort is
still the run's to change. Validate each finding, then fix it here, or **write it
as a ticket, which reaches the frontier like any other work** and is scheduled
from step 1. `[[skills/review]]`'s outcome table already makes **Ticketed**
available without the human; only **Accepted** is reserved to them.

**Two review rounds, and no third.** Review, correct, review again when the
correcting work lands. A finding still open after the second round is **recorded
unresolved with what the review said**, the pull request is left **not ready**,
and the run ends there saying so. Without that bound, review-to-ticket-to-review
is a loop with no stated end, and a loop with no stated end is precisely what the
per-ticket rule this replaces existed to prevent.

**An open finding blocks the handover.** A finding is closed by being fixed, by
becoming a ticket the run schedules, or by the human accepting it, and **the pull
request is never marked ready while one is still open.**

#### Then close it

With every finding closed, the effort is complete, and the run says so in the
file that asked for it before it says so anywhere else:

1. **Stamp `spec.md` to `status: implemented`.** That is the judgement of step 1
   above, recorded. Three things read it — `[[skills/tasks]]` skips an
   implemented effort, `[[skills/prune]]` tells a finished effort from an
   abandoned one by it, and `validate.mjs` stops checking traceability on one —
   so a close that skips the stamp leaves all three reading a value nothing ever
   set. **A stamp with an unresolved ticket still under the effort fails
   validation**, which is the guard against stamping ahead of the work.
2. **Finalise the pull request description**, and **compute
   `size:` from the diff** against the thresholds that repository's own `size:`
   descriptions state.
3. **Move the issue and the pull request to `status: in review`**, then
   **mark the pull request ready** — permitted by `[[rules/version-control]]`,
   and reached only with every review finding closed.
4. **Release the surface, then remove it.** Detach the run's worktree, which
   frees the effort branch at once so whoever reviews it can check it out, and
   only then remove the directory. **Detach first, always:** detaching succeeds
   even where removal fails, and a run that reversed them has nothing left to
   detach.

   **Leave the surface, then remove it from the repository root:**

   ```
   git -C .aep/worktrees/<effort>/_run switch --detach
   git worktree remove .aep/worktrees/<effort>/_run
   ```

   A process cannot remove the directory it is standing in, so the second command
   is run from elsewhere rather than skipped. **Removal is best-effort and
   releasing the branch is not**, but a close that only ever detaches leaves one
   directory per effort, which is how this pattern fails in practice.

   **The directory is removed on a clean close and kept on a stop or a failure**,
   so there is something to inspect after exactly the runs worth inspecting.

   Where the runtime supplied the surface, AEP took none and releases none.

**Where the repository has no tracker, steps 2 and 3 have nowhere to land and
the close is steps 1 and 4** (`[[policies/execution]]`). There is no draft to
ready and no label to move; the branch is finished, stamped, and released.

**A run that stops keeps its surface, and releases the branch anyway.** The
trip-wires below end the turn without reaching this close, and the tree is
deliberately left to be inspected. **Detach on the way out**: the directory is
what is worth keeping, and the branch held inside it is not, because a human
about to act on the stop is the person most likely to want it.

**A run that dies releases nothing**, because nothing runs. Its worktree still
holds the effort branch, and that is safe for one reason only: **the run that
resumes the effort re-enters that same worktree at step 2** rather than needing
the branch back. Re-entry is what stops a dead run locking an effort, not
detachment, which is why step 2 re-enters rather than creating a second surface.

What must never happen is the reverse pairing — a directory removed while its
branch is still claimed — which is why these two acts are ordered rather than
done together.

The human reviews and merges. **The runner never merges**, in either shape.

## What may stop the run

**Exactly three conditions reach the human before the effort is finished.**
Everything else the run notices is recorded and carried to the close.

| Trip-wire | Why it is worth an interruption |
| --- | --- |
| **evidence invalidates the technical plan** | continuing means designing while implementing, and the cost compounds with every ticket built on it |
| **the work touches a public contract or data at rest** | the blast radius is outside this repository, and it is not recoverable by amending a commit |
| **a ticket contradicts `spec.md`** | the tickets were cut wrong (`[[policies/execution]]`), and a run that builds the wrong thing ten times is worse than one interruption |

**There is no fourth.** A review that rejected once and passed after the fix does
not stop the run. A finding still open when the review bound is reached ends the
run at the close rather than interrupting it, which is the same shape as
converge's own cap. A finding, a surprise, an improvement noticed in passing:
recorded, carried to the close, and **never a reason to come and ask.**

*Why exactly three: the point of the loop is that the human intervenes at the
idea, not at the implementation. Every condition added here is a decision moved
back out of the run, and the three that stay are the ones where continuing is
worse than stopping.*

## Constraints

- **Stay bounded by the ticket.** An improvement you notice is **raised, not
  taken.** The diff stays about one thing.
- **Return to plan** the moment evidence invalidates the approach: stop, record
  the evidence, `[[skills/plan]]`, update `spec.md`, update the tickets,
  continue. Pushing through is how implementation becomes design — and it always
  arrives when stopping feels most expensive.
- **The orchestrator is the only integrator.** A child works in its own
  worktree and never merges into the effort branch; two children integrating
  themselves produce a conflict neither can see.
- Never push, never publish (`[[rules/version-control]]`).
- Prototype code is never promoted as-is. Rewrite what survives.

## Resuming after losing context

**The session is disposable, and the run is written for that.** A run over a
whole effort may cross a compaction or a session boundary, and neither stops it:
what the run needs is on disk, never only in its head.

Reconstruct from the durable record and from nothing else — **the pull request,
the issue, and the repository**:

| Read | To recover |
| --- | --- |
| commits on the effort branch | which tickets landed |
| **ticked checkboxes in the pull request** | which criteria of the in-flight ticket are verified, and what verified each |
| the collapsed **run log** | the ledger, the converge round, the review round and what it found, what was recorded and not acted on |
| `frontier.mjs` | what is left, and what blocks it |

**Where there is no tracker the repository is the whole record**, and it is
enough: the commits say which tickets landed, and each ticket file's ticked
criteria say what is verified. Those are the same ticks — the pull request was
projecting them, never storing them.

**Re-verify nothing already ticked. Trust nothing that is not.** A tick records
that a criterion was verified and carries inline what verified it, so a resumed
run reads the evidence rather than the claim (`[[policies/execution]]`). A
dispatched child never ticks its own. Where a wave of one was built here, the
tick is its author's, and what covers that case is the review over the whole
effort branch, which runs before anything is handed over.

**A detached HEAD names no branch and holds no claim** — do not guess the ticket
from the diff; claim one properly or hand back.

*No part of this may depend on triggering compaction.* An agent cannot invoke
it. It is a command the human types, or a harness firing on its own schedule and
choosing its own survivors, so a design that waits for it waits on something it
does not control.

## Done when

Every acceptance criterion of every ticket has been checked and the check was
shown, each ticket landed as one commit on the effort branch, the tests the
rules require pass, nothing outside the effort changed, and every ticket's
status reflects reality. A parked ticket is named, with what parked it.

**And converge ran.** A run that stopped because the tickets ran out has not
finished; it has run out of map. The effort is done when a converge round found
no gap, or when the cap was reached and the remaining gaps were named.
