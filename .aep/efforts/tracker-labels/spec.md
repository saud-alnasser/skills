---
status: implemented
---

# Problem

AEP gives a task two homes, and only one of them can answer a question about the
work.

A **local ticket** declares its protocol facts in frontmatter — `part-of`,
`status`, `blocked-by` — and `scripts/index.mjs` lifts them into an index
section, so a later session finds the frontier without opening every ticket
(§27).

An **external tracker** is the other home, and AEP mirrors nothing into the tree.
That part is right: a local copy of an external ticket is exactly the hidden
database §2 forbids. But nothing takes the mirror's place. No shipped surface
requires that anything *in the tracker* carry which effort an issue belongs to,
and none requires a session to read it back. The seeded references hand over
`gh issue edit --add-label <label>` and `glab issue update --label <label>` as
bare commands — no label named, no meaning attached, no requirement to apply one
or to query one.

So in an external-tracker repository, *which issues are this effort's, and which
of them can start now* is answered by listing open issues and judging from prose.
Three costs follow:

- **It is the read-everything the local index exists to prevent**, paid every
  session, and it scales with the size of the tracker rather than with the size
  of the effort.
- **Independence gets inferred.** `[[policies/execution]]` says parallelism
  follows edges read off the task graph and never a guess about what a task
  touches. An agent that cannot query which issues belong to the effort has no
  graph to read — so the prohibition stands with no means behind it, and the
  cheapest way to satisfy it is to work serially and say nothing.
- **The tracker's own vocabulary is ignored in both directions.** A repository
  whose issues already carry `blocked`, `area/api`, `type: bug` gets an agent
  that reads none of it and contributes nothing back to it. The tracker's view of
  the work and AEP's drift apart, and the humans are looking at the tracker.

A tracker has structured fields for exactly this, and using them is not
mirroring — the fact stays in the tracker, expressed in the tracker's own
mechanism, queryable by the same people and tools that already query it.

*The original framing of this section assumed the field in question would be a
label. Planning established that it usually is not — see `# Decisions taken
during planning`. The problem above is unchanged; what answers it is not.*

# Goal

Where an effort's tasks live in an external tracker, an agent finds and maintains
them **through whatever that tracker already models** — its milestones, epics,
dependencies and state first; a label it already has second; a new label, named
in the local style, only where nothing else serves.

The frontier becomes a query. The tracker stays the single home for the work,
and AEP adds to its vocabulary only where the tracker has no answer of its own.

# Scope

External trackers only — GitHub Issues, GitLab, Jira, Linear, Plane, anything the
repository actually uses.

Five shipped surfaces move:

| Surface | Gains |
| --- | --- |
| `src/policies/execution.md` | the requirement: an external task is findable in its tracker by a native query |
| `src/skills/tasks/labels.md` | **new** — the ladder, the style rule, the recording rule, the gate |
| `src/skills/tasks.md`, `src/skills/implement.md` | routing to it, and the frontier read from the recorded query |
| `src/seed/references/{github,gitlab}.md` | the verified operations, and the section the resolution is recorded in |
| `specs.md` §15.4 | the normative statement, plus assertions in `verify.mjs` |

# Requirements

1. **The protocol requires that an external task's effort membership be carried
   where the tracker can answer it as a query**, rather than by reading issue
   prose.

2. **Exactly one fact — effort membership.** Nothing else. An issue's native
   open/closed state already carries `open`/`resolved`, and closing as not-planned
   carries `obsolete`. A dependency **edge** is carried by the tracker's own
   dependency feature where it has one, and by the issue body where it does not —
   never by a label, because a label expresses set membership and `blocked-by-42`
   is a relation wearing a set's clothes.

3. **Native mechanism before a label.** Resolution runs in a fixed order, and
   stops at the first thing that serves the purpose:

   ```
   1. a first-class feature of this tracker    milestone, epic, sub-issue,
                                               issue dependency
   2. an existing label that already serves it
   3. a new label — only here
   ```

   **AEP never creates a label for something the tracker already models.** What
   is native differs per tracker, so the resolution is per-tracker and never
   generic.

