---
status: resolved
---

# fix(install): decide whether the link rewriter should see fenced blocks

## Outcome

The rewriter and the link checker agree about what a link is, or the disagreement
is recorded as deliberate with its reason.

## Acceptance Criteria

- [ ] Either the rewriter strips fenced blocks before matching, as `wikiLinks`
      does, or a comment states why it deliberately does not.
- [ ] Whichever way it goes, the install fixture covers it: a repository-owned
      file with a moved link inside a fence, asserted to be rewritten or left.

## Relevant areas

`rewriteMovedLinks` in `src/scripts/install.mjs`; `wikiLinks` in
`src/scripts/contract.mjs`, which strips fences and explains why.

## Notes

Raised by review of the effort that introduced the rewriter. **The two behaviours
are both defensible, which is why this is a decision rather than a fix:** a link
inside a fence is illustrative syntax the checker deliberately ignores, so
rewriting it edits an example; but leaving it means a shipped example keeps
naming a file that no longer exists.

Related: the rewriter also cannot tell a link that *navigates* from one that
*names a path as data*. It rewrote an acceptance criterion in this effort's own
`spec.md` on its first run — the line describing what the rewriter does. The
mitigation in force is the convention that such placeholders are written without
bracket syntax.

## Resolution — the rewriter strips fences

It matches fences and links in one pass and returns a fence untouched, so the
rewriter and the checker now agree about what a link is.

**Why this way round:** the rewriter's design is minimal reach into files the
repository owns, and editing an example is reaching further rather than less. A
fenced link naming a moved file was never resolving, so leaving it costs nothing
any checker would report. The accepted cost is that a shipped example can show a
stale path until its author updates it.

**The guard took two attempts to confirm, which is the part worth recording.**
Deleting the fence branch removes the subject *and* crashes the installer, so the
section aborts instead of reporting — and an abort reads like a failure while
proving nothing about the assertion. The perturbation that worked makes the fence
alternative unmatchable, leaving the program running and the fenced link
rewritable. The first attempt looked convincing and was not.
