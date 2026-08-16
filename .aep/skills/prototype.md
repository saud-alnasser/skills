---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
mode: [prototype]
use-when: "a technical or design question will not settle on paper and needs building to answer"
---

# /prototype — answer it by building

Builds the smallest disposable thing that settles a question, records the answer,
and throws the code away. A **capability, never a stage**.

**Enters `[[modes/prototype]]`.** Read it and hold its tradeoffs.

## When this is the right instrument

The uncertainty is **technical or experiential**: will this approach hold up,
does this state model survive real interaction, is this fast enough, does this
API behave as documented under our load. `[[rules/evidence]]` routes facts to
`[[skills/research]]` and product ambiguity to `[[skills/refine]]`.

## Procedure

1. **State the hypothesis, and what would falsify it.** Both, in writing, before
   any code. *A prototype with no failure condition confirms whatever you hoped.*
2. **Create a worktree.** `[[worktrees]]` — never prototype in the working
   checkout; the whole point is that this code is going to be deleted.
3. **Build only what answers the question.** No error handling you do not need to
   observe the result, no abstraction, no tests beyond the ones that prove the
   point. Everything else is time spent on code with a known expiry.

   Two shapes have enough craft behind them to be worth their own procedure:
   `[[skills/prototype/ui]]` when the question is what something should look
   like, and `[[skills/prototype/logic]]` when it is about state, transitions, or
   data shape. Anything else is built here.
4. **Run the experiment and observe.** Record what actually happened, including
   the parts that surprised you.
5. **Write the evidence.**
6. **Delete the worktree.**

## Output

`efforts/<effort>/evidence/prototypes/<hypothesis-slug>.md`, in the shape
`[[templates/prototype.template]]` gives: Hypothesis, Falsifier, Experiment, Observation,
Result, Conclusion, and the disposition of the code.

## Constraints

- **Prototype code MUST NOT become production code.** Promotion is an explicit
  decision recorded in the effort's `spec.md`, and what is promoted is
  **rewritten** under `[[modes/implement]]` with the tests and handling a
  prototype deliberately skipped. *Why: the value was the answer; keeping the
  code converts a learning tool into a liability that nobody remembers is one.*
- **Record the answer even when it is "no"** — especially then. A rejected
  approach nobody wrote down gets proposed again in six weeks.
- The evidence file survives; the code does not.

## Done when

The hypothesis is confirmed or refuted against its stated falsifier, the evidence
is written, and the worktree is gone.
