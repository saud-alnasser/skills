---
name: aep-handoff
description: Carry the work into a fresh session. Use when this session is ending or has run long, and the next session must pick the work up.
metadata:
  aep: adapter
  canonical: .aep/skills/handoff.md
---

Read `.aep/skills/handoff.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/handoff.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/handoff.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install` —
do not improvise the skill.
