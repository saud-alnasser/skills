---
name: specify
description: Define WHAT is changing and WHY. Use when a change is wanted and no effort describes it yet.
metadata:
  aep: adapter
  canonical: .aep/skills/specify.md
---

Read `.aep/skills/specify.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/specify.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/src/skills/specify.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
