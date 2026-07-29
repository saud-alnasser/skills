---
name: commit
description: Turn finished work into a commit — confirm the earlier stages ran, heal the Context the whole diff falsified, write the message, and advance the Marker. Use when work is ready to commit, or when /implement closes out a ticket.
---

# Commit

Mode: maintenance
Policies: `.claude/policies/knowledge.md`, `.claude/policies/specs.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`

The transaction boundary: everything before it produced a change in the working tree, and this is where that change becomes history.

Two callers, one implementation:

- **`/implement`**, closing out a ticket it claimed, built, and had reviewed.
- **A human typing it**, for work with no ticket — hand-written edits, or a change made outside this flow.

`/commit` **confirms, it does not repeat.** Every check below is a question about state. It never runs the tests, never reviews, and never researches — those stages already ran, and re-running them here is the rediscovery ADR 0010 removed from sync.

## 0 — Verification

This reads Context to check it against the diff, so it opens with the verification report `.claude/protocol.md` requires:

```
Verification
  marker a3f91c2, tree clean — context trusted as-is
  → contexts loaded: database
```

Nothing to report is still reported. The rule and both drift reads are in `.claude/protocol.md`.

## 1 — Confirm the stages ran

Three questions. Each is about state, and none re-executes anything.

- **Were the tests run, and did they pass?** A change with no test surface answers this honestly — an answer stated in one line, not a step skipped.
- **Did `/review` run, and does every finding have an outcome?** Fixed, ticketed, or accepted-and-recorded. A finding still open is a blocker or a ticket, **never a silent pass**.
- **Is the work finished against its ticket or spec?** Work that arrived without a ticket answers against what the caller asked for.

A failure here is **reported, not fixed**. Say which stage is incomplete — *the suite was never run; that is `/implement`'s* — because a refusal the caller cannot act on is a wall rather than a check. `/commit` names the incomplete stage and stops.

## 2 — The diff against knowledge

The one question no earlier stage could ask: `/implement` sees one ticket at a time, and `/commit` sees the change entire.

Read the diff and ask: did this move a boundary, retire a concept, or relocate something a Source Pointer names — and does `.claude/contexts/repository.md` still say so?

Where the diff contradicts Context, the commit is **blocked until Context is corrected**, and the correction goes into this commit, so the change and the thing it falsified never land apart.

The row for `/commit` in `.claude/policies/knowledge.md` is the narrowest in the table, and this step is where that bites: a diff that reveals a concept nobody had named is a finding to report, not a licence to name it here.

A repository with no `.claude/` has no Context to contradict. Say so in one line and carry on.

## 3 — Mark the spec implemented

Acceptance criteria can span several commits, so this is the only place the last one is knowable.

When this commit completes them, set `Status: implemented` on the spec in `.claude/designs/`. **Only the status line moves** — never a word of the spec's content. The status vocabulary, and why the rest is frozen, are in `.claude/policies/specs.md`.

Do this **before staging**, not after committing — the spec is a tracked file, and marking it afterwards leaves the tree dirty the moment the commit lands, defeating the Marker's clean path on the very next turn.

## 4 — The message

`.claude/policies/version-control.md` carries the convention AEP defaults to, and `CLAUDE.md` the standing rule that a convention is detected before it is asserted. This is where that detection happens, so make it a step: read `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, then the recent `git log`.

Where the repository documents or demonstrates another convention, follow it **silently** — without a note explaining what AEP would have written instead.

Say what capability changed, and why. **Never a file-by-file account** — the diff already lists the files.

Reference the ticket. Whether this repository has a shared tracker is in `.claude/policies/tracker.md`; the two cases below only differ on a shared one. **Which form** depends on how this commit will reach the default branch — `.claude/policies/version-control.md` states it, so it is read rather than inferred from the shape of the branch:

| How the work lands | The commit carries | Because |
| --- | --- | --- |
| a branch merged by a pull request the human writes | a reference that closes nothing | a closing keyword in a commit stays live — a cherry-pick or a rebase onto the default branch later closes an issue nobody merged. The keyword goes in the pull request body instead |
| a branch in a stack, submitted by the stacking tool | the closing keyword | the commit reaches the default branch only by merging that branch's own pull request, so the hazard above cannot happen — and the commit body is the only text AEP can pre-write that reaches the pull request at all |

`.claude/tools/github.md` has both forms and their constraints; `.claude/tools/graphite.md` records what was and was not verified about the submit path. Read them — several words that look equivalent are not.

## 5 — Make the commit

The staging rule, the commit invocation, and the amend that further changes take instead of a fixup are all in `.claude/tools/git.md`. Read it rather than reaching for a flag from memory.

What belongs to `/commit` is only the consequence: an amend rewrites the commit, so the step below runs again.

## 6 — Advance the Marker

Last, once the commit exists. **A commit cannot contain its own SHA** (ADR 0005) — the whole reason the Marker is machine-local and written here rather than committed with the work it describes.

Write the new `HEAD` to `.claude/position/marker.json`:

```json
{ "commit": "8b2d417c9e1f4a6b0d3e2c5a7f9b1d4e6a8c0f2b" }
```

That is the whole file. The Marker answers one question — what Context was last verified against — and a second field is a second answer nobody asked for.

Confirm `.claude/position/marker.json` is gitignored **before** writing it. `/configure` puts the entry in `.claude/.gitignore`; a committed Marker always names the parent of the commit it describes, so every session afterwards opens by verifying drift that is not there.

After this the **Marker equals `HEAD`** and the tree is clean. That postcondition is what every step above exists to leave true; what `.claude/protocol.md` does with it is that file's.

An amend produces a new SHA, so **the Marker re-advances on every amend**, exactly as on the first commit.

In an unconfigured repository there is no Marker to advance. State that and stop.

## Never push

`/commit` **never runs `git push`.** The rule and its reasoning are in `.claude/rules/engineering.md`; `.claude/tools/git.md` names the invocations it covers, including the ones that push as a side effect.

Stated here rather than only pointed at, because this is the file a reader opens to find out whether the commit skill publishes.

## What stays with the caller

`/commit` **does not resolve tickets.** `/implement` sets `Status: resolved` after `/commit` returns — one writer for that field, so a ticket is never left marked resolved for a commit that was refused.

---

AEP's own; there is no equivalent in [mattpocock/skills](https://github.com/mattpocock/skills). What it does was split across that set's `implement` and the sync stage AEP dissolved.
