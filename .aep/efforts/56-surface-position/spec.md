---
status: accepted
---

# Problem

Position answers one question — did this tree move since a run last read it — and
after effort 54 that question is being asked about the wrong tree.

Effort 54 moved the work into surfaces. `/specify` creates the effort branch into
`.aep/worktrees/<effort>/_run`, `/plan` enters that surface rather than checking
the branch out, and `/implement` enters it before its first read of source.
Position did not move with them. Two things follow, both observed in this clone
rather than reasoned about.

**A run cannot compute its own role.** `scripts/scope.mjs read` and
`scripts/position.mjs check`, run in the orchestrator's surface and in a child
implementer's surface of the same effort, return byte-identical answers: the same
claim, the same `isolation: worktree, enforced`, the same `marker: unset`. The
only difference is which path is printed as self. Yet the two agents are bound by
opposite rules. `[[agents/implementer]]` says "You do not integrate" and "You do
not dispatch"; `[[policies/execution]]` says the orchestrator is the only
integrator and integrates in the surface it holds. Neither statement is derivable
from where either agent stands. Both live only in prose — in a brief for the
child, in a policy for the parent — and `[[skills/implement]]` is written on the
explicit assumption that context is cleared between any two tickets, so a run
outlives the only copy of the rule that binds it.

**The marker is checked in one tree and stamped in another.** `/implement` runs
`position.mjs check` at step 0, in whatever checkout it was invoked in, enters
`.aep/worktrees/<effort>/_run` at step 2, and stamps at step 6 inside that
surface. Those are two different files. The run therefore checks a marker it will
never stamp and stamps a marker it never checked, and the drift answer it quotes
in `Position` describes the surface it is about to leave. `/specify` has a smaller
version of the same split: it reads `position/marker.json` as prose at step 1,
then opens the effort into a surface.

The cost is visible on disk. The main checkout's marker holds head
`a1fa05a768ffadbb57c11c4cf773cda10dd38e23`, a commit no branch contains, with
`sessions: []`, because `/install` is the only thing that has ever written it. Of
the four surfaces this clone currently holds, none carries a marker at all.

None of this is a defect in effort 54. It shipped exclusion, and exclusion is not
orientation. What it changed is where a run stands, and nothing told position.

## The second problem: review judges the wrong unit

Review is a stage of `/implement` run **per ticket**. `specs.md` section 21 says
so outright, section 20's stage table gives its subject as "the diff satisfies the
ticket", and `[[skills/implement]]` runs it between integrating a child and
landing that child's commit.

So the two reviewer agents never see the effort. They see one ticket's diff at a
time, and every defect that lives *between* tickets is structurally invisible to
them. This effort is its own worked example: tickets 05 and 06 both edit the same
assertion in `verify.mjs`, and a reviewer holding only one of those diffs cannot
see that the other exists.

`[[policies/execution]]` already names the hole and accepts it. Converge, it says,
"is the only stage with both the whole diff in view and nobody reviewing it".
That sentence describes a design that reviews everything except the thing a human
is asked to merge, because **the effort branch is the reviewable unit** and
exactly one pull request exists per effort.

The two problems are one problem seen twice: a run that cannot compute what binds
it, and a review that cannot see what it is judging. Both come from a unit chosen
before the work moved to where it now happens.

# Goal

An agent that finds itself in a surface can compute, from git and its own path,
which surface it is in and what role that makes it — and the rules that bind that
role refuse on the computed answer rather than on a brief that may no longer be
in context.

The marker describes the surface the work happens in. No skill checks one
surface's marker and stamps another's.

The two reviewer agents judge the effort, once, against the diff a human is asked
to merge. Nothing lands unjudged, and converge stops being the one stage with the
whole diff in view and nobody reading it.

# Scope

- `scripts/scope.mjs` gains a computed surface and role, reported beside the
  claim and the isolation it already prints.
- `[[policies/execution]]` states what a run does with the role, as it already
  states what a run does with the isolation.
- `[[agents/implementer]]` and `[[skills/implement]]` key their existing
  constraints on the computed role.
- `[[skills/implement]]`'s position check moves to after the surface is entered.
- `[[skills/specify]]`'s position read becomes a script invocation.
- `[[skills/prune]]` and `[[skills/survey]]` gain a position step against the
  surface they run in, which is the main checkout.
- `[[policies/reporting]]`'s table of what each skill puts in `Position`.
- `specs.md` sections 18 and 20.
- `[[skills/implement]]`'s step 4 and its close, where review moves from the one
  to the other.
