---
name: aep-survey
description: Find where the architecture is costing you. Use when the question is where the codebase is costing you, rather than a specific change.
metadata:
  aep: adapter
  canonical: .aep/skills/survey.md
---

Read `.aep/skills/survey.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/survey.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/survey.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install`.
Do not improvise the skill.
