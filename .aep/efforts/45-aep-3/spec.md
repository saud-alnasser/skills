---
status: accepted
---

# Problem

AEP 2 holds every primitive its target workflow needs and still costs the human
an invocation per wave, a vocabulary of twelve concepts, a tracker footprint that
grows with the size of the work, and a report that serves one reader badly. One
root: the protocol optimised for being correct at each step and never for being
cheap to run to completion.

## The runner does not exist

`[[skills/implement]]` takes the frontier once: every open, unblocked, unclaimed
task that no edge orders against the others. It dispatches that set, reconciles
it, reviews, commits, and hands back. An effort three dependency layers deep
costs three invocations. Each is a context switch the human pays for, and none is
a decision they were asked to make. The second wave was already determined by the
first the moment the edges were written.

Across several projects at once, that is the dominant cost of operating AEP. It
is also why the protocol reads as heavy when its per-turn load is not:
`protocol.md` plus one policy plus one skill is under four thousand words, the
same order as any comparable toolkit. The weight is in the number of times a
human has to come and look.

Two smaller versions sit upstream. `[[skills/specify]]` and `[[skills/plan]]`
each hand back when ambiguity survives, so removing it means a second invocation
of `[[skills/refine]]` and sometimes a third of `[[skills/research]]`. The human
is invoking a router rather than answering questions.

And there is no landing step. When the last ticket is committed the work sits as
local commits that the human assembles, describes, and submits by hand.

## Done is decided in the wrong place, from the wrong evidence

``skills/commit`` step 3 sets the effort's `spec.md` to `status: implemented`
"when this commit completes its last acceptance criterion." A skill that sees one
ticket's diff is deciding whether an entire effort is finished, from evidence
that cannot answer the question.

The runner would inherit a worse version. Its natural termination is an exhausted
ticket list, and **tickets exhausted is not the same as the spec satisfied.** The
gap between them is where a run reports done on incomplete work, and nothing in
AEP currently looks at the codebase and asks whether the change it was asked for
is actually there.

## Progress is recorded where it cannot be read back

`[[policies/execution]]` fixes that an external tracker carries exactly one fact:
which effort a task belongs to. Criteria-level progress is carried nowhere.
`[[skills/implement]]` verifies each acceptance criterion and quotes what it ran,
into a transcript that dies with the session.

Under a runner that becomes the worst failure available: a run that dies at
ticket six of ten leaves no durable record of which criteria of ticket six
passed. The resumed run either redoes verified work or trusts a claim nothing can
check. That is the hidden memory the protocol says it does without.

The same gap runs the other way. An effort's state lives in `spec.md`'s
frontmatter as `draft`, `accepted`, or `implemented`, and the tracker this
repository already maintains has a `status:` label family meaning exactly that.
Nothing projects the first onto the second, so the state is correct in the file
and absent from the tool the human actually watches.

## The run's own state lives where the session can lose it

A wave-at-a-time `/implement` fits in one context. An effort-at-a-time one may
not, and the failure is silent: context exhaustion degrades rather than throwing,
so a run that has lost its early tickets still writes a confident close.

The obvious answer is unavailable. An agent cannot flush its own context window.
Compaction is a command the human types, or a harness behaviour firing on its own
schedule and choosing its own survivors, so no protocol mechanism can decide to
compact.

That leaves one place to fix it: what the run keeps in its head. Everything
requirement 24 records and does not act on exists only in the transient close,
which means a session ending at ticket six loses it, and the claim that a resumed
run reconstructs from durable artifacts alone is not quite true.

## The report is written for one reader and serves neither

`[[policies/reporting]]` fixes four opening slots and three closing ones, and
says nothing about how long any of them may be, which is why a one-line change
arrives wrapped in seven labelled paragraphs.

It also states the readership as a rule: "A human reads it, it is governed. A
protocol agent reads it, it is exempt." Under a runner crossing ten tickets in
one turn, the orchestrator needs its own thread of where it is, and the report is
already the right shape to be it. Today it is forbidden from being that by the
policy's own scoping, so the orchestrator carries its state in prose nobody
structured, or not at all.

## The tracker footprint grows with the work

One issue per task is why ``skills/tasks/labels`` exists: nine hundred words
deciding whether a milestone, an existing label, or a new label carries the
grouping fact, plus an approval gate for creating one. All of it solves a problem
created by having many issues.

## The entrypoint is written for one runtime and loaded by another

`AGENTS.md` is already the entry, already points at `.aep/protocol.md`, and
already restates nothing of it. The other half is missing.

`payload.mjs` seeds exactly one file outside `.aep/`, `seed/AGENTS.md` to
`AGENTS.md`. `[[skills/install]]` step 6 mentions `CLAUDE.md` in a subordinate
clause, under the branch where an entrypoint already exists.
`[[skills/update]]` does not mention entrypoints at all.

So a repository installed fresh under a runtime that loads a different file by
name gets an `AGENTS.md` that runtime may never open, and a repository whose
`CLAUDE.md` predates AEP is never pointed at the entry.

## Seven frontmatter fields where one is read

Across the sixty-nine artifacts outside `efforts/`, five fields are declared and
never decided on, and a sixth restates the path.

`date` sits on all sixty-nine and is read by one consumer, `index.mjs`, to
compute the index's own `date` as the newest any artifact declares. The
specification concedes the duplication in its own normative text: `date` answers
"the same question as `aep`, and it MUST be maintained by the same mechanism."

`kind` sits on fifty-six and is read by nothing. `index.mjs` groups by directory.
The specification says it is "omitted only where the directory makes it
redundant", and the directory makes it redundant everywhere. It is also stated
twice in every file that carries it, because the heading already says it:
`# Policy — engineering`, `# Rule — authoring what ships`, `# Agent — researcher`,
`# Context — this repository`. The heading is the copy a reader sees.

`mode` sits on thirty-three and is validated against a list of eight, then never
routed on. It is declared "applicability, never state", but no code path filters
by it, and in every artifact `use-when` and `paths` already say what it says.

`report` sits on eighteen and distinguishes stage markers, which the new report
shape dissolves.

