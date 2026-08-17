---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [implement]
use-when: "reviewed work is ready to land as a commit"
---

# /commit — land the change

The transaction boundary: everything before it produced a change in the working
tree, and this is where that change becomes history.

Two callers, one implementation: **`[[skills/implement]]`**, closing out a task it
claimed and had reviewed; and **a human**, for work with no task.

**`/commit` confirms; it does not repeat.** It never runs the tests, never
reviews, never researches — those stages already ran, and re-running them here is
rediscovery dressed as diligence.

## 1 — Confirm the stages ran

Four questions about state. None re-executes anything.

- **Was the position read this run?** `node .aep/scripts/position.mjs check`.
- **Were the tests run, and did they pass?** A change with no test surface answers
  honestly, in one line.
- **Did `[[skills/review]]` run, and does every finding have an outcome?** Fixed,
  ticketed, or accepted-and-recorded. A finding still open is a blocker or a
  task — **never a silent pass**.
- **Is the work finished against its task or spec?** Work without a task answers
  against what the human asked for.

**A failure here is reported, not fixed.** Name the incomplete stage and stop
(*the suite was never run; that is `[[skills/implement]]`'s*). A refusal the
caller cannot act on is a wall rather than a check — so always name what would
clear it.

## 2 — The whole diff against knowledge

The one question no earlier stage could ask: `[[skills/implement]]` sees one task
at a time, and this sees the change entire.

Read `git diff` and `git diff --staged` **in full** — not a summary. Then ask:
did this move a boundary, retire a concept, or relocate something a
`[[contexts]]` pointer names?

- **Where the diff contradicts a context or a reference, fix that in this
  commit** — so the change and the thing it falsified never land apart.
- A diff revealing a concept nobody had named is a **finding to report**, never a
  licence to name it here.
- Anything in the diff that no task asked for is removed or raised **before**
  committing.

## 3 — Update status, before staging

- The task → `resolved`.
- The effort's `spec.md` → `status: implemented`, when this commit completes its
  last acceptance criterion. **Only the status field moves**, never the content.

Before staging, because both are tracked: moving them afterwards leaves the tree
dirty the moment the commit lands.

## 4 — Regenerate derived state, before staging

```
node .aep/scripts/index.mjs
```

Commit is the last point at which the tree is known complete — an index
regenerated earlier can be falsified by a later edit in the same change. **Never
hand-edit an index instead**; `validate.mjs` regenerates and compares, so a hand
edit is a build failure that names the file.

## 5 — The message

**Detect before asserting.** Read `git log --oneline -30`, `CONTRIBUTING.md`, and
any PR template. Where the repository demonstrates a convention, follow it
silently. `[[rules/version-control]]` supplies the default only where the
repository is silent — including **which form the task reference takes**, which
depends on how work reaches the default branch and is read rather than inferred.

Say what capability changed and why. **Never a file-by-file account** — the diff
already lists the files.

## 6 — Commit, then stamp

Where landing this change means resolving a merge or rebase conflict,
`[[skills/commit/conflicts]]` has the discipline — a conflict is two intents, and
recovering both is the work.

```
node .aep/scripts/position.mjs stamp
```

**Last, once the commit exists** — a commit cannot contain its own hash, which is
why the marker is per-clone and written here. After this the marker equals `HEAD`
and the tree is clean: the postcondition every step above exists to leave true.

**An amend produces a new commit, so the marker is re-stamped on every amend.**

## Never push

`/commit` never runs `git push`, never opens a pull request, never publishes.
`[[rules/version-control]]` has the boundary and why it sits there. Stated here
because this is the file a reader opens to find out whether the commit skill
publishes.

## Done when

The commit exists, its message states what changed and why, derived state is
regenerated, the marker is stamped, and task and effort statuses reflect reality.
