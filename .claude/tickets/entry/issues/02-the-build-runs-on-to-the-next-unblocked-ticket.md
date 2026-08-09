---
title: 'feat(implement): the build runs on to the next unblocked ticket'
status: resolved
blocked-by: []
part-of: entry
---

## Problem

The build stage takes one ticket per invocation. An approved plan of five
tickets is therefore five more invocations, each one a request to continue doing
what was already agreed — and each one a place where the maintainer has to be
present for no decision.

## Outcome

Delivering a ticket is followed by the next ticket nothing blocks, without being
asked again.

It stops where the plan already says a human is needed: a ticket carrying a
declared increment of a type that requires one. No new bound is introduced — the
stopping points were chosen at plan time, on the tickets, and this only obeys
them. It also stops where the stage already stops: a blocked ticket, a failure,
and a decision discovered undeclared.

When it stops, it says which ticket stopped it and what is being asked.

## Acceptance

- Delivering a ticket is followed by the next unblocked ticket in the effort,
  with no further instruction.
- Continuation halts at a ticket whose declared increment needs the human, and
  names the ticket and the question.
- A declared increment that needs nobody present does not halt continuation.
- Continuation halts on a blocked ticket, on a failure, and on a decision
  discovered undeclared, exactly as a single run already does.
- Continuation halts when no unblocked ticket remains, and reports what was
  delivered.
- Each ticket in a continued run is verified, reviewed, and closed out on its
  own terms — continuation changes what happens next, never what a ticket's own
  build does.
- The specification describes continuation and its stopping conditions.
