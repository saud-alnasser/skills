---
status: resolved
blocked-by: [05]
---

# feat(skills): install and update offer the merge-time job, once

## Outcome

Install offers the automation beside the label vocabulary it already offers, and
update offers it to a repository that reached 3.x before this existed. Both show
the exact text and write nothing on a refusal, and a refusal is recorded as a
decision in the repository's own version-control rule, so the next run reads it
instead of asking again.

## Acceptance Criteria

- [x] Criterion 6: install offers the automation and writes it only on
      acceptance, opt-in at the installer the way a runtime adapter already is,
      and never by default. Update makes the same offer on a fixture that
      predates it.
      `install fixture` passes `install offers the merge-time job beside the label
      vocabulary`, `the offer step writes only on acceptance, opt-in at the
      installer`, `a refusal leaves no workflow file behind` — which installs with
      no flag and fails if `.github/` or `.gitlab-ci.yml` appears — `accepting
      writes the job, byte for byte what ships`, and `a tree that predates the job
      gets the same offer on update`.
- [x] Criterion 6: a refusal leaves no workflow file and records the decision
      into `rules/version-control.md`. A second run reads that record and does
      not re-offer, and a fixture exercises the suppression rather than only the
      absence of a default write. Nothing reports the refusal as a deviation:
      the offer names refusal as a supported path, so it is the extension point
      rather than variation with nowhere to enter.
      The loop runs end to end in two fixtures that are each other's control.
      `a recorded decision withholds the offer, and writes nothing` appends the
      installer's own `DECLINED` sentence to the fixture's rule, runs
      `--update --automation github`, and fails if any workflow appears, if the
      output does not say `Declined here already`, or if it made the offer anyway.
      `removing the record is what asks again` restores the rule and reruns, and
      requires the job to be written — so the suppression is pinned to the record
      rather than to anything else about the second run. The sentence is read off
      `install.mjs` rather than pasted, so skill and script cannot drift.
      `the offer step calls a refusal a decision and not a deviation` and `the
      offer step claims no deviation status anywhere in it` cover the last
      sentence.
- [x] Criterion 7: where the repository already has a workflow that assigns
      labels, the offer proposes an addition to that file, with the exact text,
      and creates no second one. A fixture carrying a labeler gets a proposal
      rather than a new file.
      `a repository already running a labeler gets a proposal, not a second file`,
      `the proposal quotes every line of the job, and no key the file already
      has`, `a workflow in a subdirectory is read where it actually is`, and
      `several workflows assigning labels are all named, and the one read is
      said`. The proposal is the job alone rather than a trigger spliced in:
      `the shipped job guards itself rather than relying on the file it sits in`
      pins the job-level condition that makes the addition safe in a file
      triggering on `pull_request_target`.
- [x] Requirement 4: the GitLab offer states the `api`-scoped token it needs
      before it says anything else, so a repository that declines knows what it
      declined.
      `the GitLab offer states its api-scoped token before anything else` on the
      fixture, `seed/automation/gitlab.yml names its api-scoped token before
      anything else` on the shipped file, and `the GitHub offer is the other
      offer, needing nothing provisioned` keeps the two offers distinguishable.
- [x] Criterion 9: neither offer adds a tracker call to a path that had none. The
      offer is text and a write; nothing in it reads a tracker to decide.
      `the installer starts git and no other process` sweeps every child-process
      entry point in `install.mjs` and throws on a command built from a variable
      rather than passing it, so an unreadable call fails the same way an
      offending one does. `the offer step adds no tracker call to a path that had
      none` and `update reads the tree for this and never a tracker` cover the
      prose. Ticket 26's prohibition holds.
- [x] Requirement 6: `update.md`'s notice step acts on this rather than printing
      it, and an offer that cannot be settled inside the run is reported as
      outstanding, naming what is left.
      `update makes the same offer inside the step that acts on notices`, `update
      reports an offer it cannot settle as outstanding, naming what is left`, and
      `update does not re-offer where the record already stands`.

## Relevant areas

`src/skills/install.md`, step 8 and its neighbourhood, which already carries the
shape of an offer that shows exact strings and creates nothing on a refusal.
`src/skills/update.md`, the notice step. Not the step that reports declared
deviations, which is the instrument this ticket was corrected away from.
`src/scripts/install.mjs`, the opt-in write, mirroring how adapters are
requested. `src/scripts/verify.mjs`, the `install fixture` section.

## Constraints

**Files outside `.aep/` belong to the repository.** A workflow is executable, so
it is a larger thing to write into somebody's tree than a reference file, and the
rule install already applies to adapters is not relaxed for it.

**The offer adds a job.** It does not modernise an existing action, swap one out,
or reconcile a repository's label globs.

**The refusal's home is a rule.** Not a context, which orients and does not
decide, and not a state file under `.aep/`, which would be a new primitive nothing
else uses and the first step toward the hidden database the protocol forbids.
That nothing can grep a paragraph is the cost, and it is the right one: the rule
is where the next run is already reading.

*The home is unchanged and the instrument is not.* This ticket first said a
declared deviation. `[[policies/artifacts]]` reserves that for variation entering
a protocol-owned artifact through no extension point, and has `[[skills/update]]`
report one on every run until the repository conforms, so declaring a refusal one
would re-ask the settled question every upgrade and contradict requirement 6.
Both review axes reached this independently during the build and the human chose
the correction.

## Notes

Adding to an existing labeler contests nothing. All ten workflows the research
observed trigger on `pull_request_target` with the default activity types, which
exclude `closed`, and `sync-labels` provably leaves labels outside its own config
alone.

This repository has no `.github/workflows/`, so it receives the offer as a new
file on its next update and is its own first fixture. Whether it accepts is the
human's.
