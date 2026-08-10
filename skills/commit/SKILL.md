---
name: commit
description: Turn finished, reviewed work into a commit — confirm the stages ran, check the whole diff against knowledge, write the message in the repository's convention, commit, and advance the Marker. Use when a built ticket is ready to close out, or for hand-written work with no ticket. Never pushes.
metadata:
  mode: maintenance
  policies: [knowledge, specs, tracker, version-control]
---

# Commit

The transaction boundary: everything before it produced a change in the working tree, and this is where that change becomes history. Two callers, one implementation: **`/implement`**, closing out a ticket it claimed, built, and had reviewed; and **a human typing it**, for work with no ticket.

`/commit` **confirms, it does not repeat** — every check below is a question about state. It never runs the tests, never reviews, never researches: those stages already ran, and re-running them here is the rediscovery that dissolving the sync stage removed.

## 0 — Verification

This reads Context to check it against the diff, so it opens with the verification report `.claude/protocol.md` requires:

```
Position
  marker  a3f91c2  HEAD a3f91c2   commit match
  tree    9f1d2af  live 9f1d2af   tree match
  drift   reads skipped
  mode    session 468b4f04

  contexts loaded: database — trusted as-is
```

Nothing to report is still reported. The rule, the computed/judged split, and both drift reads are in `.claude/protocol.md`. **This run's Receipt is what step 1 reads**, so the report is the input to the first question below, not a formality.

## 1 — Confirm the stages ran

Four questions about state; none re-executes anything.

- **Was the position attested?** Read the Receipt beside the Marker: it must name `HEAD` as it stands now — before this commit — and this run. Recomputing would defeat the check: the question is whether the position *was* derived, and a stage that derives it here answers about itself. **No Receipt, or one naming a different position, means the report was never computed this run** — say so, **name the script to run**, and stop. That refusal is recoverable by design: a skipped verification and a deleted Position directory leave the same absence, and only one is a defect — a refusal the caller cannot act on is a wall, not a check. **A Receipt taken without a run identity attests less, and is accepted saying so** — it shows the position was computed at this commit, not that *this* run computed it; passing it as the stronger claim is the silent downgrade the mode field exists to prevent.
- **Were the tests run, and did they pass?** A change with no test surface answers honestly, in one line.
- **Did `/review` run, and does every finding have an outcome?** Fixed, ticketed, or accepted-and-recorded — a finding still open is a blocker or a ticket, **never a silent pass**.
- **Is the work finished against its ticket or spec?** Work without a ticket answers against what the caller asked for.

**A failure here is reported, not fixed** — `/commit` names the incomplete stage and stops (*the suite was never run; that is `/implement`'s*). A refusal the caller cannot act on is a wall rather than a check.

## 2 — The diff against knowledge

The one question no earlier stage could ask: `/implement` sees one ticket at a time, and `/commit` sees the change entire. Read the diff and ask: did this move a boundary, retire a concept, or relocate something a Source Pointer names — and does `.claude/contexts/repository.md` still say so?

- **Where the diff contradicts Context, the commit is blocked until Context is corrected, and the correction goes into this commit** — so the change and the thing it falsified never land apart.
- **The `/commit` row in `.claude/policies/knowledge.md` is the narrowest in the table** — a diff revealing a concept nobody had named is a finding to report, never a licence to name it here.
- A repository with no `.claude/` has no Context to contradict — say so in one line and carry on.

## 3 — Mark the spec implemented

When this commit completes a spec's acceptance criteria, set the spec's frontmatter field to `status: implemented` — this is the only place the last criterion is knowable. **Only the status field moves**, never the content; the vocabulary and the freeze are `.claude/policies/specs.md`'s, and where a spec lives is `.claude/policies/tracker.md`'s. Do it **before staging** — the spec is tracked, and marking it after the commit leaves the tree dirty the moment it lands, defeating the Marker's clean path on the next turn.

## 4 — Regenerate the generated indexes

```
pwsh -NoProfile -File .claude/scripts/regenerate-indexes.ps1
```

Commit is the last point at which the tree is known complete — an index regenerated earlier can be falsified by a later edit in the same change. Run it **before staging**, for the same reason the spec's status moves before staging. **Never hand-edit an index instead** — the suite regenerates and compares, so a hand edit is a build failure that names the file. Where the script is absent, **say the indexes are unverified** and carry on — the report is what stops an unenforced index reading as an enforced one.

## 5 — The message

`.claude/policies/version-control.md` carries the convention AEP defaults to, and `CLAUDE.md` the standing rule that a convention is detected before it is asserted — so detect here: read `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, then the recent `git log`. Where the repository documents or demonstrates another convention, follow it **silently**.

Say what capability changed, and why — **never a file-by-file account**; the diff already lists the files. Reference the ticket; whether the tracker is shared is `.claude/policies/tracker.md`'s. **Which form the reference takes** depends on how this commit reaches the default branch — `.claude/policies/version-control.md` states it, read rather than inferred:

| How the work lands | The commit carries | Because |
| --- | --- | --- |
| a branch merged by a pull request the human writes | a reference that closes nothing | a closing keyword in a commit stays live — a cherry-pick or rebase later closes an issue nobody merged; the keyword goes in the pull request body |
| a branch in a stack, submitted by the stacking tool | the closing keyword | the commit reaches the default branch only by merging that branch's own pull request, so the hazard above cannot happen — and the commit body is the only text AEP can pre-write that reaches the pull request at all |

`.claude/tools/github.md` has both forms; `.claude/tools/graphite.md` records what was and was not verified about the submit path. Read them — several words that look equivalent are not.

## 6 — Make the commit

The staging rule, the commit invocation, and the amend that further changes take are `.claude/tools/git.md`'s — read it rather than reaching for a flag from memory. What belongs to `/commit` is the consequence: an amend rewrites the commit, so the step below runs again.

## 7 — Advance the Marker

Last, once the commit exists — **a commit cannot contain its own SHA**, which is why the Marker is machine-local and written here. Write **both facts** to the marker file (`.claude/tools/git.md` names its path, the read, and the fingerprint invocation):

```json
{
  "commit": "8b2d417c9e1f4a6b0d3e2c5a7f9b1d4e6a8c0f2b",
  "tree": "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
}
```

- The two are written **together** — writing the commit and leaving a stale tree beside it is worse than writing neither: the pair claims a tree nobody fingerprinted, and the next stage would skip a drift read on the strength of it.
- **Confirm the marker file is gitignored before writing it** — a committed Marker always names the parent of the commit it describes, so every later session opens by verifying drift that is not there.
- After this the **Marker equals `HEAD`** and the tree is clean — the postcondition every step above exists to leave true.
- **An amend produces a new SHA, so the Marker re-advances on every amend.**
- In an unconfigured repository there is no Marker to advance — state that and stop.

## Never push

`/commit` **never runs `git push`.** The rule and its reasoning are `.claude/rules/engineering.md`'s; `.claude/tools/git.md` names the invocations it covers, including the ones that push as a side effect. Stated here because this is the file a reader opens to learn whether the commit skill publishes.

## What stays with the caller

`/commit` **does not resolve tickets** — `/implement` sets `status: resolved` after `/commit` returns: one writer for that field, so a ticket is never left marked resolved for a commit that was refused.

---

AEP's own; there is no equivalent in [mattpocock/skills](https://github.com/mattpocock/skills). What it does was split across that set's `implement` and the sync stage AEP dissolved.
