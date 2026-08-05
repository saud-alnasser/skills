# feat(skills): the build stage dispatches, isolates, and integrates

Status: resolved
Blocked by: 03, 04, 05
Part of: orchestration

## Problem

Everything the orchestration system needs exists by this point and nothing uses it. A ticket can declare a fan-out, roles can be dispatched by name, a policy says what a child may do, and the isolation obligation is written — but the stage that builds tickets still builds every one of them in a single context, and a declared fan-out is inert text.

## Outcome

The build stage reads a declared fan-out and acts on it. For each declared role it composes a brief from the template — objective, the inputs as paths, the files that role owns, the return shape, done-criteria, and a cap — and dispatches the child into an isolated worktree branched from the claim. The claim's unit widens to cover them, the way it already widened for stacks: claiming the ticket claims every child beneath it.

Integration is the orchestrator's and only the orchestrator's, which the harness enforces rather than the policy hoping — an isolated child's version-control commands fail if they reach the main checkout.

**The child's change record is what the orchestrator integrates by.** It navigates the child's workspace from the record rather than taking the branch on trust, and reconciles the record against the child's actual diff before anything lands: a path in the diff the record does not declare, or a path outside what that child was declared to own, stops the whole fan-out and is named. That reconciliation is what gives the declaration's file-ownership half any force — without it, ownership is a comment. What lands is a squash, so one ticket stays one commit, indistinguishable in history from a ticket built without fan-out.

Failure has a defined shape. A child that fails, or that stops on a decision it cannot make, integrates nothing — and neither does any of its siblings, because a partial set satisfies no acceptance criterion and reviewing it would review a ticket that was never built. The successful children's worktrees stay in place holding their work, so a resumed session continues rather than rebuilding. The stage hands back naming the portion that failed and the decision, if there was one.

A ticket with no declaration takes the path it takes today, unchanged.

## Acceptance

- A declared fan-out dispatches one child per role, each with a brief carrying all six parts.
- Each child works in an isolated worktree branched from the claim, and nothing it does reaches the main checkout.
- The claim's unit covers the children, and the stage says so when it creates them rather than when something breaks.
- The orchestrator integrates from each child's change record, not from the branch alone.
- A record that cannot be reconciled against the child's diff stops the fan-out, and the mismatch is named — which path, and whether it was undeclared or unowned.
- A fanned-out ticket produces exactly one commit.
- A fan-out that loses a child integrates nothing, names the failed portion, and leaves the successful children's work in place.
- A child that stopped on a decision surfaces that decision to the human; no path exists by which the stage decides on the child's behalf.
- A ticket with no declaration behaves exactly as it does today, and the suite asserts that path is untouched.
- The review stage runs on the integrated result, not per child.
- The suite passes.

## Found at review, fixed

Criterion 8 asked for a closed path and the first draft asserted one — *"no path exists by which this stage answers"* is a sentence, not a route. The decision now takes the same hand-back an undeclared decision takes, and the inline `research`/`task` resolution above it is explicitly fenced: a question that came back from a child is never one of those. That path was live and nothing had shut it.

The blast radius covered failure and not stopping, though the Outcome binds them: *"A child that fails, **or that stops on a decision it cannot make**, integrates nothing."* Both now stop the set.

**The sharpest one.** ADR 0044 says branching from the claim is a configuration obligation "not a sentence in a skill anyone can forget" — and the draft wrote that sentence into the stage, then narrowed the base-ref guard until it stopped noticing. `specs.md` §20 states the branching too, so the skill was a third home. The stage now states the isolation, defers the base to configuration, and the deferral is itself asserted; the guard was restored to the reach the narrowing had cost it, and a second check catches the positive form the probe never covered.

Also fixed: the claim-widening rule restated from the policy with no `$rulePattern` entry to catch it, and an enforcement claim ("nothing a child does reaches the main checkout") broader than either ADR 0044 or §20 supports — both say *version-control commands*.

## Blocked, and now nobody's

Ticket 05 deferred one thing here: the base check states ancestry in one direction, and inverts if the parent commits between dispatch and integration, refusing a correct child. It is **not in this ticket's acceptance criteria**, and getting it right is not a wording fix — a child branched from trunk also satisfies "child base is an ancestor of the claim", so the correct predicate has to distinguish a base on the claim's own branch from one on trunk. That is a design decision, and `/implement` does not make those.

It belongs to `/design`. Recorded here because 05 routed it to 06 and 06's criteria never took it, which is how a deferral becomes unowned.

## Accepted at review

The "single-instance path is untouched" criterion is asserted by containment — that no dispatch language leaks outside the subsection, and that the loop a ticket without a declaration takes mentions none of it. That is a proxy for *untouched* rather than a proof of it. Accepted: the criterion is about the absence of a change, and containment is what absence looks like from a guard's side.
