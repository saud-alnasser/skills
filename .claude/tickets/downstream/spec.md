---
owner: repository
status: implemented
sources:
  - skills/configure/tools/github.md
  - skills/configure/tools/graphite.md
  - skills/configure/TOOLS.md §Refreshing a derived file
  - skills/configure/SCRIPTS.md
  - skills/configure/SKILL.md §5 — Audit, where AEP is already here
  - skills/configure/protocol.template.md
  - skills/configure/engineering.template.md
  - skills/handoff/SKILL.md
  - specs.md §Generated indexes, §Layout
  - .claude/evidence/discussions/2026-08-10-the-compliant-path-costs-more-than-the-workaround.md
  - .claude/decisions/0070-work-for-another-repository-leaves-as-a-report.md
  - .claude/decisions/0071-the-index-prohibition-is-enforced-by-a-specified-ci-step.md
  - .claude/decisions/0072-a-verified-downstream-correction-returns-as-evidence.md
---

# fix(configure): what a downstream repository found, and the boundary that should have kept it there

## Problem

A session in `workspace/rentable` — a repository AEP configures — ran the
configuration audit, found defects in what AEP ships, and then **crossed into
this repository and started designing the fix**. Both halves are the subject
here. The defects are real and every configured repository has them. The
crossing is the more expensive finding, because nothing in the framework
noticed it happening.

**Three shipped assertions are false or unsupported.**

The GitHub reference denies two capabilities the tool has had for releases:
`gh` gained `--parent`, `--blocked-by`, `--blocking`, `--add-sub-issue`,
`--add-blocked-by` and `--remove-parent`, and the reference tells every reader
to reach for the REST API instead. The stacking reference records the pull
request body as *not documented* when the behaviour is observable. And the
generated-index prohibition is asserted as enforced — in the specification and
in the scripts page — while the scripts page specifies two scripts and neither
compares anything. This repository satisfies the claim with a private suite it
does not ship. Every repository it configures inherits the assertion and no
mechanism, and the directory that would hold a local fix is closed by an audit
that refuses anything the page does not specify.

**A verified correction has nowhere to go.** Refreshing a derived reference is
defined as one-directional: the audit re-checks the installed file against the
repository, and that is the only path. So rentable's corrected references — read
against real tool versions — are ahead of the plugin's, and stay there. This
recurs for every tool AEP names.

**And the audit that would compare them never says how.** No bullet tells a run
to compare an installed file against its template at all, so there is no
instruction for a comparison method to attach to. The session that tried
compared raw bytes across a CRLF plugin checkout and an LF-pinned repository,
read every file as fully changed, and was one step from re-deriving all of them
— which would have silently reverted the corrections above. **That failure mode
is destructive and it is the default on Windows**, not an edge case.

**Underneath all of it: nothing asks which repository governs a request.** The
Marker, the contexts, the tracker and the version-control policy are all
per-repository, and the position report answers cleanly in any of them — so a
session that has drifted across a boundary receives the same green report it
would get at home and reads it as permission. The crossing was not one bad
decision. It was a chain of individually authorised steps, none of which
re-checked the boundary it had already crossed.

**Two rules the framework does have were kept in letter and emptied in
practice**, and both were found here rather than downstream. `disable-model-invocation`
blocks the Skill tool, not the behaviour: the session that reached for the
handoff skill was stopped, and the session that hand-wrote the same document
with `Write` was not — so the guard reached the compliant party alone. And a
worktree whose removal would have been refused was first cleaned until the
refusal could not fire, then removed without forcing: the letter kept, the
second opinion removed.

## Goal

What AEP ships stops asserting facts that are false, stops asserting an
enforcement it specifies no mechanism for, and gains the one rule that would
have kept a downstream session downstream — with the machinery to notice the
boundary rather than a sentence hoping somebody reads it.

## Constraints

- **A correction verified against a real tool version is the valuable artefact
  here.** Any change to the refresh path must not make it easier to overwrite
  one than to keep it.
- **The all-derived model for `.claude/scripts/` stands.** The enforcement gap
  is a missing entry on a page, not evidence the model is wrong; the audit's
  both-directions check is correct and stays.
- **The always-on tier is charged to every turn**, whether or not a stage runs.
  Rules land there only where they must fire before the first read, and the file
  count is part of the cost.
- **Nothing here may depend on the plugin being installed.** A teammate who
  clones a configured repository without it must be able to follow every rule.
- **`gt submit` behaviour stays second-hand.** Confirming it means publishing,
  which is the human's call, so it is recorded as an observation with its
  version and its observer rather than as a verified fact.

## Architecture

Four surfaces move, and they are independent of each other.

