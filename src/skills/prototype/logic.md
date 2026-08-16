---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "a prototype's question is about business logic, state transitions, or data shape, and it needs to be driven by hand"
---

# Prototype — the logic branch

A small interactive program that lets a human drive a state model by hand. For
the kind of question that looks reasonable on paper and only feels wrong once
real cases go through it: *does this state machine survive X then Y*, *can this
model even represent that case*, *what should this API feel like to call*.

Wrong branch if the question is what something should look like:
`[[skills/prototype/ui]]`.

## 1 — Write the state model and the question

One paragraph at the top of the evidence file, **before any code**. A logic
prototype that answers the wrong question is pure waste, and the question is only
checkable afterwards if it was written down before the result had a chance to
reshape it.

## 2 — Take the repository's language and tooling

Whatever it already uses. **Do not add a package manager or a runtime for a
prototype.** Where the repository has no obvious runtime — a documentation
repository, say — ask.

## 3 — Put the logic behind a small pure interface

The part that answers the question goes behind an interface that could be lifted
out on its own. **The harness around it is throwaway; this module is the thing
being judged.**

The shape follows the question, not the harness:

| The question is | The shape |
| --- | --- |
| discrete events against one value of state | a pure reducer — `(state, action) => state` |
| *which actions are legal right now* | an explicit state machine |
| transformations with no current state | a set of pure functions over a plain type |
| logic that genuinely owns ongoing state | a module with a small method surface |

**Pick the shape the question needs, never the one easiest to wire up.** Keep it
pure: no I/O, no terminal code, no logging used for control flow. The harness
calls in; nothing flows back.

## 4 — Build the smallest harness that exposes the state

Re-render the whole frame each tick, so the human sees one stable view rather
than growing scrollback. Each frame, in this order:

1. **Current state**, pretty-printed and diff-friendly — one field per line, or
   formatted structured output.
2. **The keys**, at the bottom: `[a] add user  [t] tick clock  [q] quit`.

Then: initialise in memory, render, read one keystroke, dispatch, re-render,
loop until quit. **The frame fits on one screen.** Use whatever styling the
repository already has; do not add a library for this.

## 5 — Close it out

`[[skills/prototype]]` has the write-up, the handback, and the deletion. Where
the repository has no task runner to hang the run command on, put the command at
the top of the evidence file.

What is specific here is what promotion would mean: the thing with a future is
the **reducer, machine, or function set** — never the harness around it. Keeping
it pure is what makes lifting it cheap, and it is **not** a licence to skip the
rewrite, the tests, or the documented interface that `[[skills/prototype]]`
requires of anything promoted.

## Anti-patterns

- **Blurring the logic into the harness.** Once the reducer knows about prompts
  or escape codes, the one part worth lifting has been lost.
- **Shipping the harness.** It was built to be driven by hand.
- **Choosing the shape that wires up most easily.** The shape answers to the
  question.
