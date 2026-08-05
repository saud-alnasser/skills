---
name: review
description: Review a diff on two axes — does it implement what was asked, and does it follow this repository's own standards. Use when work is finished and about to be committed, or when the user asks for a review.
---

# Review

Mode: review
Policies: `.claude/policies/decisions.md`, `.claude/policies/sub-agents.md`

Two questions about one diff, asked independently:

- **Spec** — does this implement what the ticket or spec asked for?
- **Standards** — does it follow this repository's own documented standards, boundaries, and Decisions?

They are separate because a change can pass either one while failing the other — every convention followed on the wrong thing, or exactly what was asked in a style this repository rejected. Report them together and the stronger axis hides the weaker one.

**Two axes. There is no third** — architecture folds into Standards, below.

## 0 — Verification

This review reads Context for boundaries and Decisions for ADRs, so it opens with the one-line verification report `.claude/protocol.md` requires:

```
Verification
  marker a3f91c2, tree clean — context trusted as-is
  → contexts loaded: database, api
```

Nothing to report is still reported. The rule and both drift reads are in `.claude/protocol.md`.

## 1 — Pin the fixed point

Everything downstream is a function of one ref. Take whatever the caller supplied — a SHA, a branch, a tag, `main`, `HEAD~5` — or ask for it.

**The subject is the working tree, not just what is committed.** `/implement` calls this review *before* it commits, so on the path that matters most the entire change is uncommitted and a commit-range diff is empty. Pin the range and the tree together, and review their union:

- committed — the range from the fixed point
- uncommitted — staged and unstaged changes, plus untracked files

Then prove it, here, in the parent:

- the ref resolves
- the subject is **non-empty** — an empty diff *and* a clean tree

A bad ref or an empty subject fails at this step, before two subagents are spawned to review nothing — inside a subagent that failure comes back as a confident report on no content.

The committed side compares against the **merge-base**, not the raw ref, so commits that landed on the base branch since this work started are not attributed to it. Every invocation — the diff, the commit list, and the working-tree read — is in `.claude/tools/git.md`.

## 2 — Find what was asked for

In order, stopping at the first that answers:

1. **The ticket the caller is holding.** `/implement` knows which ticket it claimed; that is the spec.
2. **Issue references in the commit messages** — resolve them through the tracker (`.claude/tools/github.md`, `.claude/tools/gitlab.md`).
3. **A path the user passed.**
4. **A spec under `.claude/designs/`** matching the branch or the feature.

If none of these answers, ask. If the user says there is no spec, the Spec axis reports **no spec available** and is skipped — it does not reconstruct one from the diff. **Never invent, guess, or infer the requirements from the code being reviewed**: a spec derived from the diff agrees with the diff by construction, which turns the axis into a rubber stamp while still producing a report that reads like a review.

## 3 — Find what this repository requires

This repository's own standards, always first:

- `.claude/rules/` — the standards `/configure` discovered here, path-scoped where they apply to part of the tree
- `.claude/contexts/map.md` and the Domain Contexts it routes to — boundaries and ownership
- `.claude/decisions/` — the ADRs
- `CONTRIBUTING.md` and whatever else this repository documents about how code is written

Under those sits a fallback vocabulary of design smells, in [SMELLS.md](SMELLS.md). It exists so that a repository documenting nothing still gets a review with something to say. **The repository always overrides it.** Where a documented standard endorses something the baseline would flag, the standard wins and the smell is suppressed — silently, without a note explaining that AEP would have preferred otherwise.

Skip anything a linter, formatter, or type-checker already enforces. A finding a machine will make thirty seconds later is noise.

## 4 — Run both axes

**In parallel, as two subagents**, spawned in a single message. Parallel is for latency; separate subagents are for correctness — an axis that can see the other's findings starts agreeing with them, and that pollution is invisible in the output. Two contexts that never touch cannot converge.

Dispatch the shipped roles by name — **`spec-reviewer`** for the first axis, **`standards-reviewer`** for the second. Each carries what its axis reports and how, so nothing of that is retyped here; what a dispatched child is bound by is `.claude/policies/sub-agents.md`'s, and this stage restates none of that either.

What the brief adds is the subject, which is the part no role can know: the fixed point and both diff invocations, the commit list, where the spec is, and — for the Standards axis — [SMELLS.md](SMELLS.md) as the fallback baseline, since a role shipped to every repository cannot carry this one's.

Cap each at **400 words for Spec, 500 for Standards**. Two axes reporting at length produce a review nobody finishes, and the second half of a long report is where the findings that mattered go to be skimmed.

## 5 — Report

Both reports, under `## Spec` and `## Standards`, verbatim or lightly cleaned. **Never merge them and never rerank across them** — reranking is precisely the collapse the two axes exist to prevent, and it always favours whichever axis produced more findings rather than worse ones.

Close with one line per axis: how many findings, and the worst one *within that axis*. No single winner across the two.

## 6 — Every finding gets an outcome

A finding with no outcome is a finding that will be raised again next review.

| Outcome | Where it goes |
| --- | --- |
| **Fixed** | the code |
| **Ticketed** | a new ticket — real, but out of scope for this diff |
| **Accepted** | recorded — see below |

The third is the one that gets skipped. *"That's fine, leave it"* is a deliberate trade-off and it needs a home — a trade-off nobody wrote down is re-discovered, re-argued, and re-accepted on every future review.

Record an acceptance as an **ADR** when it clears the 3-of-3 test in `.claude/policies/decisions.md` — most do not clear it. Otherwise it is a note on the ticket. Either way the next review reads it and does not re-raise it.

**Accepting is the user's call, never the reviewer's.** A reviewer that accepts its own findings has reviewed nothing.

## Reviews are never persisted

There is no `.claude/reviews/`. A review is about a diff, and once that diff is merged its subject no longer exists — a stored review is a document describing a state of the repository that has not been true since the day it was written.

Everything durable graduates out instead: a fix is in the code, a boundary rule is in Context, an accepted trade-off is an ADR, an unfixed problem is a ticket. What is left after those four is genuinely disposable.

---

Two-axis structure and the smell baseline derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
