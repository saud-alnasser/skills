---
owner: repository
title: feat(skills): roles ship as named definitions
status: resolved
blocked-by: [02]
part-of: orchestration
---

## Problem

Every brief in the tree today is typed out at the call site against a built-in general-purpose agent. A second caller wanting the same reviewer retypes the whole thing, which is exactly the cost the survey found in the upstream this framework derives from — orchestration as a technique documented inside one skill rather than a reusable artifact. Meanwhile the framework has no way for a caller to name what it wants dispatched.

## Outcome

Shipped role definitions, referenced by name. Identity comes from the definition's name rather than its path, so a caller holds a name and nothing else — the mechanism that makes orchestration additive.

The roster is small on purpose: the published guidance is that three focused agents outperform five scattered ones, and a role nobody dispatches is a definition to maintain for nothing. It covers the axes the review stage already runs, the investigation the research stage already dispatches, and the builder the build stage will dispatch. Each points at the sub-agent policy rather than restating it, and each denies itself the tool that would let it dispatch further — one layer, enforced by the definition rather than by a sentence.

Two facts about what ships constrain the definitions and are recorded with them: a plugin's definitions silently ignore three frontmatter fields, so a constraint needing one of those is stated in the policy as an obligation instead; and a backgrounded child gets a narrower built-in tool set with no error reported, so a definition's tool list is asserted against the set a background child actually retains.

## Acceptance

- Roles ship with the plugin and are dispatchable by name, with identity coming from the name rather than the file's location.
- Every shipped role points at the sub-agent policy and restates none of it.
- Every shipped role denies itself the ability to dispatch further.
- No shipped role relies on a frontmatter field that a plugin's definitions ignore; the suite asserts none is present.
- Each role's tool list is asserted against the set a background child retains, so a role cannot silently mean two things.
- The roster covers the two review axes, the research investigation, and the build portion, and nothing speculative.
- The suite passes.

## The surface this opened

`agents/` is the second thing that ships, and every sweep in the suite walked `skills/` and stopped. Three were extended to reach it — single-home, pre-migration paths, and attribution — and `.claude/rules/skills.md` is now scoped to `agents/**`, so the authoring standards load when a role is edited rather than existing and never firing.

A trap worth knowing: a new `paths:` glob resolves against git's index, so a scope covering only untracked files fails the "matches nothing in the tree" guard until those files are staged. The guard is right; the ordering is the surprise.

## Deferred to 07, deliberately

Three roles carry brief text that still also sits in the skill that dispatches them — `spec-reviewer` and `standards-reviewer` against `skills/review/SKILL.md` §4, `researcher` against `skills/research/SKILL.md`. That duplication is this ticket's direction of travel, not a defect in it: 07 is where "spawners covered by a shipped role name the role rather than retyping its brief" removes the other copy. The attribution travelled with the text in the meantime, because a licence obligation does not wait for a later ticket.

Both review axes flagged this as a hard violation reading 03's diff alone, which is the correct read from there.
