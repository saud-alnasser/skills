# Version control

<!--
  Installed by /configure at `.claude/policies/version-control.md`. This is the **one
  home** for how work moves from a ticket to a merged change in this
  repository.

  It is the policy half of a pair. `.claude/policies/tracker.md` says where the tickets
  are; this says what happens to a ticket once somebody starts building it.
  Both are policy — what this repository *does*. How to type any of it is
  `.claude/tools/`, which is invocation and a different question.

  It is committed and carries no AEP machinery, so a teammate with no plugin
  reads it and learns how this repository works. `CLAUDE.md` names it for
  exactly that reason.

  Keep it short. Four questions, and nothing else.
-->

## Which model

{**Plain git** or **stacked changes**. One of the two, stated plainly — this is
the fact everything below depends on.}

On plain git, `blocked-by: [01]` in a ticket means *wait until 01 is resolved*.
Where the repository uses stacked changes it means *stack on top of 01*, and
waiting is the thing the tool exists to remove. Getting it wrong is expensive
in both directions, which is why it is written down rather than rediscovered.

**Confirm this statement before relying on it**, the same way any other written
claim is confirmed. It is one read:

```
ls .git/.graphite_repo_config     # exists → stacked changes. absent → plain git
```

A repository can adopt a stacking tool, or abandon one, long after this file
was written. Where the read disagrees with the statement above, **the read is
right** — correct this file where you are standing, and carry on with the true
answer. Deferring it means the next reader gets the same wrong fact.

**Confirm it by reading the filesystem, never by asking the stacking tool.**
Several of their commands initialise the repository as a side effect, so a
probe that shells out to one can make its own answer true.

## Branch naming

{This repository's branch convention, if it has one — read it off the recent
branches and off `CONTRIBUTING.md` rather than asserting one. Delete this
section if there is none, and `/implement`'s default applies.}

Whatever goes here has to **encode the ticket id** and has to be reproducible
from the ticket alone. The branch is how a ticket is claimed, so two tools that
disagree about the name disagree about whether the ticket is taken.

## Commit discipline

{What this repository's commits actually look like — subject form, scope
vocabulary, whether bodies are expected, how a ticket is referenced. Read it
off `CONTRIBUTING.md` and the recent `git log`, not off what is usual.

This section is where the answer goes once the repository has been read, so a
later run does not have to detect it again.}

AEP's defaults, applying only where the repository is silent: **Conventional
Commits — `type(scope): summary`** — for commits, PR titles, and issue titles.
The scope names an engineering domain, and `misc`, `stuff`, and `update` are
not domains.

## How work lands

{How a finished branch reaches the default branch here — merged by a pull
request, submitted as a stack, fast-forwarded by the maintainer — and who does
it.}

Where work lands by pull request, the default description covers **problem,
solution, architectural impact, testing, related issues, breaking changes** —
never a commit-by-commit account.

One pull request kind is allowed to change nothing outside `.claude/`: the
**design PR** — a single design run's deliverable, its entire diff under the
protocol directory, one per run. Approving it is approving the plan before
anyone builds, which is what makes it reviewable where other protocol-only
pull requests are not. It is the only one: every other protocol-only
change rides the build pull request that consumes it, and a multi-session
design effort lands one small design PR per session rather than holding an
effort-long branch. The test is the **diff, never a
label or commit type** — nothing mechanical marks a design PR except what
its diff touches.

**A diff confined to `.claude/scripts/` is code, not scaffolding.** The
workflow's own scripts live under the protocol directory, so they read as
protocol-only by the test above and are not. Nothing about the test changes —
such a diff fails it and rides its consumer, exactly as any other code change
does — but the reason it fails is worth stating, because "protocol scaffolding
is never its own unit of work" does not obviously reach executable content.

Publishing is the human's call: `.claude/rules/engineering.md` carries that as
a standing rule and this section does not repeat it. What belongs here is what
actually happens in this repository once the work is ready, which is a fact
about the repository rather than a rule about Claude.
