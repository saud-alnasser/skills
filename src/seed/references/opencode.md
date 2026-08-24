---
use-when: "running AEP under OpenCode, or changing what OpenCode loads from this repository"
---

# Reference — OpenCode

**This file is yours.** Installed because an OpenCode configuration was detected.
It is a starting point: correct it against the version this repository actually
runs, because OpenCode moves quickly and several of the paths below accept more
than one spelling.

## What OpenCode reads from this repository

| It loads | From |
| --- | --- |
| instructions | `AGENTS.md`, walking up from the working directory; `CLAUDE.md` as a fallback |
| extra instructions | whatever `instructions` in `opencode.json` names |
| skills | `.opencode/skill(s)/<name>/SKILL.md`, `.agents/skills/<name>/SKILL.md`, and `.claude/skills/<name>/SKILL.md` |
| agents | `.opencode/agent(s)/<name>.md` — and nowhere else |
| commands | `.opencode/command(s)/<name>.md` |

AEP's entrypoint is `AGENTS.md`, so OpenCode reads it with no adapter at all.

**Every skill OpenCode discovers also becomes a slash command.** A skill named
`aep-specify` is both loadable by the model and invocable as `/aep-specify`.

**Built-in commands win a name collision.** OpenCode registers `init` and
`review` before skills, and a skill whose name is already taken never becomes a
command. This is why AEP's wrappers are prefixed.

**Agents have no `.claude` compatibility.** The compatibility that makes
`.claude/skills/` work covers skills only, so a repository that wants AEP's
agents under OpenCode needs the OpenCode adapter itself.

## Which adapter this repository installed

AEP's installer is not part of an installed tree — it runs from the
distribution, which is what `/aep:install` and `/aep:update` do for you. Ask
either of them for a runtime adapter by name.

`opencode` writes `.opencode/`; `agents` writes `.agents/skills/`. **They are
alternatives here, not a pair** — OpenCode reads both, so installing both loads
every skill twice under one name and the winner is decided by a race. Pick
`agents` when this repository is driven through a harness that reads the neutral
location with a non-OpenCode provider; pick `opencode` otherwise.

## Failure handling

- **Config is read once at startup and never hot-reloaded.** After changing
  `opencode.json`, a skill, or an agent, the session must be restarted before the
  change has any effect. A change that "did nothing" is usually this.
- OpenCode validates its own config strictly and refuses to start on an invalid
  one. The published schema at <https://opencode.ai/config.json> is authoritative;
  declare it as `$schema` so the editor catches a mistake before startup does.
- An unknown key in an agent's frontmatter is **not** rejected — it is routed
  silently into that agent's options. A typo there fails invisibly.
- External skill locations can be switched off by flag, `.claude` and `.agents`
  together. Only `.opencode/` is unconditional.