`owner` is read, and it is also a restatement of the path. `validate.mjs` already
enforces that `policies/` holds only `owner: protocol` and `rules/` only
`owner: repository`, which is the same rule stated twice: once in a table, once
on every file it covers.

And the field that survives all of this is the one nothing checks. Every
`validate.mjs` run ends by saying so: "Not checked mechanically: whether each
use-when states a trigger rather than a topic." The specification calls that
failure the one this shape can still produce, and says why it is fatal, since an
artifact without a real trigger "cannot participate in progressive discovery and
is therefore either loaded always or never." Removing five fields concentrates
the whole mechanism in the unverified one.

`aep` is credited with catching an artifact edited without being restamped, and
it is not what catches it. `release.mjs` hashes content **with the `aep:` and
`date:` lines removed**, and `verify.mjs` says which mechanism does the work:
comparing content against the manifest "is what catches an edit that never got
restamped". The stamp is written as a result of that check. `adapters.mjs` never
reads it, and `index.mjs` reads `protocol.md`'s alone. On a repository-owned
artifact it is worse than unread: `contexts/repository.md` declares a release it
was never built from, since the repository edits it freely and no upgrade touches
it.

## Twelve primitives where seven do work

Four of the twelve are not primitives. **Modes** duplicate their own skills:
every constraint in `modes/implement.md` appears in `skills/implement.md`, and
across eight files the content appearing nowhere else is two short paragraphs
each. **Evidence** and **tasks** are parts of an effort. **Worktrees** and
**position** are mechanisms. The cost is not tokens. It is that a reader meets
twelve concepts before doing anything.

## Seven commands where four are the workflow

`review` and `commit` already run unprompted from inside `[[skills/implement]]`.
`refine` and `research` are reached by the human retyping what the previous skill
told them to type.

# Goal

**Everything is an effort, and an effort is one issue, one branch, one pull
request**, present from the first draft because the pull request is what the
effort's own artifacts land through. Its shape never varies. How much writing it
takes does.

**One `/implement` invocation** carries an effort from its first unblocked ticket
to a pull request ready for review, without returning to the human except on a
declared trip-wire.

**The run ends when the spec is satisfied**, judged against the codebase, not
when the ticket list runs out.

**The effort's state is projected onto the tracker's labels**, so it is visible
where you already watch. The files stay authoritative.

**The report is four short slots and a ledger**, read by the human as progress
and by the orchestrator as its own state.

**Four workflow commands.** **Seven primitives.**

# Scope

- The effort as the single unit of work, with a uniform tracker shape and
  artifacts that scale to the change.
- `spec.md` and `plan.md` as separate files, mapping onto the issue and the pull
  request.
- Effort directories numbered from the tracker.
- The issue and pull request opening at first draft, and every artifact revision
  landing as a `docs` commit on the effort branch.
- **Labels** as a projection of the effort's state, with a seeded label set for
  repositories that have none of their own.
- An effort-level runner in `[[skills/implement]]`, with wave-based integration
  onto one branch.
- **Converge** as the runner's termination condition.
- The dissolution of ``skills/commit``.
- **The report**: seven slots to four, plus a ledger written for two readers.
- **The entrypoint**: `AGENTS.md` as the one entry, and a pointer file per
  targeted runtime.
- **Frontmatter**: six fields to one, with ownership derived from location and
  the release named once in `protocol.md`.
- The primitive cut, twelve to seven, and the removal of `modes/`.
- The command surface, seven workflow skills to four.
- Migration of AEP 2.x repositories through `[[skills/update]]`, including
  tracker artifacts belonging to efforts still in flight.
- `specs.md` and the verification suite moved in the same pass
  (`[[rules/authoring]]`).

**This lands as one effort.** It is large, and splitting it into a chain was
considered and declined: every part of it changes the same artifacts, so a chain
would migrate each file four times and each stage would be planned against a tree
the next stage moves. The spec is long because the change is, and neither is
trimmed to look smaller than it is.

# Requirements

## The effort

1. Every change is an effort. There is no second path for a small one.

   **A fix that falls inside an open effort's scope is a commit on that effort's
   branch, not a new effort.** Only a change with no open effort anywhere opens
   one, and requirement 2 is what keeps that bearable.

2. An effort's artifacts scale to the change. `spec.md` is always written and may
   be four lines. `plan.md` is written only where the approach is not obvious.
   A trivial effort has one ticket.

3. `spec.md` and `plan.md` are separate files under `efforts/<id>-<slug>/`,
   beside `evidence/` and `tickets/`. `spec.md` holds what is changing and why,
   with one acceptance criterion per requirement. `plan.md` holds how.

4. An effort directory is created as `xxxx-<slug>` and renamed to its tracker
   number when the issue is created. Where there is no tracker, a local counter
   supplies the number.

5. Tickets are local files under the effort. The dependency graph stays
   machine-readable and never reaches the tracker.

## Opening the work

6. **When `spec.md` first exists, even as a draft**, one step creates the issue,
   renames the directory to its number, creates the branch, commits the effort's
   artifacts as a `docs` commit, and opens a draft pull request. The pull request
   exists from the first draft because it is what the effort's own artifacts land
   through.

   **This step is the one human moment in an effort, and it asks once**: for
   permission to push and open a public pull request, and for the effort's
   `priority:`. Both are the human's and both are needed at the same instant, so
   asking twice would be two interruptions where the work needs one.

7. The issue body is `spec.md`, carrying the effort's acceptance criteria as
   checkboxes. It is rewritten as the spec changes.

8. The pull request body carries the approach from `plan.md`, each ticket's
   acceptance criteria as checkboxes once tickets exist, and the keyword that
   closes the issue on merge. Before tickets exist it says so rather than
   carrying an empty list.

9. Every revision to `spec.md`, `plan.md`, `evidence/`, or `tickets/` lands as a
   further `docs` commit on the effort branch. Grilling, research, and planning
   are visible in the pull request as they happen.

10. **Abandoning an effort closes both the issue and the pull request**, labelled
    `flag: wontfix`. An abandoned draft is never left open.

