---
title: 'fix(configure): the tool references stop asserting false facts, and a verified correction has a way back'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

The shipped GitHub reference states that `gh` has **no sub-issue subcommand** and
**no blocking subcommand**, and routes the reader to the REST API instead. Both
are false. Checked against `gh 2.96.0`: `gh issue create` takes `--parent`,
`--blocked-by` and `--blocking`; `gh issue edit` takes `--add-sub-issue`,
`--remove-sub-issue`, `--add-blocked-by`, `--remove-blocked-by`, `--add-blocking`,
`--remove-blocking` and `--remove-parent`. A reader following the reference does
by hand, through an API, what one flag does — and does it believing the framework
checked.

The stacking reference records the pull request body as *not documented*, so
nothing may depend on it. **That wording is correct and stays** — it was going to
be replaced here with a stronger claim, and the stronger claim is false. A
configured repository observed `gt 1.8.6` leaving the body as an unfilled
template with the commit body reaching neither; submitting from this repository
on the same version prefilled the body from the commit in full. Two observations
of one version disagree, and the shipped wording is the only statement consistent
with both. `.claude/evidence/drift/2026-08-10-gt-submit-does-prefill-the-pull-request-body.md`
records the check.

What the stacking reference genuinely lacks is smaller: it does not say that
submit behaviour is configurable through `gt config`'s submit settings, which is
the likeliest reason two runs of one version disagreed, and it omits that a
non-interactive submit opens new pull requests as drafts unless `--publish` is
passed.

Behind both: refreshing a derived reference is defined as one-directional. The
audit re-checks an installed file against the repository it describes, and that is
the only path — so a repository that verified a correction against a real tool
version has nowhere to send it, and the shipped reference keeps asserting the
false version. A configured repository's corrected copies are already ahead of
the plugin's, and nothing can carry them back.

## Outcome

Every entry that moved states what the named version actually does, and names
that version, so a later reader can tell a fact that has gone stale from one that
was wrong when written.

The stacking entry keeps its refusal to claim what the body will hold, and gains
the reason that refusal is right: the behaviour is configurable, so a fact
checked on one machine is not a fact about the version. Where an entry does
record an observation, it names the version and says it was observed rather than
verified.

A repository that verifies a correction has a specified way to return it, and the
refresh section describes both directions rather than one. The return is a
written record handed back, not a patch applied upstream by whoever found it —
the same shape the repository-boundary rule requires of any finding about another
repository, so the two interlock rather than competing.

## Acceptance

- No shipped tool reference asserts that a capability is absent when the named
  version has it.
- Every entry corrected here names the tool version it was checked against.
- The stacking entry still refuses to state what a submit puts in the body, and
  says why — the behaviour is configurable, so one machine's answer is not the
  version's.
- The stacking entry states that a non-interactive submit creates drafts, and
  what opts out.
- No entry promotes a single observation to a verified fact; one that records an
  observation names its version and says which it is.
- The refresh section names both directions, and the upstream direction produces a
  record rather than an edit made in the other repository.
- The suite fails when a shipped reference denies a capability its own named
  version documents, confirmed against a deliberate reintroduction and then
  restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