4. **A derived label is minimal and matches local style.** One label, not a
   family; named with the separator, casing, and prefixing convention the
   tracker's existing labels already use.

5. **The resolution is recorded once, in the repository's own tracker
   reference** — which mechanism carries the fact, and the query that returns the
   effort's open work. AEP requires the fact; the repository names the mechanism.
   A resolution rederived each session is a resolution that differs each session.

6. **Creating a label or a milestone publishes.** Whatever the resolution
   requires creating is proposed together with the issue set, through the gate the
   references already state — write the whole set first, show it, get it approved,
   then create. Never one at a time, mid-run.

7. **Finding work is a query.** `[[skills/tasks]]` and `[[skills/implement]]`
   locate an effort's tasks and its frontier through the recorded query, never by
   listing every open issue and reading it.

8. **The seeded GitHub and GitLab references carry the operations** — reading
   what the tracker offers natively, listing labels, creating and applying one,
   and the query that returns an effort's open tasks — each verified against that
   tool's own documentation rather than guessed, as drafts the repository
   corrects.

9. **The specification states it and the suite asserts it.** §15.4 gains the
   requirement, and `verify.mjs` gains assertions over the shipped surfaces.

10. **The procedure is self-sufficient without the seeded section.** An upgrade
    never re-seeds a reference the repository has corrected, so an existing
    installation will never receive the new section in `github.md`. The behaviour
    must arrive entirely through the protocol-owned skill note, which proposes and
    records the resolution on first run into whatever reference is there.

# Acceptance Criteria

- [x] R1 — `policies/execution.md` states the requirement, and states *why*
      carrying it in the tracker is not the mirroring §15.4 forbids.
- [x] R2 — the one fact is named in the policy; the exclusion of `status` and of
      dependency edges is written down with its reason, not merely omitted.
- [x] R3 — the skill note states the three steps **in order**, and states that a
      label is never created for a fact the tracker models natively. A run that
      creates a label without having established that no native mechanism serves
      the fact violates a stated step.
- [x] R4 — the derivation rule is stated with a worked example showing the same
      fact landing as two different strings in two differently-styled trackers.
- [x] R5 — the note requires the resolution to be written into the repository's
      tracker reference, and both seeded references carry the section it is
      written into, marked as the draft it is.
- [x] R6 — creation appears in the same approval gate the references already state
      for issue creation, naming labels and milestones explicitly so it cannot be
      read as covered by implication.
- [x] R7 — `skills/implement.md`'s frontier step reads the recorded query, and
      `skills/tasks.md` reports the graph from it. Neither instructs an agent to
      list all open issues.
- [x] R8 — every command in `github.md` and `gitlab.md` is checked against that
      tool's documentation before it ships, and an operation the tool does not
      expose is written down as a gap rather than given a guessed flag.
- [x] R9 — `node src/scripts/verify.mjs` passes, and each new assertion fails with
      the right name when the claim it covers is deliberately removed from the
      shipped surface (`[[rules/authoring]]` — a green run proves nothing until
      the perturbation is confirmed to have removed the subject).
- [x] R10 — the skill note alone is sufficient: a repository whose `github.md`
      predates this change still reaches a recorded resolution on its first
      `/tasks` run.
- [x] `node src/scripts/adapters.mjs` regenerated; the committed adapter is not
      stale.
- [x] A repository with **no** external tracker reads identically to today — no
      new step fires, no new prose applies.

# Decisions taken during planning

Recorded here because both narrow the WHAT rather than only deciding the HOW, and
absorbing that into the approach would be a scope change nobody agreed to.

| Was | Is | Because |
| --- | --- | --- |
| two facts — effort and gated | **one fact — effort** | minimal by principle; *gated* is not dropped but reassigned to the tracker's native dependency feature, where it is not AEP's to maintain |
| an existing **label** is preferred over a new one | a native **feature** is preferred over any label | a tracker that models dependencies, epics, or milestones already answers the question; adding a label beside it is the second home the protocol exists to prevent |

