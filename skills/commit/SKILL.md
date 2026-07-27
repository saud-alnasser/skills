---
name: commit
description: Turn finished work into a commit — confirm the earlier stages ran, heal the Context the whole diff falsified, write the message, and advance the Marker. Use when work is ready to commit, or when /implement closes out a ticket.
---

# Commit

The transaction boundary. Everything before it produced a change in the working tree; this is where that change becomes history.

Two callers, one implementation:

- **`/implement`**, closing out a ticket it claimed, built, and had reviewed.
- **A human typing it**, for work with no ticket — hand-written edits, or a change made outside this flow.

`/commit` **confirms, it does not repeat.** Every check below is a question about state. It never runs the tests, never reviews, and never researches — those stages already ran, and re-running them here is the rediscovery ADR 0010 removed from sync.

## 0 — Verification

This reads Context to check it against the diff, so it opens with the verification report `CLAUDE.md` requires:

```
Verification
  marker a3f91c2, tree clean — context trusted as-is
  → contexts loaded: database
```

Nothing to report is still reported. The rule and both drift reads are in `CLAUDE.md`.

## 1 — Confirm the stages ran

Three questions. Each is about state, and none of them re-executes anything.

- **Were the tests run, and did they pass?** A change with no test surface answers this honestly — but that is an answer, stated in one line, not a step skipped.
- **Did `/code-review` run, and does every finding have an outcome?** Fixed, ticketed, or accepted-and-recorded. A finding still open is a blocker or a ticket, **never a silent pass**.
- **Is the work finished against its ticket or spec?** Work that arrived without a ticket answers against what the caller asked for instead.

A failure here is **reported, not fixed**. Say which stage is incomplete — *the suite was never run; that is `/implement`'s* — because a refusal the caller cannot act on is a wall rather than a check. `/commit` does not implement, review, or research its way past one of these; it names the incomplete stage and stops.

## 2 — The diff against knowledge

The one question no earlier stage could ask. `/implement` sees one ticket at a time; `/commit` sees the change entire, which is what makes this whole-diff check its own and nobody else's.

Read the diff and ask: did this move a boundary, retire a concept, or relocate something a Source Pointer names — and does `.claude/context.md` still say so?

Where the diff contradicts Context, the commit is **blocked until Context is corrected**. The correction then goes into this commit, alongside the change that falsified it, so the two never land apart.

This is **healing, not authorship**. `/commit` corrects what the diff falsified; it does not author new concepts or vocabulary, which belong to `/implement` and `/design` (ADR 0005). Anything added passes `domain-modeling`'s compression test first, or it is not added.

A repository with no `.claude/` has not been configured and has no Context to contradict. Say so in one line and carry on.

## 3 — Mark the spec implemented

Acceptance criteria can span several commits, so this is the only place the last one is knowable — the diff is finished and its effect on the criteria is visible.

When this commit completes them, set `Status: implemented` on the spec in `.claude/docs/designs/`. **Only the status line moves** — never a word of the spec's content. The full status vocabulary, and why the rest of the document is frozen, are in `/design`'s [`SPEC-FORMAT.md`](../design/SPEC-FORMAT.md).

Do this **before staging**, not after committing. The spec is a tracked file, so marking it afterwards leaves the tree dirty the moment the commit lands — and a dirty tree defeats the Marker's clean path on the very next turn, which is the whole point of the step below.

## 4 — The message

`CLAUDE.md` carries the convention Tenure defaults to, and the standing rule that a convention is detected before it is asserted. This is where that detection actually happens, so make it a step: read `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, then the recent `git log`.

Where the repository documents or demonstrates another convention, follow it **silently** — without a note explaining what Tenure would have written instead.

Say what capability changed, and why it changed. **Never a file-by-file account**: the diff already lists the files, and a message that re-lists them spends the reader's attention on the one thing they could have got for free.

## 5 — Make the commit

The staging rule, the commit invocation, and the amend that further changes take instead of a fixup are all in [`tools/git.md`](../tools/git.md). Read it rather than reaching for a flag from memory.

What belongs to `/commit` is only the consequence: an amend rewrites the commit, so the step below runs again.

## 6 — Advance the Marker

Last, once the commit exists. **A commit cannot contain its own SHA** (ADR 0005) — that is the whole reason the Marker is machine-local and written here rather than committed with the work it describes.

Write the new `HEAD` to `.claude/marker.json`:

```json
{ "commit": "8b2d417c9e1f4a6b0d3e2c5a7f9b1d4e6a8c0f2b" }
```

That is the whole file. The Marker answers one question — what Context was last verified against — and a second field in it is a second answer nobody asked for.

Confirm `.claude/marker.json` is gitignored **before** writing it. `/configure` puts the entry in `.claude/.gitignore`; without it the Marker gets committed, and a committed Marker always names the parent of the commit it describes, so every session afterwards opens by verifying drift that is not there.

After this the **Marker equals `HEAD`** and the tree is clean. That postcondition is what every step above exists to leave true; what `CLAUDE.md` then does with it is `CLAUDE.md`'s.

An amend produces a new SHA, so **the Marker re-advances on every amend**, exactly as it did on the first commit.

In an unconfigured repository there is no Marker to advance. State that and stop there.

## Never push

`/commit` **never runs `git push`.** The rule and its reasoning are in `CLAUDE.md`; `tools/git.md` names the invocations it covers, including the ones that push as a side effect.

The prohibition is stated here rather than only pointed at, because this is the file a reader opens to find out whether the commit skill publishes.

## What stays with the caller

`/commit` **does not resolve tickets.** `/implement` sets `Status: resolved` after `/commit` returns — one writer for that field, so a ticket is never left marked resolved for a commit that was refused.

---

Tenure's own; there is no equivalent in [mattpocock/skills](https://github.com/mattpocock/skills). What it does was split across that set's `implement` and the sync stage Tenure dissolved.
