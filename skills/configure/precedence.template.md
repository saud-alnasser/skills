# Precedence

<!--
  Installed by /configure at `.claude/rules/precedence.md`.

  No `paths:` frontmatter, deliberately. A precedence ladder that loaded only
  when Claude opened a particular file would resolve conflicts on some turns and
  not others, which is worse than having no ladder — the failures would be
  intermittent rather than absent.

  Copied as-is. Ranks 3 through 6 name paths every configured repository has, so
  there is nothing to fill in. A repository that adds a source of instruction
  the ladder does not rank should add the rank here rather than argue it out
  again per conflict.
-->

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. `CLAUDE.md` and the unconditionally-loaded rules beside this file
3. `.claude/contexts/repository.md` and the Domain Contexts
4. `.claude/decisions/` — an accepted ADR
5. Path-scoped rules in `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the repository's documentation — CONTRIBUTING outranks it because CONTRIBUTING says how this repository is worked on and README says what it is

A user instruction overrides everything here. Say so when it does, and follow it.

Ranks 2 and 5 are the same directory, split by **how a rule loads**. A rule with no `paths:` frontmatter is injected on every turn and ranks with `CLAUDE.md`; a path-scoped rule loads only when a file it covers is read, and ranks below Decisions because it is a standard discovered in one part of the tree rather than a decision taken for the whole of it.

`.claude/rules/` holds standards discovered in **this repository**. A rule that applies to only part of the tree carries `paths:` frontmatter naming that part, so the scope is enforced by the harness rather than honoured by Claude.
