# Logic Prototype

A small interactive terminal app that lets the user drive a state model by hand. Use this when the question is about **business logic, state transitions, or data shape** — the kind of thing that looks reasonable on paper and only feels wrong once real cases go through it.

## When this is the right shape

- "I'm not sure this state machine handles X then Y."
- "Does this data model actually let me represent the case where…"
- "I want to feel out what the API should look like before writing it."
- Anything where the user wants to **press keys and watch state change**.

If the question is *what should this look like* — wrong branch. Use [UI.md](UI.md).

## 1 — State the question

Before writing code, write down the state model and the question. One paragraph, at the top of the write-up in `.claude/docs/prototypes/<name>.md`.

A logic prototype that answers the wrong question is pure waste, and the question is only checkable later if it was written down at the start — before the result had a chance to reshape it.

## 2 — Pick the language

Whatever the host repository uses. Match its existing tooling; do not add a package manager or a runtime for a prototype. If the repository has no obvious runtime — a docs repo, say — ask.

## 3 — Isolate the logic behind a small pure interface

Put the part that answers the question behind an interface that could be lifted out on its own. The TUI around it is throwaway; the logic module is the thing being judged.

The shape follows the question:

- **A pure reducer** — `(state, action) => state`. Good when actions are discrete events and state is one value.
- **A state machine** — explicit states and transitions. Good when *which actions are legal right now* is part of the question.
- **A set of pure functions** over a plain data type. Good when there is no implicit current state, only transformations.
- **A module with a clear method surface**, when the logic genuinely owns ongoing internal state.

Pick the shape that fits the question, **not the one easiest to wire to a TUI**. Keep it pure: no I/O, no terminal code, no logging for control flow. The TUI imports it and calls in; nothing flows back the other way.

## 4 — Build the smallest TUI that exposes the state

Clear the screen and re-render the whole frame on every tick, so the user sees one stable view rather than growing scrollback.

Each frame, in this order:

1. **Current state**, pretty-printed and diff-friendly — one field per line, or formatted JSON. Bold for field names, dim for derived values and IDs. Native ANSI escapes are fine; do not add a styling library that is not already there.
2. **Keyboard shortcuts**, at the bottom: `[a] add user  [d] delete user  [t] tick clock  [q] quit`.

Then: initialise state in memory, render, read one keystroke at a time, dispatch to a handler, re-render the whole frame, loop until quit. The frame fits on one screen.

## 5 — Close it out

The handback, the write-up, and the deletion are the same on both branches and are in [SKILL.md](SKILL.md). If this repository has no task runner to hang the run command on, put the command at the top of the write-up.

What is specific here is what promotion means: the thing worth promoting is the **reducer, machine, or function set** — never the shell around it. Keeping it pure is what makes that cheap, and it is not a licence to skip the redesign, the tests, or the documented interface.

## Anti-patterns

- **Blurring the logic into the TUI.** If the reducer references prompts or escape codes it is no longer portable, and the one part worth lifting has been lost.
- **Shipping the TUI shell.** The shell is built to be driven by hand. The module behind it is the part with a future.
- **Choosing the shape that wires most easily to a TUI.** The shape answers to the question, not to the harness.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
