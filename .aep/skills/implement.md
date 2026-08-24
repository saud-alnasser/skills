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
node .aep/scripts/position.mjs check
```

**This is what fills `Position` in the turn report**
(`[[policies/reporting]]`): the script's output, then what no script can produce
— the contexts this task touches, and every claim the source contradicted, with
what was corrected.

**Nothing to report is still reported** — a silent check is indistinguishable
from one that never ran.

A marker match licenses skipping the drift read and **nothing else**. Any
statement you are about to rely on is still checked against the source
(`[[policies/authority]]`), and anything found stale is fixed where it is found.

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

**The claim is the branch, and creating it is the first act of the run** — before
the first read of source, and long before the first edit. A claim made after the
first edit is a report of a race already lost.

```
effort branch      <effort>                     aep-3
ticket branch      <ticket-id>-<slug>           17-assignment-and-claim
```

The effort branch is created once and every wave lands on it. **Children in a
wave branch from the effort branch's current tip, and the next wave branches from
the new tip** — so each wave sees everything the waves before it landed, and no
child is working against a tree three tickets stale.

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

   **A ticket is never split across sub-agents** (`[[policies/execution]]`). A
   ticket too large for one child is too large — it goes back to
   `[[skills/tasks]]`.

5. **Build**, matching the surrounding code — idiom, naming, comment density.
6. **Verify each acceptance criterion explicitly**, one at a time, and **quote
   what you ran and what it printed**. "It should work" is not verification.

## 4 — Integrate, review, land, repeat

**Integrate each child as it returns**, one at a time, into the effort branch.
Not all of them at the end: a conflict then arrives as one pile with no ticket to
name it, and the second child's work is what gets untangled by whoever is least
able to. Integrated per ticket, **a conflict surfaces at that ticket's
integration and is named against that ticket**.
`[[skills/implement/conflicts]]` has the discipline.

`[[policies/execution]]` holds what the orchestrator owes once the last child
returns, under `## What the orchestrator owns once the last child returns`.

Then `[[skills/review]]`, apply the fixes, and land it — **without prompting.**
Landing reviewed work is part of finishing, which is why there is no separate
command to type: by the time the work is reviewed there is nobody left to ask.

Review runs **as a stage of this turn** and opens no report of its own
(`[[policies/reporting]]`). Everything it produces still reaches the human; only
the preamble is not repeated.

**A review that rejects twice parks the ticket.** Two fix attempts, then record
it unresolved with what the review said, **leave its dependents alone**, and
carry on with the tickets that do not need it. A third attempt is a loop that
looks like work, and converge sees the gap regardless.

### Landing it

**Confirm; do not repeat.** The tests ran, and `[[skills/review]]` ran with an
outcome against every finding — fixed, ticketed, or accepted and recorded. **A
finding still open is a blocker, never a silent pass.** A stage that did not run
is named and the run stops there, saying what would clear it: a refusal the
reader cannot act on is a wall rather than a check.

1. **Mark the ticket resolved** before staging. It is tracked, so moving it after
   the commit leaves the tree dirty the moment the commit lands.
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
5. **Stamp the marker** — `node .aep/scripts/position.mjs stamp`. Last, once the
   commit exists, because a commit cannot contain its own hash. **An amend
   produces a new commit, so an amend re-stamps.**

Further changes amend that commit.

6. **Write the run log**, in the pull request, before taking the next ticket.
   The ledger line for this ticket, the converge round, how many times each
   ticket failed review, items recorded but not acted on, and anything a child
   raised that was not a trip-wire (`[[policies/execution]]`). **A failed write
   is reported, never continued past** — the run has just lost its memory and
   does not know it yet.

7. **Re-sync the derived labels** on both objects: `status:` from where the
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

### When a round finds no gap

The effort is complete, and the run says so in the file that asked for it
before it says so anywhere else:

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
   **mark the pull request ready** — the run's own last act, permitted by
   `[[rules/version-control]]`.

The human reviews and merges.

## What may stop the run

**Exactly three conditions reach the human before the effort is finished.**
Everything else the run notices is recorded and carried to the close.

| Trip-wire | Why it is worth an interruption |
| --- | --- |
| **evidence invalidates the technical plan** | continuing means designing while implementing, and the cost compounds with every ticket built on it |
| **the work touches a public contract or data at rest** | the blast radius is outside this repository, and it is not recoverable by amending a commit |
| **a ticket contradicts `spec.md`** | the tickets were cut wrong (`[[policies/execution]]`), and a run that builds the wrong thing ten times is worse than one interruption |

**There is no fourth.** A review that rejected once and passed after the fix does
not stop the run. A ticket parked after two rejections does not stop the run. A
finding, a surprise, an improvement noticed in passing: recorded, carried to the
close, and **never a reason to come and ask.**

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
| the collapsed **run log** | the ledger, the converge round, review attempts, what was recorded and not acted on |
| `frontier.mjs` | what is left, and what blocks it |

**Re-verify nothing already ticked. Trust nothing that is not.** A tick was made
by `[[agents/reviewer-correctness]]` and never by the agent that wrote the code,
which is what makes it safe to resume on (`[[policies/execution]]`).

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
