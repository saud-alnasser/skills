---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
use-when: "creating a file and deciding whether it belongs to AEP or to the repository"
---

# Rule — placement

**Everything AEP owns lives under `.aep/`, plus the entrypoint and whatever
adapter a runtime needs.** Nothing else.

| Lives where | What |
| --- | --- |
| `.aep/` | every AEP artifact: the protocol, rules, modes, skills, agents, templates, contexts, references, efforts, scripts, position, worktrees |
| repository root | the entrypoint — `AGENTS.md`, and a runtime's own equivalent — which **points at** `[[protocol]]` and never restates it |
| a runtime's directory | adapters only, such as `.claude/skills/` wrappers. Never canonical state |

## The test

**Ask of any file: were AEP removed, would this still have a reason to exist?**

If yes, it is not AEP's to place, and it stays where the repository keeps it.

That test decides by **whose process the file serves** — never by what the file
is made of, and never by whether it is executable:

- a script that regenerates AEP's index serves AEP → `.aep/scripts/`
- a script that builds or tests what the repository exists to produce serves the
  repository → wherever that repository keeps its scripts, **neither moved nor
  claimed**

## Consequences

- **A runtime directory MUST NEVER hold canonical AEP state.** `.claude/`,
  `.cursor/`, `.codex/` hold pointers. A repository has one AEP state, not one
  per agent.
- **Never reference `.aep/` from source comments or from the repository's own
  documentation.** AEP is protocol machinery; code that cites it acquires a
  dependency on a tool that may be removed.
- **Per-clone state stays per-clone.** `position/` and `worktrees/` are
  gitignored, and nothing shared may depend on them.
- **An artifact is placed by its scope.** What belongs to one effort — its spec,
  its evidence, its tickets — lives in that effort's directory. What spans every
  effort lives at the root of `.aep/`.
