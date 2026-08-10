---
owner: repository
---

# Version control

<!--
  Installed by /configure at `.claude/policies/version-control.md`, derived per
  repository: the **one home** for how work moves from a ticket to a merged
  change here. The policy half of a pair — `.claude/policies/tracker.md` says
  where the tickets are; this says what happens to one once somebody builds it.
  How to type any of it is `.claude/tools/`.

  The installed copy declares `owner: repository` and the two facts below as
  frontmatter fields — the extension points through which a repository varies
  the framework's delivery defaults. A stage acts on the fields; the prose
  elaborates them.
-->

{The installed copy's frontmatter — the declared repository facts, written by
/configure from the tree and confirmed with the user:}

```yaml
---
owner: repository
model: plain | stacked-changes
unit: ticket | effort
---
```

## Which model

{**Plain git** or **stacked changes** — stated in the `model` field above and
elaborated here. This is the fact everything below depends on.}

- On plain git, `blocked-by: [01]` means *wait until 01 is resolved*; on stacked changes it means *stack on top of 01* — waiting is the thing the tool exists to remove, and getting the model wrong is expensive in both directions.
- **Confirm the declaration before relying on it** — one read: `ls .git/.graphite_repo_config` (exists → stacked changes; absent → plain git). Where the read disagrees, **the read is right**: correct this file where you stand and carry on, or the next reader gets the same wrong fact.
- **Confirm by reading the filesystem, never by asking the stacking tool** — several of their commands initialise the repository as a side effect, so a probe can make its own answer true.

## The unit

{**Ticket** or **effort** — stated in the `unit` field above. On `ticket`, one
ticket is one branch, one commit, one unit of review, and the dispatched-set
axis lands one commit per ticket. On `effort`, an effort is one branch and one
commit that every ticket amends — and the consequences below apply.}

Under `unit: effort` only:

- **A set may still be dispatched — dispatch is independent of landing.** The work is built in isolated worktrees and reaches history only as the orchestrator folds each diff into the effort's one commit, under the contract `.claude/policies/sub-agents.md` states. What is lost relative to per-ticket landing, stated rather than discovered: **a failed sibling is excluded by the orchestrator's judgement over what each workspace reported, where per-ticket branches would have excluded it by topology.**
- **A spent worktree here is dirty by construction** — its work landed through integration and the tree kept its uncommitted state — so the removal refusal fires on every one and carries no second opinion. Once the work is **verified integrated against its change record and the suite is green**, forced removal is the sanctioned exit — state the verification where the removal is done. Cleaning a tree until the refusal cannot fire keeps the rule's letter while killing its check; the force at least leaves its trace in the command.

## Branch naming

{This repository's branch convention, read off the recent branches and
`CONTRIBUTING.md` rather than asserted. Delete this section if there is none,
and the build stage's default applies.}

- **The name must encode the ticket id and be reproducible from the ticket alone** — the branch is how a ticket is claimed, so two tools that disagree about the name disagree about whether the ticket is taken. A repository whose unit is the effort encodes the effort instead, on the same reproducibility test.

## Commit discipline

{What this repository's commits look like — subject form, scope vocabulary,
whether bodies are expected, how a ticket is referenced. Read off
`CONTRIBUTING.md` and the recent `git log`; write the answer here so a later
run does not detect it again.}

- AEP's defaults, where the repository is silent: **Conventional Commits — `type(scope): summary`** — for commits, PR titles, and issue titles; the scope names an engineering domain, and `misc`, `stuff`, and `update` are not domains.

## How work lands

{How a finished branch reaches the default branch here — merged by a pull
request, submitted as a stack, fast-forwarded — and who does it.}

- Where work lands by pull request, the description covers **problem, solution, architectural impact, testing, related issues, breaking changes** — never a commit-by-commit account.
- **One pull request kind may change nothing outside `.claude/`: the design PR** — a single design run's deliverable, its entire diff under the protocol directory, one per run; approving it is approving the plan before anyone builds, which is what makes it reviewable where other protocol-only pull requests are not. It is the only one: every other protocol-only change rides the build pull request that consumes it, and a multi-session design effort lands one small design PR per session. The test is the **diff, never a label or commit type**.
- **A diff confined to `.claude/scripts/` is code, not scaffolding** — the workflow's own scripts sit under the protocol directory, so they read as protocol-only by the test above and are not: such a diff fails it and rides its consumer, exactly as any other code change does.
- Publishing is the human's call — `.claude/rules/engineering.md` carries the standing rule; what belongs here is only what happens in this repository once the work is ready.
