---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture

The merged row is the only row in the ladder that no file can derive. Every row
above it reads `spec.md`'s `status:` and projects it. Merged is a fact the forge
holds and the repository never learns, which is why the row was written without
an owner rather than by oversight — there was nothing local to point it at.

So the approach does not try to make merge a local fact. It gives the row two
owners at different latencies, and keeps the second one honest by never letting
it fetch anything itself.

**A forge-native job, offered once.** It fires on the forge's own merge event,
moves `status:` on both objects, and needs no AEP run to have happened. On GitHub
this is self-contained; on GitLab it is not, and the offer says so before it says
anything else (`evidence/research/merge-time-label-automation`).

**A computed reconciliation, always present.** `scripts/reconcile.mjs` takes what
a caller already fetched, computes expected against observed, and prints the
disagreement. It makes no network call, which is what lets requirement 9 hold
without a rule about it: a script that cannot reach a tracker cannot add a call
to a run that was not already making one.

## Where the tracker half comes from

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. Observations piped in** | forge-agnostic; testable in a fixture with no network; requirement 9 falls out of the shape rather than being enforced; matches `frontier.mjs`, which reads files and prints | the caller has to fetch, so the invocation is two commands rather than one | an observation is stale by the time it is compared — bounded, because a stale comparison reports a disagreement a re-run clears | one parser per forge's JSON shape, in one file |
| B. The script shells out to `gh`/`glab` | one command at the call site | a shipped script becomes forge-specific; unrunnable offline; unrunnable in `verify.mjs` without a network fixture | it *is* the unconditional tracker call ticket 26 forbids, on the one path meant to be free of them | a branch per forge CLI, and per CLI version |
| C. The script prints expectations only | trivial to write | the comparison is then an agent's judgement | requirement 8 says computed and never judged; this is judged | none, and it buys nothing |

**A.** The decisive point is not testability, it is that B makes the fallback —
the thing that exists so a repository which declined the offer still converges —
the one component that reaches for a tracker unconditionally. The fallback would
carry the cost it was built to avoid.

C loses because *which efforts disagree* is a comparison, and handing a
comparison to a model is how one input gets two answers.

## Where a refusal is recorded

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. A recorded decision in `rules/`** | read where the next run already reads the version-control rule; repository-owned, so an upgrade preserves it; a decision carrying a reason is what a rule holds | the installer has to key on it, so a sentence in a file the repository owns becomes load-bearing | a human rewords their own paragraph and a settled offer silently re-opens | the sentinel sentence, which now has two copies: the installer and the skill that tells a human to write it |
| B. A line in `contexts/repository.md` | cheapest to write | a context orients; it does not decide. Substituting one primitive for another is what `[[protocol]]` forbids outright | the record sits where nothing loads it before offering | none |
| C. A state file under `.aep/` | machine-readable | a new primitive nothing else uses | close to the hidden database §2 forbids, and the first one makes the second one easy | a schema, a validator, an entry in the manifest |

**A.** The refusal is a decision about how this repository works, carrying a
reason, which is what a rule is rather than what state is: an offer suppressed by
a file nobody reads is worse than one suppressed by a paragraph in the rule the
skill already opens.

**The cost is not the one this row first named.** It said prose, so nothing can
key on it mechanically, and that turned out to be false of what shipped:
`install.mjs` reads `.aep/rules/version-control.md` and greps it for the exact
sentence `The merge-time status job is declined`. So the real cost is the
opposite of the one recorded. A sentence inside a file the repository owns is now
load-bearing, and a human who rewords their own paragraph, which is a thing they
are entitled to do to a file that is theirs, silently re-opens a question they
had settled. Nothing warns them, because nothing can: the file is theirs.

That is still the right trade, for the reason above and because deleting the
paragraph is how a repository is meant to change its mind. But it is a different
trade from the one this table claimed, and the sentinel is a second copy of prose
held in two places, the installer and the skill that tells a human what to write.
`verify.mjs` holds those two together; nothing holds either to what a human
actually typed. Corrected here after the standards review of 2026-08-26 found the
row describing a cost the code does not pay.

**A was first written as a declared deviation, and that was wrong.** Corrected
during ticket 06, after both review axes reached it independently and the human
chose the correction. `[[policies/artifacts]]` defines a declared deviation as
variation entering a protocol-owned artifact through no extension point, and
requires `[[skills/update]]` to report it on every run until the protocol grows
the point or the repository conforms. The offer names refusal as a supported
path, so a refusal is the extension point rather than variation with nowhere to
enter, and declaring it one would have update report a settled no as an open fork
on every upgrade. That is the opposite of requirement 6, which asks that a
refusal is recorded rather than re-asked every run.

