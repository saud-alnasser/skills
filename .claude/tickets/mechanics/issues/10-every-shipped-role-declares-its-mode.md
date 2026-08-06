---
title: feat(agents): every shipped role declares its mode
status: resolved
blocked-by: []
part-of: mechanics
---

## Problem

The specification says a skill declares exactly one mode, and the mode carries the reasoning posture — what the work optimises for and what it gives up. The five shipped agent roles declare none.

A dispatched child inherits the boot tier and its own system prompt, and neither carries a posture. So a role that exists to investigate facts runs without the posture that says evidence comes before conclusions, and a role that exists to review runs without the posture that says assume defects exist. The mode files these roles would name already exist and are small; nothing is missing except the declaration and something that reads it.

## Outcome

Every shipped role declares its mode, and the declaration is a field rather than prose, because a child's system prompt is assembled rather than read by a person. The role reaches the mode by pointer and restates none of it — the posture has one home and gains no second copy per role.

The suite asserts that every role's declared mode names a mode that exists, so a rename on either side fails rather than leaving a role pointing at nothing.

## Acceptance

- Each shipped role declares exactly one mode.
- Each declared mode names a mode that exists.
- A role declaring a mode that does not exist fails the build, naming the role.
- A role added with no declared mode fails the build.
- No role restates any of its mode's content — asserted by a guard confirmed to fail against a paraphrase rather than only against a quotation.
- The suite passes.
