---
status: accepted
load-when: a request has to reach a stage without the user naming it, or which invocation axis a skill sits on is in question
sources: [CLAUDE.md, skills/configure/CLAUDE.template.md, skills/design/SKILL.md, scripts/verify.ps1]
supersedes: []
superseded-by: []
---

# Unplanned work enters the spine from the boot tier, and planning became selectable

A request that needs planning could not reach the stage that plans. Every other spine stage was model-invoked; `/design` alone carried `disable-model-invocation: true`, so a description of a problem selected `/implement`, which found no ticket and told the human to go type the command the model was forbidden to select. The decision is to state the entry stage in the always-on entrypoint — beside the question-versus-change guard that already sits there — and to move planning onto the model-invoked side of the axis this repository already defines, which the verification suite records as *the ones that must fire from a description of the problem*.

The route is a **boot-tier rule rather than a router skill**, because the failure being fixed is *a skill not being selected*, and a router would have to be selected too. Only the tier the harness loads unconditionally fires without being chosen.

## Considered Options

- **A router skill** — one model-invoked entry that classifies and hands off. Rejected: it inherits the failure mode it exists to fix, and adds a file.
- **Sharpening the description alone**, leaving the flag off. Rejected: the description would become the entire guard against planning firing on a question, with no backstop and nothing asserting it.
- **A prompt-submit hook** injecting claim and ticket state into every turn. The only genuinely deterministic option, and rejected for now: it cannot make the question-versus-change judgment anyway, it adds a moving part, and it becomes harness-specific under the runtime-independence effort that follows this one.
- **A Work Model, Planner, Executor, and Evaluator** as new systems, per the proposal this effort started from. Rejected: this protocol has seven stages in one order, so there is no execution graph to compose; the plan object already exists as the ticket set; and none of the four has an enforcing mechanism, which every existing system has.

## Consequences

Planning can now fire when nobody asked for it, and that is the cost. It is bounded by stating the route in one line before entering, so a misfire costs a line and a correction rather than a grill — which is why the stated route is load-bearing here and not presentation.

The reason the flag existed was recorded only as the name of an assertion, never as a Decision. That is what let it read as an unexamined convention on first inspection. The principle it encoded — *planning starts because the user asked for it* — is not discarded so much as re-read: in practice the alternative to planning starting on its own was never no planning, it was planning after a round trip.
