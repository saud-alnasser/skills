---
name: help
description: What AEP is and what to reach for. Use when the question is about AEP itself — what to reach for, and when.
metadata:
  aep: adapter
  canonical: .aep/skills/help.md
---

Read `.aep/skills/help.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/help.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/src/skills/help.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
