# Version control

How work moves from a ticket to a landed change here. `.claude/policies/tracker.md` is the other half of the pair — it says where the tickets are; this says what happens to one once somebody starts building it. How to *type* any of it is `.claude/tools/`.

## Which model

**Stacked changes.** `blocked-by: [03]` in a ticket means *stack on top of 03* — not *wait until it is resolved*.

Confirm before relying on it. It is one read:

```
ls .git/.graphite_repo_config     # exists → stacked changes. absent → plain git
```

Where the read disagrees with the line above, **the read is right** — correct this file where you are standing and carry on with the true answer. Deferring it means the next reader gets the same wrong fact.

Confirm by reading the filesystem, never by asking a stacking tool. Several of their commands initialise the repository as a side effect, so a probe that shells out to one can make its own answer true. The stacking-tool reference is `.claude/tools/graphite.md` — an operation with no entry there is a docs fetch, never a guessed flag.

## The unit is the effort, not the ticket

**A directory under `.claude/tickets/` — its `spec.md` and its `issues/` together — is one branch and one commit.** Not one per ticket. This is where this repository departs from AEP's default, deliberately and with the workflow's own permission: ADR 0008 makes AEP's conventions defaults for when the repository is silent, and this repository is not silent. ADR 0051 records the choice.

It is also what `main` already demonstrates. Every commit there is one effort, squash-merged from one pull request; the per-ticket commits only ever existed on branches and were collapsed on landing. The old convention produced a shape no reader of the default branch ever saw.

**What this costs, stated rather than discovered:** the second orchestration axis does not run here. A dispatched set lands one commit per ticket on that ticket's own branch, which is what lets a failed sibling leave the rest landed (ADR 0046) — and there is no per-ticket branch here for it to land on. So the frontier is worked in one branch, and a set is not dispatched. The first axis is unaffected: a fan-out already squashes its portions into one commit, and one commit is what an effort gets.

## Branch naming

```
<effort>                                worktrees
                                        parallel-tickets
```

The branch is named for the directory under `.claude/tickets/`, so it is reproducible from the effort alone and the effort is recoverable from the branch by reading it.

**The effort identifies the claim; any prefix a tool adds is transport.** A stacking tool configured with a branch prefix produces `<prefix>/<effort>` from the same input, so a claim checked under one form and created under the other is not an exclusion at all. Check `refs/heads/<effort>` **and** `refs/heads/*/<effort>`, and never conclude a branch is free from one read.

This removes the collision the per-ticket convention carried: ticket numbers restart at `01` in every effort, so `01-` had already meant two different tickets and two efforts in flight together would have needed the effort in the name anyway. Naming the branch for the effort is what the id was standing in for.

**Work with no ticket has no effort to be named for**, and takes a short name for the change itself. That is the second caller `/commit` serves — a maintainer's own edits, or a convention changed in conversation — and it is a branch and a commit like any other. It carries no `Refs:`, because there is no ticket file to cite.

**The Claim is the effort's branch**, and it therefore covers every ticket in that effort at once. Two instances cannot take different tickets of one effort — which is the exclusion the unit change implies, not a limitation added on top of it.

A branch is deleted once it has landed.

## Commit discipline

**One effort is one commit.** Every ticket in it amends that commit rather than adding to it, exactly as further changes to a single ticket always did. That is only safe while nothing is pushed, which is what makes the standing prohibition below load-bearing rather than fussy.

Conventional Commits — `type(scope): summary` — which is also AEP's default; the scope names an engineering domain, and `misc`, `stuff`, and `update` are not domains. The parts worth recording are the ones this repository does that the default does not say:

- **A two-clause subject is normal**, joined by `, and`, when one commit genuinely did two things: `refactor(configure): derive tool references, and delete the tools skill`.
- **The scope names an engineering domain**, and the vocabulary in use is `knowledge`, `configure`, `layout`, `implement`, `tracker`, `coordination`, `skills`, `rules`, `verify`, `dist`.
- **The body is prose, and it is expected.** What changed and why, including what was rejected and what was found by running something. Never a file-by-file account — the diff already lists the files.
- **`Refs:` carries the effort's spec and every ticket file in it**, from the repository root, one trailer line each. With the effort as the commit, the message is the only place the ticket boundaries survive — the history no longer records them, so a trailer left off loses a ticket rather than a citation. Earlier commits used a bare number and a `.scratch/` path; both predate the current layout and neither is the convention now.
- **`Co-Authored-By: <the model that authored the commit> <noreply@anthropic.com>`** closes the message — the model's own name, because the trailer is attribution rather than style.

## How work lands

The maintainer lands work by pull request, squash-merged — `main`'s recent history is squash commits carrying the PR number (`#1`, `#2`). Earlier history was fast-forwarded from ticket branches without pull requests; that is what predates, not the convention now. `.claude/policies/tracker.md` covers how external pull requests are treated.

Where efforts stack — one built on another's branch before either has landed — they land in the same order they were built, each still producing one commit on `main`. Tickets no longer stack: within an effort they amend one commit, so the only thing an edge orders is the sequence of amends.

One pull request kind is allowed to change nothing outside `.claude/`: the **design PR** — a single design run's deliverable, its entire diff under the protocol directory, one per run. Approving it is approving the plan before anyone builds, which is what makes it reviewable where other protocol-only pull requests are not. It is the only one: every other protocol-only change rides the build pull request that consumes it, and a multi-session design effort lands one small design PR per session rather than holding an effort-long branch. The test is the **diff, never a label or commit type**.

Publishing is the human's call. `.claude/rules/engineering.md` carries that as a standing rule and this section does not repeat it; what is recorded here is only what happens once the work is ready.