- `[[skills/review]]`'s subject, and `[[policies/execution]]`'s ticking rule and
  run log.
- `specs.md` section 21, where review's unit, its subject, and the commit rule
  are stated. Section 20 is the position half and the two do not overlap.
- `scripts/verify.mjs`, in the same pass.

# Requirements

1. **`scope.mjs` computes the surface and the role.** It reports which surface the
   run is standing in and what role that surface makes it, derived from git and
   the path, beside the claim and isolation it already prints. Both `read` and
   `--json` carry them.

2. **The derivation is by path shape, and `_run` is the discriminator.**
   `.aep/worktrees/<effort>/_run` is the orchestrator of that effort;
   `.aep/worktrees/<effort>/<anything-else>` is a child on that ticket; the common
   checkout is the main surface; a linked worktree outside `.aep/worktrees/` is a
   surface the runtime supplied, whose occupant is the orchestrator, since a run
   given one takes no second.

3. **Nothing is stored.** `position/marker.json` keeps exactly `tree`, `head` and
   `sessions`. Surface and role are computed on every call and written nowhere, so
   neither becomes a second copy of a fact git already holds.

4. **A skill never checks one surface's marker and stamps another's.**
   `/implement`'s position check moves to after the surface is entered, so its
   check and its stamp address one file.

5. **`/specify` reads position by script rather than by prose**, against the
   surface it is standing in at the time of the read, which is the main checkout
   before the effort is opened.

6. **`/prune` and `/survey` check the marker of the surface they run in on entry,
   and stamp it at close.** They run in the main checkout, which is a surface like
   any other, and they are what keeps its marker meaningful. They stamp because
   the marker records the tree a run *read*, not the tree a run committed, so
   reading is the act that earns a stamp.

7. **The role refuses, and the refusal lives in the skill rather than the
   script.** A run computing `role: implementer` refuses to integrate into the
   effort branch and refuses to dispatch; a run computing `role: orchestrator`
   integrates only in the surface it holds. `scope.mjs` reports and never exits
   non-zero on a role, exactly as it reports the isolation and lets
   `[[policies/execution]]` decide.

8. **An unresolvable surface reports `unknown` and refuses nothing.** Where the
   path matches no known shape, the role is `unknown`, every rule keyed on it
   declines to fire, and the run proceeds as it does today.

9. **`specs.md` defines the surface, the role, and the one-marker-per-surface
   rule**, in sections 18 and 20, so a conforming implementation is told what to
   compute and what to do with it.

10. **The suite moves in the same pass.** Every claim above that a script can
    check has an assertion, and the assertions this change invalidates are
    rewritten rather than left to fail.

11. **The two reviewer agents are dispatched once for the effort.** `/implement`
    stops running review between integrating a ticket and landing it, and runs it
    once after converge finds no gap, against the effort branch, before the work
    is handed over.

12. **The orchestrator ticks a criterion when it verifies it**, carrying inline
    what verified it. The rule that an author never ticks its own is **narrowed,
    not dropped**: a dispatched child still never ticks. Where the orchestrator
    built the ticket itself, which is what a wave of one does, the effort review
    is what judges it, and that review is now guaranteed to run.

13. **An open finding blocks the handover.** The rule that a review rejecting
    twice parks a ticket is replaced, because a finding against the effort names
    no single ticket. Every finding is fixed, ticketed, or accepted by the human,
    and one still open stops the pull request being marked ready.

14. **`specs.md` says review's unit is the effort**, and the sentence forbidding
    an agent from committing work that has failed review is restated so it is
    satisfiable. As written it cannot be met once review runs after every commit,
    and a requirement nothing can satisfy is one every implementation quietly
    ignores.

15. **A validated finding becomes a ticket, and the run schedules it.** The
    orchestrator validates each finding and either fixes it or writes it as a
    ticket, which then reaches the frontier like any other work. Nothing is
    amended across work that has left the run's reach, because nothing has: the
    effort branch is held in the orchestrator's own surface and its pull request
    is a draft, so every commit is still the run's to change. **The loop is
    bounded at two review rounds**, carrying forward the bound from the parking
    rule this replaces. A finding surviving the second round is recorded
    unresolved with what the review said, and the run stops and says so rather
    than scheduling a third.

# Acceptance Criteria

