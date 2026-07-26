# feat(code-review): review axes for Tenure

Status: ready-for-agent
Blocked by: 01

## Problem

matt's `code-review` runs two axes as parallel subagents — Standards and Spec. `workflow.md` asks the review stage to also validate **architecture**: boundaries respected, ownership maintained, no unnecessary abstraction introduced. That is not clearly covered by either existing axis.

Ships as `/code-review`, not `/review`, to preserve the built-in GitHub PR reviewer (decision 13).

## Outcome

`./skills/code-review/` — model-invoked, so `/implement` and `/commit` can reach it.

**Two axes**, as matt's has them — no third:

- **Spec** — does the diff faithfully implement what the ticket or spec asked for?
- **Standards** — does it follow this codebase's own documented guidelines and conventions?

Architecture folds into Standards rather than earning its own subagent, because boundaries and ownership are *this repo's* documented rules, read from `.claude/context.md`. The questions it must reach:

- Are ownership boundaries in `.claude/context.md` still respected?
- Was an abstraction introduced that the change didn't require?
- Does the diff contradict an ADR without saying so?

### Every finding gets one of three outcomes

| Outcome | Where it goes |
| --- | --- |
| **Fixed** | the code |
| **Ticketed** | a new ticket, when it is real but out of scope here |
| **Accepted** | recorded — an ADR when it passes the 3-of-3 test, otherwise a note on the ticket |

The third is the one that must not be skipped. *"That's fine, leave it"* is a deliberate trade-off, and with nowhere to record it the same finding is raised again on every future review — which trains the reader to skim reviews, at which point the review has stopped working. A recorded acceptance is read by the next review and not re-raised.

Acceptance is the user's call, never the reviewer's.

**Reviews are never persisted.** A review is about a diff; once merged its subject no longer exists. Everything durable graduates — a finding gets fixed (it's in the code), becomes a boundary rule (context), an accepted trade-off (an ADR), or an unfixed problem (a ticket). `.claude/docs/reviews/` is dropped from the layout.

## Acceptance

- Axes run in parallel subagents so they don't pollute each other's context.
- A diff contradicting an existing ADR is surfaced explicitly, not silently accepted.
- Findings are reported against the repo's own documented standards, not generic ones.
