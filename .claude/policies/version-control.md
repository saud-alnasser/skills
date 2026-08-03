# Version control

How work moves from a ticket to a landed change here. `.claude/policies/tracker.md` is the other half of the pair — it says where the tickets are; this says what happens to one once somebody starts building it. How to *type* any of it is `.claude/tools/`.

## Which model

**Stacked changes.** `Blocked by: 03` in a ticket means *stack on top of 03* — not *wait until it is resolved*.

Confirm before relying on it. It is one read:

```
ls .git/.graphite_repo_config     # exists → stacked changes. absent → plain git
```

Where the read disagrees with the line above, **the read is right** — correct this file where you are standing and carry on with the true answer. Deferring it means the next reader gets the same wrong fact.

Confirm by reading the filesystem, never by asking a stacking tool. Several of their commands initialise the repository as a side effect, so a probe that shells out to one can make its own answer true. The stacking-tool reference is `.claude/tools/graphite.md` — an operation with no entry there is a docs fetch, never a guessed flag.

## Branch naming

```
<NN>-<slug-of-the-ticket-summary>       04-adopt-derived-tools-here
                                        05-version-control-policy-file
```

`NN` is the ticket's two-digit number and the slug comes from its filename, so the branch is reproducible from the ticket alone and the ticket is recoverable from the branch by reading up to the first `-`.

**The number is scoped to the effort, and the branch name does not carry the effort.** Ticket numbers restart at `01` in each one, so `01-` has already meant two different tickets. This has not collided because efforts have run one at a time and the slug distinguishes them, but it is a real limit rather than a property: two efforts in flight together would need the effort in the name. Not changed here, because the convention is what the history demonstrates and renaming it mid-effort would break the thing it exists to provide.

A branch is deleted once it has landed.

## Commit discipline

**One ticket is one commit.** Further changes amend it rather than stacking a `fix typo` on top. That is only safe while nothing is pushed, which is what makes the standing prohibition below load-bearing rather than fussy.

Conventional Commits — `type(scope): summary` — which is also AEP's default; the scope names an engineering domain, and `misc`, `stuff`, and `update` are not domains. The parts worth recording are the ones this repository does that the default does not say:

- **A two-clause subject is normal**, joined by `, and`, when one commit genuinely did two things: `refactor(configure): derive tool references, and delete the tools skill`.
- **The scope names an engineering domain**, and the vocabulary in use is `knowledge`, `configure`, `layout`, `implement`, `tracker`, `coordination`, `skills`, `rules`, `verify`, `dist`.
- **The body is prose, and it is expected.** What changed and why, including what was rejected and what was found by running something. Never a file-by-file account — the diff already lists the files.
- **`Refs:` carries the path to the ticket file**, from the repository root, as its own trailer line. Earlier commits used a bare number and a `.scratch/` path; both predate the current layout and neither is the convention now.
- **`Co-Authored-By: <the model that authored the commit> <noreply@anthropic.com>`** closes the message — the model's own name, because the trailer is attribution rather than style.

## How work lands

The maintainer lands work by pull request, squash-merged — `main`'s recent history is squash commits carrying the PR number (`#1`, `#2`). Earlier history was fast-forwarded from ticket branches without pull requests; that is what predates, not the convention now. `.claude/policies/tracker.md` covers how external pull requests are treated.

Where tickets stack — one built on another's branch before either has landed — they land in the same order they were built, each still producing one commit on `main`.

One pull request kind is allowed to change nothing outside `.claude/`: the **design PR** — a single design run's deliverable, its entire diff under the protocol directory, one per run. Approving it is approving the plan before anyone builds, which is what makes it reviewable where other protocol-only pull requests are not. It is the only one: every other protocol-only change rides the build pull request that consumes it, and a multi-session design effort lands one small design PR per session rather than holding an effort-long branch. The test is the **diff, never a label or commit type**.

Publishing is the human's call. `.claude/rules/engineering.md` carries that as a standing rule and this section does not repeat it; what is recorded here is only what happens once the work is ready.
