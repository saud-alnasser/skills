---
owner: repository
status: accepted
load-when: the tracker's declaration of what a ticket is has to be read or changed
sources: [.claude/policies/tracker.md]
supersedes: []
superseded-by: []
---

# What a ticket is, is a declared tracker fact

The first external field run (`.claude/evidence/research/2026-08-03-rentable-field-run.md`) published seven decision tickets on a tracker whose version-control policy binds every ticket to one branch, one commit, one pull request — where a decision, producing no branch, cannot be a ticket at all. Nothing in AEP compared its assertion against the target's definition. We decided the tracker policy declares **what a ticket is here** — *branch-bound* or *tracked intent* — written by `/configure` from the repository's version-control policy and re-checked by its audit, and the maps policy places decision work by reading that declaration: on branch-bound trackers decisions live in the design document, resolved in place, with only the map itself on the tracker.

## Considered Options

An at-use routing step inside the maps policy, re-deriving the branch-bound test from version-control prose on every map run, was rejected: it is the same inference-instead-of-reading that the tracker policy's "read rather than inferred" rule exists to prevent, and a repository phrasing its model unusually gets misread silently. A transitional both-homes variant (declaration plus an in-policy fallback test) was rejected as two homes for one rule; the fallback test lives once, in the tracker template, for repositories configured before this decision.

## Consequences

`/configure` and its audit gain a detect-and-re-check obligation. Decision-ticket numbering and edge-semantics questions largely dissolve on branch-bound trackers, because decision work stops being tickets there.
