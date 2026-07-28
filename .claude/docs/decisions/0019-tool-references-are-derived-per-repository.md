# Tool references are derived per repository, and the tools skill is deleted

Reverses spec decision 34, which put workflow tools (`git`, `gh`, `glab`, `gt`) in a shipped model-invoked skill and repository tools in `.claude/tools/`, and which ticket 15 built as two tiers.

`/configure` now detects which tools a repository actually uses and derives one file per tool into `.claude/tools/`, and the shipped reference becomes source material for `/configure` in the same way the `CLAUDE.md` and tracker templates already are. There is one place to look for how to type any command, and it is committed. The decisive argument is not tidiness: the shipped tier existed only where the plugin was installed, so a teammate who cloned the repository without Tenure had no tool reference while still being bound by the rule forbidding them to guess a CLI. `CLAUDE.md` admitted that gap in the same sentence as the rule. Deriving into the repository closes it, and it is the one place the "nothing committed may assume Tenure is installed" constraint was leaking.

**Derivation filters whole entries; it never summarizes.** `/configure` chooses which tools and which entries apply, and carries every entry it keeps over intact. A tool reference's value is concentrated in gotchas — an exact porcelain column layout, a verb whose name lies about what it does — and a rewrite is what smooths those away. Filtering loses whole entries, which is visible and mechanically checkable; summarizing loses clauses, which is neither.

## Considered Options

Copying verbatim and re-syncing on audit keeps a diffable relationship to the shipped version, and was rejected because a per-repository file should carry that repository's own tooling in the same document as the workflow's, which a verbatim copy cannot do. Keeping the two tiers and sharpening the pointer between them was rejected because it leaves the plugin-less-teammate gap open, which is the strongest reason to make the change at all. Deriving but keeping a pointer back to the full shipped reference was rejected because it reintroduces the second place to look.

## Consequences

The relationship becomes a vendoring one: a fix Tenure ships to its own reference does not reach an already-configured repository on its own. `/configure`'s audit branch already promises to re-check `.claude/tools/` against the repository, and that is now the only path by which a derived file is refreshed. This is accepted — the audit checks the file against the repository it describes, which is the check that matters, and a repository whose tooling has not changed does not need the shipped text's changes.

A needed entry that is missing is a **configuration gap**: say so, re-run `/configure`, and fall back to the tool's own documentation if it still is not there. Never a guess.

`tools` leaves the Primitive list in `.claude/context.md`, which drops to four.
