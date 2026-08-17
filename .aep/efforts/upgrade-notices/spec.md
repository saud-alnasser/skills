---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: spec
status: implemented
---

# Problem

An upgrade moves files and says nothing about what the release *means*.

`install.mjs --update` replaces protocol-owned artifacts, applies declared
`MOVES`, repairs links, and reports all of it. That covers everything a release
does **to the tree**. It covers nothing a release requires **of the reader** —
and some releases require something.

The `tracker-labels` effort is the proof. It added a section to the GitHub and
GitLab references where a repository records what carries its effort. Those
references are seeded, and **an upgrade never re-seeds a reference the repository
has corrected** — asserted, deliberately, and right. So every existing
installation gets the new protocol behaviour and never gets the section that
behaviour writes into. The effort caught it and answered it inside its own skill
note (R10), which works for that one case and is not a mechanism.

Three costs:

- **Per-release knowledge has no home.** *If you had X, check Y* is real, it is
  known at release time, and today it is written in a changelog the consuming
  repository never receives.
- **`CHANGELOG.md` does not ship.** `PAYLOAD_FILES` is `['protocol.md']`. A
  repository running `/update` has no changelog to read, so "read the changelog"
  is advice that cannot be followed where it is needed.
- **The next release repeats it.** Nothing accumulates. Each release that needs
  to tell the reader something invents a place to say it, or does not say it.

# Goal

A release can declare **what a reader must check when crossing it**, and an
upgrade reports exactly the notices for the releases actually being crossed —
computed from the tree's declared release, not judged, and not shown to a
repository the notice does not apply to.

# Scope

The mechanism, its report, the skill that acts on it, and the first notice.

# Requirements

1. **A release MAY declare notices**, each carrying the release it is `since:`
   and one statement of what to check and why.
2. **An upgrade reports exactly the applicable ones** — those whose `since:`
   the installed tree precedes. A tree already at or past the release sees
   nothing; a tree declaring nothing is treated as predating everything, matching
   how `MOVES` already resolves the same question.
3. **The report is prominent.** A notice is the one part of the output that
   requires a human to do something, so it is not a line among the file counts.
4. **`--dry-run` previews notices** exactly as a real run reports them.
5. **`/update` acts on them** — reads each, does what it says or reports why it
   cannot, and never treats reporting as having handled it.
6. **Release 2.3.0 declares the first notice**: a repository whose tracker
   reference predates it will not be re-seeded, so the section that records what
   carries an effort has to arrive by hand or on the next `/tasks`.
7. **The specification states it and the suite asserts it**, including that a
   current tree is shown nothing.

# Acceptance Criteria

- [x] R1 — `NOTICES` is declared beside `MOVES` in `payload.mjs`, each entry
      carrying `since` and the text.
- [x] R2 — the same `precedes(declared, since)` predicate gates them, so notices
      and moves cannot disagree about which releases a tree is crossing.
- [x] R3 — the upgrade prints applicable notices under their own heading, after
      the file lists, where the reader is looking when the run ends.
- [x] R4 — a `--dry-run` upgrade of an old tree prints the same notices.
- [x] R5 — `skills/update.md` states that a notice is acted on, not merely read,
      and that one it cannot act on is reported rather than dropped.
- [x] R6 — a 2.3.0 notice exists naming the tracker-reference section.
- [x] R7 — `specs.md` states it, gains a conformance line, and `verify.mjs`
      asserts: an old tree receives the notice, **a current tree receives none**,
      and a dry run previews it. Each assertion perturbed and observed failing.

# Constraints

- **Computed, never judged.** The set of notices is a function of two release
  numbers. Nothing decides at runtime whether a notice is *relevant*.
- **A notice is not a changelog entry.** It says what to check; it does not
  narrate the release. A release with nothing to ask of the reader declares no
  notice, and most will not.
- **Notices are protocol-owned.** They describe AEP releases. A repository does
  not add its own.
- Shipped text cites nothing that exists only in this repository.

# Out of Scope

- **Shipping `CHANGELOG.md` into consuming repositories.** The changelog is the
  source repository's history for humans reading it there. A notice is the
  narrow, actionable subset, and shipping the whole file would put a growing
  historical document in every installation to deliver a line or two.
- **Machine-applied notices.** A notice is prose for a reader. Anything a release
  can apply itself belongs in `MOVES` or in the installer, not here.
- **Retiring old notices.** They accumulate in the declaration and are filtered
  by version, which is what makes them cheap. Pruning is a later problem and a
  small one.
- **Per-repository or per-effort notices.** Not this mechanism.

# Architecture

`MOVES` already answers *what does this release do to a tree that predates it*.
A notice is the same question with prose as the payload, so it takes the same
shape, the same gate, and the same reporter.

```
payload.mjs   NOTICES = [{ since, check }]
     │
install.mjs   filter: precedes(declared, since)   ← the MOVES predicate, reused
     │
     └─→ reported under its own heading, dry-run included
             │
skills/update ─→ acts on each, or reports why it cannot
```

## Where notices are declared

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. `payload.mjs`, beside `MOVES`** *(chosen)* | one gate for both, so they cannot disagree about which releases are crossed; the installer already reports; `verify.mjs` can assert against the array | the prose lives in a script rather than an artifact | a notice written like a changelog entry rather than an instruction | one array entry per release that needs one — most need none |
| **B. A shipped `upgrades.md` artifact** | prose in an artifact, readable in the tree afterwards | nothing gates which entries apply, so every reader reads every historical note; a file that only grows | the reader skims it, which is the same as not shipping it | a growing document in every installation |
| **C. Ship `CHANGELOG.md` and read it** | no new concept | it does not ship today, and shipping it puts full release history in every repository to deliver two lines; nothing separates *what to check* from *what changed* | the actionable line is buried in the narrative | the whole changelog becomes payload |

**A**, because the gate is the valuable part and it already exists. C is what the
request first suggested and it is closed by a fact rather than a preference: the
changelog is not payload, and making it payload costs far more than the mechanism
it would replace.

# Testing Strategy

The fixture already builds a tree declaring an earlier release — `legacyTree()`,
used for the moves. The notice assertions ride on it:

| Criterion | Assertion |
| --- | --- |
| R2, R3 | an upgrade of a pre-notice tree prints the notice |
| R2 | **an upgrade of a current tree prints none** — the half that catches a filter matching everything |
| R4 | a dry run previews it |
| R1, R6 | every `NOTICES` entry parses as a release and carries text; a 2.3.0 entry exists |
| R5 | `skills/update` states a notice is acted on rather than read |

The negative case is the load-bearing one. A gate that always fires reads exactly
like a gate that works, and the moves already proved that shape is easy to get
wrong.

# Technical Risks

- **A notice that outlives its usefulness** still prints for any tree old enough.
  Accepted: the alternative is deciding relevance at runtime, which is judgement,
  and the filter is the thing that makes this trustworthy.
- **Notices become a changelog** — one per release, narrating. The constraint
  says what a notice is for; the suite cannot check tone.
