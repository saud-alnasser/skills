---
owner: repository
title: fix(skills): the ignore rule covers the harness's child workspaces
status: resolved
blocked-by: []
part-of: worktrees
---

## Problem

The block `/configure` writes into a repository covers `/position/` and `settings.local.json`. The harness creates a worktree for every isolated child under `.claude/worktrees/`, and its documentation names adding that path to `.gitignore` as the remedy. So a repository AEP configures shows a dispatched child's whole checkout as untracked inside the protocol directory the first time it fans out, and keeps showing it, because a worktree that holds work is kept on purpose.

The orchestration effort shipped the system that creates those directories without the rule that covers them.

## Outcome

The shipped ignore block covers the harness's child workspaces, anchored as `/position/` is and for the same reason — a child workspace contains its own `.claude/`, so an unanchored pattern would match inside it. The comment states the category rather than listing instances: there are now two paths outside `position/` and both are the harness's, so the reason is the shape they share and not their names.

`/configure` repairs a repository whose ignore file predates the rule instead of reporting it, because a repository that was configured once does not get configured again on its own.

§21 names the directory and marks it as the harness's. This is the split the layout had not resolved — `position/` is listed for being AEP's, `settings.local.json` omitted for being per-clone, and this path is both. Naming it is what brings it inside the entry-for-entry comparison of the generated tree against §21, which is the guard that caught this class of divergence the last time it happened. ADR 0050 records the amendment. **The version move is the human's call under ADR 0029** — surface it, do not take it silently.

## Acceptance

- A repository configured by AEP does not show a dispatched child's workspace as untracked in its main checkout.
- The entry is anchored, so it cannot match a `.claude/worktrees/` nested inside a child's own checkout.
- The ignore file's comment gives the reason in terms of the category, and no longer claims `settings.local.json` is the only path outside `position/`.
- A repository whose ignore file predates the rule is repaired by `/configure` rather than reported, and the path that reaches it is the one an already-configured repository actually takes.
- §21 names the directory and says it is the harness's, not this workflow's.
- The version move is put to the human rather than taken.
- The suite asserts the shipped block covers the path, that it is anchored, and that the repair path names it — each guard confirmed to fail against a deliberate removal before it is trusted.
- The suite passes.

## The generated tree moved too, and the plan did not say so

The design put the directory in §21 and said nothing about `/configure`'s own generated tree. `aep/06` asserts the two agree **entry for entry, in both directions** — "the tree generates X and the spec does not name it" is a failure exactly as the converse is — so naming it in one was never available. The tree gained the row as well.

That is the right outcome rather than a concession to a guard. The tree already lists directories `/configure` does not create: everything under the lazy-creation paragraph is there because the tree is the shape of a conforming repository, not a manifest of what a run writes. `worktrees/` is the strong case of the same thing — no command of this workflow ever creates it — and the skill now says so where a reader meets the row.

It also falsified a paragraph nobody was looking at. The prose beneath the tree explained the two `settings` files as the harness's, with per-clone status as what keeps `settings.local.json` out of the layout. `worktrees/` is per-clone *and* in the layout, so that reasoning read as a rule it never was. Corrected in the same change: what keeps a path out is not being per-clone, it is not being a category. The three `orchestration/05` guards pinning that paragraph's wording still hold.

## Notes

The guard is the risky part, not the entry. `.claude/rules/skills.md` records the recurring failure — a guard that matches a phrase travelling with the subject rather than the subject itself, passing while what it existed to catch sits in the tree. Four assertions already parse the block out of `configure/SKILL.md`; read them before adding a fifth, and confirm the new one goes red against a deliberate reintroduction.
