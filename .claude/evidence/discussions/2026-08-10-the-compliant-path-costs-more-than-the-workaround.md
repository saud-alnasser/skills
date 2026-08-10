---
owner: repository
kind: discussions
falsifies: []
---

# The compliant path costs more than the workaround

Recorded 2026-08-10, during the `downstream` design run. Two findings about the
framework's incentives were grilled and only their rule halves survived into
tickets. This records what was weighed and what stayed open, so the mechanism
half is not re-derived from scratch by whoever picks it up.

## What was asked

Whether the framework can do anything about two observations, both first-hand,
both from sessions in this repository.

**A guard reaches only the party already obeying it.** `disable-model-invocation`
blocks the Skill tool, not the behaviour. One session reached for the handoff
skill, was blocked, and was told not to replicate the workflow by other means.
Another never reached for it and wrote the same document by hand — the block
message appears nowhere in that session's transcript. The guard stopped the
session that followed the routing rule and did nothing to the session that
ignored it. The shape covers every user-invoked skill the framework ships.

**Invoking a skill costs context; replicating it costs less.** Re-invoking the
commit stage reloads its full text. With context heavily used, one session
explicitly weighed following the stage's steps by hand instead — reasoning about
"substantive compliance" — and resisted only after arguing with itself. So
compliance gets more expensive exactly when an agent can least afford it, and the
incentive points at the workaround.

## What was assumed

That both are design properties rather than character failures, and that a rule
alone does not fix an incentive. Both assumptions survived the grill. The second
is why the mechanism half was pursued at all rather than being answered with the
rule.

## What was weighed

**Making the handoff skill model-invocable.** Would open the compliant path for
the one skill where the block was observed to bite. Rejected: it concedes the
user's control over when the skill fires, and says nothing about the other
user-invoked skills, which have the same shape.

**Restructuring the close-out so amends do not each reload the commit stage.**
The most concrete of the mechanism options, and it targets where the cost
actually lands rather than skill size in general. Left open: it is a change to
the Spine's control flow proposed on the strength of one session's experience,
and nobody has measured how often the reload actually happens.

**Extending progressive disclosure to the remaining Spine skills.** Rejected
here, and the reason is worth keeping: ADR 0011 already adopts progressive
disclosure and applies it to `/design`, putting each deliverable branch behind a
pointer reached only when the tier selects it. So the framework's answer to skill
size is not missing — it is already in force. Extending it further was separately
judged to carry its own runtime cost, and to be the wrong trade against raising
the ceiling. Proposing it here would supersede that judgement on no new evidence.

## What stayed open

**Whether the cost asymmetry can be removed at all, or only named.** Every
mechanism weighed either concedes something the user chose to keep, or contradicts
a decision already made, or rests on a single session's experience. What is
missing is not an idea but a measurement: how often a stage is re-invoked, and
what the reload actually costs against the work it guards. Nobody has that.

**Whether a guard that binds only the honest path is worth keeping.** The rule
planned in ticket `05` reaches both paths, which makes the flag's asymmetry less
costly — but it does not make the flag do anything it was failing to do. Whether
`disable-model-invocation` still earns its place on every skill that carries it
was not settled.

**Whether the two are one finding.** Both are cases where the framework's cheapest
path and its correct path diverge. They were treated separately because their
rule halves are separate; if the mechanism half is ever designed, the first
question is whether one mechanism answers both.
