---
status: implemented
sources:
  - skills/configure/SKILL.md
  - skills/configure/MIGRATION.md
  - specs.md §21
  - .claude/.gitignore
  - .claude/policies/sub-agents.md
  - .claude/decisions/0006
  - .claude/decisions/0012
  - .claude/decisions/0045
  - scripts/verify.ps1
---

# fix(skills): the ignore rule covers the harness's child workspaces

## Problem

AEP dispatches children into isolated worktrees, and the harness puts every worktree it creates under `.claude/worktrees/` at the repository root. The ignore block `/configure` writes covers `/position/` and `settings.local.json` and nothing else. So **every repository AEP configures accumulates untracked child checkouts inside its own protocol directory the first time a fan-out or a dispatched set runs** — and the harness's own documentation names the remedy this workflow skipped, telling the reader to add exactly that path to `.gitignore` so worktree contents do not appear as untracked files in the main checkout.

It bites twice rather than once. A change record is Position and goes under the child's `.claude/position/`, which read from the main checkout is `.claude/worktrees/<child>/.claude/position/…`. The inner path is ignored by the committed ignore file the worktree checked out; the outer one is not. The orchestrator's own integration artefacts are therefore the first thing to surface.

Two things make this worse than untidy status output. A worktree holding work is **kept deliberately** — `/implement` keeps a failed child's workspace so a resumed session continues instead of rebuilding — so the noise is durable rather than transient, and a whole second checkout of the repository sits in every working-tree read the workflow makes, including the drift read the Marker falls back to. And the defect arrived with the orchestration effort itself: the system that causes the directory to exist shipped without the rule that covers it.

## Goal

A repository configured by AEP ignores the workspaces the harness creates for its children, and one configured before this rule is repaired rather than reported. The specification names the directory, so the guard that compares the generated tree against §21 can see it.

## Constraints

- **The path belongs to the harness, not to this workflow.** It cannot move under `position/`, for the same reason `settings.local.json` cannot: the harness fixes the location and would not find it anywhere else.
- **The repository's own root ignore file is left alone** (ADR 0006). What makes AEP addable and removable as one directory is that it never leaks entries into a file the repository owns.
- **One source of truth for the block.** `/configure` writes it exactly as the skill states it, so the skill is where it changes and nowhere else.
- **A change to what ships moves the suite in the same pass**, and a guard is confirmed to fail against a deliberate reintroduction before it is trusted.

## Architecture

**Position gains a second harness-owned exception, not a new category.** A child's workspace passes the membership test already written into the ignore file — it would be wrong in another clone — and it satisfies the invariant that nothing shared may depend on it, because losing one costs a rebuild and `/implement` already treats a returned ticket that way. What stops being true is the comment's claim that `settings.local.json` is *the one file outside* the directory. There are two such paths, both the harness's, and the comment states the shape rather than enumerating instances.

**The specification names the directory, marked as the harness's** (ADR 0050). This is the split the layout had not had to resolve: `position/` is listed because it is AEP's, `settings.local.json` is omitted because it is per-clone, and a path that is both per-clone and the harness's satisfies one rule each way. Naming it is what puts it inside the entry-for-entry comparison of the generated tree against §21 — the guard ADR 0031 introduced after this same class of divergence, and the one that caught it last time.

## Approach

Two tickets, a chain rather than a set: the second reads the first's output. The first changes what ships — the block, the migration row, the suite guard — so every repository AEP configures gets the fix. The second adopts it here, which is the pattern every prior effort ends on.

**The second ticket's whole effect is under `.claude/`.** That is protocol-only work, and the rule against it binds only what the workflow creates on a *shared* tracker; this repository's tracker is markdown files under `.claude/`, where the policy says the rule is vacuous. Recorded here so a reviewer reaching for it finds the answer already given.

Rejected, with reasons, so none of them is proposed again:

- **Relocating worktrees under `position/` by symlink.** Not available: the harness refuses to create a worktree when `.claude`, `.claude/worktrees`, or the worktree directory itself is a symlink, and names the symlinked path in the error.
- **A `WorktreeCreate` hook placing worktrees elsewhere.** It works, and it replaces the default git logic entirely — which also disables `.worktreeinclude` processing. A large mechanism, with its own failure mode at session startup, bought to avoid one ignore entry.
- **Adding the entry to the repository's root `.gitignore`.** Forbidden by ADR 0006, and it would put the fix where a repository could not remove AEP cleanly.
- **Leaving §21 alone and changing only the ignore block.** Cheaper, and it leaves the directory invisible to the one guard that would catch the next drift here.

## Acceptance criteria

- A repository configured by AEP does not show a dispatched child's workspace as untracked in its main checkout.
- A repository configured before this rule is detected and repaired, rather than reported as a finding.
- The ignore file states why the entry exists in terms of the category, so a reader deleting it knows what they are deleting, and does not read as a list of instances.
- §21 names the directory and marks it as the harness's rather than this workflow's.
- The suite asserts the shipped block covers the path, that the entry is anchored, and that the migration row names it — each guard confirmed to fail against its removal.
- The suite passes.

## Risks

- **The guard matches the wrong thing.** `.claude/rules/skills.md` records this as the recurring failure: a guard written from the new wording matches only that wording, or matches a phrase travelling *with* the subject rather than the subject. The detection is to write the guard, then delete the entry and confirm it goes red.
- **Anchoring.** `/position/` is anchored deliberately, because unanchored it would match at every depth. The new entry needs the same treatment for the same reason, and a child worktree contains a full checkout — including its own `.claude/` — so an unanchored pattern would match inside it.
- **Already-configured repositories never re-run `/configure`.** The repair path is real only if the audit branch reaches it; if it does not, the fix ships and no existing repository receives it. Detection is to check the audit against a repository whose ignore file predates the rule.

## Out of scope

- **A `.worktreeinclude` file.** A child inheriting the parent's `marker.json` would inherit a verification claim it did not earn, and nothing else per-clone is wanted in a child.
- **Where change records live.** Under the child's `.claude/position/` is correct and stays.
- **Worktree cleanup.** The harness sweeps worktrees older than `cleanupPeriodDays` and skips any that still hold work; `/implement` relies on that, and nothing here changes it.
- **The waiting drift finding** on the tracker's tracked-intent declaration. Unrelated to this request and still unconsumed.
