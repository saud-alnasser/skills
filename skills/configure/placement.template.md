---
owner: framework
version: 1.18.0
---

# Placement

**Everything AEP owns lives in one of two places: the plugin, or `.claude/`.**

- **The plugin holds what AEP ships** — skills, dispatched roles, and the templates they install. **`.claude/` holds what a repository runs on** — the protocol file, policies, modes, rules, contexts, decisions, evidence, tickets, tool guides, generated files, and scripts serving AEP's own process (`.claude/scripts/`).
- **`CLAUDE.md` at the repository root is the only entry AEP adds outside those two** — the harness loads it by name, so it cannot move.
- **Ships or is installed decides which of the two** — a template is the plugin's, and the file it writes is `.claude/`'s.
- **Whose process a file serves decides whether it is AEP's at all** — never its material, never its executability: a script that regenerates AEP's indexes serves AEP; a script that builds or tests what the repository exists to produce serves the repository, and stays where it is — neither moved nor claimed.
- **Ask of anything: were AEP removed, would this still have a reason to exist?** If yes, it is not AEP's to place.
