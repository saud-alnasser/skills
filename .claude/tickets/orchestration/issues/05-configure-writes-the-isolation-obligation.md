---
owner: repository
title: feat(skills): configure writes the isolation obligation
status: resolved
blocked-by: [02]
part-of: orchestration
---

## Problem

Worktree isolation branches a child from the repository's default branch, not from the parent session's head. A child dispatched to build a portion of a claimed ticket would therefore branch from trunk and build against a tree that does not contain the work it is extending. The failure is silent and produces plausible code: the child succeeds, the integration looks routine, and the result is wrong in a way no test on the child's side can see. A sentence in a skill telling a caller to set the base ref correctly is not enough, because the caller that forgets produces no error.

## Outcome

The configure stage writes the isolation configuration when it configures a repository, so a child branches from the work in progress rather than from trunk. The obligation is recorded where configuration is recorded, and the migration recognises a repository that has orchestration but not the setting and repairs it.

Configuration alone is not trusted, because a repository can be configured by hand or by an older version. The build stage confirms a child's base before integrating anything, so a wrong base is caught by the integrator rather than by whoever reads the merged result weeks later. That check is this ticket's, not the dispatching ticket's, because the reason for it belongs with the reason for the setting.

## Acceptance

- The configure stage writes the isolation configuration, and a newly configured repository has it without anyone asking.
- The migration detects a repository missing the setting and repairs it rather than reporting it.
- The obligation states why it exists — that the default branches from trunk and that the failure is silent — so a reader deleting it knows what they are deleting.
- The build stage confirms a child's base before integrating, and refuses to integrate a child based on anything but the claim.
- The refusal names what it found, rather than failing generically.
- The suite asserts the setting is written, the migration row exists, and the base check exists at the integrator — each guard confirmed to fail against its removal.
- The suite passes.

## The specification moved, and it was not planned to

Writing `.claude/settings.json` puts a file in the configured repository that §21's canonical layout did not name. The first answer was that it could stay out of the layout, since `settings.local.json` is out of it too — wrong, and caught at review: §21 already lists `.gitignore`, which git owns and `/configure` generates, and ADR 0031 put it there rather than narrowing the layout to exclude it. `settings.local.json` is absent because it is Position; a committed file has no such cover.

So §21 gains the entry, ADR 0045 records the amendment, and the version moves to 1.6.0 — the human's call under ADR 0029, taken as one. `streamline/05`'s one-loose-file criterion was amended in the same pass to mean one loose file *this workflow owns*, with the exemption as a named list rather than a raised count.

Worth carrying forward: the check that caught the divergence is `aep/06`'s entry-for-entry comparison of the generated tree against §21 — the guard ADR 0031 introduced after the same failure.

## Noted, not fixed

The base check states ancestry in one direction: the claim must be an ancestor of what the child built on. That holds while the parent's HEAD sits at the claim, and inverts if the parent commits between dispatch and integration — a correct child would then be refused. The mechanics of a moving parent belong to 06, which owns dispatch and integration; recorded here because this ticket wrote the sentence.
