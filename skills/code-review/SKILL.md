---
name: code-review
description: Review a diff on two axes — does it implement what was asked, and does it follow this repository's own standards. Use when work is finished and about to be committed, or when the user asks for a review.
---

# Code Review

Two questions about one diff, asked independently:

- **Spec** — does this implement what the ticket or spec asked for?
- **Standards** — does it follow this repository's own documented standards, boundaries, and Decisions?

They are separate because a change can pass either one while failing the other. Code that follows every convention and builds the wrong thing passes Standards and fails Spec. Code that does exactly what was asked in a style this repository rejected passes Spec and fails Standards. Report them together and the stronger axis hides the weaker one.

**Two axes. There is no third** — architecture folds into Standards, below.

## 0 — Verification

This review reads Context for boundaries and Decisions for ADRs, so it opens with the one-line verification report `CLAUDE.md` requires:

```
Verification
  marker a3f91c2, tree clean — context trusted as-is
  → contexts loaded: database, api
```

Nothing to report is still reported. The rule and both drift reads are in `CLAUDE.md`.

## 1 — Pin the fixed point

Everything downstream is a function of one ref. Take whatever the caller supplied — a SHA, a branch, a tag, `main`, `HEAD~5` — or ask for it.

**The subject is the working tree, not just what is committed.** `/implement` calls this review *before* the commit question, so on the path that matters most the entire change is uncommitted and a commit-range diff is empty. Pin the range and the tree together, and review their union:

- committed — the range from the fixed point
- uncommitted — staged and unstaged changes, plus untracked files

Then prove it, here, in the parent:

- the ref resolves
- the subject is **non-empty** — an empty diff *and* a clean tree

A bad ref or an empty subject fails at this step, before two subagents are spawned to review nothing. Inside a subagent that failure is invisible: it comes back as a confident report on no content.

The committed side compares against the **merge-base**, not the raw ref, so commits that landed on the base branch since this work started are not attributed to it. Every invocation — the diff, the commit list, and the working-tree read — is in [`tools/git.md`](../tools/git.md).

## 2 — Find what was asked for

In order, stopping at the first that answers:

1. **The ticket the caller is holding.** `/implement` knows which ticket it claimed; that is the spec.
2. **Issue references in the commit messages** — resolve them through the tracker ([`tools/github.md`](../tools/github.md), [`tools/gitlab.md`](../tools/gitlab.md)).
3. **A path the user passed.**
4. **A spec under `.claude/docs/designs/`** matching the branch or the feature.

If none of these answers, ask. If the user says there is no spec, the Spec axis reports **no spec available** and is skipped — it does not reconstruct one from the diff. **Never invent, guess, or infer the requirements from the code being reviewed**: a spec derived from the diff agrees with the diff by construction, which turns the axis into a rubber stamp while still producing a report that reads like a review.

## 3 — Find what this repository requires

This repository's own standards, always first:

- `.claude/rules/` — the standards `/configure` discovered here, path-scoped where they apply to part of the tree
- `.claude/context.md` and the Domain Contexts it routes to — boundaries and ownership
- `.claude/docs/decisions/` — the ADRs
- `CONTRIBUTING.md` and whatever else this repository documents about how code is written

Under those sits a fallback vocabulary of design smells, in [SMELLS.md](SMELLS.md). It exists so that a repository documenting nothing still gets a review with something to say. **The repository always overrides it.** Where a documented standard endorses something the baseline would flag, the standard wins and the smell is suppressed — silently, without a note explaining that Tenure would have preferred otherwise.

Skip anything a linter, formatter, or type-checker already enforces. A finding a machine will make thirty seconds later is noise, and noise is what teaches a reader to skim reviews.

## 4 — Run both axes

**In parallel, as two subagents**, spawned in a single message. Parallel is for latency; separate subagents are for correctness. An axis that can see the other's findings starts agreeing with them — the second reviewer to read "this looks fine" is measurably less likely to disagree, and pollution in that direction is invisible in the output. Two contexts that never touch cannot converge.

Give each one the diff invocation and the commit list. Give each one **paths, not pasted content**, wherever the source is a file in the repository — a subagent can read, and pasting spends the parent's context on material only the child needs.

### Spec

Brief: report (a) requirements the spec asked for that are **missing or partial**; (b) behaviour in the diff nobody asked for — **scope creep**; (c) requirements that look implemented but are **implemented wrongly**. Quote the spec line for each finding. Under 400 words.

### Standards

Brief: report where the diff breaches a documented standard, citing the file and the rule; and any baseline smell, naming it and quoting the hunk. **Every finding cites its source** — a finding with no citation is an opinion, and an opinion in a review is indistinguishable from a standard to the person receiving it.

Architecture is part of this axis, not a third one, because boundaries and ownership are *this repository's* documented rules and not general engineering advice. Three questions it must reach:

- Are the ownership boundaries in `.claude/context.md` still respected?
- Was an abstraction introduced that the change did not require?
- Does the diff **contradict an ADR**? Say so explicitly — name the ADR and the line of the diff that contradicts it. A contradiction the reviewer notices and lets pass silently is worse than one it never saw, because the record now shows the decision was reviewed and upheld.

Two rules are Tenure's own and apply even where the repository documents neither (ADR 0007). `/implement` writes to them; this axis is where a breach is caught:

- **Comments explain *why*, not *what*.** Flag a comment that would be unnecessary if the code named things honestly — the finding is the naming, not the comment.
- **A public interface is documented; private implementation is not.** Flag an undocumented contract callers depend on, and documentation of internals that now has to be kept true for no caller.

Mark each finding **hard violation** or **judgement call**. A documented standard can be breached hard; a baseline smell is always a judgement call.

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

The third is the one that gets skipped. *"That's fine, leave it"* is a deliberate trade-off and it needs a home, because a trade-off nobody wrote down is re-discovered on every future review, argued again, and accepted again. That is how reviews become noise, and a reader who has learned to skim one review skims the one that mattered.

Record an acceptance as an **ADR** when it clears the 3-of-3 test in [`domain-modeling`'s ADR-FORMAT.md](../domain-modeling/ADR-FORMAT.md) — most do not clear it. Otherwise it is a note on the ticket. Either way the next review reads it and does not re-raise it.

**Accepting is the user's call, never the reviewer's.** A reviewer that accepts its own findings has reviewed nothing.

## Reviews are never persisted

There is no `.claude/docs/reviews/`. A review is about a diff, and once that diff is merged its subject no longer exists — a stored review is a document describing a state of the repository that has not been true since the day it was written.

Everything durable graduates out instead: a fix is in the code, a boundary rule is in Context, an accepted trade-off is an ADR, an unfixed problem is a ticket. What is left after those four is genuinely disposable.

---

Two-axis structure and the smell baseline derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