# Established facts

Checked against `gh` 2.96.0 directly and against GitLab's own documentation, then
written into the two references — which are where *how a tool is operated here*
lives. Recorded as an outcome, not duplicated: the commands live in the
references and nowhere else.

**GitHub — every fact is native, and AEP creates no label at all.**

| Fact | Mechanism | Verified |
| --- | --- | --- |
| effort membership | an effort issue; tasks are its sub-issues | `--parent`, `--add-sub-issue`, `--json parent,subIssues` |
| gating edge | issue dependencies | `--blocked-by`, `--add-blocked-by`, `--json blockedBy` |
| status | state + close reason | `--state`, `close --reason {completed\|not planned}` |
| type | issue type | `--type` |

The hierarchy rather than a milestone, decided by the human after the references
were first written. It wins on the things that matter: creating a parent issue is
`gh issue create` where creating a milestone is a drop to the REST API; an effort
gets a body and a thread rather than a title; and milestones here usually already
mean releases, which an effort is not. It loses on filtering — see the gap below.

The frontier is therefore **computable** on GitHub: one query returns the
effort's open issues with `blockedBy` attached, and the frontier is those whose
gates are empty or closed. That is the strongest possible outcome for
`[[policies/execution]]`'s *independence is read, never inferred* — the edges
come back from the tracker rather than being reconstructed.

Two real gaps, both written into the reference rather than smoothed over. There
is **no `gh milestone` command** — creation goes through `gh api`, which is what
makes the milestone the alternative rather than the default. And there is **no
`--parent` filter on `gh issue list`**: `parent` comes back in `--json` and is
narrowed with `--jq`, client-side, *after* truncation. `parent-issue:` exists but
is a **Projects** filter, not an issue-search qualifier, so `--search` does not
reach it either.

That truncation is the sharp edge, and the reference says so: a filtered short
page looks exactly like a complete answer, and the tasks it dropped read as *not
in this effort* rather than as *not fetched*. Raising `--limit` is the fix;
falling back to a milestone is the escape where a repository is too large for one
page.

**Body text is not a control surface, and believing otherwise fails silently.**
Checked because it is a plausible belief an agent would act on. Only the closing
keywords in a *pull request* body drive GitHub — `close`/`closes`/`closed`,
`fix`/`fixes`/`fixed`, `resolve`/`resolves`/`resolved`. A bare `#123` is a
timeline cross-reference with no direction or meaning. **`Blocked by #123` in a
body does nothing at all** — dependencies come only from the UI, the CLI flags,
or the API. And `- [ ] #123` is a checklist item, not a relationship: tasklist
blocks stopped rendering on 30 April 2025 and sub-issues replaced them.

This is the sharpest argument for the design. An agent that writes *Blocked by
#12* into a body has recorded the gate **nowhere**: the sentence reads correctly
to every human who sees it, the tracker holds nothing, and the frontier query
returns that task as ready to start. A wrong answer that looks right is worse
than an error, so the reference states it as a table of what each form actually
does. The same warning is now on the GitLab side, where the description-carried
edge is explicitly a hand-maintained convention rather than state.

**GitLab — the degradation the ladder predicted, landing on one fact.**

`glab` has **no subcommand for issue links at all**, and GitLab's `blocks` /
`is blocked by` are Premium and Ultimate; Free has only an undirected *relates
to*. So the gating edge is recorded in the issue description. GitLab also has no
close reason, which makes `obsolete` the one fact on either tracker with no
native carrier — **the single place a derived label is genuinely the answer.**

That asymmetry is the design working. The same ladder produced no labels on one
tracker and exactly one on the other, because it asked what each tracker already
models instead of imposing a vocabulary on both.

A correction landed with it: the previous GitLab seed carried
`--description-file`, which is not among the documented flags. A seeded command
the repository does not have is worse than no reference at all, and it had been
shipping.