## Labels

11. Labels are **markings, not state.** `spec.md` and `plan.md` are the source of
    truth for what an effort is and where it stands; the labels project that onto
    the tracker. Where a label and the file disagree, **the file wins**
    (`[[policies/authority]]`) and the label is corrected.

12. `spec.md` keeps its `status:` frontmatter field. A repository with no tracker
    loses the projection and nothing else.

13. AEP requires the `status:` family, or a recorded mapping onto this
    repository's equivalents, because that family is what the effort's state
    projects onto:

    | Effort state | Issue | Pull request |
    | --- | --- | --- |
    | spec drafting | `status: backlog` | `status: backlog` |
    | spec accepted, tickets cut | `status: ready` | `status: ready` |
    | runner working | `status: in progress` | `status: in progress` |
    | converge clean, ready for review | `status: in review` | `status: in review` |
    | merged | closed by the pull request | `status: done` |

14. AEP sets **every family**: `status:`, `type:`, `size:`, `priority:`, and
    `flag:`. The issue and the pull request both carry **the repository's own
    labels**, chosen from what already exists there. **AEP adds no label naming
    itself.**

15. A label AEP sets is either **derived** or **initial**, and the two are
    maintained differently:

    - **Derived** labels are re-synced on every write to the effort's issue or
      pull request, because a file or a diff determines them: `status:` from the
      spec's state, `type:` from what the spec describes, `size:` from the diff,
      and the flags a fact establishes.
    - **Initial** labels are set once when the effort is opened and **never
      updated by the agent**: `priority:`, and any flag that invites another
      person to act. **A human's change to one of these is never overwritten.**

    *Why the split: a derived label restates something the repository already
    says, so re-syncing it can only correct drift. An initial label states a
    judgement the agent is not the authority on, so re-syncing it would overwrite
    the human who is.*

16. `size:` is computed from the diff when the pull request goes ready for
    review, against the line thresholds the repository's own label descriptions
    state.

17. The flags AEP derives, and what establishes each: `breaking changes` from the
    public-contract trip-wire, `discussion` while the spec carries open
    questions, `dependencies` and `release` from the diff, `confirmed`,
    `unconfirmed`, and `cant reproduce` from a diagnosis, `triage` on a fresh
    draft, and `wontfix` under requirement 10. **A flag with no fact behind it is
    not set.**

18. `[[skills/install]]` and `[[skills/update]]` **offer AEP's label set as a
    seed** where the repository carries only its tracker's default labels.
    Accepting it replaces those defaults.

19. Where the repository has labels of its own, **only the missing ones are
    created**, named and coloured in the style already in use, and the whole set
    is proposed with exact strings before any is created.

## The runner

20. `/implement` invoked against an effort runs until converge finds no gap, or a
    trip-wire fires. An exhausted ticket list is not the end of the run.

21. Scheduling reads the declared edges. When the frontier is empty and
    unresolved tickets remain, the runner identifies what blocks them and builds
    that first.

22. Children in a wave branch from the effort branch's current tip. The
    orchestrator integrates each child as it returns, so a conflict surfaces per
    ticket at integration rather than in one pile at the end. The next wave
    branches from the new tip.

23. Each ticket lands as one commit on the effort branch, **with no exception for
    a ticket that produces no diff**: one that verifies something is already true
    lands an empty commit whose message carries what was checked and what it
    printed. The evidence is then in the history that a bisect reads, and the
    ledger line looks like every other.

24. **Exactly three conditions may stop a run and reach the human**: evidence
    that invalidates the technical plan, work that touches a public contract or
    data at rest, and a ticket that contradicts `spec.md`. The third is
    `[[policies/execution]]`'s and the policy is not softened to remove it: a
    contradiction means the tickets were cut wrong, which is worth one
    interruption rather than a run building the wrong thing ten times.

    Everything else the run notices is recorded to the run log under requirement
    28 and carried to the close. **In particular, a ticket whose review rejects
    twice is parked**: recorded unresolved, its dependents left alone, and the run
    continues to the tickets that do not need it. Two fix attempts, then move on,
    because converge will see the gap regardless and a third attempt is a loop
    that looks like work.

25. A ticket's criteria are ticked in the pull request body by
    `[[agents/reviewer-correctness]]`, which already judges each requirement and
    each acceptance criterion against the diff. **The agent that built the ticket
    never ticks its own criteria.**

26. A criterion is ticked **at the moment it is verified**, carrying inline what
    verified it.

    **A ticket is not `resolved` while one of its criteria is unticked.** The
    status is the claim that the work is done and the ticks are the evidence for
    it, so a resolved ticket with an open box is the claim with its evidence
    removed. A criterion that cannot be met leaves the ticket parked unresolved
    under requirement 24, or marks it `obsolete` where the spec moved on. Neither
    is ticking it.

27. A resumed run reconstructs its position from the pull request, the issue, and
    the repository, and from nothing else.

28. **The session is disposable. Nothing the run needs lives only in its
    context.**

    - What a child returns is capped, so the orchestrator's growth is a function
      of ticket count rather than of the work inside each ticket.
    - As the run proceeds, the orchestrator writes into a **collapsed run log
      section of the pull request** everything not already durable elsewhere: the
      ledger, items recorded but not acted on, which converge round it is in, how
      many times each ticket failed review, and anything a child raised that was
      not a trip-wire.
    - **Auto-compaction is therefore harmless, and the run does not stop for
      it.** The summary loses whatever it loses; the run continues correctly
      because the pull request holds what it needs. A session that dies outright
      resumes by the same route, under requirement 27.

    *No AEP mechanism may depend on triggering compaction.* An agent cannot
    invoke it. It is a command the human types, or a harness behaviour that fires
    on its own schedule and chooses its own survivors, so a design that waits for
    it is waiting on something it does not control.

## Converge, and closing the work

29. When no unresolved ticket remains, the runner **converges**: it assesses the
    codebase against `spec.md` and `plan.md`, and where the spec is unmet it
    appends the remaining work as new tickets and continues. The effort is
    complete when a converge round finds no gap.

