# fix(configure): the map template stops contradicting the ticket format

Status: resolved
Blocked by: 01
Part of: fieldwork

## Problem

Four defects in one file, each of which forced an improvised call in the field. The prose says a decision ticket differs from an ordinary one in exactly two ways while its own template silently makes a third — a bare-question title where the ticket format requires a Conventional Commit subject. Decision tickets carry their own two-digit numbering even where the tracker assigns ids, so every edge forces a lookup between two numbering systems with no stated relationship. A decision ticket's blocking edge reads as a stacking instruction on a stacking repository, which is meaningless for work that produces no branch. And nothing says what the design document becomes once the map it proposed exists on the tracker.

## Outcome

Shipped behaviour. The map template states three differences and the title rule with its rationale — a decision ticket's commit is the record of the answer, usually `docs:`, so the Conventional subject still writes itself. Where the tracker assigns ids, its id is the ticket's only number and edges use it. A decision ticket's edge is stated as always answer-gating, never a stacking instruction, whatever the repository's version-control policy makes edges mean for build tickets. One sentence settles the design document: until the map is created it is the map; afterwards the created map supersedes it, and the proposal it holds is not mirrored there.

## Acceptance

- The map template's example title is in Conventional Commit form and the prose counts three differences, with the rationale stated.
- Numbering defers to the tracker where the tracker assigns ids; no artifact carries two ids for one ticket.
- The answer-gating sentence and the design-document disposition sentence each appear exactly once, in this file.
- The suite guards the template's title line against regressing to a bare question, and the guard is confirmed to fail against the old form.
- The suite passes.

## Comments

Built on the shared `fieldwork` branch — the user's standing instruction for this effort overrides the per-ticket convention: the whole effort is one unit of work, one branch carrying one commit, and each ticket lands by amending it. Review: Spec axis clean; Standards' three findings fixed in the diff (single-home guards for the two placed rules, both plant-proven; the title clause now defers to the tickets policy), plus one contradiction of ADR 0036 this file carried ("a label on GitHub") fixed under its own guard. "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
