# Spec Format

Standard and above. Written to `.claude/docs/designs/<slug>.md`.

A spec is the reasoning behind the tickets — the thing that lets someone judge whether the tickets are the right ones. Tickets say what to build; the spec says why that and not something else.

## Template

```markdown
# type(scope): summary

Status: draft
Sources: <paths worth starting from>

## Problem

What is wrong or missing now, from the perspective of whoever feels it.
State the problem, not a solution wearing a problem's clothes — "we have
no caching layer" is a solution; "the dashboard takes nine seconds to
load" is a problem.

## Goal

What becomes true when this is done. One or two sentences.

## Constraints

What the solution has to live within, and that a reader would not guess:
compatibility promises, latency or cost budgets, data that cannot move,
deadlines that shape the approach. Not preferences.

## Architecture

The shape of the solution in this repository's vocabulary — the modules
involved, the seams between them, what crosses each seam. Enough that a
reader can picture it, not enough to be a substitute for reading code.

## Approach

How the work gets done, and in what order. Where the risky part is, and
what is done first to find out whether it is really risky.

Name the options that were considered and rejected, with the reason.
Otherwise the first reviewer proposes one of them again.

## Acceptance criteria

- Checkable statements about observable behaviour, by someone who did
  not write the code.
- The same standard as a ticket's, at the scope of the whole change.

## Risks

What could go wrong, how likely, and how you would find out early.
A risk with no detection plan is a wish.

## Out of scope

What this deliberately does not do. The explicit no-s stop the scope
creeping back in during review.
```

## Rules

- **No file paths outside `Sources:`, and no code.** Both go stale, and inside a spec they read as commitments. The exception is a snippet from a prototype that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape. Inline it, say it came from a prototype, trim it to the decision-rich part.
- **Use the repository's vocabulary.** Terms come from `.claude/context.md` and the Domain Contexts the work touches. A spec that invents its own words for existing concepts forces every reader to translate.
- **A section with nothing to say gets deleted, not padded.** Filler trains the reader to skim, and the sections that matter are the casualty.
- **The spec is not the decision record.** When the grill produced something that passes the 3-of-3 test, it becomes an ADR in `.claude/docs/decisions/` and the spec links to it. A spec is superseded by the next spec; an ADR is not.

## Status

`draft` while the grill is still running, `accepted` when the user approves it and the tickets are cut, `superseded` when a later spec replaces it. A spec that shipped stays on disk — it is the record of why the tickets looked like that.
