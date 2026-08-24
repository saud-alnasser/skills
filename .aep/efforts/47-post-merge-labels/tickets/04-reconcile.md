---
status: resolved
blocked-by: [03]
---

# feat(scripts): reconcile computes tracker drift from an observation it is handed

## Outcome

`scripts/reconcile.mjs` takes the forge's own JSON, which the caller already
fetched, computes expected against observed from `spec.md` and the ladder table,
and prints the disagreement. It makes no network call of its own — which is what
keeps requirement 9 true by shape rather than by a rule somebody has to remember.

## Acceptance Criteria

- [x] Requirement 8 / criterion 8: run against this repository's tree with a
      recorded observation, it prints that effort 45's objects and its spec agree;
      move a label in the recorded observation and it prints the drift. Which
      efforts disagree is computed and quoted, never judged.
      `effort 45 agrees against a recorded observation of its own objects` and
      `moving a label in the observation prints the drift`, the second changing
      one label and nothing else, so nothing but the label can account for the
      verdict changing. Run live against the real tree and a real fetch it printed
      `agree 45-aep-3 status: done`, and found genuine drift nobody had noticed:
      `drift 54-working-surface issue 54 status: in review want status: done` and
      the same for 56, which is the exact defect this effort exists to remove.
- [x] Criterion 3: an observation whose change request is closed without merging
      expects the terminal value, and `in review` does not survive it.
      `a change request closed without merging expects the terminal value`: both
      objects are reported wanting `status: done`, and the assertion fails if any
      line for that effort reads `agree`.
- [x] Requirement 8: an effort whose spec reads `accepted` is not reported as
      drift whichever of the two labels that status reaches. `accepted` projects
      onto both `status: ready` and `status: in progress`, because taking the
      first ticket moves the label without moving the field, so a consumer that
      takes the first matching row reports every run in flight as drift. The
      fixture is an effort mid-run, and this effort is one.
      Two assertions, one per label, both against effort 47, which is this one:
      `an effort mid-run showing status: ready is not drift` and
      `an effort mid-run showing status: in progress is not drift`. A third,
      `the two labels accepted reaches are the two the ladder gives it`, reads the
      pair off `STATUS_LADDER` rather than restating it, so a ladder that stopped
      giving `accepted` two rows fails here instead of silently narrowing.
- [x] Criterion 11: an issue still open after its change request merged is
      reported as its own finding, demonstrated against a recorded observation of
      #51 and #52.
      `an issue still open after its change request merged is its own finding`
      records #51 and #52 as they stood on 2026-08-24, after the merge and before
      a person closed the issue by hand, and gets
      `drift 51-branch-scope issue 51 open after change-request 52 merged` at exit
      1. `an issue closed behind its merged change request is not that finding`
      is the control: the same observation with the issue closed produces no such
      line.
- [x] Requirement 10 / criterion 10: no observation supplied is exit 0 with every
      effort `unobserved`. A repository with no tracker runs it and learns
      nothing, which is the answer rather than a fault.
      `no observation is exit 0 with every effort unobserved` fails on an empty
      output as well as on a non-`unobserved` line, so silence cannot pass for
      the answer. `an effort with no observed object is unobserved rather than
      agreeing` covers the same distinction inside a partial observation.
- [x] Criterion 9: the `forbidden` sweep is extended so `reconcile.mjs` is inside
      it, and the script carries no forge invocation. Fire-checked by adding a
      `gh` call, confirming it is actually in the file the sweep reads, and
      watching the sweep name it. This is the guard the plan singles out: ticket
      26's version once passed green because an edit had moved its subject out
      from under it.
      `no installed script starts a forge CLI` sweeps every process start in every
      script in `PAYLOAD_SCRIPTS`, reading the code rather than the prose, because
      each script's header explains what it does not call and a text scan for
      `gh` matches the sentence saying so. A command assembled from a variable
      throws rather than passing. Fire-check: `execFileSync('gh', ['issue',
      'list'])` added to `main()`, confirmed present at `reconcile.mjs:233` and
      confirmed that `PAYLOAD_SCRIPTS` contains `reconcile.mjs`, then
      `[forbidden] no installed script starts a forge CLI: reconcile.mjs starts gh`.
      Reverted, and the section returns to `11 passed, 0 failed`. The subject is
      pinned separately by `the sweep covers reconcile.mjs by name`, which is what
      ticket 26's version lacked.
