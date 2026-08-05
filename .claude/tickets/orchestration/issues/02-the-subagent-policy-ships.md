---
title: feat(skills): the sub-agent policy ships
status: resolved
blocked-by: [01]
part-of: orchestration
---

## Problem

There is no single statement of what a sub-agent may do with the framework's systems. Four skills each carry a fragment, none carries the whole, and a fifth stage about to dispatch children has nothing to point at. Without one home the rules are restated per caller, which is how one of the four came to be wrong about what a child inherits.

## Outcome

One policy, installed by the configure stage and reached from the router like every other policy, stating the sub-agent contract in three parts.

**What a child may use.** It reads the Codebase, Context, and Decisions and verifies at use exactly as a session does — it inherits the entrypoint hierarchy and the always-on rules, so it arrives already bound by them and the policy narrows rather than bootstraps. Knowledge it finds false becomes a drift finding, which the evidence policy already permits from whoever finds it.

**What is closed to it.** It writes no knowledge layer, claims nothing, commits nothing, pushes nothing, and integrates nothing. It never approves a permission prompt or supplies consent for another agent, and a denial is not relayed around. A decision it reaches is recorded and stopped on, never taken.

**The two shapes that cross the boundary.** The brief a parent writes — objective, inputs as paths rather than pasted content, the files this child owns, the return shape, done-criteria, and a cap. And the change record a child writes — what changed, why, what it could not do, and any decision it stopped on — of which the child returns only the path and a compressed summary. The record is per-clone state, so the ignore rule's membership test covers it.

The record is a **manifest, not a report**: the orchestrator navigates the child's workspace by it and integrates from it, so the format is specific enough to be reconciled against the child's actual diff. That bar is the format's, stated here; what the orchestrator does with a mismatch is the build stage's.

## Acceptance

- The configure stage installs a sub-agent policy, and the router's stage table reaches it from every stage that dispatches.
- The policy states the three parts above, and states the inheritance fact rather than leaving a reader to assume a child starts bare.
- The brief template names all six of its parts, and a brief missing one is identifiable as incomplete.
- The change record format names what changed, why, what was not done, and any decision stopped on.
- The format is specific enough that a record can be reconciled against a diff; a record that cannot be is identifiable as a defect rather than as terse.
- The policy states that the record is per-clone state and says where it lives; the ignore rule's membership test covers it without a new exception.
- The policy carries the consent boundary — no agent approves for another, no denial is relayed — as a rule rather than as advice.
- No skill restates any part of the policy; the single-home guard for each placed rule is confirmed to fail against a reworded restatement planted elsewhere.
- The suite passes.

## Added during the build

**A child dispatches nobody.** Orchestration is one layer deep — the user's constraint, set while this ticket was being built. The harness permits nesting up to three layers, so the policy states both the bound and that it is the workflow's choice rather than a limit it inherited. Guarded, and the guard is confirmed to fail against an inverted statement as well as against a deletion.

## Accepted at review

The closed list says a child "claims nothing, commits nothing, pushes nothing, and integrates nothing", and the last two restate `engineering.template.md`'s never-push rule that a child already inherits. Accepted as the ticket's own wording: the list is one closed boundary, and splitting it into two novel prohibitions plus a pointer costs a reader more than the duplication does. Do not re-raise.

## Deferred to 07, deliberately

Two rules this policy places have a second home that only ticket 07 can remove, so their single-home guards are written there rather than here — `verify.ps1` names both at the `$rulePattern` table:

- **what a child inherits** — `codebase-design/DESIGN-IT-TWICE.md` states its opposite.
- **inputs by path, never pasted** — `review/SKILL.md` states it and the same argument for it.
