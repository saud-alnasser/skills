---
title: 'feat(rules): work for another repository leaves as a report, and the router computes which one governs'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

Nothing in the framework asks which repository governs a request. Every
per-repository fact a stage checks — the Marker, the contexts, the tracker, the
version-control policy — answers cleanly in *any* configured repository, so a
session that has drifted into someone else's receives the same green position
report it would get at home and reads it as permission to work there.

That is what happened. A session configuring one repository diagnosed a defect in
the framework, read the framework's own files to confirm it — legitimately — and
then offered fixing it as an option, recommended it, and entered a planning stage
in a repository that was not its project. Every individual step carried
authorisation, which is precisely why no step felt like the one to stop at.

Two shipped rules pushed it. The entry rule says to *enter the stage rather than
answering with something for the user to run*, which reads as a general
prohibition on reporting instead of acting — and reporting was the correct output.
The design stage's *never silently decide architecture* turns any diagnosis into
an options list, with no carve-out for a diagnosis whose subject is another
repository, where the right output is a finding rather than a menu.

## Outcome

An always-on prohibition, in `.claude/rules/` with no `paths:` frontmatter, beside
precedence, engineering and placement. It is always-on because it must fire
*before* the first read in the other repository — a scoped rule arrives only once
a covered file has been read, which is after the decision it exists to inform.

What it covers, from what actually happened: reading another repository is fine,
and writing, planning, or entering a stage in one is not. A finding about another
repository is a report handed back, never an options list — which is what
suppresses the escalation from diagnosis to proposal. Authorization does not
transfer across the boundary: a user authorising the work cannot thereby authorise
*this session* to be the place it happens. And the boundary is stated when it is
reached, so the crossing is visible at the crossing rather than three steps later.

The machinery is the router's, mirroring the Marker exactly — rule in the
always-on tier, computation in the file reached by pointer. The position report
gains which repository governs the request, and the stage table refuses to enter a
stage for one that is not this project's. A clean position report stops reading as
jurisdiction because the report now answers the jurisdiction question separately
and can say no.

The refusal names both repositories — the one it believes governs and the one the
session is standing in — because a refusal a reader cannot check is a wall rather
than a check.

## Acceptance

- The prohibition is a file under `.claude/rules/` with no `paths:` frontmatter,
  shipped as a template and installed by `/configure`.
- It permits reading another repository explicitly, and bounds writing, planning,
  and entering a stage.
- It states that a finding about another repository is a report rather than an
  options list, and that authorization does not transfer across the boundary.
- It requires the boundary to be stated when it is reached.
- The position report answers which repository governs the request, and the stage
  table refuses a stage for one that does not.
- A refusal names the governing repository and the one being stood in.
- Every count of the always-on rule set agrees with what `/configure` installs —
  the validation step says three today and installs three, and this makes four.
- Nothing in the rule depends on the plugin being installed.
- The suite fails when the rule is absent from the always-on tier, and when the
  position report omits the governing repository — each confirmed against a
  deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.


## Reopened by review

Only §4 Generate installs `boundary.md`. §5 Audit has no bullet that installs a missing
always-on rule, and `skills/configure/migration-changelog.md` gained no entry — so an
already-configured repository, which is the case that produced this effort, never
receives the boundary rule, the two new `engineering.md` clauses, or the protocol
changes. Precedent puts migration rows at release rather than at build, so this may be
convention; reopened so the release cannot miss it.

## Comments

The release did not miss it: `chore(dist): release 1.16.0` (#28) cites this reopen and
ships the changelog entry — the boundary rule installed as an absent always-on rule, the
engineering clauses and router changes reported as additive, each reaching an
already-configured repository through §5's version-cursor bullet. The reopen's own
hedge held: migration rows land at release, so no standing §5 bullet was added, and the
delivery is the changelog entry rather than a build change. Every acceptance criterion
re-checked against the tree at 1.16.0. The release closed the migration half and said
so in its own message; the audit half it left open — a §5 bullet comparing an installed
file against its template — lands in the same commit as this resolution, via ticket 02.
