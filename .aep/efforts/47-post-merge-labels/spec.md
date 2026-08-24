---
status: implemented
---

# Problem

`[[policies/execution]]` ends the label ladder with a row nothing executes:

| The effort | Issue | Pull request |
| --- | --- | --- |
| merged | closed by the pull request | `status: done` |

Every other derived label is re-synced "on every write to the issue or the pull
request". After `[[skills/implement]]`'s close there are no more writes: step 3
moves both objects to `status: in review`, marks the pull request ready, and the
run ends. The human then merges, and the merge is deliberately theirs — the
protocol says so in three places. So the last agent act in an effort's life
leaves both objects saying `in review`, permanently, and the row that would
correct it has no owner.

This is not a hypothetical. On this repository's first effort opened under the
3.0 ladder, pull request #46 merged at 15:47:25 and issue #45 still read
`status: in review` until a person removed it by hand at 15:54:29. The label was
right only because somebody noticed.

**The row's premise is unowned too, not only its label half.** "Closed by the
pull request" is a claim about a closing keyword, and nothing shipped puts one
there. `[[skills/specify]]` fixes exactly what the runner writes into the body it
opens, the approach and each ticket's criteria as checkboxes, and never mentions
the keyword. The only shipped text that knows the keyword exists is the seeded
forge reference, which documents the syntax, and the seeded version-control rule,
which says where it belongs. Neither is reached while the body is being written.

So the issue closes on merge when somebody happens to remember, and not
otherwise. Pull request #46 carried `Closes #45` and issue #45 closed itself;
pull request #52 carried `Refs #51`, which is the commit form, and issue #51
survived its own merge on 2026-08-24 until a person closed it by hand. Same
protocol, different luck. This repository's own rule made the omission easy to
walk into: it says the keyword "belongs in the pull request body, which a human
writes", which stopped being true when the runner started opening that body.

The cost is that `status:` stops being trustworthy at exactly the point people
use it. An issue list filtered on `status: in review` returns finished work, and
the family that exists so a scanner can see effort state without opening a file
is wrong for every effort that ever completed.

**A second, older contradiction sits underneath it.** `specs.md` §478 says a
conforming implementation MUST NOT create a label for a fact the tracker already
models, and merged and closed are both modelled natively. Taken literally, that
forbids the `status: done` this repository's own label vocabulary defines as
"merged, or completed without a merge". Two normative documents disagree about
whether the terminal value should exist at all, and the disagreement has to be
settled here rather than inherited by whatever gets built.

# Goal

When a human merges, the tracker reflects it without anybody remembering to make
it so — and where nothing automated is in place, the next AEP run that touches
the tracker corrects the drift rather than adding to it.

# Scope

The `merged` row gains owners, at two levels:

- **a forge-native job, firing at merge**, offered when AEP is installed or
  updated, so the correction is immediate and needs no later agent run;
- **a computed reconciliation**, always present, so a repository that declined
  the offer or predates it still converges.

Plus the keyword the row's premise rests on, written by the runner rather than
remembered by a person.

Plus the normative repair the two above depend on: `specs.md` and
`[[policies/execution]]` saying the same thing about the terminal `status:`
value, and the ladder covering a change request closed without merging as well as
one merged.

# Requirements

1. **The merged row names its owners.** `[[policies/execution]]`'s label ladder
   states, for the terminal row, what moves the label and what corrects it if
   that did not happen. No row in the ladder is left without one.

2. **`specs.md` stops contradicting the ladder.** §478's prohibition is amended
   so that a `status:` family AEP maintains keeps its terminal value, with the
   reason stated: a family with a hole cannot be filtered on, and the value is a
   projection of the effort's state rather than a second copy of the forge's.

3. **Closed without merging reaches the same terminal value.** This repository's
   own `status: done` description already reads "merged, or completed without a
   merge". Both the automation and the fallback treat an abandoned change request
   the same way, so `flag: wontfix` is not the only trace an abandoned effort
   leaves.