The home was never what was wrong. A refusal belongs in the repository's own
version-control rule for every reason stated above; it is recorded there as an
ordinary decision, with what was declined and when, and nothing reports it as a
fork.

# Components

| Component | Becomes responsible for |
| --- | --- |
| `src/policies/execution.md` | naming both owners on the terminal row, and covering closed-unmerged |
| `specs.md` §478 | the amended prohibition, so a `status:` family AEP maintains keeps its terminal value |
| `src/scripts/contract.mjs` | the ladder's rows as a value, beside `TICKET_STATUSES` |
| `src/scripts/reconcile.mjs` | expected against observed, computed from `spec.md` and a supplied observation |
| `src/seed/automation/github.yml`, `.../gitlab.yml` | the merge-time jobs themselves |
| `src/scripts/payload.mjs` | a `forge()` seed helper that cannot be called without an automation file |
| `src/skills/install.md`, `src/skills/update.md` | the offer, and the refusal's home |
| `src/skills/specify.md`, `src/skills/implement.md` | the two halves of the closing keyword |
| `src/seed/labels.json` | `status: done` covering completion without a merge |
| `src/scripts/verify.mjs` | eleven assertions, one per criterion |

# Interfaces

```
node .aep/scripts/reconcile.mjs [--root <path>] [--observed <file>|-]

  agree      <effort>  <status>
  drift      <effort>  issue <n> <observed> want <expected>
  drift      <effort>  change-request <n> <observed> want <expected>
  drift      <effort>  issue <n> open after change-request <n> merged
  unobserved <effort>  no tracker object supplied

  exit 0  every observed effort agrees
  exit 1  at least one disagreement
  exit 2  the tree or the observation could not be read
```

Matching `frontier.mjs`: pure functions plus a `main()`, `--root`, one line per
finding, an exit code that means something. **No observation supplied is exit 0
with every effort `unobserved`** — a repository with no tracker runs it and
learns nothing, which is the correct answer rather than a fault (requirement 10).

The observation is the forge's own JSON, unmodified:

```sh
gh issue list --json number,state,labels --state all
gh pr list --json number,state,labels,closingIssuesReferences --state all
```

The forge `[[references]]` carries the exact fetch and how the two are combined.
The script accepts either forge's shape and says which one it read.

# Data Model

`expected` is a function of two inputs and nothing else:

```
observed change request state is MERGED or CLOSED  →  status: done
otherwise                                          →  project spec.md's status:
```

This is the whole reason the terminal row needed a second input: `status: done`
is not reachable from `spec.md`, which stops at `implemented`. The projection is
`[[policies/execution]]`'s existing ladder, read from a table in `contract.mjs`
rather than restated in the script, and the policy and that table are asserted
equal in `verify.mjs` so the pair cannot drift.

# Technical Approach

The order is forced in two places and free elsewhere.

1. **`specs.md` §478 and the ladder, together.** Both normative documents change
   in one ticket or a reader holds two contradicting claims for the length of the
   stack. Nothing later can be asserted until the ladder names owners, because
   every later check quotes it.
2. **The ladder's rows into `contract.mjs`.** The projection has to be a value
   before a script can compute with it.
3. **`reconcile.mjs`.** Depends on 2, and on nothing else.
4. **The `forge()` helper and the two automation files.** Independent of 1–3.
   The helper lands with at least one automation file, or `verify.mjs` fails on
   its own new assertion.
5. **The install and update offers.** Depends on 4 — an offer needs something to
   write.
6. **The closing keyword in `specify` and `implement`, and the seeded
   `status: done` description.** Independent of everything above. Cut it early so
   it is not the ticket that slips.

Each of these is a branch carrying one commit, cut from the branch of the ticket
its `blocked-by` names, so `blocked-by` here means *branch on top of*
(`[[rules/version-control]]`). Where a ticket names nothing it is cut from the
effort branch and can be built beside the others.

**A ticket branch is a build claim rather than a level of the stack.** It is named
`47-post-merge-labels/<id>-<slug>`, it is built in its own worktree under
`.aep/worktrees/`, and it is not tracked in Graphite: it exists so git refuses a
second run the same ticket, and it holds nothing once the orchestrator has
integrated its work into the effort branch, which is the step that deletes it.
The reviewable unit is `post-merge-labels` itself, one commit amended in place,
and it is the only branch here carrying a pull request.

