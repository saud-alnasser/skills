---
status: accepted
load-when: something is about to be written to a tracker other people read
sources: [.claude/policies/tracker.md]
supersedes: []
superseded-by: []
---

# What Tenure may write to a tracker other people read

On a shared tracker, every write lands in someone else's workspace. Four rules bound what Tenure may do there.

**Creating an issue is publishing.** `tools/github.md` already gates pull request creation on exactly this reasoning and left `gh issue create` ungated — so `/design` could spray a whole ticket set into a team's tracker unasked, which is the booming failure at its worst. The set is proposed, iterated, and approved before anything is created; it lives in the design document until then, where a teammate can argue with the breakdown while that is still cheap.

**One `/design` run creates exactly one root issue**, with every ticket beneath it as a sub-issue. A design yielding a single ticket makes that ticket the root — wrapping one child in a parent is noise. The tracker's top level therefore grows by exactly one per design, which makes booming visible at a glance rather than needing a count.

**The frontier is build tickets only.** An incoming issue somebody filed and triaged to `ready-for-agent` has no outcome, no acceptance criteria, and no edges; `/implement` cannot build from it. It is `/design`'s input, and becomes a root. On a shared tracker the triage queue and the build frontier are the same list, which is where the two vocabularies actually meet.

**The merge resolves the ticket, not Tenure.** Tenure commits but never pushes, opens a pull request, or merges, so setting `resolved` on a shared tracker asserts an outcome it does not control. Commits carry a non-closing `Refs #NN`; the drafted pull request body carries `Closes #NN`; the issue closes when the human merges.

## Considered Options

- **Close the issue at commit.** Rejected: a closed issue whose pull request is later rejected is a lie the tracker now tells everyone, and it contradicts the standing rule that publishing is the human's.
- **A `built` state between claimed and closed.** Rejected: it is a state only Tenure ever writes or reads, on a surface reserved for human-level facts.
- **`Closes` in the commit message.** Guarantees closure without depending on the drafted body being used, but gives every commit live closing power — a cherry-pick or a rebase onto the default branch then closes an issue nobody merged. Rejected for plain git; the hazard does not exist under stacked changes, where it is reversed (ADR 0016).

## Consequences

Between commit and merge no new tracker state is needed: the branch still exists, so the Claim still holds and the ticket stays off the frontier on its own.

Closure depends on the drafted pull request body actually being used. A human who writes their own without the keyword gets no closure — an acceptable cost, because the alternative is a commit that can close issues by accident.

`gh` has no blocking or sub-issue subcommand. Parent/child uses the sub-issues REST API through `gh api`, whose payload shape is explicitly not stable knowledge and requires a docs fetch; blocking edges stay as text in the body. Nothing in the ticket format may promise an invocation the tool reference does not document.
