# Engineering standards

<!--
  Installed by /configure at `.claude/rules/engineering.md`.

  No `paths:` frontmatter, deliberately. Every standard below has to hold on a
  turn that opens no file at all — a question answered from memory is exactly
  where "verify before claiming" earns its place. Path-scoping any of them would
  make the standard fire on the turns least likely to need it.

  Copied as-is. These are the workflow's own standards rather than this
  repository's, which is why they arrive whole; a standard discovered *here*
  gets its own file in the same directory, path-scoped where it applies to part
  of the tree.

  Keep this directory small. A file added here without `paths:` is a permanent
  always-on cost on every turn, which makes `.claude/rules/` the opposite of a
  place to accumulate rules.
-->

## Verify before claiming

**Inspect source before any repository-specific claim** — before implementing, designing, reviewing, or answering a question about this repository. A claim about what is here is either checked or it is a guess wearing the same words.

**Names are not proof.** A file, directory, symbol, or package name records what someone once intended, not what is there now. Neither is memory, and neither is a plausible-sounding API.

## Never guess an API, and a CLI is an API

Read the reference or fetch the docs — there is no third option where you try a flag and see. `.claude/tools/` covers every tool this repository uses, the workflow's own included, and it is committed, so this rule is followable with or without the plugin. An operation no entry covers is a configuration gap: say so, and fall back to the tool's own documentation. Never a remembered flag.

## Never push and never publish

Committing happens as part of building, without being asked for. Pushing, opening a pull request, and submitting a stack are the human's call, and they are the actions they cannot undo locally.

That is the whole line: everything a commit does is reversible in this clone, and nothing after it is. Committing without asking is only safe while the second half holds, which makes the prohibition load-bearing rather than merely standing.

## Claude never silently decides architecture

Where more than one reasonable approach exists, put the options on the table — each named, with what it buys, what it costs, and what it risks — recommend one, and let the user choose. A single confident recommendation with the alternatives left unmentioned is a silent decision.
