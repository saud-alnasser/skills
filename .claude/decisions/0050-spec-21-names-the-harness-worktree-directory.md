---
owner: repository
status: accepted
load-when: the ignore file or the layout omits a directory something writes
sources: [.claude/.gitignore]
supersedes: []
superseded-by: []
---

# Spec §21 names the harness's worktree directory

The harness creates a worktree for every isolated child under `.claude/worktrees/`, so orchestration puts a directory inside the protocol directory that §21's canonical layout did not name and that `/configure` does not create. The layout's two existing rules each answer differently: `position/` is listed because it is this workflow's, and `settings.local.json` is omitted because it is per-clone — and this path is both at once. We decided §21 **names it, marked as the harness's rather than AEP's**, and that the ignore block covers it as a second instance of the exception already made for `settings.local.json`: a harness-fixed path that cannot be moved under `position/`. It is Position by the membership test — wrong in another clone, and depended on by nothing, since losing one costs a rebuild that `/implement` already treats as the price of a returned ticket.

## Considered Options

- **Omitting it, as `settings.local.json` is omitted** — rejected: `aep/06`'s entry-for-entry comparison of the generated tree against §21 is the guard ADR 0031 introduced after this same class of divergence, and it cannot see a directory §21 does not name. The cheaper option is the one that leaves nothing watching.
- **Relocating worktrees under `position/` by symlink** — not available. The harness refuses to create a worktree when `.claude`, `.claude/worktrees`, or the worktree directory itself is a symlink.
- **A `WorktreeCreate` hook placing them elsewhere** — rejected: it replaces the default git logic entirely, which also disables `.worktreeinclude` processing, and adds a startup failure mode. A large mechanism bought to avoid one ignore entry.
- **Treating a child workspace as a new category beside Position** — rejected: it passes Position's own membership test unchanged, and a second category would need its own invariant to answer the question Position's already answers.

## Consequences

Amends the specification's repository layout (§21) in the same change, per ADR 0029, moving it to **1.8.0** — the human's call, taken as one, and the same size of move ADR 0045 made for the same section. Follows ADR 0045, which put `.claude/settings.json` into the same layout for the same reason — a harness-owned path the workflow depends on. The ignore file's comment stops naming `settings.local.json` as the only path outside `position/`: there are two, both the harness's, and the comment states the shape they share.