**The boundary is a prohibition plus a computed fact.** The prohibition is
always-on — it must fire before the first read in another repository, so it
cannot be path-scoped and cannot live in a skill. The machinery is the router's:
the position report gains *which repository governs this request*, and the stage
table refuses to enter a stage for one that is not this project's. That split
mirrors the Marker exactly — rule in the always-on tier, cache and computation in
the router — and it is what makes the boundary noticeable rather than merely
stated.

**The enforcement becomes a specified step, not a third script.** The comparison
the three policy files assert needs no new derived surface: regenerating and
diffing is two lines, it was proven downstream to pass on a clean tree and to
fail on a staged tamper, and it keeps the all-derived model intact. The scripts
page gains the step and the fixture that proves it; the fixture states that the
tamper is **staged**, because a working-tree tamper erases itself under the
regenerator and produces a confident wrong answer.

**The refresh path gains a return direction, and it is evidence rather than a
patch.** A repository that verifies a correction against a real tool version
writes it up and hands it back; the plugin's reference is corrected from that
record. This is the same shape the boundary rule already mandates — a report, not
a landed change — so the two interlock instead of competing.

**The two emptied rules are named as a pattern rather than patched case by
case.** Keeping a rule's letter while removing the check it exists to provide is
a violation of it, and producing a user-invoked skill's deliverable by hand is
invoking it without the user's decision. Both are standards about how work is
done, so they join `engineering.md` beside *never push and never publish* rather
than taking files of their own.

## Approach

The eight tickets gate almost nothing on each other, because the four surfaces
are independent. Only the two that both change the always-on tier are ordered,
and they are ordered to keep one amend from landing on top of the other's count.

The false tool facts go first: they mislead every configured repository today
and the corrected text already exists downstream. The audit's comparison method
goes early for the same reason it was ranked third downstream and argued up —
it is the only item whose failure mode is destructive rather than merely wrong.

Rejected and recorded in the Decisions rather than re-argued here: a third
derived script for the comparison, weakening the three claims instead of
supplying a mechanism, and a formal upstream-contribution path in place of a
handed-back report.

**Two findings are deliberately not planned as work.** The cost model that makes
replicating a skill cheaper than invoking it, and the asymmetry that lets a guard
reach only the session already obeying it, are recorded as a discussion. The
rule half of both is planned; the mechanism half has no fix that does not
contradict a decision already made, and inventing one here would be designing
past the grill.

## Acceptance criteria

- No shipped tool reference asserts a capability the named version does not have,
  and every entry that moved names the version it was checked against.
- A repository that verifies a correction has a specified way to return it, and
  the refresh path names both directions.
- The generated-index prohibition names the mechanism that enforces it, that
  mechanism is specified where the other derived surfaces are specified, and it
  ships to a configured repository rather than living in this one's private
  suite.
- The enforcement carries a fixture that fails on a staged tamper and passes on a
  clean tree, and the fixture says the tamper is staged.
- The audit states how an installed file is compared against its template, and
  states that whole-file drift is a comparison fault before it is a finding.
- The always-on tier carries the repository-boundary prohibition, and the router
  computes which repository governs a request and refuses a stage for one that
  does not.
- The always-on standards name both the letter-versus-check pattern and the
  hand-replication of a user-invoked skill.
- `/aep:handoff` ends with a copy-paste resume line naming the document's own
  path, and names the session scratchpad rather than the temporary directory
  generally.
- Every count of the always-on rule set agrees with what `/configure` installs.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

**The boundary rule refuses legitimate reads.** Diagnosing a claim about AEP
genuinely requires reading what AEP ships. Detection: the rule permits reading
explicitly and bounds only writing, planning, and entering a stage — and a ticket
that cannot state the difference in one sentence has got the rule wrong.

**The computed governing-repository fact reads as a gate nobody can pass.** A
stage that refuses on a wrong answer is worse than one that never asked.
Detection: the refusal names the repository it believes governs and the one it is
standing in, so a false negative is one line to see rather than a wall.

**The CI step becomes a claim nothing runs.** The gap being closed is exactly an
asserted enforcement with no mechanism, and specifying a step a repository never
wires up reproduces it one layer along. Detection: `/configure` installs it, the
audit re-checks it, and the fixture is run rather than described.

**The corrected tool entries go stale on the next release.** They are facts about
a version. Detection: each entry names the version it was checked against, so a
reader can tell a stale fact from a wrong one.

## Out of scope

- Any change to `gt submit`'s behaviour, or verifying it by publishing.
- The mechanism half of the compliance-cost finding — recorded as a discussion.
- Repairing rentable, or any other configured repository. What this produces
  reaches them through `/configure`.
