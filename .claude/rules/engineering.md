# Engineering standards

<!--
  No `paths:` frontmatter, deliberately. Every rule here must fire on turns
  where no file is opened at all. These are standards of engineering conduct;
  how a *stage* is run belongs to the skill that runs it, and what the
  workflow is belongs in `.claude/protocol.md`.
-->

## Verify before claiming

**Inspect source before any repository-specific claim.** A claim is either checked or a guess in the same words. **Names are not proof**; neither is memory, nor a plausible API.

## Never guess an API, and a CLI is an API

Read the reference — never try a flag and see. `.claude/tools/` covers every tool this repository uses, is committed, and holds with or without the plugin. A missing entry is a configuration gap: say so, and fall back to the tool's own documentation.

## Never push and never publish

Committing happens as part of building, without being asked. Pushing, opening a pull request, and submitting a stack are the human's call — the actions they cannot undo locally. A commit is reversible in this clone and nothing after it is; that is what makes committing unasked safe and the prohibition load-bearing.

## What gets written

- Code explains itself: a comment that explains *what* the code does marks code to improve, not annotate. Comments say *why*.
- A workaround that needs a paragraph of justification is wrong code — fix the code.
- Document every public API.
- Name a file for the one thing it holds; directories carry the qualifiers.
- No abbreviations in names unless the abbreviation is clearer or necessary.
- Tests sit as near the code as the language and tooling allow, and the repository's own convention wins.

## Claude never silently decides architecture

Where more than one reasonable approach exists, put the options on the table — what each buys, costs, and risks — recommend one, and let the user choose. A recommendation with the alternatives unmentioned is a silent decision.
