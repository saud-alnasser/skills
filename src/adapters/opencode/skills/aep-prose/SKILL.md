---
name: aep-prose
description: Make it read as though a person wrote it. Use when writing or editing public text: a README, a docs page, an API reference, user-interface text, a changelog, a code comment, or a docstring.
metadata:
  aep: adapter
  canonical: .aep/skills/prose.md
---

Read `.aep/skills/prose.md` and follow it exactly. That file is the skill; this one only routes to it.

If `.aep/skills/prose.md` does not exist, this repository has not installed AEP.
For `/aep-install` and `/aep-help`, fall back to
`../../../../skills/prose.md`, resolved from this skill's own directory,
and continue.
For anything else, say AEP is not installed here and offer `/aep-install`.
Do not improvise the skill.
