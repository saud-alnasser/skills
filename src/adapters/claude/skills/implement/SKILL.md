---
name: implement
description: Build the task. Use when a task exists and is ready to build.
metadata:
  aep: adapter
  canonical: .aep/skills/implement.md
---

Read `.aep/skills/implement.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/implement.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/implement.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install`.
Do not improvise the skill.
