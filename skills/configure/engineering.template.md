---
owner: framework
version: 1.19.0
---

<!-- Unconditional: no `paths:` frontmatter, deliberately — these must hold on every turn, and adding to this tier is a permanent always-on cost. -->

# Engineering standards

- **Inspect source before any repository-specific claim** — a claim is either checked or a guess in the same words; **names are not proof**, nor memory, nor a plausible API.
- **Never guess an API, and a CLI is an API** — read the reference, never try a flag and see. A `reference` record covers every tool this repository uses, and is queried at the operation that needs it rather than delivered with a row; a tool with no reference is a configuration gap — say so, and fall back to the tool's own documentation.
- **Never push and never publish** — committing happens as part of building, without being asked; pushing, opening a pull request, and submitting a stack are the human's call, the actions they cannot undo locally. A commit is reversible in this clone and nothing after it is — what makes committing unasked safe and the prohibition load-bearing.
- **Obeying a rule means letting its check fire** — keeping its letter while arranging that the check cannot fire violates it more completely than defiance, which leaves a trace. Before satisfying a rule, ask what it would have caught and whether that is still reachable.
- **A user-invoked skill is invoked by the user** — producing its deliverable by hand is invoking it without the user's decision. It covers every user-invoked skill AEP ships, binding the run that never reached for one exactly as the one that was blocked.
- **Claude never silently decides architecture** — with more than one reasonable approach, put the options on the table — what each buys, costs, and risks — recommend one, and let the user choose; alternatives unmentioned is a silent decision.

## What gets written

- **Code explains itself** — a comment that explains *what* marks code to improve, not annotate; comments say *why*.
- **A workaround that needs a paragraph of justification is wrong code — fix the code.**
- **Document every public API.**
- **Name a file for the one thing it holds; directories carry the qualifiers.**
- **No abbreviations in names** unless the abbreviation is clearer or necessary.
- **Tests sit as near the code as the language and tooling allow** — the repository's own convention wins.
- **Treat `.claude/` as internal protocol implementation** — never reference its files from code comments or repository documentation.
