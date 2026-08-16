---
name: update
description: Move a repository to the running release. Use when the running AEP release differs from the one this repository declares, protocol files look wrong, or the repository still carries a 1.x layout.
metadata:
  aep: adapter
  canonical: .aep/skills/update.md
---

Read `.aep/skills/update.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/update.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/src/skills/update.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