# Constraints

- **No mirror, in either direction.** Nothing about an external task is written
  into `.aep/`. *Why: §15.4, and because a local copy is the artifact that goes
  stale silently while still reading as current.*
- **Labels express membership, never relations.** *Why: a `blocked-by-42` label
  has to be removed by someone when 42 closes, and nothing in the tracker knows
  to. The tracker's own relation field, or the issue body, holds the edge.*
- **Never duplicate state the tracker already owns.** *Why: a status label beside
  a native open/closed state is a second place it can change, and they disagree
  on the first issue closed from the tracker's UI.*
- **AEP requires the fact; the repository names the mechanism.** *Why: the same test
  that makes version-control a rule and not a policy (§7) — how a commit
  references a task, and what a tracker calls its labels, are facts about a
  repository. Fixing `aep:effort/<slug>` protocol-wide collides with every
  existing taxonomy and with every tracker where an agent cannot create a label.*
- **Shipped text cites only what resolves where it is read** (`[[rules/authoring]]`).
  `specs.md` and section numbers exist only here.
- **Every checkable claim added moves the suite in the same pass**
  (`[[rules/authoring]]`).
- **An operation not in the reference is a gap, reported rather than guessed.**
  The seeded commands are verified against each tool's documentation before they
  ship, because a seeded command the repository does not have is worse than no
  reference at all.

# Out of Scope

- **Local tickets.** `efforts/<effort>/tickets/`, its template, its frontmatter,
  and the index section built from it are untouched. Labels are what an external
  tracker has instead of frontmatter, not in addition to it.
- **An index section for external tasks.** That is the mirror, by another name.
  Labels exist precisely so the tree does not need one.
- **Type, priority, area, component, and milestone labels.** AEP holds no fact
  that belongs in them. What the repository does with its own taxonomy is the
  repository's, and an agent applying `priority: high` is making a decision that
  is not its to make.
- **Encoding dependency edges as labels.** Named separately from the constraint
  above because it is the obvious next thing to build.
- **Maintaining a gated or blocked marker.** The fact is real and it is the
  tracker's, carried by whatever dependency feature the tracker has. AEP reads it
  where it can and never keeps a marker of its own in sync — a derived flag that
  nothing removes when the gate clears is worse than no flag.
- **Seeded references for Jira, Linear, or Plane.** None exist today, and install
  detection has no signal to gate them on. Those repositories are served by the
  protocol requirement plus a reference the human writes.
- **Any scheduled reconciliation, sync command, or drift check** between the
  tracker and the tree. `[[skills/help]]` states there is no synchronization
  command and this does not add one.
- **Writing to a tracker belonging to another repository** — already
  `[[policies/authority]]`'s, and unchanged.
- **Renaming, merging, or deleting a label that already exists.** The tracker's
  vocabulary is read and extended, never reorganized.

# Assumptions

- ~~GitHub models issue dependencies and `gh` can reach them.~~ **Verified, and
  R8 is landed for both forges** — see *Established facts* below. What was the
  effort's largest assumption is now the thing the design rests on.
- **A tracker's naming style is inferable from its label list.** Materially
  smaller than it was, because step 3 now fires only when neither a native
  feature nor an existing label serves the fact, and because R5 freezes the
  answer the first time rather than rederiving it. If inference is a coin-flip,
  the recorded resolution is what makes it not matter after run one.
- Most trackers model *grouping* natively — milestones, epics — so the effort
  fact often resolves at step 1 rather than becoming a label at all. This is what
  makes one fact sufficient.
- Creation permission varies by tracker and by token. Some agents will be able to
  apply a label but not create one, and some will be able to do neither.

# Open Questions

- **Who removes what AEP applied, when an effort is abandoned rather than
  finished?** `/prune` handles the tree and reaches nothing in a tracker. Left
  open deliberately: a protocol that writes to a tracker on abandonment is a
  larger claim than this change makes.
