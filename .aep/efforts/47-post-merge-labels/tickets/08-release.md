---
status: resolved
blocked-by: [01, 04, 06, 07]
---

# chore(dist): release the merge-time half and reinstall this repository's tree

## Outcome

The release ships: the ladder with its owners, the reconciliation, the two
automation files, the offer, and the closing keyword. This repository reinstalls
onto its own release, and a repository upgrading is told what it will be offered
and that declining is recorded rather than re-asked.

## Acceptance Criteria

- [x] `node src/scripts/release.mjs 3.5.0` writes the version of record,
      re-baselines the stamps, syncs the plugin manifest, and regenerates the
      adapters, in that one command. Nothing is stamped by hand.
      One invocation: `released 3.5.0`, `8 artifacts changed since the last
      release`, `112 unchanged`. The eight are `policies/execution.md`, both seed
      forge references, `seed/rules/version-control.md`, and the four skills this
      effort edited. `src/stamps.json`, `src/protocol.md`, `specs.md` and
      `src/adapters/claude/.claude-plugin/plugin.json` are the only files it wrote,
      and no `aep:` line was touched by hand.
- [x] The bump is minor: a new shipped script, new seed files, and a widened
      normative contract, with nothing a consuming repository owns changing shape
      and no file of theirs ceasing to validate.
      Added: `scripts/reconcile.mjs`, `seed/automation/github.yml` and
      `gitlab.yml`. Widened: the specification's prohibition on labelling a
      natively modelled fact now excepts a `status:` family AEP maintains, which
      permits more than it did rather than less. Nothing repository-owned changes
      shape: the reinstall onto this repository replaced seven protocol-owned
      files and left every `rules/`, `contexts/`, `references/` and `efforts/`
      file alone, and `validate.mjs` reads `211 artifacts checked, no failures`
      afterwards.
- [x] The number is **3.5.0**, read off the record rather than pinned, which is
      what this criterion asked for from the beginning and what it has now been
      through three times.

      *3.5.0, as first written*, on the expectation that effort 48 merged 3.4.0
      first.

      *3.4.0, on 2026-08-26*, when the gate was read and shut: the record said
      3.3.0 and #50 was open. The human was given both sides and chose to release
      from here rather than wait. That was recorded, and then corrected, because
      effort 48 had already released 3.4.0 on its own branch and this had
      duplicated it rather than taken a number nobody held. Put back with the
      correction, the choice stood, on the understanding that #49 would merge
      first.

      *3.5.0 again, the same day*, because **#50 merged.** Effort 48 landed as
      `ab5073c` and the record on `main` now reads 3.4.0. This branch restacked
      onto it and, by the rule effort 48's own ticket 09 states, whichever merges
      second re-cuts. This effort is now the second, so it re-cuts. **The human's
      choice was not overridden; it was overtaken.** It was a choice about merge
      order, and the merge happened the other way.

      Read four ways after the restack: `src/protocol.md`, `specs.md`, the plugin
      manifest and the changelog all say 3.5.0, asserted by `every place the
      release is written agrees`. Effort 48's 3.4.0 entry and its `since: '3.4.0'`
      notice both survive underneath, unmodified.
- [x] Any notice this release declares is gated on `since: '3.5.0'`. A gate below
      the version being shipped is skipped by every tree already past it, which
      fails silently rather than loudly.
      One notice declared, `since: '3.5.0'`, at the head of `NOTICES`. It is the
      version being shipped rather than one below it, so no tree already past the
      gate skips it.
- [x] Requirement 6: the changelog carries the notice that `update` acts on — that
      the merge-time automation is offered, what it writes, and that a refusal is
      recorded as a decision rather than re-asked every run. It reads as an
      instruction to the reader, not as a changelog entry.

      *Corrected from "a declared deviation", which this criterion said until
      2026-08-26. Ticket 06 established that a refusal is an ordinary recorded
      decision: `policies/artifacts` reserves a declared deviation for variation
      entering a protocol-owned artifact through no extension point, and has
      `skills/update` report one on every run until the repository conforms, so
      filing a refusal as one would re-ask the settled question at every upgrade
      and contradict requirement 6. `plan.md` carries the correction; this
      criterion had not.*
      The 3.5.0 entry states all three: what is offered and on which forge, what
      each needs provisioned, that it is written only on acceptance and proposed
      as an addition where a labeler already exists, and that a refusal is
      recorded in the repository's own version-control rule and read before the
      offer is made again. Its `Upgrading` section addresses the reader directly
      and names the one thing an upgrade will not do for them: a forge reference
      is theirs, so the fetch is not added to it.