**This effort is its own stack, based on `main`.** It sat on `artifact-paths`
until 2026-08-25 and no longer does, so nothing under it moves and the two
efforts build at the same time. What they still share is `verify.mjs`,
`payload.mjs`, `specs.md`, and `.aep/index.md`; whichever merges second restacks
on `main` and resolves there, and `index.md` is regenerated rather than merged
by hand.

# Integration

**`.github/workflows/` is not AEP's.** The offer proposes text and writes on
acceptance only, which is `[[skills/install]]`'s existing rule for adapters and
is not relaxed here — a workflow is executable, so it is a larger thing to put in
someone's repository than a reference file.

Where a labeler already exists, the job is proposed as an addition to that file.
The research settles that this contests nothing: all ten workflows observed
trigger on `pull_request_target` with the default activity types, which exclude
`closed`, and `sync-labels` provably leaves labels outside its own config alone.

**This repository has no `.github/workflows/`**, so it receives the offer as a
new file on its next `/update` and is its own first fixture.

# Migration

Nothing to migrate. A repository that reached 3.x before this existed gets the
offer from `[[skills/update]]` step 6, which already exists to act on what a
release requires of the reader. No workflow is written anywhere without a yes,
and a repository that never updates keeps working — with labels that are late
rather than wrong, which is the risk `spec.md` already accepts.

**Already-merged efforts are not backfilled** (`spec.md`, Out of Scope). The
reconciliation reports them; correcting history is the human's call.

# Testing Strategy

`verify.mjs` gains assertions in sections that already exist, plus one new
section for the script. Every criterion in `spec.md` maps to one:

| Criterion | Checked by |
| --- | --- |
| 1 | `policies` — every ladder row parses to a named owner, and the terminal row specifically |
| 2 | `the specification` — §478's amended clause is present, and the ladder is asserted against it rather than against the old one |
| 3 | `reconcile` — a fixture whose change request is closed unmerged expects `status: done` |
| 4 | `seeds` — each automation file parses as YAML, fires on that forge's merge event, guards on the merge having happened, and writes both objects; the GitLab file names its `api`-scoped token before anything else |
| 5 | `seeds` — every `forge()` seed in `payload.mjs` has an automation file, and adding a forge reference without one fails |
| 6 | `install fixture` — install offers and writes only on acceptance; a refusal leaves no workflow file and records the decision; a second run reads it and does not re-offer. Update makes the same offer on a 3.0 fixture |
| 7 | `install fixture` — a fixture carrying a labeler gets a proposed addition to that file, with exact text, and no second file |
| 8 | `reconcile` — run against this repository's tree with a recorded observation for effort 45: agrees. Move a label in the fixture: drift |
| 9 | `forbidden` — the payload-wide sweep from ticket 26, extended so `reconcile.mjs` is covered by it |
| 10 | `install fixture` — a no-tracker fixture runs install, update, and `reconcile.mjs`; none reaches for a tracker, and none reports the absence as a fault |
| 11 | `skills` — both skills state their half and cite the rule, and a skill naming one shape as the only one fails. `seeds` — neither version-control rule still says a human writes the body |

**Each guard is fire-checked**: break the subject deliberately, confirm the
subject is actually gone, then watch the guard fail by name. Criterion 9's is the
one to fire-check hardest — it is a phrase-matching sweep, and ticket 26 records
it passing green once because an edit moved its subject out from under it.

# Operational Considerations

**The GitLab half ships from documentation, not from a passing run.** Nothing
here runs on GitLab. Its offer text names the `api`-scoped token first, so a
failure on somebody's first use reads as a missing credential rather than as a
broken job.

**The reconciliation is somebody's to run, never scheduled.** It runs where a run
is already reaching the tracker — `[[skills/implement]]`'s close,
`[[skills/specify]]`'s label sync — and reports what it finds. Nothing sweeps.

# Technical Risks

- **The ladder's rows live in two places once `contract.mjs` holds them.** Shows
  up as a script projecting a status the policy no longer states. Mitigated by
  the equality assertion in `verify.mjs`; without that assertion this is the
  effort's worst idea rather than its load-bearing one.
- **The observation's shape is the forge's, and it can change.** Shows up as
  `reconcile.mjs` reporting every effort `unobserved` against a real fetch.
  Mitigated by the parser naming which shape it read, so the failure says it
  recognised nothing rather than returning a confident empty answer.
- **An install fixture grows a network-shaped dependency.** The offer is text and
  acceptance, so nothing fetches today; the risk is a later ticket reaching for
  `gh` inside a fixture to check a label was created. Shows up as a suite that
  fails when offline.