30. Converge distinguishes work that was **not built** from an approach that
    **does not work**. The first becomes tickets. The second is the
    return-to-plan trip-wire, and converge raises it rather than building around
    it.

31. **Converge runs at most twice per effort.** Converge, build the gap, converge
    again. Past that the remaining gaps are named at the close and in the pull
    request, and the run ends rather than grinding.

    *Why two and not a configurable number: a third round finding new gaps means
    the plan was wrong rather than the work incomplete, and that is requirement
    24's first trip-wire rather than more rounds. A configurable cap is a value
    nobody can set correctly until a run has already gone wrong.*

32. Converge owns the two effort-level judgements ``skills/commit`` currently
    makes from one ticket's diff: whether the effort is implemented, and whether
    the change moved a boundary, retired a concept, or falsified a
    `[[contexts]]` or `[[references]]`. What it falsified is corrected in the
    same effort.

33. When converge finds no gap, the runner **stamps `spec.md` to
    `status: implemented`**, finalises the pull request description, computes
    `size:`, moves both objects to `status: in review`, and marks the pull
    request ready. The human reviews and merges.

    **That stamp is the one edit converge makes to `spec.md`, and requirement
    32's judgement is what it records.** Every other part of a spec is what was
    asked for, and a converge able to edit those closes a gap by narrowing the
    ask. `status` is the only field stating a fact about the work rather than a
    requirement of it, and the fact is the answer converge has just given.

    Left unwritten it is a judgement made and discarded, with three readers of a
    value nothing sets: `[[skills/tasks]]` skips an implemented effort,
    `[[skills/prune]]` reads the status to tell a finished effort from an
    abandoned one, and `validate.mjs` stops checking traceability on one.

34. A chain of efforts built on unmerged work stacks at the effort level, one
    pull request each, in the shape the repository's rule fixes. A ticket is
    never a pull request.

35. AEP creates exactly one issue and one pull request per effort, and no other
    tracker object.

## Reporting

36. A turn reports in **four slots, one line each**: `Position` and `Assuming`
    before the work, `State` and `Next` after it.

37. Between them sits a **ledger**: one line per ticket, marked as it is crossed,
    carrying the ticket, how many of its criteria are verified, and the commit it
    landed as.

38. The ledger is written for **two readers**. The human reads it as progress;
    the orchestrator re-reads its own lines to recover where it is in a long run.
    `[[policies/reporting]]`'s exemption for text a protocol agent reads is
    narrowed so the ledger is governed by both at once: it reads as a person
    wrote it, and its labels and order are stable enough to be parsed by the run
    that wrote them.

39. A run that stops early names in `Next` what would clear it. That is what the
    removed third closing slot carried.

## The cut

40. `protocol.md` names seven primitives: policies, rules, references, contexts,
    efforts, agents, skills. Evidence and tasks are described as parts of an
    effort. Worktrees and position are described as mechanisms where used.

41. `modes/` is removed, and `mode:` goes with it under requirement 55. Each
    mode's Mindset and What this gives up fold into its skill.

42. Four workflow commands remain invocable: `specify`, `plan`, `tasks`,
    `implement`. `refine`, `research`, `review`, and `converge` become stages
    those four run. `install`, `update`, `help`, `prune`, `survey`, `handoff`,
    and `prototype` remain as utilities outside the workflow, and `tdd`,
    `domain`, and `prose` remain sub-skills reached from inside another. **The
    cut removes no capability aimed at the codebase rather than at a change**:
    `survey`, `domain`, and `prune` all survive.

43. ``skills/commit`` is removed. Its mechanics run inline in the runner:
    stage, write the message, commit, regenerate the index, stamp the marker,
    mark the ticket resolved. Its two effort-level judgements move to converge
    under requirement 32. Its conflict note survives as depth the runner reads
    when integration hits a conflict, and moves to
    `[[skills/implement/conflicts]]`: a note under a directory whose skill has
    been deleted is unreachable from any skill, which the artifact contract
    already forbids.

44. `[[skills/specify]]` resolves material uncertainty inside the invocation:
    factual by research, product and tradeoff by grill. `[[skills/plan]]` does
    the same for the technical approach. Neither hands back a routing
    instruction.

45. ``skills/tasks/labels`` is removed with its ladder and its approval gate.
    Requirements 11 through 19 replace it, and they answer a different question:
    which of this repository's labels describe this effort, not which label
    carries a grouping fact.

46. `/tasks` fails where a ticket traces to no requirement in `spec.md`, which is
    what keeps two files from drifting apart.

## Carrying repositories across

47. `[[skills/update]]` migrates a 2.x tree to 3 without losing anything
    `owner: repository`. What it cannot translate is reported by name rather than
    dropped. A 2.x `spec.md` carrying `# Architecture` is split into `spec.md`
    and `plan.md`, and its `status:` frontmatter is projected onto a label under
    requirement 13 while staying in the file.

48. `[[skills/update]]` reshapes tracker artifacts **only for efforts still in
    flight**: the effort's task issues collapse into one issue and one pull
    request in AEP 3 shape. **An effort that has landed is left exactly as it
    is**, because a merged pull request's body is the record of what was
    reviewed.

49. Milestones **entirely AEP's**, where every issue under one belongs to an AEP
    effort, are deleted. Labels are not deleted, because deleting one strips it
    from closed issues the migration deliberately did not touch, and because the
    1.x and 2.x effort labels are how the migration finds what to reshape. Every
    tracker write in requirements 48 and 49 is proposed as one set, with exact
    strings, and approved before anything is written.

50. `[[rules/version-control]]` in this repository states what the runner is
    permitted to push and open, and the permission is explicit rather than
    inferred from the invocation.

## The entrypoint

51. **`AGENTS.md` is the entrypoint.** `[[skills/install]]` writes it at the
    repository root from the seed where none exists. It points at
    `.aep/protocol.md` and restates nothing of it, because a summary in an
    entrypoint is a second home and it is the copy that drifts.