1. `scope.mjs read` and `scope.mjs read --json`, run in each of the four shapes in
   requirement 2, report the surface and role for that shape. The orchestrator's
   surface and a child's surface of the same effort no longer produce identical
   output.
2. A fixture covering all four path shapes, including a linked worktree outside
   `.aep/worktrees/`, resolves each to its stated surface and role.
3. `position.mjs read` on a stamped marker returns exactly three keys. A shape
   assertion rejects a fourth.
4. In `skills/implement.md`, the `position.mjs check` step is ordered after the
   step that enters the surface, and an assertion pins that ordering by name.
5. `skills/specify.md` invokes `position.mjs` rather than naming
   `position/marker.json` in prose.
6. The invoker set asserted by `verify.mjs` is exactly `implement`, `install`,
   `prune`, `specify` and `survey`, and the comment above it states why each is in
   it. A fixture in which `/prune` runs and then exits leaves a marker whose
   `head` matches the tree it read.
7. `agents/implementer.md` and `policies/execution.md` state their existing
   constraints as keyed on the computed role, and an assertion fails if either
   states the constraint without naming what it is keyed on.
8. `scope.mjs` exits 0 or 1 on the claim alone. A fixture in which the role is
   `unknown` exits with the same code as the identical fixture in which it
   resolves.
9. `policies/reporting.md`'s table has a row for every skill that reads position,
   and an assertion fails when a skill invokes `position.mjs` without a row.
10. `node src/scripts/verify.mjs` passes, and every assertion added here was seen
    to fail first against a deliberate perturbation that removed its subject.
11. `verify.mjs` asserts that section 18 names every surface kind and the role
    each carries, and that section 20 states one marker per surface and what a
    skill may therefore not do across two. The pattern is the block of assertions
    that already read the specification's text directly.
12. `skills/implement.md` names `[[skills/review]]` after converge and not in the
    per-ticket landing sequence. An assertion pins both halves, because either
    alone is satisfied by a document that runs review twice.
13. `policies/execution`'s ticking section says the orchestrator ticks what it
    verified and that a dispatched child never ticks its own. An assertion fails
    if the unqualified sentence survives beside the narrowed one, since two rules
    that disagree is worse than the old one alone.
14. The rule parking a ticket after two rejections is gone, and an open finding
    is stated as blocking the pull request being marked ready. An assertion fails
    if the parking rule survives anywhere in the shipped tree.
15. `verify.mjs` asserts that the specification gives review's subject as the
    effort, no longer says review runs per ticket, and states the commit rule in
    a form an implementation running review after the commits can satisfy.
16. `skills/implement.md` states that a validated finding becomes a ticket which
    reaches the frontier, and states the two-round bound. An assertion fails if
    the correction path is described without the bound, since a loop with no
    stated end is the failure the rule it replaces existed to prevent.

# Constraints

- **Computed, never judged.** The surface and the role are functions of git output
  and a path. No model decides either, so two agents in one surface cannot
  disagree about what they are.
- **The refusal is the skill's, not the script's.** This is the shape effort 54
  established: `scope.mjs` reports the isolation and `[[policies/execution]]` keys
  the decision on it. Role follows the same split, so there is one place a reader
  looks for what a run does about what a script found.
- **Fails open.** `scope.mjs`'s own `resolveBase` already establishes the
  direction: a wrong answer widens what is permitted rather than narrowing it,
  because the worst outcome of the alternative is blocking correct work. A role
  that will not resolve therefore refuses nothing.
- **Path comparison is built from git output.** `resolveScope` carries a comment
  earned the hard way: on Windows one spelling of a path can arrive as an 8.3
  short name, which `path.relative` cannot reconcile, and what it returns then
  matches nothing while reading as though it worked. Any new comparison is subject
  to the same hazard.
- **Shipped text cites only what resolves where it is read**
  (`[[rules/authoring]]`). The `specs.md` section numbers in this spec may not
  travel into `src/`.
- **Nothing here enters the live surfaces.** Two of this clone's four surfaces
  hold running agents. This effort's own work happens in its own surface and reads
  no git state in theirs.

# Out of Scope

- **Storing the role, the effort, or the surface in the marker.** Effort 54 drew
  this boundary and restated it as its requirement 7, and `specs.md` section 20
  forbids it outright. This change is designed around that boundary rather than
  against it: everything it adds is derived.

- **Changing how drift is computed.** `tree` and `head` keep their meanings and
  their comparison is untouched, which is effort 54's boundary still holding. What
  changes is which surface the comparison is made for, not the comparison.

