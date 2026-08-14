---
owner: framework
version: 1.19.0
---

# Placement

**Everything AEP owns lives in one of two places: the plugin, or `.claude/`.**

- **The plugin holds what AEP ships** — skills, dispatched roles, the framework store, and the templates and scripts a run installs. **`.claude/` holds what a repository runs on** — the protocol file, the unconditional rules, the store of the repository's own records, its tickets, its copied scripts, and its per-clone state.
- **`CLAUDE.md` at the repository root is the only entry AEP adds outside those two** — the harness loads it by name, so it cannot move.
- **Ships or is installed decides which of the two** — a template is the plugin's, and the file it writes is `.claude/`'s.
- **Whose process a file serves decides whether it is AEP's at all** — never its material, never its executability: a script that assembles a stage's row serves AEP; a script that builds or tests what the repository exists to produce serves the repository, and stays where it is — neither moved nor claimed.
- **Ask of anything: were AEP removed, would this still have a reason to exist?** If yes, it is not AEP's to place.
