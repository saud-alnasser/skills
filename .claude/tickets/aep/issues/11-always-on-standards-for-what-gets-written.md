---
title: feat(rules): the always-on standards cover what gets written, and close-out invokes the commit skill
status: resolved
blocked-by: [09]
part-of: aep
---

## Problem

The rules about what gets written — self-explanation, comment discipline, public-API documentation, file naming, abbreviations, test placement — lived only in the stage skills that apply them, so they fired only when a stage ran; a turn that edits code outside a stage never met them. And `/implement`'s close-out said "through `/commit`" without saying the commit skill is *invoked* — read as prose, a hand-rolled `git commit` satisfied it.

## Outcome

`.claude/rules/engineering.md` carries the standards as terse always-on directives, worded so the guarded anchor phrases keep their single homes in the skills that elaborate them — the directive is always-on, the worked forms stay where they were. A seventh directive is new: a workaround that needs a paragraph of justification is wrong code, fixed rather than annotated. `/implement`'s close-out names the invocation of the commit skill explicitly.

## Acceptance

- The engineering template and this repository's copy each carry the six directives.
- The single-home sweep stays green — no elaboration lost its anchor to the new section.
- The workaround-comment rule has a duplication guard, confirmed to fire.
- `/implement`'s close-out invokes the `commit` skill by name and rules out the hand-rolled commit.
- The boot ceiling moves only by the directives' measured cost, with the raise recorded as deliberate.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