4. **A merge-time automation ships for every tracker AEP seeds a reference
   for** — today GitHub and GitLab. Each one is sized to what that forge actually
   requires, and the GitLab offer states up front that it needs a project access
   token with `api` scope, because its job token cannot write to a merge request
   and no pipeline fires at merge
   (`evidence/research/merge-time-label-automation`).

5. **A new tracker reference brings its automation with it.** The rule that ties
   the two together is written down, so a later forge reference added to
   `src/seed/references/` does not silently ship without the merge-time half.

6. **`[[skills/install]]` and `[[skills/update]]` both offer it.** Install offers
   it beside the label vocabulary it already offers at step 8; update offers it
   to a repository that reached 3.x before this existed. Both ask, and a refusal
   is recorded rather than re-asked every run.

7. **An existing labeler is extended, never duplicated.** Where the repository
   already has a workflow that assigns labels, the merge-time job is proposed as
   an addition to that file. Ten repositories on this machine carry one, all
   triggered on `pull_request_target` with the default activity types, none of
   which include `closed`, so the addition contests nothing
   (`evidence/research/merge-time-label-automation`).

8. **A shipped script computes the drift.** Which efforts have tracker objects
   disagreeing with their `spec.md` is computed and quoted, never judged, in the
   shape `frontier.mjs` and `position.mjs` already establish.

9. **The fallback costs no run a tracker call it was not already making.** The
   reconciliation runs where a run is already reaching the tracker, and a run
   that reaches no tracker gains no unconditional call to one, which is the
   constraint ticket 26 established.

10. **Where there is no tracker, none of this fires.** The no-tracker posture is
    unchanged: no issue, no pull request, no labels, and nothing new to skip.

11. **The runner writes the closing keyword the merged row depends on, where
    that repository's shape puts it.** `[[rules/version-control]]` already
    carries the two rows: a repository merging a branch through a pull request a
    human writes puts the keyword in the body, and a repository submitting
    stacked changes puts it on the commit that completes the work. The runner
    reads that row rather than assuming one, so the issue closes on merge rather
    than when somebody remembers — `[[skills/specify]]` owns the body half when
    it opens the pull request, and `[[skills/implement]]` owns the commit half on
    the amend that finishes the work. The reconciliation in requirement 8 covers
    an issue left open after its change request merged, the same way it covers a
    label left stale.

# Acceptance Criteria

1. `policies/execution.md`'s ladder has an owner named for every row including
   the terminal one, and `verify.mjs` fails if the terminal row names none.
2. `specs.md` carries the amended clause; a reader can hold §478 and the ladder
   at once without either being wrong. `verify.mjs` asserts the ladder against
   the amended clause rather than the old one.
3. Given a change request closed unmerged, both the automation and the drift
   script report the terminal value, and neither leaves `in review` standing.
4. A GitHub workflow exists that fires on merge, guards on the merge actually
   having happened, and moves `status:` on both the change request and the issue
   it closes. A GitLab counterpart exists, and its own text names the
   `api`-scoped token it requires before anything else.
5. Adding a forge reference to `src/seed/references/` without its merge-time
   automation fails `verify.mjs`.
6. Running install on a fixture repository offers the automation and writes it
   only on acceptance; running update on a 3.0 fixture makes the same offer. A
   refusal leaves no workflow file and is not re-offered on the next run.
7. Given a repository with an existing labeler workflow, the offer proposes a
   change to that file, with the exact text, and does not create a second one.
8. The script runs against this repository and prints, for effort 45, that its
   objects and its spec now agree, and prints the disagreement when a label is
   moved by hand to something else.
9. No skill gains a tracker call on a path that had none. Checkable by reading
   the diff for tracker invocations added outside a branch that has already
   established a tracker exists.
10. A fixture with no tracker runs install, update, and the drift script, and
    none of them reaches for a tracker or reports a missing one as a fault.
