# chore(configure): adopt the covered ignore rule here

Status: resolved
Blocked by: 01
Part of: worktrees

## Problem

This repository dispatches children on both axes and carries `.claude/worktrees/` already, uncovered by its own ignore file. Until it adopts what 01 ships, the framework's own clone has the defect the framework just fixed for everyone else — and its installed ignore file diverges from the block it distributes, which is how the audit branch finds work that nobody meant to leave.

## Outcome

`.claude/.gitignore` here matches the block 01 ships, so a child workspace in this clone is ignored and the installed copy stops diverging from the distributed one.

This is the adopt-here ticket every effort in this repository ends on. Its whole effect is under `.claude/`, which is protocol-only work — and the rule against protocol-only tickets binds a *shared* tracker, where creating an item publishes. This tracker is markdown files under `.claude/`; the policy says the rule is vacuous here, and every prior effort's final ticket is the precedent.

## Acceptance

- `.claude/.gitignore` in this repository is byte-identical to the block 01 ships.
- A path inside a child workspace in this clone is confirmed ignored by asking git, not by reading the file.
- `.claude/protocol.md` here no longer claims a single path sits outside `position/` — 01's whole-diff check found the router stating the same count the ignore comment did, and fixed only the shipped copy.
- The suite passes.

## Comments

**"Byte-identical" is asserted modulo line endings.** The file is checked out with the platform's, so a literal byte comparison fails on Windows and passes in CI — green in the one place nobody would look. The guard normalises `\r\n` and compares the rest exactly.

**The over-broad half of the git probe could not fire, twice.** It asserts the entry does not hide committed knowledge, and it was written against a committed file path. `git check-ignore` **skips tracked paths** — ignore rules do not apply to tracked content — so it answered "not ignored" no matter what the patterns said. The first repair guessed the cause was directory-versus-file matching and added a directory probe; that was also wrong, and appending `policies/` kept it green a second time. `--no-index` is what makes the probe answer the question. Both wrong theories are recorded because the guard looked correct each time, which is the failure mode `.claude/rules/skills.md` describes and the reason it demands the mutation rather than the reasoning.

**One of 01's criteria was completed here.** The spec asks the suite to assert the **migration row** names the entry, and 01 edited `MIGRATION.md` without guarding it — the audit-repair guard covers a different path in, so nothing caught the gap. Found by the spec check at this commit, and added here rather than by amending 01, which would have restacked this branch to close a bookkeeping hole. Mutation-tested like the rest.

**The ticket's own scope was outside the vocabulary.** It was written `chore(protocol)`; `.claude/policies/version-control.md` lists the domains in use and `protocol` is not one. Retitled `chore(configure)` to match the commit.

**`git check-ignore` has no entry in `.claude/tools/git.md`.** It was used repeatedly across this effort — to establish the defect, and now as the assertion — and its tracked-path behaviour is exactly the kind of fact that reference exists to hold. A configuration gap, stated rather than filled here: the shipped `skills/configure/tools/git.md` would need the same entry, which is more than this ticket's acceptance covers.
