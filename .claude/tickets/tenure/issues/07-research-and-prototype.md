---
owner: repository
title: chore(skills): vendor /research and /prototype
status: resolved
blocked-by: []
---

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

## Comments

**Neither skill restates gating or graduation, against this ticket's own
wording.** The ticket spells out *"Gated research blocks / Ungated research runs
in the background"* and *"durable findings graduate to `context.md` or an ADR"*.
`skills/design/SKILL.md` §4 already carries both, and ADR 0007 binds harder than
the ticket. Both are `/design`'s by ownership too: `/design` decides at the gate
and `/design` waits, and `/design` read the findings in order to decide while
nothing downstream will. What stays here is each skill's own boundary — *never
write Context directly* — and a pointer. The first draft restated both, and one
assertion *required* the duplication in order to pass; both rules are now in
`verify.ps1`'s single-home table so it cannot come back.

**`.claude/prototypes/` cannot hold a UI variant, and this ticket does not say
so.** Acceptance reads *"`/prototype` [writes] to `.claude/prototypes/`"*, but
`UI.md`'s sub-shape A mounts variants **on the real route** — which is the entire
reason it works, since a layout is only judgeable against real header, real data,
real density. Such code lives where it renders and is therefore *not* gitignored,
making it the prototype code most likely to be committed by accident. It is named
as the one exception, and deletion applies **harder** there, not softer: the
variants and the switcher come out in the same change that records the answer.
Reverse this by forcing every UI prototype into sub-shape B, at the cost of
judging layouts in a vacuum.

**The exemption is on the conclusion, not the write-up.** This ticket says
*"Conclusion … optional only when promoted"*; ADR 0009 says *"[the write-up] is
optional only when a prototype was promoted"*. The ticket's wording is kept
because it is the more precise of the two — the conclusion lives inside the
write-up, so a skippable write-up would make *"a prototype is not finished until
its conclusion is recorded"* unenforceable.

**matt's capture step is cut, not adapted.** Both originals end by committing the
prototype to a throwaway branch and leaving a pointer to it as a primary source.
ADR 0009 says the opposite and wins. A scanner over `skills/prototype/*.md`
rejects any line that puts prototype code on a branch, because that sentence is
exactly what a future re-vendor would reintroduce.

**`LOGIC.md` and `UI.md` carry only what is branch-specific.** The first draft
repeated `SKILL.md`'s shared rules — one command to run, no tests, no
persistence, the promotion rule, even the same illustrative quote — which is
duplication wearing progressive disclosure as a costume. What is left is the TUI
frame and the pure-module shape on one side, the sub-shapes and `?variant=`
switcher on the other.

**Review found five assertions that could not fail**, all the same shape: a
file-wide presence check that unrelated prose in the same file satisfied. The
write-up fields and the four conclusion values were greppable from the
surrounding text with the template gutted; the paths were named in four places
so moving them out of `.claude/` in the table stayed green; *optional only when
promoted* returned a bare `promot`; and *promotion is a fresh implementation
effort* only ever checked the second half of its own name. All rewritten against
the template, the table, or the step that owns them, and re-mutated.
