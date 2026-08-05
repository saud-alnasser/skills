# Precedence

<!--
  Installed by /configure at `.claude/rules/precedence.md`.

  No `paths:` frontmatter, deliberately: a ladder that loaded only sometimes
  would resolve conflicts intermittently, which is worse than not at all.

  Copied as-is. A repository that adds a source of instruction the ladder does
  not rank should add the rank here rather than argue it out per conflict.
-->

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. `CLAUDE.md` and the unconditionally-loaded rules beside this file
3. `.claude/contexts/repository.md` and the Domain Contexts
4. `.claude/decisions/` — an accepted ADR
5. Path-scoped rules in `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the documentation — CONTRIBUTING says how the repository is worked on, README what it is

A user instruction overrides everything here — say so when it does, and follow it.

Ranks 2 and 5 split one directory by how a rule loads: no `paths:` is injected every turn, ranking with `CLAUDE.md`; path-scoped loads when a covered file is read and ranks below Decisions — a standard discovered in part of the tree rather than the whole. `.claude/rules/` holds standards discovered in **this repository**, path-scoped so the harness enforces the scope.

For what is *built* here, `specs.md` is authoritative and `.claude/tickets/` records what was done, `aep/` live. Where it and an ADR disagree, the ADR wins and the specification is amended in the same change (ADR 0029).