52. **Every runtime AEP targets gets its own entrypoint file, and each is one
    line pointing at `AGENTS.md`.** Which file a runtime loads by name is a row
    in the adapter target table, beside where that runtime's wrappers land, so
    the fact is stated once rather than in each skill's prose. A runtime whose
    entrypoint already is `AGENTS.md` gets no second file.

53. `[[skills/install]]` and `[[skills/update]]` both check every entrypoint.
    Where one exists and does not point at `AGENTS.md`, the pointer is **added
    and nothing else is changed** — the file is the repository's and may carry
    instructions predating AEP.

## Frontmatter

54. An artifact's frontmatter carries **`use-when`, and `paths` where it
    narrows**. For most artifacts that is one field. Effort artifacts
    additionally carry the two fields that are real state: `status` and
    `blocked-by`.

55. `aep`, `date`, `kind`, `mode`, `report`, `owner`, and `part-of` are removed
    from every artifact.

    **Nothing loses a function. Each one moves to where the answer already is:**

    | Removed | What it did | Where that lives in 3 |
    | --- | --- | --- |
    | `aep` | detect an artifact edited without being restamped | `stamps.json`, unchanged: it already hashes content with `aep:` stripped |
    | | say which release this file is from | `protocol.md`'s `version:`, under requirement 58 |
    | | say when this file last changed | `git log -1 <file>`, which cannot go stale |
    | `date` | the same question as `aep`, by a second mechanism | git. The index's own `date`, computed as the newest any artifact declared, goes with it |
    | `kind` | say what kind of artifact this is | the directory, and the heading that already says it |
    | | validate the value is legal | nothing left to validate |
    | `mode` | say which activities this is relevant to | `use-when` states the occasion, `paths` matches the file |
    | | carry the concept of a working posture | requirement 41: each mode's Mindset and What this gives up move into its skill. The posture survives; the artifact and the label go |
    | `report` | pick stage markers on or off | one shape for every turn. The ledger belongs to the runner, stated there |
    | | let the human know the shape before the run | better served, since all turns are four slots and no field needs reading |
    | `owner` | decide what an upgrade replaces or preserves | the generated manifest in `contract.mjs`, which is the list the upgrade already acts on |
    | | catch a file in the wrong directory | requirement 57, which is stricter than the declaration was |
    | | carry the declared-deviation mechanism | unchanged. It rests on the concept of ownership, not on a field |
    | `part-of` | say which effort a ticket belongs to | the path `efforts/<effort>/tickets/` |

    The only function that leaves the file rather than moving inside the tree is
    `aep`'s per-file *when did this last change*, and it moves to git.

    **`paths` stays**, and it is not the same case as `mode`. `mode` was an enum
    with no matcher, fully restated by `use-when`. `paths` is a glob, so it
    answers *does this apply to the file I am about to edit* exactly, where prose
    can only approximate. It is on two artifacts and costs nothing.

56. **Ownership is derived from location, and `protocol.md` states the rule** in
    one table: which directories are the protocol's, which are the repository's,
    with `protocol.md` and `index.md` named individually. A reader learns
    ownership once from the bootstrap rather than from a declaration on every
    file.

57. **The guard `owner` was providing moves to a generated manifest.**
    `contract.mjs`, which already ships to installed trees and already carries a
    closed list of skills, carries the exact set of paths the payload ships.
    Validation fails by name on a file inside a protocol-owned directory that is
    not on it.

    *Why this is stronger than what it replaces: a declaration is a per-file
    claim checked against nothing, and the manifest is the list the upgrade
    actually acts on.*

58. **`protocol.md` carries `version:`, the single release of record.** Every
    protocol-owned artifact is at that version by construction, because an
    upgrade replaces all of them. A repository-owned artifact carries no version,
    because it has none: the repository edits it freely and no upgrade touches
    it.

    *Removing the per-artifact stamp costs no detection.* `release.mjs` already
    hashes content with the `aep:` and `date:` lines stripped, so deleting those
    lines changes no hash and `stamps.json` is unchanged. `verify.mjs` states
    which mechanism does the work: comparing content against the manifest "is
    what catches an edit that never got restamped". The stamp was written as a
    result of that check, never as the check. And `index.mjs` already reads the
    release from `protocol.md` alone rather than from each artifact.

59. `release.mjs` loses its per-artifact stamping pass and keeps the baseline
    update. Setting the version of record becomes one write to `protocol.md`.

60. **`use-when` is checked mechanically.** Four checks, each a hard failure
    naming the file:

    - it names an **occasion**: begins with a gerund, or contains `when`,
      `while`, `before`, or `after`;
    - it is **not a bare noun phrase**;
    - it does **not restate the artifact's own heading**, which is how a topic
      gets written by accident;
    - it is **within a stated length bound**, because a `use-when` that runs to
      three lines is a summary rather than a trigger.

    *Why this is not optional here: requirement 55 concentrates discovery in this
    one field, and `validate.mjs` today ends every run by admitting it cannot
    check it. A proxy that catches the common instance is worth more than an
    honest admission that catches none.*

    The admission narrows to what the proxies do not cover rather than
    disappearing, because a trigger can satisfy all four and still be wrong.

## The tracker is not optional, and neither is its absence

61. **An upgrade reconciles this repository's rules against the law that changed
    under them.** A rule may tighten or extend a policy and may never soften,
    contradict, or opt out of one (`[[policies/authority]]`) — and that judgement
    was made against the release the rule was written under. When a crossed
    release changes the policy, the rule does not move with it.

    The candidates are **computed, not judged**: every rule citing a policy the
    crossed releases changed. Each is then classified, and the classification is
    what a human reviews:

    | The rule | Do |
    | --- | --- |
    | restates law the release changed | rewrite it to cite the policy rather than repeat it |
    | contradicts the new law — softens it, or opts out | rewrite it to the new law, or record a **declared deviation** where the repository means to differ |
    | tightens a policy the release did not touch | **untouched** |

    **Every edit is shown as exact before-and-after strings, as one set, before
    the first one is made, and on a refusal nothing is written** — the same gate
    a tracker write passes, for the same reason: this is somebody else's
    governance. A rule is never deleted; a contradiction the repository means to
    keep becomes a deviation that says so.

    *Why the upgrade and not validation: a rule and a policy can only be read
    against each other at the moment one of them moves, and the upgrade is that
    moment. Today it is also the one step that deliberately looks away —
    `[[skills/update]]` preserves `rules/` untouched and reports only deviations
    somebody already declared. This repository is the instance: 3 gives the
    runner permission to push the effort branch, and a repository whose
    `version-control` rule still reads "never push, never publish" carries a rule
    the protocol now contradicts, with the policy quietly winning and nobody
    told.*

