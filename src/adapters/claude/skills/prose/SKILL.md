---
name: prose
description: Make it read as though a person wrote it. Use when about to emit text a human will read, or editing text that reads as though nobody wrote it.
metadata:
  aep: adapter
  canonical: .aep/skills/prose.md
---

Read `.aep/skills/prose.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/prose.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/prose.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
