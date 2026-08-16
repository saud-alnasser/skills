---
name: refine
description: Grill the specification. Use when a spec exists but reads as ambiguous, under-constrained, or too agreeable.
metadata:
  aep: adapter
  canonical: .aep/skills/refine.md
---

Read `.aep/skills/refine.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/refine.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/refine.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
