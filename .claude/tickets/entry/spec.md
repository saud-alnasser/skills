---
status: implemented
sources:
  - CLAUDE.md
  - skills/configure/CLAUDE.template.md
  - skills/design/SKILL.md
  - skills/implement/SKILL.md
  - specs.md §5, §10, §11
  - scripts/verify.ps1
  - .claude/decisions/0061-unplanned-work-enters-the-spine-from-the-boot-tier.md
  - .claude/contexts/skill-authoring.md
---

# feat(rules): a request reaches its stage without being named

## Problem

Describing a change gets you routed to the wrong stage, and then told to go back.

Every spine stage is model-invoked except the one that plans, which is marked
user-invoked. So a description of a problem selects the build stage, which finds
no ticket, and hands back with an instruction to type the plan command — the one
command the model is structurally forbidden to select. The human types it, and
the work starts where it should have started one round trip ago.

The cost is not only the round trip. It trains the maintainer to name stages
before describing work, which is the opposite of what the protocol is for: the
protocol is supposed to know which activity is taking place.

A second, smaller version of the same friction sits after a plan is approved.
The build stage takes one ticket per invocation, so an approved plan of five
tickets is five more invocations, each of them a request to continue doing
what was already agreed.

## Goal

A free-form request reaches the right stage on its own, having said out loud
where it is entering and why, and — once a plan is approved — the build runs
through to the next point the plan itself says a human is needed.

## Constraints

- **The entrypoint is always-on and budgeted.** Whatever is added is paid for on
  every turn, including turns that route nothing, and the budget is asserted
  rather than estimated.
- **A question must still get an answer.** The guard separating a question from
  a change request is what currently makes the entrypoint cheap for
  conversational turns, and routing must not weaken it.
- **The approval gate stays.** The plan stage stops at its deliverable and never
  invokes the build stage, because that invocation is the human's approval.
  Nothing here touches it.
- **Human authority is not delegated.** A decision that needs the human still
  stops for the human, and continuation must not resolve one on its own.
- **Nothing committed may assume the framework is installed.** A reader without
  the plugin follows the same pointers and reads the same files.
- **The shipped template moves before the installed copy does**, and both move in
  the same change.
- **The specification is amended in the same change**, since this alters how the
  protocol determines the activity.

## Architecture

Three moving parts, no new system.

**The route is stated in the always-on tier.** The entrypoint already carries the
paragraph separating a question from a change, and already requires a
classification to be stated before anything is touched — what kind of change,
how much process. It gains one field: where it enters. The destinations are the
existing stages, and the choice between them is dominated by repository state
rather than by judgment — whether a claim is held, whether a ticket exists,
whether the request carries a reference from outside, whether the repository is
configured. Only two parts are judgment: question versus change, and which of
plan-or-build applies when a ticket might exist.

This is placed in the always-on tier and nowhere else because the failure is a
skill *not being selected*. A router that is itself a skill has to be selected
too, so it cannot fix the case it exists for. The always-on tier is the only one
that fires without being chosen.

**Planning moves across the invocation axis.** This repository already sorts
skills by whether they must fire from a description of the problem or are typed
by a human. Planning is on the typed side; the whole request is that it belongs
on the other. Its selection condition has to be rewritten at the same time,
because for a model-invoked skill the description is the entire basis on which
it gets chosen — and the existing one is broad enough to reach questions.

**The stated route is what makes a misfire cheap.** Planning is the expensive
stage, so making it selectable means it will sometimes fire when a two-line
answer was wanted. Announcing the route before entering turns that from a
wasted grill into a line and a correction. The announcement is not presentation;
it is the mitigation that lets the selection be imperfect.

**Continuation is bounded by what the plan already declares.** The build stage
runs on past a delivered ticket to the next one that is not blocked, and stops
where the plan says a human is needed. No new bound is invented: tickets already
carry declared increments, typed by whether they need the human present, and the
sub-agent rules already treat two of those types as requiring one. The stopping
points are therefore chosen at plan time, by the human, on the tickets — and the
build stage only obeys them. It also stops, as it already does, on a blocked
ticket, on a failure, and on a decision discovered undeclared.

Note what continuation does *not* get here: this repository builds one branch
and one commit per effort, so a set of tickets is not dispatched in parallel and
the frontier is worked in sequence. Continuation is the shipped behaviour;
parallel dispatch is a separate axis that this repository has already recorded
as not running.

## Approach

The riskiest part is the selection condition, and it is risky in a way that only
shows up in use: prose that reads correctly can still over-fire or under-fire.
So the flag and the description move together with the assertion that pins them,
and the route statement lands in the same ticket — the mitigation and the risk
must not be separable, or a misfiring stage arrives without the line that makes
it cheap.

Continuation is independent of routing and is cut as its own ticket. It gates
nothing and is gated by nothing; it can land in either order.

The recorded reason for the current arrangement lives as the name of an
assertion rather than as a Decision, which is why it read as an unexamined
convention until the suite was searched. Rewriting that assertion is part of the
work, not incidental to it, and the reasoning it carried moves into a Decision
where the next reader will find it.

The general test behind the axis — must this fire from a description of the
problem, or does a human type it — is likewise recorded only in a comment beside
the assertions. It is healed in place, into the domain context that already
defines both kinds of skill.

Options considered and rejected are recorded in the Decision this effort
produces: a router skill, a sharpened description with the flag left in place, a
prompt-submit hook, and the classification-and-planning system architecture the
effort was originally proposed as.

## Acceptance criteria

- A request describing a change, with no ticket and no command typed, reaches
  the planning stage.
- Before anything is touched, one line states what kind of change it is, how
  much process it gets, and which stage it is entering.
- A question still gets an answer and enters no stage.
- The build stage, on finding no ticket for a request, enters planning rather
  than instructing the human to.
- After a plan is approved, delivering a ticket is followed by the next
  unblocked ticket without further instruction.
- Continuation stops at a ticket whose declared increment needs the human, and
  says which ticket and which question.
- The specification describes entry and continuation as they now behave.
- The always-on entrypoint stays within its asserted budget.
- The shipped template and this repository's installed copy carry the same rule.

## Risks

- **Planning fires on a question.** Most likely failure, detected the first time
  a conversational turn opens a grill. Mitigated by the stated route, which caps
  the cost at one line; if it recurs, the selection condition is tightened
  before anything structural is reconsidered.
- **Planning fails to fire on work**, leaving the original problem in place with
  extra machinery. Detected the same way — by the next request that gets routed
  to the build stage and hands back. This is the failure that would send the
  design back to the prompt-submit hook.
- **Continuation runs further than intended**, because a plan declared no
  increments where a human was in fact wanted. Detected at review, and the
  correction is in how increments are declared rather than in the bound.
- **The single-home guard for the new rule matches its own wording** rather than
  the subject, and passes while a restatement sits in the tree. This is the
  named recurring failure for guards here; it is caught by confirming the guard
  fails against a deliberate reintroduction before trusting it.

## Out of scope

- **Runtime independence and the second-harness adapter.** Agreed as a separate
  effort, later. Nothing here needs undoing for it: this places content *in the
  boot tier*, and where the boot tier lives is exactly what a harness binding
  defines.
- **A multidimensional work model, a planner, an executor, or an evaluator.**
  Rejected in the Decision, with reasons.
- **Flipping any other skill across the invocation axis.** Configuring,
  surveying, triaging, and handing off stay typed; they are deliberate acts.
- **Parallel dispatch of a ticket set.** A second orchestration axis, already
  recorded as not running in this repository.
- **Changing the approval gate between planning and building.**