- [x] Requirement 8: the interface matches `frontier.mjs` — pure functions plus a
      `main()`, `--root`, one line per finding, exit 0 for agreement, exit 1 for
      disagreement, exit 2 for a tree or an observation that could not be read.
      Six exported pure functions and a `main()` guarded by the same
      `import.meta.url` comparison `frontier.mjs` uses. Exit 0 asserted on
      agreement and on no observation, exit 1 on drift, and exit 2 pinned on three
      separate causes: a root resolving to no tree, a tree with no efforts
      directory, and an observation that is not JSON. The middle one also fails if
      anything was printed to stdout, so an unreadable tree cannot look like one
      that agreed.
- [x] Requirement 8: the parser says which forge's shape it read, so an
      unrecognised shape reports that it recognised nothing rather than returning
      a confident empty answer.
      `the parser says it read GitHub, and counts what it read` pins the `read`
      line, `the parser reads GitLab shapes and says so` runs the same effort
      through `iid`, lower-case states, string labels and `closesIssues` and gets
      the same verdict, and `a shape matching neither forge reports that it
      recognised nothing` requires exit 2, the message, and an empty stdout.
      The `read` line is one verb more than `plan.md`'s interface listed. It was
      added rather than sent to stderr because a caller that cannot see which
      shape was read cannot tell a forge-agnostic answer from a misread one, and
      that is the thing this requirement asks to be visible.
- [x] Requirement 8: `src/seed/references/github.md` and `gitlab.md` carry the
      exact fetch that produces the observation and how the issue and
      change-request lists are combined, so the two-command invocation is written
      down where the caller already reads.
      Both gained a `The observation reconcile.mjs reads` subsection inside
      `## Reading`. GitHub carries the two `--json` fetches and a combining
      pipeline needing nothing but `gh`. GitLab carries its two `--output json`
      lists and states the difference rather than mirroring the GitHub text: a
      merge request list carries no link to the issue it closes, so
      `closes_issues` is its own call, one per merge request. The GitLab half is
      written from documentation and not from a run, which is the risk `spec.md`
      already records for everything GitLab in this effort.
- [x] `reconcile.mjs` is registered as a payload script and lands in an installed
      tree.
      `reconcile.mjs is a payload script and not a build-only one` and
      `reconcile.mjs is in the shipped manifest`. Installed into a fresh fixture,
      `.aep/scripts/` lists it beside the other six, and `node
      .aep/scripts/reconcile.mjs` run from that tree exits 0 having found nothing
      to say, which is the correct answer for a repository with no efforts.

## Relevant areas

`src/scripts/reconcile.mjs`, new. `src/scripts/frontier.mjs` is the shape to copy
— it reads files, prints one line per finding, and returns an exit code that means
something. `src/scripts/payload.mjs` for the script registration.
`src/scripts/verify.mjs`, a new `reconcile` section plus the `forbidden` sweep.
`src/seed/references/github.md` and `gitlab.md`, their `Reading` sections.

## Constraints

**It fetches nothing.** This is the component that exists so a repository which
declined the offer still converges, and it is therefore the one component that
must not reach for a tracker. A `gh` or `glab` call here would make the fallback
carry the exact cost it was built to avoid.

**The file wins.** Drift is reported as a label to correct, never as a spec to
edit, including when the drift was a human's edit.

**Derived families only.** `priority:` and the inviting flags are not reported
on. Re-deriving an initial label overwrites the person who set it.

**The observation in the suite is a recorded fixture, not a live fetch.** The
plan flags this as a live risk: the first fixture that reaches for `gh` is the
one that makes the suite fail offline.

## Notes

The forge references carry the fetch; the script takes that JSON unmodified,
which is what makes it forge-agnostic without either forge's CLI being present.

An observation is stale by the time it is compared. That is bounded and
acceptable: a stale comparison reports a disagreement that a re-run clears.
