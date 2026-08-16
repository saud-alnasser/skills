---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: rule
mode: [plan, implement, prototype, review]
use-when: "writing code, or making any claim about how this repository works"
---

# Rule — engineering standards

## Claims

- **Inspect the source before any repository-specific claim.** A claim is either
  checked or a guess in the same words — and **names are not proof**, nor memory,
  nor a plausible API. Never infer an API from a filename: `src/auth/` is where
  to start reading, not evidence that an auth module exists there.
- **Never guess an API, and a CLI is an API.** Read the reference; never try a
  flag and see. `[[references]]` covers the tools this repository uses; an
  operation none of them covers is a gap — **say so** rather than inventing an
  invocation.
- **Separate what you verified from what you assume**, and say which is which.
  An assumption stated as a fact is indistinguishable from a finding by the time
  anyone acts on it.

## Change

- **Smallest sufficient change.** An improvement you notice outside the task is
  raised, not taken.
- **Read before modifying** — the whole of what you are about to change, not the
  part you expect to matter.
- **Preserve architectural consistency.** Match the surrounding code: its idiom,
  naming, error handling, and comment density. A correct diff that reads as
  foreign is still a maintenance cost.
- **Root cause, not workaround.** When you hit a limitation, find out why it
  exists before designing around it. Where a workaround genuinely is the answer,
  record **why it exists, what else was considered, and the condition under which
  it is removed** — without a removal condition, "temporary" is an intention
  rather than a state anything can leave.
- **Obeying a rule means letting its check fire.** Keeping a rule's letter while
  arranging that its check cannot run violates it more completely than defiance,
  which at least leaves a trace. Before satisfying a rule, ask what it would have
  caught and whether that is still reachable.

## What gets written

- **Code explains itself.** A comment explaining *what* marks code to improve,
  not to annotate. Comments say **why**.
- **A workaround needing a paragraph of justification is wrong code — fix the
  code.**
- **Document every public API.**
- **Name a file for the one thing it holds**; directories carry the qualifiers.
- **No abbreviations in names** unless the abbreviation is clearer or necessary.
- **Tests sit as near the code as the language and tooling allow** — the
  repository's own convention wins.

## Decisions

**Never silently decide architecture.** Where more than one reasonable approach
exists, put the options on the table — each named, with what it buys, what it
costs, what it risks, and what it means for maintenance — recommend one, and let
the human choose. **An alternative left unmentioned is a decision made silently.**

## Publishing

Never push, never publish, never open a pull request unasked
(`[[rules/version-control]]` names exactly what that covers, and why the line
sits where it does).
