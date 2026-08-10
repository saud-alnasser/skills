---
owner: repository
title: "feat(policies): the delivery policies convert and the set-dispatch prohibition narrows to landing"
status: resolved
blocked-by: [01, 03]
part-of: crystallize
---

## Problem

The delivery-family policies — tickets, specs, version control, sub-agents, and
the tracker template — have the same essay-with-norms shape and no ownership.
One of them also asserts a falsified norm: the version-control policy bans
dispatching a ticket set, while its stated premise only supports a rule about
landing, and the worktree-removal rule misfires by construction on children that
never commit. A waiting drift finding records both.

## Outcome

The delivery-family policy templates convert to framework-owned norm form with
their extension points named — the commit unit, the tracker choice, and the spec
home become declared repository facts rather than policy prose. The dispatch
norm is rewritten to what ADR 0077 decided: dispatch is independent of landing;
on an effort-commit repository the orchestrator integrates children into the
effort's commit and excludes a failed sibling by judgement, and that judgement
cost is stated in the norm. The worktree norm gains the never-commit
disposition ADR 0077 defines. The drift finding records where it was healed.

## Acceptance

- Same conversion criteria as the knowledge family, including the manifest
  mechanism the pilot proved: ownership declared, norm form throughout,
  extension points named, no single-repository facts, every manifest row
  guarded and fire-checked.
- The dispatch norm permits what the recorded successful run did and states
  what is lost relative to per-ticket landing.
- The worktree norm gives a child that never commits an exit that does not
  require cleaning a tree to dodge a refusal.
- The set-dispatch drift finding is marked consumed, naming this healing.

## Comments

The whole-effort review found the first criterion partially delivered: the
tickets, specs, and sub-agents policies were stamped and byte-locked but their
prose was not rewritten to norm form. Ticketed rather than rushed — ticket 09
carries the remaining conversion with the same manifest mechanism, split out
because the three files carry ~70 suite pins and a late-run rewrite risks the
stability this effort exists to buy.
