# chore(skills): vendor /research and /prototype

Status: ready-for-agent
Blocked by: —

## Problem

Both are Heavyweight-gate destinations: `/design` sends work to `/research` when an assumption needs *facts*, and to `/prototype` when it needs *feel* (does this state model work, what should this look like). Both exist in matt's set and need little beyond vendoring.

## Outcome

`./skills/{research,prototype}/` — both model-invoked, since `/design` must reach them.

`/research` keeps its shape: subagent, primary sources only, every claim traced to the source that owns it, findings written as one cited Markdown file at `.claude/docs/research/`.

The subagent is for **context isolation**, not for skipping the wait — it burns its own window reading and returns one small cited file. Whether `/design` waits is a separate axis:

- **Gated research blocks.** The Heavyweight gate fires because an assumption is load-bearing, so the design cannot proceed around it. Dispatch, wait, read findings, continue.
- **Ungated research runs in the background.** It enriches but changes no decision; `/design` keeps working and folds findings in when they land.

Findings record **what they were verified against** — version and date. A fact about an external API is true at a version, not forever.

Research is **evidence, not knowledge**: nothing validates it afterwards. A durable finding graduates to `context.md` (how things behave) or an ADR (why an approach was chosen), exactly as prototype findings do. Check `.claude/docs/research/` for an existing answer before starting new research — same reuse discipline as prototypes.

`/prototype` keeps its question-shaped branches. Change the code location to `.claude/prototypes/<name>/` and the write-up to `.claude/docs/prototypes/`. Note the distinction — throwaway *code* and its *write-up* live apart, and the write-up outlives the code.

Prototype lifecycle per ADR 0009:

- **Code is always deleted** once the question is answered — promoted first if it can be, deleted either way. `.claude/prototypes/` is gitignored scratch. No reusable-harness exception.
- **The write-up is the artifact** — `.claude/docs/prototypes/<name>.md`: question tested, hypothesis, method, what it was verified against (version and date), limitations, result, conclusion.
- **Conclusion** is one of Successful / Partially Successful / Failed / Inconclusive, with reasoning. Required for Failed, Inconclusive, and unpromoted Successful; optional only when promoted.
- **Written before deletion.** A prototype is not finished until its conclusion is recorded — this ordering is what makes the discipline hold.
- **Hand back a way to see it.** A prototype that answers a *feel* question — does this layout work, does this interaction read right — is worthless until the user looks at it. End with the command that runs it, or drive the built-in `run` skill. Do not describe a UI in prose and call the question answered.
- **Reuse operates on the write-up**, not the code: same question, assumptions still hold, trust the recorded finding.
- **Promotion is a new effort** — redesign, integration, tests, documented APIs. Not moving files.
- **Findings graduate.** How the repo behaves → `context.md`. Why an approach was chosen → an ADR. The write-up stays as evidence, not as knowledge.

## Acceptance

- `/research` writes to `.claude/docs/research/`, `/prototype` to `.claude/prototypes/` and `.claude/docs/prototypes/`.
- Neither is user-invoked — `/design` must be able to reach both.
