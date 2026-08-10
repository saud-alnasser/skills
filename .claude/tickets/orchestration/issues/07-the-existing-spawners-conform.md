---
owner: repository
title: feat(skills): the existing spawners conform to the policy
status: resolved
blocked-by: [02]
part-of: orchestration
---

## Problem

Four shipped skills spawn sub-agents and each carries its own fragment of the rules. One of the fragments is false: it instructs the author to quote vocabulary into a brief rather than pointing at the file, on the belief that a child has no context of its own. A child inherits the whole entrypoint hierarchy and the always-on rules; what it lacks is the conversation and the on-demand contexts, which it can read. The instruction spends the parent's window to buy nothing, and it is shipped guidance telling users to do the same.

This ticket is also the test of whether the design is additive. If conforming these four requires changing what any of them does, the claim that orchestration is a system stages opt into was wrong.

## Outcome

The four spawners point at the sub-agent policy for the rules that are now the policy's, and keep the reasoning that is genuinely theirs — why two axes must not see each other's findings, why isolation is not the same as not waiting. Neither of those is a dispatch rule; both are statements about that stage's own correctness, and moving them would be the single-home rule misapplied.

The false instruction is removed and replaced with what is true: a child arrives bound by the entrypoint hierarchy and the always-on rules, holds none of the conversation, and reads what it needs by path.

Where a spawner types a brief at the call site that a shipped role now covers, it names the role instead. Behaviour does not change; the brief stops being retyped.

## Acceptance

- Each of the four spawners reaches the sub-agent policy and restates none of it.
- The reasoning specific to a stage stays with that stage; the suite asserts both surviving statements are still where they were.
- The falsified brief-construction instruction is gone, and what replaces it states the inheritance correctly.
- No spawner changed what it does — the diff for this ticket removes and redirects text, and adds no behaviour.
- Spawners covered by a shipped role name the role rather than retyping its brief.
- A single-home guard covers each rule moved into the policy, confirmed to fail against a reworded restatement planted back in a skill.
- The suite passes.

## The additive test: passed

Nothing any of the four does changed. Modes are unmoved, each still dispatches, and both stage-owned statements — why the axes must not see each other's findings, and why isolation is not the same as not waiting — are where they were. What moved was text, into the roles the stages now name.

## The one that nearly got through

Repointing the review assertions at a `$reviewSurface` that unioned the stage with **both** roles made a Standards guarantee satisfiable by the *Spec* role. A review proved it: delete the smell-marking rule from `review/SKILL.md` and from `standards-reviewer`, and the assertion stayed green on `spec-reviewer`'s copy. The block exists to keep the axes apart, and the union could not see one crossing — a guard weakened to fit the change it was meant to police.

Each assertion is now scoped to its own axis, and the exploit is confirmed dead: removing the marking rule from `standards-reviewer` alone now fails, with `spec-reviewer` untouched.

Two guarantees were also *deleted* rather than relocated when the per-axis briefs came out — the Spec axis's word cap, and the obligation to name a baseline smell and quote its hunk. Both restored, in the stage and the role respectively. Deleting a guarantee while claiming to move it is the same defect as the union, arrived at from the other side.

## Discharged from 02 and 03

Both deferred single-home guards are placed. `what a child inherits` had a second home stating its *opposite*, which counts: a rule contradicted elsewhere is not single-homed, it is disputed. `inputs by path, never pasted` had one in `/review` along with its argument. The `researcher` retype that ticket 03 recorded is gone too — `/research` §2 now names the role rather than restating the source discipline.

## Noted, not fixed

`survey` and `codebase-design/DESIGN-IT-TWICE.md` now read `.claude/policies/sub-agents.md` without declaring it, because neither carries a `Policies:` line — a Primitive and an on-ramp have no router row to declare against. Giving them one changes what a Primitive *is*, which is a design decision rather than a conformance fix.
