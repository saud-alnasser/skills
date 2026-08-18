---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: reference
mode: [implement, review]
use-when: "running AEP through T3 Code, or explaining why a skill is or is not offered there"
---

# Reference — T3 Code

**This file is yours.** Installed because a `t3.json` was detected. It is a
starting point: correct it against the version this repository's team actually
runs.

## What T3 Code is, and what that means for AEP

T3 Code is a **control surface**, not an agent runtime. It wraps provider CLIs —
Claude Code, Codex, Cursor, Grok, OpenCode — and serves them to desktop, web, and
mobile clients. It defines no skill, agent, command, or instruction format of its
own.

So **AEP reaches T3 Code through the provider**, never through T3 Code. Whatever
the provider loads is what a session gets, and the AEP adapter that matters is
the one that provider reads.

## Skill discovery

For its composer picker, T3 Code scans, in this order:

1. the provider's config directory `skills/`
2. `<workspace>/.agents/skills`
3. `<workspace>/.claude/skills`

**A later root wins a name collision.** Where the same skill name exists in more
than one of these, the one from `.claude/skills` is the one offered.

`.agents/skills/` is the location that serves every provider T3 Code drives,
which is what AEP's `agents` adapter targets — ask `/aep:install` or
`/aep:update` for it by name, since the installer runs from the distribution
rather than from an installed tree.

Where the provider is OpenCode, prefer the `opencode` adapter instead — both
locations are read there, and installing both loads every skill twice.

## Failure handling

- **A skill that does not appear is usually a provider question, not a T3 Code
  one.** Check what the provider itself loads from this repository before
  changing anything here.
- Provider authentication is the provider's own — T3 Code points a provider at a
  config directory rather than replacing its login.
- `t3.json` is checked in and shared by the team. Treat it as team configuration:
  scripts declared there run for everyone, including on worktree creation.