- **Does a milestone genuinely serve as effort membership, or only resemble it?**
  Teams use milestones for releases, and an effort is not a release. The
  resolution is human-confirmed (R5), so the wrong answer is caught by a person
  rather than shipped — but the note should say what makes a native feature a
  *match* rather than merely adjacent.

# Risks

- ~~A native feature is claimed that the tool's CLI cannot actually reach.~~
  **Resolved for GitHub and realized for GitLab.** `gh` reaches everything; `glab`
  reaches no issue link at all, so the GitLab reference ships the gap rather than
  a command. The risk was real and it landed on exactly one of the two.
- **Milestone-as-effort collides with a team's release milestones**, and AEP's
  proposal lands in a field other people manage. The approval gate is the
  mitigation, and it works only if the proposal names the exact milestone it
  would create.
- **A repository with restricted creation permission** gets a `/tasks` that stops
  where today it proceeds. Correct behaviour, but a behaviour change, and it
  arrives at the moment the human is least expecting one.
- **Regex assertions pin prose.** A later rewrite that preserves the meaning and
  changes the wording fails the suite. That is the existing cost of this
  repository's verification idiom, accepted rather than solved here.

# Architecture

The change ships as **prose in the payload plus a recorded resolution in the
repository's own reference**, asserted by pinned-phrase regex in `verify.mjs`.
Nothing executable is added.

The shape is a ladder evaluated once per tracker, and a mapping frozen at the
top of it:

```
        the fact                     resolved by, in this order
  ┌────────────────────┐      1. a first-class feature of the tracker
  │ which effort this  │  →      milestone · epic · sub-issue · dependency
  │ task belongs to    │      2. an existing label that already serves it
  └────────────────────┘      3. a new label, minimal, in local style
             │
             ▼
   recorded once in references/<tracker>.md
             │
             ▼
   every later session reads the mapping and runs the query
```

The frozen mapping is the load-bearing part. Everything above it happens once,
under human confirmation; everything after it is a lookup. That is what keeps two
sessions from reaching two answers, and it is why the recorded resolution is a
requirement rather than a convenience.

## Where the behaviour is enforced

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. Prose in the payload, asserted by regex** *(recommended)* | matches every existing surface here; generalises to any tracker including ones with no CLI; nothing to authenticate; the suite already has the idiom | enforcement is an agent following prose, not a mechanism refusing | an agent skips a step and nothing notices at runtime | prose and its pinned phrase move together; the existing cost of this repository |
| **B. A shipped `scripts/labels.mjs` that shells to the forge CLI** | computes the resolution instead of describing it — closest to *where a script can compute an answer, run it* | breaks the dependency-free, filesystem-only contract every shipped script holds; needs an authenticated external binary; works for two forges and no others | a protocol script that fails on an auth error at session start, on someone else's machine | a per-forge code path per tracker, forever |
| **C. A new frontmatter field or artifact kind for the mapping** | machine-readable; `validate.mjs` could check it | the mapping describes a system outside the repository — a field for it is the local mirror §15.4 forbids, wearing a schema | the mirror goes stale silently while still validating | a new field in the frontmatter contract, and a migration for it |

**A.** B is the tempting one and it is the one that breaks the distribution's
central promise: every shipped script is dependency-free ESM a bare Node runtime
can run. Shelling to `gh` makes that false, and buys correctness for GitHub and
GitLab at the cost of everyone else.

## Where the recorded resolution lives

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. The tracker's reference — `references/github.md`** *(recommended)* | the file already answers *how is this tool operated here*, which is exactly what the mapping is; already repository-owned; already loaded by `use-when` when the tracker is touched | a repository with a tracker AEP seeds no reference for has to write one | none material | one section in a file the repository already maintains |
| **B. A repository rule — `rules/tracker.md`** | governance-weight; 1.x had `policies/tracker.md`, so there is precedent | a mapping is not a requirement; it is an operating detail, and the primitive table says a reference is where those go | the rule primitive erodes into a place for configuration | a new seeded rule, gated on nothing |
| **C. The effort's `spec.md`** | closest to the work | re-decided per effort; the whole point is that it is decided once per tracker | two efforts resolve the same tracker differently | every effort carries it |