62. **Where the repository has no tracker, an effort is a branch, and merging it
    is the human's.** `[[skills/specify]]` creates no issue and no pull request
    and makes no tracker call; the local counter of requirement 4 supplies the
    number; the run's durable record is the repository itself — one commit per
    ticket on the effort branch, and each ticket's criteria ticked in its own
    file. The close stamps `spec.md` to `implemented` under requirement 33 and
    stops there, because there is no draft to mark ready. **The human merges the
    branch.** The runner never merges, with a tracker or without.

    *Why this needs stating: requirement 12 says a repository with no tracker
    "loses the projection and nothing else", and the projection is the only thing
    it loses for free. It also loses the issue, the pull request, the run log's
    home, and the record `[[skills/implement]]` reconstructs a killed session
    from. Each of those needs a named substitute, and each already has one,
    because requirement 5 made tickets local files: the commits say which tickets
    landed and the ticked boxes say what was verified.*

63. **Where the repository has a tracker, the issue and the pull request are not
    optional, and each links to the effort in both directions.** Requirement 6
    creates both; this is what makes not creating them a defect rather than a
    posture. The tracker points at the repository by the effort directory being
    named for the issue number (requirement 4); the repository is pointed at from
    the tracker by both bodies naming the effort's path. A run that finds a
    tracker and an effort without its two objects **opens them and says so**,
    rather than continuing in the shape of requirement 62.

    *Why: "no tracker" was never a posture a run was meant to choose, and nothing
    said so, which made it one — reachable by not asking. This repository is the
    instance and the reason this requirement exists: issues are enabled, and
    across forty-four pull requests, thirty-eight of them merged, it has never
    opened one, so every effort in it has been half the shape the protocol
    describes.*


# Acceptance Criteria

1. A one-line bug fix and a fifteen-ticket feature both produce one issue, one
   branch, and one pull request. The bug fix has no `plan.md`.

2. An effort directory exists as `xxxx-<slug>` before the issue and as
   `<number>-<slug>` after, and the rename does not appear in history.

3. Running `/specify` on a fresh request ends with an open issue, an open draft
   pull request, and a branch whose only commit contains the effort's artifacts
   and nothing else.

4. A spec revised three times during grilling produces three `docs` commits on
   the effort branch, and the pull request shows all of them.

5. Abandoning a draft effort leaves no open issue and no open pull request, both
   labelled `flag: wontfix`.

6. The issue body states every requirement with a checkbox beside its acceptance
   criterion. The pull request body states every ticket with its criteria as
   checkboxes, or says tickets are not yet cut.

7. Moving an effort from draft to accepted changes both objects from
   `status: backlog` to `status: ready` in the same step, and `spec.md` still
   carries `status: accepted`. Editing either the field or the label by hand and
   re-running leaves the label corrected to match the file, never the reverse.

8. The issue and pull request carry only labels that existed before the effort,
   unless the run reported creating one and said why. No label names AEP.

9. A pull request that changes a dependency manifest carries
   `flag: dependencies`; one that fires the public-contract trip-wire carries
   `flag: breaking changes`. An effort opened with a `priority:` label still
   carries that label after ten runs, and a human changing it is not overwritten
   by the next run.

10. A pull request going ready for review carries a `size:` label matching the
    thresholds in that label's own description, computed from the diff.

11. `install` in a repository carrying only its tracker's default labels offers
    the seeded set and, on acceptance, leaves the defaults gone. `install` in a
    repository with its own labels creates only what is missing, in that
    repository's naming style, and shows the exact strings first.

12. An effort with three dependency layers completes in one `/implement`
    invocation, with every layer dispatched and no hand-back between them.

13. Given an effort whose only open tickets are blocked, the run builds the
    blocking work and continues.

14. Two children in one wave that touch the same file produce a conflict at the
    second one's integration, named against that ticket, not at the end.

15. The effort branch has one commit per ticket, plus the `docs` commits.

16. Given an effort whose tickets are all resolved but whose spec has an unmet
    requirement, the run appends tickets for the gap and continues rather than
    marking the effort complete.

17. Given an effort whose tickets are all resolved and whose spec is satisfied,
    converge finds no gap and the pull request goes ready for review in the same
    run.

18. Given a converge round that finds the approach itself does not satisfy a
    requirement, the run stops on the return-to-plan trip-wire rather than
    appending tickets.

19. An effort that reaches the converge cap ends with the remaining gaps named in
    both the close and the pull request, and with the pull request not marked
    ready.

20. A criterion's checkbox is ticked by the correctness reviewer. No checkbox is
    ticked by the agent that wrote the code it refers to.

21. A run in which a child finds the plan invalid stops and names the evidence
    and the plan decision it invalidates. A run in which a child touches a schema
    stops before that change lands. A run where a review rejected once and the
    fix passed completes without stopping and names both at the close.

22. Opening the pull request partway through a run shows which tickets are done,
    which criteria of the in-flight ticket are verified, and what verified each.

23. Killing a run at ticket six of ten and re-invoking `/implement` resumes at
    the first unverified criterion, re-verifying nothing already ticked and
    trusting nothing not ticked.

24. A run that crosses an auto-compaction boundary mid-effort completes
    correctly, and its close names every ticket, including those that landed
    before the boundary.

25. Killing a session at ticket six and resuming in a fresh one reaches the same
    next ticket, the same converge round, and the same list of recorded-not-acted
    items, read from the pull request alone.

26. A ten-ticket run emits exactly four slot lines plus ten ledger lines. No slot
    line exceeds one line.

