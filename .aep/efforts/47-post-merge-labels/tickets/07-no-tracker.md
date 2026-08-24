---
status: resolved
blocked-by: [04, 06]
---

# test(verify): the no-tracker posture survives everything this effort added

## Outcome

A fixture with no tracker runs install, update, and the drift script, and none of
them reaches for a tracker or reports the absence as a fault. The posture is
unchanged by this effort, and that is asserted rather than assumed.

## Acceptance Criteria

- [x] Criterion 10: the no-tracker fixture runs install, no automation is offered
      and none is written, and the skip is stated rather than silent.
      `the fixture genuinely has no tracker, and the absence is stated` requires
      `references/github.md (not detected)` and the GitLab line in the output, and
      fails if either reference reached the tree anyway. `install on a no-tracker
      fixture offers no automation and writes none` requires `protocol files
      written` in the output before it checks anything, so the three negatives
      cannot pass on an install that never ran.
- [x] Criterion 10: the same fixture runs update and gains nothing it can never
      settle — no notice it cannot act on, no outstanding item with no path to
      being closed.
      `update on a no-tracker fixture gains nothing it can never settle` gates on
      `seeds skipped` for the same reason, then fails on any workflow written, on
      the word outstanding anywhere in the output, and on the job being offered.
      An upgrade that handed a tracker-less repository a job it can never accept
      would report the same thing on every run for ever.
- [x] Criterion 10: `reconcile.mjs` runs in that fixture and exits 0 with every
      effort `unobserved`.
      `reconcile runs in that fixture and is exit 0 with every effort unobserved`
      installs, writes one effort into the installed tree, and runs the script
      with no observation. It fails on an empty stdout, on any line that is not
      `unobserved`, and on a non-zero exit.
- [x] Requirement 10: no issue, no pull request, no labels, and nothing new to
      skip. Each of the three paths is asserted to have actually been exercised,
      and each assertion is fire-checked by putting a tracker read back into that
      path and watching it go red by name.
      No tracker object can be created because no path can reach a forge: `no path
      this effort added can reach a forge CLI` sweeps the process starts of
      `install.mjs` and `reconcile.mjs` and requires every literal command to be
      `git`. Nothing new is skipped: step 9 skips exactly where step 8 already
      did, pinned by `the offer step gates on there being a tracker at all`.

      Four fire-checks, each confirmed applied before the suite ran and each
      reverted after, and each named its own assertion:

      | Perturbed | Named |
      | --- | --- |
      | `execFileSync('gh', ['label', 'list'])` into `offerAutomation`, at `install.mjs:570` | `no path this effort added can reach a forge CLI: install.mjs starts gh` |
      | the automation list defaulting to `['github']` instead of empty | `install on a no-tracker fixture offers no automation and writes none: wrote effort-status.yml`, and the update assertion the same way |
      | `unobserved` counted as a disagreement in the exit code | `reconcile runs in that fixture and is exit 0 with every effort unobserved: exited 1; learning nothing is not a fault` |
      | `detected()` returning true unconditionally | `the fixture genuinely has no tracker, and the absence is stated: references/github.md was skipped silently, or not skipped` |

      The first also tripped ticket 26's own sweep, `the installer starts git and
      no other process`, which is the corroboration worth having: two independently
      written guards over the same prohibition, both firing on one edit.

## Relevant areas

`src/scripts/verify.mjs` — the `install fixture` section, and the `reconcile`
section this effort added.

## Constraints

**No network in a fixture, ever.** The plan names this as a live risk: a later
ticket reaching for `gh` inside a fixture to confirm a label was created is how
the suite starts failing offline, and it will look like thoroughness while it does
it.

**Assert the path ran, not only that nothing happened.** A guard that passes
because the code never executed is indistinguishable from one that passes because
the code behaved, and this whole ticket is guards.

## Notes

Split out rather than folded into either ticket it depends on, because it covers a
posture across three paths and neither of those tickets owns more than half of it.
Folded into one, the other half would be nobody's.
