---
owner: framework
version: 1.18.0
---

<!-- Unconditional: no `paths:` frontmatter, deliberately — precedence must hold on every turn, and adding to this tier is a permanent always-on cost. -->

# Precedence

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. `CLAUDE.md` and the unconditionally-loaded rules beside this file
3. `.claude/contexts/repository.md` and the Domain Contexts
4. `.claude/decisions/` — an accepted ADR
5. Path-scoped rules in `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the documentation

- **A user instruction overrides everything here — say so when it does, and follow it.**
- **Ranks 2 and 5 split one directory by how a rule loads** — no `paths:` is injected every turn, ranking with `CLAUDE.md`; path-scoped loads when a covered file is read and ranks below Decisions, a standard discovered in part of the tree. `.claude/rules/` holds standards discovered in **this repository**, path-scoped so the harness enforces the scope.
- **A repository's own authority facts — which document is normative for what it builds — declare in its `CLAUDE.md`, never in this file** — `CLAUDE.md` ranks beside it, so nothing is lost.
