---
name: commit
description: Land the change. Use when reviewed work is ready to land as a commit.
metadata:
  aep: adapter
  canonical: .aep/skills/commit.md
---

Read `.aep/skills/commit.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/commit.md` does not exist, this repository has not installed AEP.
For `/aep:install` and `/aep:help`, fall back to
`${CLAUDE_PLUGIN_ROOT}/src/skills/commit.md` and continue.
For anything else, say AEP is not installed here and offer `/aep:install` —
do not improvise the skill.
