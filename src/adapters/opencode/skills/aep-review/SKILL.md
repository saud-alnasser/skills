---
name: aep-review
description: Judge the work against the change. Use when work is finished and about to land, or a diff needs judging against what was asked.
metadata:
  aep: adapter
  canonical: .aep/skills/review.md
---

Read `.aep/skills/review.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/review.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/review.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install`.
Do not improvise the skill.
