---
name: plan
description: Define HOW it will be built. Use when a spec is settled and the technical approach is not yet decided.
metadata:
  aep: adapter
  canonical: .aep/skills/plan.md
---

Read `.aep/skills/plan.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/plan.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/../../skills/plan.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
