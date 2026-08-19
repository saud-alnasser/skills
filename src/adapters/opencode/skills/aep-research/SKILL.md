---
name: aep-research
description: Establish what is true. Use when a decision turns on a fact that is not in this repository.
metadata:
  aep: adapter
  canonical: .aep/skills/research.md
---

Read `.aep/skills/research.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/research.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/research.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install`.
Do not improvise the skill.
