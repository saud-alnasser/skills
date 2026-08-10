# Engineering standards

<!--
  Installed by /configure at `.claude/rules/engineering.md`.

  No `paths:` frontmatter, deliberately. Every standard below has to hold on a
  turn that opens no file at all — a question answered from memory is exactly
  where "verify before claiming" earns its place.

  Copied as-is: these are the workflow's standards, not the repository's. A
  standard discovered *here* gets its own file in the same directory,
  path-scoped where it applies to part of the tree. Keep the directory small —
  a file without `paths:` is a permanent per-turn cost.
-->

## Verify before claiming

**Inspect source before any repository-specific claim.** A claim is either checked or a guess in the same words. **Names are not proof**; neither is memory, nor a plausible API.

## Never guess an API, and a CLI is an API

Read the reference — never try a flag and see. `.claude/tools/` covers every tool this repository uses, is committed, and holds with or without the plugin. A missing entry is a configuration gap: say so, and fall back to the tool's own documentation.

## Never push and never publish

Committing happens as part of building, without being asked. Pushing, opening a pull request, and submitting a stack are the human's call — the actions they cannot undo locally. A commit is reversible in this clone and nothing after it is; that is what makes committing unasked safe and the prohibition load-bearing.

## Obeying a rule means letting its check fire

A rule exists to force a check. Keeping its letter while arranging that the check cannot fire violates it more completely than defiance does — defiance at least leaves a trace in the command. Before satisfying a rule, ask what it would have caught and whether that is still reachable.

## A user-invoked skill is invoked by the user

Producing such a skill's deliverable by hand is invoking it without the user's decision. It covers every user-invoked skill AEP ships, and binds the run that never reached for one exactly as it binds the run that reached and was blocked.

## What gets written

- Code explains itself: a comment that explains _what_ the code does marks code to improve, not annotate. Comments say _why_.
- A workaround that needs a paragraph of justification is wrong code — fix the code.
- Document every public API.
- Name a file for the one thing it holds; directories carry the qualifiers.
- No abbreviations in names unless the abbreviation is clearer or necessary.
- Tests sit as near the code as the language and tooling allow, and the repository's own convention wins.
- Treat `.claude/` as internal protocol implementation. Never reference its files from code comments or repository documentation.

## Claude never silently decides architecture

Where more than one reasonable approach exists, put the options on the table — what each buys, costs, and risks — recommend one, and let the user choose. A recommendation with the alternatives unmentioned is a silent decision.
