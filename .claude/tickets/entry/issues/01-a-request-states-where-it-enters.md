---
title: 'feat(rules): a request states where it enters, and planning is selectable'
status: resolved
blocked-by: []
part-of: entry
---

## Problem

Planning is the one spine stage the model may not select. So a description of a
change selects the build stage, which finds no ticket and hands back with an
instruction to type the planning command — which the model was forbidden to
select on its own. The human types it, and the work begins one round trip after
it could have.

The reason planning was held on the typed side of the invocation axis is
recorded only as the name of an assertion, never as a Decision, so it reads as
convention until the suite is searched.

## Outcome

Describing a change reaches the stage that plans it, without a command being
typed, and says where it is going before it goes there.

Before anything is touched, one line states what kind of change this is, how
much process it gets, and which stage it is entering — so a wrong route costs a
correction rather than a grill. A question still gets an answer and enters
nothing.

The build stage, on finding no ticket for a request, enters planning itself
instead of instructing the human to.

## Acceptance

- A request describing a change, with no ticket and no command typed, reaches
  the planning stage.
- One line stating the kind of change, the amount of process, and the entry
  stage precedes any file being touched.
- A question is answered and enters no stage.
- The build stage, given a request with no ticket, enters planning rather than
  handing back an instruction.
- The planning stage is model-invoked, and its selection condition distinguishes
  a change request from a question.
- The rule stating the route is carried by the always-on tier, and by both the
  shipped template and this repository's installed copy.
- The always-on entrypoint remains within its asserted budget.
- The specification describes how the protocol determines the entry stage.
- The single-home guard for the new rule is confirmed to fail against a
  deliberate reintroduction before it is trusted.
- The comment beside the invocation assertions points at the domain context that
  now states the axis test, rather than restating it.

## Comments

**The rule and its destination table were split, which the spec did not anticipate.**
The spec put the whole rule in the always-on tier. Built that way it failed two
standing assertions: nothing in that tier may assume a command exists, because a
teammate without the plugin still has to be able to follow it — and the addition
put the tier over its measured ceiling.

The obligation stayed in the tier and the destination table moved to the router,
which is where concrete routing already lives and which names commands freely.
This was forced by the constraint rather than chosen for the budget; the ceiling
relief was a consequence, and the ratchet comment records it that way so a later
reader does not learn the wrong lesson from it. The addition still exceeded the
ceiling after the split, and the ceiling was raised to 7,300 with the reasoning
the ratchet requires.

Recorded here rather than by editing the spec: an accepted spec's reasoning is
frozen, and it is corrected by supersession, not rewriting.
