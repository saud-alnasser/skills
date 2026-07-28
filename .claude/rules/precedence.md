# Precedence

<!--
  No `paths:` frontmatter, deliberately. This rule decides which source wins
  when two disagree, and that question arises on every turn — including turns
  that open no file any glob could match. A scope here would make the ladder
  load only sometimes, which is the silent failure the split exists to prevent.
-->

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. `CLAUDE.md` and the unconditionally-loaded rules beside this file
3. `.claude/context.md` and the Domain Contexts
4. `.claude/decisions/` — an accepted ADR
5. Path-scoped rules in `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the repository's documentation — CONTRIBUTING outranks it because CONTRIBUTING says how this repository is worked on and README says what it is

A user instruction overrides everything here. Say so when it does, and follow it.

Ranks 2 and 5 are the same directory, split by **how a rule loads**. A rule with no `paths:` frontmatter is injected on every turn and ranks with `CLAUDE.md`; a path-scoped rule loads only when a file it covers is read, and ranks below Decisions because it is a standard discovered in one part of the tree rather than a decision taken for the whole of it.

`.claude/rules/` holds standards discovered in **this repository** — they belong to it, not to Tenure.

For what is being *built* here, `.claude/tickets/tenure/spec.md` is authoritative — 43 numbered decisions, the build order, and the target layout — and the tickets beside it record what was actually done. Where the spec and an ADR disagree, the ADR is later and wins.