**A.** The mapping answers *how this tool is operated here*, which is the
reference primitive's definition. Putting it in a rule would make governance out
of an operating detail, and the migration note already sends 1.x's
`policies/tracker.md` to "a rule or `references/`" — this settles which.

## Where the procedure lives

Chosen, not defaulted: a skill note at `skills/tasks/labels.md`, linked from both
`skills/tasks.md` and `skills/implement.md`. The alternatives — inlining it in
both skills, or putting it in `policies/execution.md` — lose to the second-home
problem and to the policy/skill split respectively.

# Components

| File | Owner | Gains |
| --- | --- | --- |
| `src/policies/execution.md` | protocol | the requirement (R1, R2) and why carrying it in the tracker is not mirroring |
| `src/skills/tasks/labels.md` | protocol | **new** — the ladder, the style rule, the recording rule, the gate (R3–R6, R10) |
| `src/skills/tasks.md` | protocol | step 2 routes to the note once the tracker is external |
| `src/skills/implement.md` | protocol | the frontier step reads the recorded query (R7) |
| `src/seed/references/github.md` | repository | the operations, and the section the mapping is recorded into (R8) |
| `src/seed/references/gitlab.md` | repository | the same |
| `specs.md` §15.4 | — | the normative statement (R9) |
| `src/scripts/verify.mjs` | — | the assertions (R9) |
| `src/adapters/claude/**` | generated | regenerated; the note is not published as a command |

No change to `payload.mjs` — `skills/` is already a payload directory and the
note travels with it. No change to `index.mjs`, `validate.mjs`, or the
frontmatter contract.

# Interfaces

The section a tracker reference gains, written as the draft every seeded line is:

````markdown
## AEP tasks in this tracker

**Draft.** Resolved on the first `/tasks` run and confirmed by a human. Correct
it where this repository differs.

| Fact | Carried by | Established |
| --- | --- | --- |
| effort membership | milestone `<name>` | native — no label created |
| the dependency edge | issue dependencies | native |
| status | open / closed | native |

Find this effort's open work:

```sh
gh issue list --milestone "<effort>" --state open
```
````

The proposal shown at the gate, before anything is created:

```
Tracker resolution — github
  effort membership  →  milestone "tracker-labels"     CREATE
  dependency edge    →  issue dependencies             native, nothing to create
  status             →  open / closed                  native, nothing to create

Issues to create: 6
```

**Exact strings, never a summary.** A gate that shows "labels will be created"
is a gate the human cannot actually judge.

# Technical Approach

1. **`policies/execution.md`** gains a short section under the sub-agent material:
   the requirement, the one fact, the two exclusions with their reasons, and the
   sentence that separates this from mirroring — *the fact stays in the tracker,
   expressed in the tracker's own mechanism; nothing about it is written into
   `.aep/`.*
2. **`skills/tasks/labels.md`** is written from `templates/skill.template`, with
   `kind: skill` and a `use-when` naming the branch it serves — *tasks live in an
   external tracker and the effort's work must be findable in it*. It states the
   ladder in order, the never-create-what-is-native rule, the style rule with a
   worked two-tracker example, the recording rule, and the gate.
3. **`skills/tasks.md` step 2** already asks where tasks live. It gains one
   branch: where the answer is a tracker, go to the note before writing anything.
4. **`skills/implement.md` step 1** gains the query as the way the frontier is
   computed when tasks are external, replacing nothing — the local path is
   untouched.
5. **The two seeds** gain the operations and the recording section. Every command
   is read out of that tool's documentation first; an operation the tool does not
   expose is written as a gap in the failure-handling section rather than given a
   plausible flag.
6. **`specs.md` §15.4** gains a paragraph, and `verify.mjs` gains the assertions
   below.
7. **Regenerate** the adapter and reinstall this repository's own tree.

