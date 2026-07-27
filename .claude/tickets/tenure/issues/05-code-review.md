# feat(code-review): review axes for Tenure

Status: resolved
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

## Comments

**The review subject is the working tree, not a commit range.** Not in this
ticket, and it is the defect that would have made the skill useless to its
stated primary caller. `/implement` runs `/code-review` *before* the commit
question (`implement/SKILL.md` §4), so on that path the entire change is
uncommitted and `git diff <fixed>...HEAD` is empty — and the skill as first
written treated an empty diff as a stop. Every `/implement`-driven review would
have halted at step 1. Step 1 now pins the range and the tree together, and
`tools/git.md` gained the staged, unstaged, and untracked reads.

**The comment and public-API rules landed here, from ticket 13.** ADR 0007
places them by name — *"comment and public-API rules in `/implement` and
`/code-review`"* — so they are this skill's to carry, not ticket 13's to
distribute later. They apply even where the repository documents neither.
`/implement` carried neither and now writes to them in §2; this skill's
Standards axis catches a breach. The pair is what ADR 0007 asks for — a
producer and its checker, worded for their own actions — not one rule in two
homes. **Ticket 13 must not place either again.**

**`SMELLS.md` is a judgement call, and the one worth reversing if you disagree.**
This ticket's third acceptance criterion reads *"Findings are reported against
the repo's own documented standards, not generic ones"*, which is a fair reading
of *drop matt's Fowler baseline entirely*. It was kept, subordinated: the
repository's own standards are ranked first and always override, a baseline
finding is always labelled a judgement call, and the list is a separate file the
Standards subagent opens rather than context every caller pays for. The reason
for keeping it is that a repository documenting nothing otherwise gets a
Standards axis with nothing to say — which is the repository that most needs
one. Nothing else in Tenure carries this vocabulary; `codebase-design` is deep
modules and seams, not smells. Cutting `SMELLS.md` and its three assertions is a
clean reversal if the strict reading was intended.

**`tools/git.md` owns the review invocations**, including the three-dot/two-dot
pairing, which is the opposite of the Marker read in the same file and silently
wrong rather than broken when confused. The skill points at it. Two assertions
under ticket 15 pin the dot counts, because `..HEAD` still produces a plausible
diff — just one that blames this work for whatever landed on the base branch
after it started.
