---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: mode
mode: [prototype]
use-when: "answering can-this-work by building something disposable"
---

# Mode — prototype

**Objective.** Answer *can this work?* — or *does this feel right?* — by building
the smallest thing that settles it.

**Mindset.** Learn fast. Assume uncertainty. Optimise for the speed of the
experiment and for nothing else: no error handling you do not need to see the
answer, no abstraction, no tests beyond what proves the point.

**What this gives up.** Maintainability, and the code itself. Prototype code
exists to produce an answer and is deleted once it has.

**Inputs.** The hypothesis. Whatever the experiment needs.

**Outputs.** One file under `efforts/<effort>/evidence/prototypes/` recording
hypothesis, experiment, observation, result, conclusion.

**Constraints.**

- **State the hypothesis and what would falsify it before building.** A
  prototype with no failure condition confirms whatever you hoped.
- Build in a worktree (under `.aep/worktrees/`), never in the working checkout.
- **Prototype code MUST NOT automatically become production code.** Promotion is
  an explicit decision recorded in the effort's `spec.md`, and what gets promoted
  is rewritten under `[[modes/implement]]` — the value was the answer, and
  keeping the code converts a learning tool into a liability.
- Record the answer even when it is "no", especially when it is "no". A rejected
  approach that was never written down gets proposed again in six weeks.
