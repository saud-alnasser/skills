---
name: aep-install
description: Join a repository to AEP. Use when a repository has no .aep/ directory and should start running AEP.
metadata:
  aep: adapter
  canonical: .aep/skills/install.md
---

Read `.aep/skills/install.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/install.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/install.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install` —
do not improvise the skill.
