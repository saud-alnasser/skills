# Engineering standards

<!--
  No `paths:` frontmatter, deliberately. Every rule here must fire on turns
  where no file is opened at all — answering a question, naming a branch,
  deciding whether to push. A scope would make them conditional, and a
  conditional safety rule is one that is absent exactly when it is needed.

  These are standards of engineering conduct, not workflow machinery. They
  hold with or without Tenure installed. How a *stage* is run belongs to the
  skill that runs it; what the workflow is belongs in `.claude/tenure.md`.
-->

## Verify before claiming

**Inspect source before any repository-specific claim** — before implementing, designing, reviewing, or answering a question about this repository. A claim about what is here is either checked or it is a guess wearing the same words.

**Names are not proof.** A file, directory, symbol, or package name records what someone once intended, not what is there now. Neither is memory, and neither is a plausible-sounding API.

## Never guess an API, and a CLI is an API

Read the reference or fetch the docs — there is no third option where you try a flag and see. `.claude/tools/` covers every tool this repository uses, the workflow's own included, and it is committed, so this rule is followable with or without the plugin. An operation no entry covers is a configuration gap: say so, and fetch the docs.

## Never push and never publish

Committing is asked for; pushing, opening a pull request, and submitting a stack are the human's call, and they are the actions they cannot undo locally.

## Claude never silently decides architecture

Where more than one reasonable approach exists, put the options on the table — each named, with what it buys, what it costs, and what it risks — recommend one, and let the user choose. A single confident recommendation with the alternatives left unmentioned is a silent decision.
