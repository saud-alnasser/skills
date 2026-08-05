---
title: fix(tools): the git reference names where the Marker is read
status: resolved
blocked-by: []
part-of: fieldwork
---

## Problem

The git reference's Marker section gives the two check invocations against a placeholder and never says where its value comes from, so the path rides on the reader's memory of the protocol file. In the field a wrongly recalled path found no file and produced a confident false verification report — on the one artifact whose whole job is proving the discipline ran. The failure is invisible when it fires.

## Outcome

Shipped behaviour. The git reference's Marker check opens with the read that produces the placeholder's value — the marker file at its position path — so the skills that open with a verification report reach the correct path through the file they already consult for the invocations. No skill gains a restatement; the single home is the invocation home.

## Acceptance

- The git reference's Marker section names the exact marker path and the read that yields the commit to check.
- No spine skill restates the path, and the suite's single-home guard covers it — confirmed to fail against a restatement planted in a skill.
- The suite passes.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. Three restatement sites (commit, handoff, the protocol template) now reach the path by pointer; the pre-existing shape assert that *required* the path in /commit moved with the design, keeping the payload obligation. This repository's derived `.claude/tools/git.md` synced its Check-the-Marker entry in the same pass — demanded verbatim by the derived-match assert, distinct from ticket 07's policy adoption. Review: Spec axis clean, guard independently re-proven against a plant; Standards' three judgement calls dispositioned — the read-don't-recall restatement in the protocol template was trimmed (fixed); the missing-file overlap resolved as two deliberate homes, the invariant in the protocol (a pre-existing assert requires it — it is why the Marker is safe outside the always-on file) and the operational read in the git reference, each pointing at the other (accepted, recorded here); the single-home guard living as a ticket assert rather than a `$rulePattern` row is accepted because the table cannot express the migration-row exemption (recorded here). "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
