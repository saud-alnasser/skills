---
name: prune
description: Remove what is no longer true. Use when the .aep/ tree has accumulated stale, contradicted, or orphaned artifacts.
metadata:
  aep: adapter
  canonical: .aep/skills/prune.md
---

Read `.aep/skills/prune.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/prune.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/prune.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install`.
Do not improvise the skill.