- [x] `node src/scripts/verify.mjs` passes, including the stamps baseline, so
      nothing this effort edited went unreleased.
      `2199 passed, 0 failed`, with `the failure path works. Seeded failure
      discarded` printed, which is the line that says the harness can still tell a
      failure from a pass. The five `stamps` failures carried through every wave
      of this effort are gone, which is what says nothing edited went unreleased.
- [x] `node .aep/scripts/validate.mjs` passes on this repository's reinstalled
      tree.
      `211 artifacts checked, no failures`, run after
      `install.mjs --into . --update` and `index.mjs`. Seven protocol-owned files
      were replaced and `scripts/reconcile.mjs` arrived, so the tree this
      repository runs on is the release it ships.
- [x] The changelog and README are governed text and read as such: no em dashes,
      no curly quotes, no decorative emoji, sentence-case headings.
      Both swept for the em dash and all four curly quotes: clean. The suite's own
      `CHANGELOG.md carries no em dash` and `README.md carries no em dash` pass.
      The README needed no edit: its script list is representative and already
      omits `frontier.mjs`, `position.mjs` and `scope.mjs`, so a seventh does not
      falsify it.

      *Raised, not taken: `CHANGELOG.md` holds a literal NUL byte at offset 13653,
      inside an older entry whose own subject is that byte. It predates this
      effort, `git` reports the file as binary because of it, and the suite is
      green regardless. It belongs to whoever owns that entry.*
- [x] Every acceptance criterion in `[[efforts/47-post-merge-labels/spec]]` is
      ticked, or the ticket that owns it is `obsolete` with its reason. Criterion
      11's half in this repository's own `rules/version-control.md` is read rather
      than asserted, since the suite covers shipped surfaces and that file is not
      one.
      All eight tickets are `resolved` with every box ticked and none `obsolete`:
      5, 5, 4, 10, 7, 6, 4 and 9 criteria. Criterion 11's repository-owned half
      was read rather than asserted: neither `.aep/rules/version-control.md` nor
      `src/seed/rules/version-control.md` still says the pull request body is one
      a human writes, and the repository's own rule puts the keyword on the commit
      that completes the work, with `Refs #<n>` while a branch is still being
      amended.

## It parked once, and here is how that ended

**Parked on 2026-08-26, unparked the same day.** Kept rather than deleted,
because the gate is the interesting part of this ticket and a record of it
working is worth more than a tidy file.

The third criterion said to read the version of record and stop where effort 48
had not merged. Both halves were read, and both said stop:

| | Read |
| --- | --- |
| `src/protocol.md`, `.aep/protocol.md`, `specs.md` | `3.3.0` |
| `origin/main:src/protocol.md` | `3.3.0` |
| pull request #50, effort 48 | `OPEN`, `mergedAt` null |

So the ticket stopped and said so, which is what it was written to do. The
question it could not answer for itself is which side of the gate to be on:
waiting for #50 and shipping 3.5.0 as pinned, or shipping from here and letting
effort 48 re-cut. **Both were put to the human and the human chose to ship from
here**, so the number is 3.4.0, the next minor over the record, and no version
goes unpublished.

**Effort 48 now re-cuts to 3.5.0.** That is its own ticket's work and none of it
is done here; this ticket touches no file of effort 48's and no branch but its
own.

## Relevant areas

`src/scripts/release.mjs`, `src/protocol.md`, `src/stamps.json`,
`.claude-plugin/`, `CHANGELOG.md`, `README.md`, and this repository's `.aep/`
tree.

## Constraints

**The baseline is re-cut once, here.** A mid-effort re-cut tells the suite that
everything in the tree is the new reference point, which is exactly how an
unreleased edit gets hidden.

**Reinstalling this repository's own tree is the dogfood the suite already
asserts.** A release that would ask its own tree for a conversion would ask
everybody's.

## Notes

This repository has no `.github/workflows/`, so reinstalling is also the first
time the offer meets a real repository rather than a fixture. Whether it accepts
is the human's, and a refusal recorded here is the mechanism working rather than
the effort failing.
