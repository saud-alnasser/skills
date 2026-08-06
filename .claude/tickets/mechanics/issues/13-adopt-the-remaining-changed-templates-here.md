---
title: chore(skills): adopt the remaining changed templates here
status: resolved
blocked-by: [04, 09, 11]
part-of: mechanics
---

## Problem

The templates change before this repository adopts them, so after the shipping tickets land, this repository is running the previous marker rule, the previous stage table, and the previous evidence policy while shipping the new ones. That gap is deliberate and bounded, and closing it is what this ticket is.

The gap is not only textual. The marker file in this clone carries one fact, and the rule that reads it will be expecting two — so adoption has to cover the position state as well as the installed policies, and it is the one part of this effort that touches something never committed.

## Outcome

The installed protocol file, the installed evidence policy, and the installed git guide carry what their templates carry. The stage table carries this repository's actual set, derived from the skill defaults plus whatever is local to it, with the current divergence gone.

This clone's marker holds both facts, produced by the documented recipe rather than by hand, so the first stage to run afterwards takes the cheap path rather than falling back.

The ignore rule that keeps position state out of the repository still covers the marker unchanged — the file gained a field, not a location.

## Acceptance

- Each installed file carries the same text as the template it ships from, asserted once per file and in this ticket only.
- The installed stage table has exactly one row per stage, and no guide named by a skill default is missing from its row without the row recording why.
- This clone's marker holds both facts, and the tree fact was produced by the documented recipe.
- A stage run immediately after adoption takes the cheap path and says so in its verification report.
- Nothing committed by this ticket depends on any position state — deleting every ignored file under the protocol directory loses this clone a shortcut and no one else anything.
- The suite passes.

## Comments

The adoption covered five files, not the three this ticket named: the router, the evidence policy
(already adopted early under 11) and the git guide, plus the **context and decisions policies**,
which tickets 06 and 07 changed and this ticket's own criterion covers — "each installed file
carries the same text as the template it ships from". Ticket 12 had migrated this repository's
data to declared fields while those two policies still described the prose format, so the gap was
live rather than theoretical.

The git guide is *derived* rather than copied (ADR 0019), so it is checked by content — the entry
and the two things about it that are not obvious — instead of by text equality.
