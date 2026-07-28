# refactor(knowledge): derive this repository's own tool references

Status: resolved
Blocked by: 03

## Problem

This repository's `.claude/tools/` holds only its own tooling. Once the shipped tool skill is deleted, every skill working in this repository points at a directory that has no entry for the tools they most often reach for — the ones the workflow itself drives.

## Outcome

This repository's tool directory holds a derived reference for each tool it actually uses, alongside the entries it already has for its own tooling. Working here needs no file outside it.

## Acceptance

- A reference exists for each tool this repository is detected to use, and none for tools it does not.
- Every carried-over entry is byte-identical to the shipped entry it came from.
- The entries this repository already had for its own tooling survive unchanged.
- Every reference to a tool file from this repository's own knowledge resolves.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**Detection found two tools, and the third and fourth are absent on evidence.** `git` because there is a `.git/`, `gh` because the remote is GitHub. No `glab` — no GitLab remote. No `gt` — `.git/.graphite_repo_config` does not exist, which is the read `graphite.md` prescribes and not the `gt log --stack` probe, which initialises the repository as a side effect. The assertion reads all four facts off the tree rather than hardcoding the answer, so acquiring a GitLab remote or running `gt init` here turns it red instead of leaving a reference describing somebody else's repository.

**`gh` carries two entries of nine.** Seven are GitHub Issues operations — create, find work, comment and label, assignment, sub-issues, blocking, close-by-merging — and this repository's tracker is markdown files, with `tracker.md` recording that the GitHub issues are deliberately empty. `TOOLS.md`'s rule is to drop an entry when the operation cannot arise here, and none of them can. Kept: auth, and opening a pull request.

**One cross-reference is knowingly left dangling.** `git.md`'s never-push entry links `graphite.md`, which is not derived here. Byte-identity (criterion 2) and every-reference-resolves (criterion 4) genuinely collide, and editing inside a kept entry is the one thing the derivation rule forbids — so the entry is carried intact and the file says so above its first heading. The alternative of correcting the shipped source was rejected as a `skills/` change inside an adoption ticket. An assertion holds the exemption to exactly this one link and requires the carrying file to document it, so it cannot widen quietly.

**Deviation from criterion 3.** "The entries this repository already had for its own tooling survive unchanged" — `plugin.md` did; `verify.md` did not. It documented `-Ticket 09` and *"two digits, always"*, a CLI that `layout/01` replaced with `<effort>/NN` when it namespaced the ticket ids. A tool reference naming a form the tool rejects is worse than no entry, so it was healed at the moment it was read rather than left to satisfy the criterion's wording. The criterion's intent — derivation must not clobber this repository's own entries — holds.

**Healed in passing.** `layout/02`'s section comment claimed to be the only one asserting against `.claude/`; `tenure/20` already read `.claude/rules/`, `.claude/context.md`, and the spec. Corrected to the distinction that is actually true: reading `.claude/` as evidence is ordinary, reading it as the subject is what the two adoption tickets do.

**`CLAUDE.md`'s never-guess rule was repaired here**, as `03`'s comments assigned. It no longer conditions the workflow's tool reference on the plugin being installed.

**No Context update.** The change moves no concept and no boundary — `.claude/context.md` already records that ADR 0019 replaced the `tools` Primitive with a derived directory.