- **Removing `sessions`.** Two agents sharing the main checkout stays reachable,
  since the skills in requirement 6 run there, and that is the condition the field
  exists to make visible.

- **A position step for `/plan`.** `/plan` enters the effort's surface and reads
  no marker today. Giving it one is a behavioural change this problem does not
  require, and adding it silently is how a scope grows.

- **A position step for `/domain`.** It was in this spec's first draft and came
  out at `[[skills/plan]]`. `[[policies/reporting]]` names `/domain` as a stage of
  the turn it is inside, alongside `[[skills/review]]`, `[[skills/tdd]]` and
  `[[skills/prose]]`, and a stage opens no report of its own. It has no scope read
  either. Giving it a position step would make it the one stage in the protocol
  that reads position while its parent already did.

- **Fixing `isolationOf`'s enforcement.** It computes `worktrees.length > 1`,
  which describes the clone rather than the checkout, which is why the main
  checkout of this clone reports `checkout, enforced` while being the surface that
  needs one most. Effort 54 raised this and did not take it. Neither does this,
  and for the same reason: every rule here keys on the kind.

- **A third review axis.** Correctness and standards stay the two, and
  architecture stays folded into standards. Only review's subject and its moment
  change; what each agent reads and how the two are reported does not.

- **Per-ticket review kept as an option.** It is removed, not made configurable.
  A protocol that supports both units has to say which one a conforming
  implementation picks, and that is the decision this effort is making.

- **Reviewing a partial effort.** Review runs once, after converge finds no gap.
  Not on a wave boundary, not on a timer, and not on request mid-run.

- **The two-object rule.** Still one issue and one pull request per effort. A
  finding that becomes a ticket becomes a file under `tickets/`, as every ticket
  already is, and never a third tracker object.

- **Cross-clone anything.** Out of git's reach, as it was for effort 54.

- **Retrofitting efforts 47 and 48.** They finish under the shape they started in,
  which is the boundary effort 54 already drew for them.

# Assumptions

- `.aep/worktrees/<effort>/{_run,<ticket>}` is the only shape AEP creates, and
  `_run` is reserved. Read from `skills/specify.md` and `skills/implement.md`, and
  matched against the four surfaces this clone currently holds.
- No runtime places its own worktrees under `.aep/worktrees/`. Section 18.1 says a
  conforming implementation must not create, name, or remove a worktree the
  runtime owns, and `.aep/worktrees/` is AEP's own, so the collision would be the
  runtime reaching into AEP's directory.
- A child's surface is a sibling of `_run` under the effort directory. Observed:
  `.aep/worktrees/47-post-merge-labels/03-the-ladder-as-a-value` beside
  `.aep/worktrees/47-post-merge-labels/_run`.
- The ticket-branch naming rule in `[[rules/version-control]]`, `<effort>/<ticket>`,
  is this repository's and not the protocol's, so the derivation reads the path and
  never the branch name.

# Risks

- **The derivation is wrong on a path nobody anticipated**, and a run refuses an
  act it should have taken. Requirement 8 is the mitigation: an unresolved role
  fires no rule. It would show up as a run reporting `role: unknown` while
  standing somewhere that plainly has one.
- **The refusals are written where they cannot fire.** This is the failure
  `[[rules/authoring]]` names: a guard matching something travelling with the thing
  it checks rather than the thing itself. Criterion 10 is the mitigation, and it is
  the criterion most likely to be skipped.
- **The invoker-set assertion is loosened rather than rewritten.** It is the one
  assertion this change is guaranteed to break, and the cheap way past it is to
  stop asserting the set. That would remove the check that noticed this problem in
  the first place.
- **The correction loop does not terminate.** A finding becomes a ticket, the
  ticket lands, the effort diff changes, and the changed effort is reviewed again.
  Requirement 15 bounds it at two rounds, carrying forward the bound from the
  parking rule it replaces. Unbounded, it would show up as a run that keeps
  finding work and never reaches the handover, which is the failure mode the old
  "two fix attempts, then park" existed to stop.
- **The narrowed ticking rule is read as a dropped one.** Requirement 12 keeps
  "a dispatched child never ticks its own" and gives up only the case where the
  orchestrator built the ticket itself. A reader skimming for the old sentence
  finds it changed and concludes the guarantee is gone. Criterion 13 is written
  against exactly that: it fails if the old sentence survives beside the new one,
  because two rules that disagree are worse than the weaker one alone.
