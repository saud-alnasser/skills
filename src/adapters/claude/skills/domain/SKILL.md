---
name: domain
description: Sharpen the domain model. Use when the words the problem is described in are doing the damage — a fuzzy term, or one word meaning three things.
metadata:
  aep: adapter
  canonical: .aep/skills/domain.md
---

Read `.aep/skills/domain.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/domain.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/domain.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
