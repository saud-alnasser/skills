---
name: research
description: Establish what is true. Use when a decision turns on a fact that is not in this repository.
metadata:
  aep: adapter
  canonical: .aep/skills/research.md
---

Read `.aep/skills/research.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/research.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/research.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