**Two constraints the implementer will hit.** Shipped text may not cite
`specs.md` or a section number — `verify.mjs` asserts it over the whole payload,
and this spec cites them freely only because it is not shipped. And the note must
be linked from `skills/tasks.md`, or the skill-notes section fails it as
unreachable.

# Integration

- `index.md` gains nothing. The `## Tickets` section stays local-only, and the
  existing assertion that it is **absent** without local tickets is the standing
  guard that this change did not grow a mirror.
- `/commit` is untouched: closing an issue is already the tracker's own
  operation, and the references already carry it.
- `/prune` is untouched, and reaches nothing in a tracker — named in Open
  Questions rather than solved.
- A repository with no external tracker takes no new path.

# Migration

Nothing to migrate in the tree, and **one real gap.** An upgrade never re-seeds a
reference the repository has corrected — `verify.mjs` asserts exactly that — so
an existing installation's `github.md` will never receive the new section.

R10 is the answer: the behaviour arrives entirely through the protocol-owned note,
which is replaced on upgrade like every payload file. On its first run in such a
repository the note proposes the resolution and writes the section into the
reference itself. Fresh installs get it seeded; existing ones get it written on
first use; neither is left without it.

# Testing Strategy

Each new assertion in the existing idiom — a pinned phrase over a shipped
surface, in the section that owns it.

| Criterion | Assertion | Section |
| --- | --- | --- |
| R1, R2 | `policies/execution` requires an external task to be findable in its tracker | `policies` |
| R2 | `policies/execution` keeps status and edges out of labels, with the reason | `policies` |
| R3 | the note states the three steps in order | `skill notes` |
| R3 | the note forbids creating a label for a natively-modelled fact | `skill notes` |
| R4 | the note carries a two-tracker style example | `skill notes` |
| R5 | the note requires the resolution to be recorded in a reference | `skill notes` |
| R5 | both forge seeds carry the recording section | `seeds` |
| R6 | the note names labels and milestones in the creation gate | `skill notes` |
| R7 | `skills/implement` computes an external frontier by query | `skills` |
| R10 | the note states it writes the section where none exists | `skill notes` |
| — | the note is linked from `skills/tasks.md`, one level deep, not published as a command | `skill notes`, already generic |
| — | no shipped text cites `specs.md` | `forbidden`, already generic |
| — | the fixture's index still has no `## Tickets` section | `install fixture`, already generic |

**Every new assertion is perturbed before it is trusted** (`[[rules/authoring]]`):
delete the pinned phrase from the shipped file, run `verify.mjs`, confirm it fails
naming that assertion, restore. A green run over an assertion never observed
failing is not evidence.

Not mechanically checkable, and reported as such rather than faked: whether the
ladder's ordering actually changes what an agent does, and whether a proposed
milestone is a genuine match for effort membership rather than an adjacent
concept.

# Operational Considerations

- **Creating publishes**, and now in two ways rather than one — a label and a
  milestone both land in a shared workspace. Both go through the single gate with
  the issue set.
- **Permission is separate from approval.** An agent may be authorised by the
  human and refused by the token. The note treats that as a stop with a report,
  never a fallback to a different mechanism chosen on the spot.
- **Auth and rate limits** are already handled by each reference's failure
  section, and this change adds no new failure mode there.

# Technical Risks

- **A native feature the CLI cannot reach.** GitHub models issue dependencies;
  whether `gh` exposes them is unverified. If it does not, the reference says so
  as a gap and the edge falls to the issue body — an honest degradation, and the
  one outcome R8 must not paper over with a guessed flag.
- **The note grows into governance.** It states a procedure; the moment it starts
  stating requirements, the policy and the note are two homes for one rule. The
  split to hold: the policy says the fact must be findable, the note says how to
  find out what carries it.
- **The two seeds drift apart.** They describe different tools and will diverge
  legitimately; the risk is that only one gets corrected when the shape changes.
  The `seeds` section asserts both carry the recording section, which catches the
  structural half of it.
