---
aep: 2.0.0
owner: protocol
date: 2026-08-16
use-when: "recording how a tool is actually operated in this repository"
---

# Template — reference

Copy to `references/<tool>.md`. References are always `owner: repository` —
they describe *this* repository's usage, never an ecosystem in the abstract.

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: reference
mode: [<modes this is relevant to>]
use-when: "<when an agent needs this tool>"
---

# Reference — <tool>

## Purpose
What this tool does here, and when to reach for it.

## Prerequisites
What must be installed, authenticated, or running first.

## Commands
The real invocations — flags included — taken from this repository's scripts and
CI, not from the tool's documentation.

## Expected output
What success looks like, so failure is recognisable.

## Verification
How to confirm the operation actually did what it claimed. A command that exits
zero has not necessarily done anything.

## Failure handling
The failures that actually happen here, and what each one means.

## Never run
Anything that publishes, deletes, or is otherwise irreversible.
```

## The two rules

**A reference is not governance.** It says how to do a thing; it never requires
that the thing be done, and it never grants permission. A requirement is a rule.

**Do not create a reference for an abstract practice.** `tdd.md` does not exist
because TDD exists. If TDD is required here, that is a rule — and the rule may
link to procedural material through `[[references]]`.

**Record what this repository runs, not what the ecosystem defaults to.** A
reference stating a plausible command is worse than no reference, because it will
be trusted.
