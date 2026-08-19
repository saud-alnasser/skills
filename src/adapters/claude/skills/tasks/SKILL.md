---
name: tasks
description: Derive executable work from the spec. Use when a spec is accepted and needs to become executable work.
metadata:
  aep: adapter
  canonical: .aep/skills/tasks.md
---

Read `.aep/skills/tasks.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/tasks.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/tasks.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install`.
Do not improvise the skill.