27. A run that stops on a trip-wire has a `Next` naming what would clear it.

28. A diff that relocates something a `[[contexts]]` pointer names is caught by
    converge and the context is corrected before the pull request goes ready.

29. `grep -r 'modes/' src/` returns nothing outside the migration path.
    `protocol.md`'s primitives table has seven rows. `src/skills/commit.md` does
    not exist and `src/skills/implement/conflicts.md` does.

30. Typing `/refine`, `/research`, `/review`, `/commit`, or `/converge` is not
    required to complete any workflow. A `/specify` invocation on a request
    carrying a factual unknown produces a spec and an evidence file in one turn.

31. `/tasks` exits non-zero on a ticket whose criteria trace to no requirement.

32. `[[skills/update]]` run against a 2.x tree produces a 3 tree in which every
    `owner: repository` artifact is present and unedited, every 2.x spec carrying
    `# Architecture` has become a `spec.md` and a `plan.md`, and its report names
    every artifact it could not translate.

33. `[[skills/update]]` run against a repository with one landed effort and one
    in flight reshapes only the second. The landed effort's issues and pull
    request are byte-identical afterwards.

34. `[[skills/update]]` shows every tracker write as exact strings before making
    any of them, and makes none if approval is refused.

35. Installing into a repository with no entrypoint leaves `AGENTS.md` pointing
    at `.aep/protocol.md`, plus one file per targeted runtime whose entire
    content is a pointer to `AGENTS.md`.

36. Installing or updating in a repository whose `CLAUDE.md` predates AEP leaves
    that file's existing content intact with a pointer to `AGENTS.md` added, and
    nothing else changed.

37. A runtime pointer file names `AGENTS.md` and names nothing under `.aep/`.
    Which file each runtime reads appears once, in the adapter target table, and
    in no skill's prose.

38. A skill's frontmatter is `use-when` and nothing else. No artifact under
    `.aep/` carries `aep`, `date`, `kind`, `mode`, `report`, or `owner`, and
    `protocol.md` is the only file naming a release.

39. Running `release.mjs` against the 3 tree produces content hashes identical to
    those the 2.x tree produced for the same content, because the hash already
    stripped the fields that were removed.

40. `protocol.md` states which directories the protocol owns and which the
    repository owns, and names `protocol.md` and `index.md` individually.

41. Placing a repository-authored file in a protocol-owned directory fails
    validation by name, and the message says where it belongs.

42. An upgrade preserves every repository-owned artifact and replaces every
    protocol-owned one, with no artifact declaring which it is.

43. A `use-when` reading `"Database documentation"` fails validation by name. One
    reading `"changing anything under src/"` passes. One that repeats its own
    file's heading fails.

44. A local ticket's frontmatter is `status` and `blocked-by`, and nothing else.

45. `[[rules/version-control]]` names pushing a branch and opening a draft pull
    request as permitted for an effort the human opened, and states it rather
    than leaving it implied. Nothing else in the right-hand column of its table
    moves.

46. The verification suite exits zero and asserts each claim above against the
    specification.

47. An effort whose converge round found no gap carries `status: implemented` in
    `spec.md` before its pull request is marked ready. A spec at `implemented`
    with an unresolved ticket under it fails validation by name.

48. A ticket at `status: resolved` with an unticked criterion fails validation by
    name. An `obsolete` ticket is exempt, and so is every ticket under an effort
    whose spec is `implemented`, because a landed effort is the record of what
    was reviewed.

49. A rule restating a policy an upgrade changes is rewritten to cite it, and a
    rule tightening a policy the upgrade did not touch is byte-identical
    afterwards. Every edit is shown as before-and-after strings before the first
    is written, and a refusal leaves every rule unchanged.

50. In a repository with no tracker, `/specify` ends with a branch and a commit
    and makes no tracker call, and the close stamps `spec.md` to `implemented`
    and leaves the merge to the human.

51. In a repository with a tracker, an effort carries exactly one issue and one
    pull request, the effort directory is named for the issue number, and both
    bodies name the effort's path. This repository's own effort is the first to
    carry both, as issue 45 and `.aep/efforts/45-aep-3/`. Its branch keeps the
    name `aep-3` it was pushed under, because renaming a pushed branch to match
    a directory is a cost the requirement never asked for.


# Constraints

- **A task is never split across sub-agents** (`[[policies/execution]]`). A
  ticket too large for one child goes back to `[[skills/tasks]]`.
- **Human authority is never delegated downward** (`[[policies/execution]]`).
  Requirement 15's initial class is this constraint applied to labels: the agent
  may open with a judgement, and may never revise the human's.
- **Never silently decide architecture** (`[[policies/engineering]]`). Autonomy
  below the plan is the point of this change; requirement 30 is what stops
  converge from becoming a back door above it.
- **Converge assesses; it does not redefine.** It appends tickets and never edits
  `spec.md` or `plan.md`. A spec that turns out to be wrong is a return-to-plan
  event.
- **The tracker is never mirrored into `.aep/`.** Requirement 27 reads the pull
  request; it does not copy it.
- **The repository outranks its projection.** Requirement 11 is
  `[[policies/authority]]` applied to labels. A label is a marking of what the
  files say, and it never becomes the thing that says it.
- **The orchestrator is the only integrator.** A child never merges into the
  effort branch.
- **A tracker write to shared data is proposed before it happens**, with exact
  strings rather than a summary. This covers label creation under requirement 19
  and every write under requirements 48 and 49.
- Prototype stays out of the implement path, and prototype code is never promoted
  as-is.
- Requirement 3 supersedes the one-file rule in `templates/spec.template`, which
  states there is no `plan.md`. That rule existed to stop one claim living in two
  files; requirement 46 replaces the mechanism it was protecting.

# Out of Scope

**Re-platforming AEP onto spec-kit.** Assessed against workflow quality with cost
disregarded, and it loses. Its task model is a flat checklist with dependencies
written as prose; its implement runs tasks in one session with no per-task
branch, no worktree, no dispatch, and no review gate; its `taskstoissues` creates
one issue per task that nothing reads back. The runner here needs exactly the
primitives spec-kit lacks and AEP already has. A deferral, not a boundary.

