---
owner: repository
model: stacked-changes
unit: effort
---

# Version control

How work moves from a ticket to a landed change here. `.claude/policies/tracker.md` is the other half of the pair — it says where the tickets are; this says what happens to one once somebody starts building it. How to *type* any of it is `.claude/tools/`. The two frontmatter fields above are the declared repository facts; the prose elaborates them.

## Which model

**Stacked changes.** Declared in the `model` field above. `blocked-by: [03]` in a ticket means *stack on top of 03* — not *wait until it is resolved*.

- **Confirm before relying on it** — one read: `ls .git/.graphite_repo_config` (exists → stacked changes; absent → plain git). Where the read disagrees with the field, **the read is right**: correct this file where you stand and carry on.
- **Confirm by reading the filesystem, never by asking a stacking tool** — several of their commands initialise the repository as a side effect, so a probe can make its own answer true. The stacking-tool reference is `.claude/tools/graphite.md`; an operation with no entry there is a docs fetch, never a guessed flag.

## The unit is the effort, not the ticket

**A directory under `.claude/tickets/` — its `spec.md` and its `issues/` together — is one branch and one commit** (`unit: effort` above). Not one per ticket: ADR 0008 makes AEP's conventions defaults for when the repository is silent, and this repository is not silent — ADR 0051 records the choice, and `main` demonstrates it: every commit there is one effort, squash-merged from one pull request.

- **A set may still be dispatched — dispatch is independent of landing (ADR 0077).** The work is built in isolated worktrees and reaches history only as the orchestrator folds each diff into the effort's one commit, under the contract `.claude/policies/sub-agents.md` states. What is lost relative to per-ticket landing, stated rather than discovered: **a failed sibling is excluded by the orchestrator's judgement over what each workspace reported, where per-ticket branches would have excluded it by topology** — ADR 0046's failure isolation rests on branches this repository does not have, and ADR 0051 stands. The fan-out axis is unaffected: it already squashes its portions into one commit, and one commit is what an effort gets.
- **A spent worktree here is dirty by construction** — its work landed through integration and the tree kept its uncommitted state — so `git worktree remove`'s refusal fires on every one and carries no second opinion. Once the work is **verified integrated against its change record and the suite is green**, forced removal is the sanctioned exit — state the verification where the removal is done. Cleaning a tree until the refusal cannot fire keeps the rule's letter while killing its check; the force at least leaves its trace in the command.

## Branch naming

```
<effort>                                worktrees
                                        parallel-tickets
```

- **The branch is named for the directory under `.claude/tickets/`** — reproducible from the effort alone, and the effort recoverable from the branch by reading it. Ticket numbers restart at `01` per effort, so the old per-ticket `01-` form had already collided; the effort name is what the id was standing in for.
- **The effort identifies the claim; any prefix a tool adds is transport** — a stacking tool configured with a branch prefix produces `<prefix>/<effort>` from the same input. Check `refs/heads/<effort>` **and** `refs/heads/*/<effort>`, and never conclude a branch is free from one read.
- **Work with no ticket has no effort to be named for** and takes a short name for the change itself — the second caller `/commit` serves. It carries no `Refs:`, because there is no ticket file to cite.
- **The Claim is the effort's branch and covers every ticket in the effort at once** — two instances cannot take different tickets of one effort; that exclusion is what the unit change implies.
- A branch is deleted once it has landed.

## Commit discipline

**One effort is one commit.** Every ticket in it amends that commit, exactly as further changes to a single ticket always did — safe only while nothing is pushed, which is what makes the standing prohibition load-bearing rather than fussy.

Conventional Commits — `type(scope): summary` — which is also AEP's default. What this repository does that the default does not say:

- **A two-clause subject is normal**, joined by `, and`, when one commit genuinely did two things.
- **The scope names an engineering domain** — the vocabulary in use is `knowledge`, `configure`, `layout`, `implement`, `tracker`, `coordination`, `skills`, `rules`, `verify`, `dist`, `protocol`, `policies`, `spec`.
- **The body is prose, and it is expected** — what changed and why, including what was rejected and what was found by running something; never a file-by-file account.
- **`Refs:` carries the effort's spec and every ticket file in it**, from the repository root, one trailer line each — with the effort as the commit, the message is the only place the ticket boundaries survive, so a trailer left off loses a ticket rather than a citation.
- **`Co-Authored-By: <the model that authored the commit> <noreply@anthropic.com>`** closes the message — the model's own name, because the trailer is attribution rather than style.

## How work lands

The maintainer lands work by pull request, squash-merged — `main`'s recent history is squash commits carrying the PR number. Where efforts stack — one built on another's branch before either lands — they land in the order they were built, each still one commit on `main`. Tickets no longer stack: within an effort they amend one commit, so the only thing an edge orders is the sequence of amends. `.claude/policies/tracker.md` covers how external pull requests are treated.

- **One pull request kind may change nothing outside `.claude/`: the design PR** — a single design run's deliverable, its entire diff under the protocol directory, one per run; approving it is approving the plan before anyone builds. It is the only one: every other protocol-only change rides the build pull request that consumes it, and a multi-session design effort lands one small design PR per session. The test is the **diff, never a label or commit type**.
- **A diff confined to `.claude/scripts/` is code, not scaffolding** — AEP's own scripts sit under the protocol directory, so they read as protocol-only by the test above and are not: such a diff fails it and rides its consumer, exactly as any other code change does.
- Publishing is the human's call — `.claude/rules/engineering.md` carries the standing rule; what is recorded here is only what happens once the work is ready.
