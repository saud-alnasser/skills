# Placement

**Everything AEP owns lives in one of two places: the plugin, or `.claude/`.**

- **The plugin** holds what AEP *ships* — its skills, its dispatched roles, and the templates they install.
- **`.claude/`** holds what a repository *runs on* — the protocol file, policies, modes, rules, contexts, decisions, evidence, tickets, tool guides, every generated file, and any script serving AEP's own process, which goes in `.claude/scripts/`.

**`CLAUDE.md` at the repository root is the only entry AEP adds outside those two**, because the harness loads it by name and it cannot move.

Which of the two a file belongs to is decided by whether it **ships or is installed**: a template is the plugin's, and the file that template writes is `.claude/`'s.

## Whether a file is AEP's at all

Decided by **whose process it serves**, never by what it is made of and never by whether it is executable. A script that regenerates AEP's indexes serves AEP. A script that builds or tests the code the repository exists to produce serves the repository, and stays wherever that repository already keeps it — AEP neither moves it nor claims it.

Ask of anything: *were AEP removed, would this still have a reason to exist?* If yes, it is not AEP's to place.