**Converge as an invocable command**, and **converge per ticket.** The first
costs the four-command surface; the second asks a question
`[[agents/reviewer-correctness]]` already asks.

**Tickets as pull requests, and stacks of tickets.** Stacks solve human review
latency and no human is in the loop during implementation here. Per-ticket
granularity comes from commits, reviewed commit by commit inside one pull
request.

**Reshaping landed tracker artifacts, and deleting labels.** Requirements 48 and
49 draw both lines. Rewriting a merged pull request's body makes the tracker
state something that did not happen.

**Revising a label the human set.** Requirement 15's initial class. The agent
opens an effort with a `priority:` and never touches it again.

**Compaction as a mechanism.** An agent cannot invoke it, and a design that waits
on the harness to summarise is waiting on something it neither triggers nor
steers. Requirement 28 makes the question moot by making the session disposable.

**A handoff artifact for the runner.** Requirement 27 says a resumed run
reconstructs from the pull request, the issue, and the repository and from
nothing else. A handoff carrying anything the run needs would make that false,
and one carrying nothing it needs is the closing block written twice.

**Merging.** The human merges.

**Restructuring `references/` or `contexts/`.** Both survive unchanged, and the
seed reference library is untouched.

# Assumptions

- More than one repository beyond this one runs AEP 2.x. Count unknown, and it
  does not alter the design.
- A tracker can express a checkbox and a link in an issue and a pull request
  body, and be updated mid-run without rate limiting becoming the bottleneck.
  True of GitHub, unverified elsewhere.
- A tracker's default label set is identifiable, so requirement 18 can tell "only
  defaults" from "has its own". True of GitHub's nine.
- Continuous integration on a draft pull request is wanted rather than
  suppressed. Some repositories deliberately skip drafts.
- Converge can judge an unmet requirement from the codebase without re-running
  the whole test suite. Unverified, and it decides whether converge is cheap
  enough to run more than once.
- 1.x and 2.x efforts can be told apart from each other, and in-flight from
  landed, by what is already in the tracker. Requirement 49 depends on it.

# Open Questions

None. The eight that stood when the spec was written were settled before
planning, and each landed in a requirement rather than in a note here:

| Was open | Settled in |
| --- | --- |
| whether a public pull request on every draft is acceptable | requirement 6, folded into the one human moment |
| what sets `priority:` at open | requirement 6, asked at the same instant |
| a spec-versus-ticket conflict against `policies/execution` | requirement 24, three trip-wires, policy unchanged |
| what bounds the review-and-fix cycle | requirement 24, two attempts then park |
| what the converge cap is | requirement 31, two rounds, fixed |
| how a ticket with no diff is tracked | requirement 23, an empty commit carrying the verification |
| where landing work with no effort goes | requirement 1, folded into an open effort where one exists |
| whether `survey`, `domain`, and `prune` survive | requirement 42, all three do |

# Risks

- **The trip-wires are too narrow and the runner lands something wrong across ten
  tickets before anyone looks.** The cost accepted in exchange for the
  interruptions. Mitigated by the per-ticket review gate and by converge.

- **Converge becomes a scope-growth engine.** It appends tickets, the runner
  builds them, and the next round finds gaps the new work introduced. A cap set
  too high turns a bad plan into hours of grinding; too low and it reports gaps
  one more round would have closed.

- **Converge inherits the weakness it was added to fix.** It judges the codebase
  against the spec by reading, which is an assessment rather than a test. A
  converge that reads generously reports satisfied on work that is not, at
  exactly the moment the human stops watching.

- **The ledger has two masters.** Text a run parses drifts toward terse and
  stable; text a human reads drifts toward explanatory. Requirement 38 asks for
  both, and the failure mode is a ledger that stays machine-stable and quietly
  stops being readable, which nobody catches because the machine keeps working.

- **A stale label misleads the human even though the protocol knows better.**
  Requirement 11 settles which side wins, so a run that dies between changing the
  file and updating the label leaves a defect with a defined repair rather than
  an ambiguity. What it does not fix is that the human reads the tracker, sees
  `status: in progress` on an effort that stopped an hour ago, and has no signal
  that the projection is behind.

- **The run log grows through the effort and becomes the section nobody reads.**
  Requirement 28 writes everything into it, which is what makes compaction
  harmless, and it is also how a stale or wrong entry hides in plain sight on a
  pull request the human is scrolling past to reach the diff.

- **A failed write to the run log is invisible.** Requirement 28 makes the pull
  request the run's memory, so a tracker call that fails or is rate limited
  silently costs the run the thing it would have resumed from. The session
  carries on looking fine, and the loss shows up only in a resume hours later.

- **`spec.md` and `plan.md` drift.** Requirement 46 catches a ticket with no
  requirement. It does not catch a plan that quietly contradicts one.

- **Discovery now rests on one field, and its checks are proxies.** Requirement
  60 catches a topic written as a noun phrase, and it cannot catch a trigger that
  is well formed and wrong. Before the cut a badly written `use-when` was one
  weak field among six; after it, the artifact is loaded always or never and
  nothing else compensates.

- **An artifact separated from its tree no longer says anything about itself.**
  With `aep`, `owner`, and `kind` gone, a file copied out of `.aep/` and pasted
  into an issue, a chat, or another repository carries no release, no ownership,
  and no type. Everything that identified it was in the path, and the path is
  what a copy drops. Nothing in AEP depends on this, and the first person to
  paste a policy somewhere and ask which version it is will notice.

- **Deriving ownership moves a per-file fact into a manifest that can go stale.**
  Requirement 57's guard is only as good as the generated list, and a payload
  entry missing from it makes a protocol file look like the repository's, which
  an upgrade then preserves instead of replacing. The declaration it replaces
  could not have that failure, because it travelled with the file.

- **The migration touches shared data and has one attempt per repository.**
  Requirements 48 and 49 bound what it may touch and gate every write, but a
  collapse that merges the wrong issues is recovered by hand, in a workspace
  other people are using.