11. `skills/specify.md` and `skills/implement.md` each state which half of the
    closing keyword they write, and that which half applies is read from
    `[[rules/version-control]]` rather than assumed. `verify.mjs` fails if either
    statement goes missing, and fails if either skill names one shape as the only
    one. Neither version-control rule still says the pull request body is one a
    human writes. The drift script reports an effort whose issue is open after
    its change request merged, demonstrated against #51 and #52.

# Constraints

- **AEP stays a filesystem protocol.** A workflow file is written into the
  repository once, on acceptance, and nothing in `.aep/` depends on it running.
  The fallback is what makes that true: the automation is an optimisation over
  the reconciliation, never a prerequisite for it. Without this, a declined offer
  would leave the protocol broken rather than slower.
- **Files outside `.aep/` belong to the repository**, so the offer asks first and
  shows exact strings. This is `[[skills/install]]`'s existing rule for adapters
  and is not relaxed for a workflow, which is executable and therefore a larger
  thing to write into someone's repository than a reference file.
- **The file wins when a label disagrees with it.** Reconciliation corrects the
  label to match `spec.md`, never the reverse, including when the drift was a
  human's edit (`[[policies/authority]]`).
- **`priority:` and the inviting flags stay initial.** The drift script reports
  on derived families only. Re-deriving an initial label overwrites the person
  who set it, which is the failure the derived and initial split exists to
  prevent.
- **No label AEP sets names AEP**, and the automation matches the vocabulary
  already in the repository: separator, casing, and the emoji prefix this
  repository's tracker uses.

# Out of Scope

- **Merging.** Nothing here moves toward the agent merging anything. The merge
  stays the human's, and this effort exists precisely because it is.
- **The other derived families being computed twice.** The ten labeler workflows
  on this machine already assign `type:` and `flag: dependencies` from the pull
  request title and the diff, which is the same derivation
  `[[policies/execution]]` has the agent perform. Whether the agent should stand
  down where CI already does it is a real question and a separate effort; this
  one touches `status:` only.
- **Replacing or upgrading an existing labeler.** The offer adds a job. It does
  not modernise `actions/labeler@v7`, swap out
  `mauroalderete/action-assign-labels@v1`, or reconcile a repository's label
  globs.
- **Bitbucket, Gitea, Forgejo, and Jira.** AEP seeds no forge reference for any
  of them. Requirement 5 is what makes adding one later carry its automation, and
  it is deliberately the mechanism rather than a list to extend now.
- **A GitLab token being provisioned for the human.** The offer names what is
  needed and stops. Creating or storing a credential on somebody's behalf is not
  something an installer should do.
- **Backfilling every already-merged effort.** The drift script reports; whether
  a repository wants its history corrected is the human's call, and a sweep that
  rewrote closed objects would be a tracker write to shared data nobody asked
  for.

# Assumptions

- Issue #45 and pull request #46 are the only effort ever opened under the 3.0
  ladder, so this is a gap in the design rather than a regression in it. Pull
  requests #40 to #44 carry no labels at all, which is consistent with them
  predating the ladder.
- A repository running AEP will normally see another AEP run after an effort
  merges, which is what makes the fallback effective in practice rather than only
  in principle. A repository where AEP is installed and never used again has no
  reader for the labels either.

# Open Questions

- Whether the merge-time automation should also correct `size:`, which is
  computed at the close from a diff that can change between then and the merge.
  Raised because it is the same class of staleness; not answered, because it
  costs nothing to defer and widening now would blur what this effort is for.

# Risks

- **The offer is refused everywhere and the fallback carries the whole load.**
  Shows up as labels that are correct but late. Acceptable, and the reason the
  fallback is a requirement rather than a nicety.
- **The GitLab half ships unverified.** Nothing in this repository runs on
  GitLab, so its workflow is written from documentation rather than from a
  passing run. Shows up as a job that fails on first use in somebody's
  repository. Mitigated by the offer naming its token requirement in its own
  text, so a failure is legible rather than mysterious.
- **A repository's existing labeler is edited badly.** Shows up as a broken
  workflow in a file AEP did not author. Mitigated by proposing the exact text
  and never writing without acceptance, and bounded by requirement 7 adding a job
  rather than restructuring the file.
