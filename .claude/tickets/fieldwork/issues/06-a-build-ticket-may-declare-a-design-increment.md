---
title: feat(skills): a build ticket may declare a design increment
status: resolved
blocked-by: [01]
part-of: fieldwork
---

## Problem

Some decisions cannot be answered before partial code exists — whether a surface reads as raised needs real rows; how a table behaves in another locale needs a populated table. Today such a question is either guessed at design time and recorded as settled, or it ambushes the build: the implement stage hits it and must choose between deciding silently and handing back blocked, both bad, and the map that spawned the ticket cannot exit honestly because its condition demands nothing be left to decide.

## Outcome

Shipped behaviour. The ticket format gains an optional declared-increments section, written only at design time, naming the step, the question, and the type. On reaching a declared increment the implement stage invokes the design activity scoped to that increment only, never widening: AFK types resolve inline and land in the same commit; HITL types stop at a point the human could schedule, holding the claim — not `blocked`, because the plan is right and only the human is absent. The guardrail ships in the same edit: the implement stage may never invent an increment, and a decision discovered undeclared is still `blocked`, exactly as today. The map's exit condition relaxes to match — done when every remaining decision is settled or declared as a scoped increment. An increment's resolution is recorded where any design decision is: an ADR when it clears the bar, the design document otherwise.

## Acceptance

- A ticket can declare increments with step, question, and type; the design stage's text says it writes them and the tier gate still applies.
- The implement stage resolves a declared AFK increment inline in the ticket's commit, and stops at a declared HITL increment holding the claim, stating the distinction from `blocked`.
- An undeclared decision discovered mid-build still hands back `blocked`, and the guardrail sentence lands in the same change as the section it bounds.
- The map exit condition accepts settled-or-declared, and a map exiting with declared increments names which tickets carry them.
- The specification's workflow section already carries the amendment (ADR 0037); this change conforms to it.
- The suite asserts the section exists in the ticket format, the guardrail exists in the implement stage, and the exit condition names both halves — each guard confirmed to fail against its removal.
- The suite passes.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. Four placed rules, each with a single-home guard proven in both directions: against removal of the guarded text, and against reworded restatements planted in other skills. Review: Spec axis clean on every bullet including the same-edit guardrail constraint and specs.md conformance; Standards' three hard findings fixed — the design stage's restatement of the timing rule trimmed to a pointer and the guard broadened to the subject (it had matched only the template's wording, and the restatement was the live proof), the tickets template no longer claims the type vocabulary decides presence (that is `/implement`'s statement, which is what dissolves the `task`-either-vs-AFK contradiction the pointer had created), and the design assert re-anchored off a travelling phrase. Two judgement calls: the maps intro now points at the normative exit test instead of paraphrasing it (fixed); the literal type list in the declaration example stays as illustration with semantics delegated to the maps policy (accepted, recorded here). "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
