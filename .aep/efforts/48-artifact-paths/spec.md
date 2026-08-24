---
status: implemented
---

# Problem

Shipped and entrypoint text makes claims that nothing checks, and three of them
have now failed in the same week. An agent following the instructions literally
writes protocol artifacts outside the protocol tree; a release retires a field
and the entrypoint goes on describing it; a skill sends its own output to a file
the specification reassigned two releases ago. Each was caught by a person, and
in all three cases the suite was green.

## The instruction does not say where it starts from

`[[skills/specify]]` step 9 reads:

> The directory is `efforts/xxxx-<slug>/` — a literal `xxxx`, because the number
> is the tracker's and does not exist yet.

That is a filesystem path with no root. The actual location is
`.aep/efforts/xxxx-<slug>/`. Nothing on the line, or near it, says so.

It is not one line. Thirty-seven sites across the shipped surfaces express
artifact locations the same way, and every one of them is an instruction to write
something:

| Surface | Says | Means |
| --- | --- | --- |
| `skills/specify.md:77, 89, 156` | `efforts/xxxx-<slug>/`, `efforts/<effort>/spec.md` | `.aep/efforts/…` |
| `templates/spec.template.md:7` | "Copy to `efforts/<effort>/spec.md`" | `.aep/efforts/…` |
| `templates/ticket.template.md:7` | "Copy to `efforts/<effort>/tickets/<NN>-<slug>.md`" | `.aep/efforts/…` |
| `templates/plan.template.md:7`, `prototype.template.md:7`, `research.template.md:7` | "Copy to `efforts/<effort>/…`" | `.aep/efforts/…` |
| `skills/tasks.md:20, 86` | "Tasks live under `efforts/<effort>/tickets/`" | `.aep/efforts/…` |
| `skills/research.md:36, 47`, `skills/prototype.md:44`, `skills/refine.md:23`, `skills/handoff.md:24` | `efforts/<effort>/evidence/…` | `.aep/efforts/…` |
| `policies/engineering.md:103` | "Evidence lives at `efforts/<effort>/evidence/`" | `.aep/efforts/…` |
| `policies/execution.md:138` | "the tickets, under `efforts/<effort>/tickets/`" | `.aep/efforts/…` |

`[[protocol]]` does state the convention, but only for links: "Links between AEP
files are double-bracketed, relative to `.aep/`". A path inside backticks in a
*Copy to* instruction is not a link, and the rule that would have covered it was
written about something else. The only two places the true location appears are
the tree diagram at `protocol.md:51` and a table column headed "Lives in" at
`protocol.md:28`, both of which are read once at orientation and neither of which
is in front of the reader at the moment they write a file.

The ambiguity is sharpest in this repository, where `src/` and `.aep/` already
train a reader to take a bare path as repository-relative. It is not confined to
here: any consuming repository gets the same text.

## Nothing catches the result

`validate.mjs` and `index.mjs` both take `--root <path-to-.aep>` and walk only
inside it. An artifact written outside that root is not wrong to them, it is
absent — and absent is indistinguishable from never existing.

Observed in this session: `/specify` created `efforts/xxxx-post-merge-labels/` at
the repository root, with a complete `spec.md` and an evidence tree under it.
`node .aep/scripts/validate.mjs` then reported:

```
150 artifacts checked, no failures
```

A whole effort in the wrong place, and the check that exists to judge the tree
was green. `index.mjs` would have omitted it for the same reason. A human caught
it, which is the failure mode this protocol is built to remove.

## What it costs

An effort outside `.aep/` is not indexed, not validated, and not
traceability-checked, so every guarantee the tree offers silently does not apply
to it. Worse, `[[protocol]]` fixes ownership by where a file sits — "Ownership is
where a file sits. Nothing declares it" — and a directory at the repository root
named `efforts/` sits nowhere the ownership table reaches. It belongs to nobody,
survives an upgrade by accident rather than by rule, and the next install has no
opinion about it at all.

## An entrypoint describes an implementation that changed under it

This repository's `AGENTS.md` carried two claims AEP 3 falsified:

> **`aep:` is the release an artifact's content last changed in.** Never restamp
> by hand.

The `aep:` frontmatter field does not exist. `release.mjs:57` says so in its own
words: "`aep:` is what it declared before 3.0.0, and both have to go." The
baseline moved to `src/stamps.json`. A reader following `AGENTS.md` would go
looking for a field that no shipped artifact carries.

The second was "the Claude adapter", in two places, against a `TARGETS` table in
`adapters.mjs` that has carried more than one runtime since 2.6.0, with two
committed adapters on disk.

`git log -- AGENTS.md` puts its last change at `ed03670`, which is #41. AEP 3
landed as #46 and never touched it.

**Nothing could have caught this.** `verify.mjs:90` lists `AGENTS.md` in
`EXEMPT_DOCS`, and the only assertion on the file, at line 2707, is that it
contains the string `.aep/protocol.md`. Its factual claims are unasserted by
construction, so the suite passing says nothing about whether the entrypoint is
true. Both claims were corrected by hand once found, which is the repository-wins
invariant working as designed, and is also the point: that invariant fires when
somebody happens to read the file, and nobody reads an entrypoint on the turn
that falsifies it.

## A skill describes an output the specification reassigned

`[[skills/plan]]` opens by saying it "Extends the **same** `spec.md` with the
technical approach", and its Output section lists `# Architecture` and nine
siblings as headings `spec.md` gains.

`specs.md` says the opposite, in a sentence written to leave no room:

> **`/plan`** establishes the technical approach as `plan.md`, beside the spec it
> plans.

Eight other shipped surfaces agree with the specification and not with the skill:
`protocol.md:32`, `policies/execution.md:25`, `templates/spec.template.md:10`,
`templates/plan.template.md:7`, `skills/help.md:79`, `skills/implement.md:223`,
`skills/update.md:166`, and `skills/specify.md:92`. The payload ships
`templates/plan.template.md`, whose entire subject is the file the skill says is
not written. AEP 3 reversed a 2.0 decision here deliberately, and `specs.md`
records the reversal by name in its own changelog of reversals; `skills/plan.md`
did not move with it.

`verify.mjs` holds ten assertions about `plan.md` across those surfaces and none
about the skill that produces it. Its only assertion on `skills/plan.md`, at line
750, is that the file matches `/never restates the spec/` — true of the stale
text and the correct text alike, which is the same shape of check as the
substring match on `AGENTS.md`.

Found while running `/plan` on this effort. The skill routed its own output to
the wrong file, and the specification is what settled it.

## What these have in common

A path with no root, an entrypoint naming a retired field, and a skill naming the
wrong output file are one defect in three costumes: **shipped prose asserts
something about the implementation, and no check ties the two together.** Converge
exists to catch what a change falsified and caught none of them, because an
entrypoint is in no effort's diff, a bare path is not wrong until somebody acts on
it, and a skill's opening line is read by whoever is already following it.

# Goal

A claim that shipped or entrypoint text makes about the implementation fails the
suite when it stops being true, rather than waiting for somebody to read the file
and notice. Concretely: a path says what it is relative to at the point somebody
acts on it, an artifact written outside the tree fails the check, an entrypoint
naming a retired field fails the check, and a skill naming an output the
specification does not assign it fails the check.

# Scope

Four repairs. They are independent, and any one alone leaves a real hole.

- **The text.** One convention for how a filesystem path is written in shipped
  prose, chosen once and applied to every site, plus the bootstrap stating it
  where it already states the convention for links.
- **The tree check.** `validate.mjs` distinguishing an artifact that does not
  exist from one written outside the root, and failing on the second.
- **The claim check.** `verify.mjs` asserting the entrypoints against the
  implementation they describe, instead of exempting them from everything but a
  substring match.
- **The output check.** `verify.mjs` asserting that a skill naming the artifact
  it produces names the one the specification assigns it.

# Requirements

1. **A filesystem path in shipped text is unambiguous at the point of use.** One
   convention, applied to every site listed in the Problem and any other the
   sweep finds. A reader who has scrolled past the document's opening still knows
   what the path is relative to.

2. **The bootstrap states the convention for paths, not only for links.**
   `[[protocol]]` already says links are relative to `.aep/`; it says nothing
   about the paths in "Copy to" instructions, which is the gap that let this
   through. Both conventions live in the same place.

3. **`validate.mjs` fails on a protocol artifact outside the root.** It reports
   which artifact, where it was found, and where it belongs. "No failures" stops
   being a possible answer when an effort is sitting at the repository root.

4. **The stray check identifies artifacts by shape, never by directory name
   alone.** A consuming repository may legitimately have its own `templates/`,
   `references/`, or `contexts/` at its root. Only a directory holding
   AEP-shaped artifacts is a finding.

5. **`verify.mjs` asserts the convention.** A new bare path added to a shipped
   surface fails the suite, so this does not decay back the way it arrived.

6. **The convention is chosen, not accumulated.** Whatever form is picked, the
   reason is recorded, because the alternative is that the next person writing a
   skill picks a different one and the surfaces drift apart again.

7. **An entrypoint's factual claims are asserted.** `AGENTS.md` stops being
   exempt from everything but a substring match. Each claim it makes about the
   implementation, a frontmatter field, a script's name, a command's effect, a
   count of adapters, is checked against the thing it describes.

8. **A retired field cannot be described anywhere in shipped or entrypoint
   text.** `aep:` is the worked example and the check is written against the
   general case, so the next field a release retires is caught by the same
   assertion rather than needing a new one.

9. **The correction already applied is preserved and covered.** The two claims
   fixed by hand in `AGENTS.md` this session are the first cases the new
   assertions must catch. An assertion that passes only because the text was
   already fixed is one nobody has seen fail.

11. **A permission the specification grants is one the implementation honours.**
    Added on 2026-08-26, when review found `specs.md` §15.1 permitting a
    repository-owned note beside a shipped skill and `validate.mjs` refusing
    exactly that path since AEP 3. It is the same defect as the other three,
    seen from the other side: not a claim nothing checks, but a claim checked
    into falsity. The human chose to close it here rather than specify it
    separately, and this records that choice so the work traces to something.

10. **A skill's declared output is checked against the specification.**
    `skills/plan.md` is corrected to name `plan.md`, and the check is written
    against the general case: where a skill names the artifact it produces, that
    name is asserted against what the specification says that skill produces. The
    next output a release reassigns is caught by the same assertion rather than
    surviving in the one file nobody re-read.

# Acceptance Criteria

1. Every site in the Problem table reads unambiguously, and a grep for a bare
   artifact path across `src/skills`, `src/policies`, and `src/templates` returns
   nothing the convention does not cover.
2. `protocol.md` states the path convention alongside the link convention, and
   `verify.mjs` fails if that statement is removed.
3. Given a fixture with a valid effort at the repository root and a valid `.aep/`
   tree, `validate.mjs` exits non-zero and names the stray effort and its correct
   location. Seen to fail before the fix, and to pass after.
4. Given a fixture whose repository root has a `templates/` directory of ordinary
   project files, `validate.mjs` reports nothing. Seen to pass.
5. Adding a bare `efforts/<effort>/…` path to a shipped surface fails
   `verify.mjs`. Seen to fail with the path present, and to pass with it removed.
6. The chosen convention and its reason are written down where somebody authoring
   a new skill will meet them, rather than only in this spec.
7. `AGENTS.md` is no longer in `verify.mjs`'s `EXEMPT_DOCS` for claim checking,
   and the suite asserts more about it than that it contains
   `.aep/protocol.md`.
8. Reintroducing the retired `aep:` field into `AGENTS.md` fails `verify.mjs`.
   Seen to fail with the sentence restored, and to pass with it removed. The same
   assertion fires for a second retired field, tested with a fixture rather than
   with `aep:` alone.
9. Reverting either hand-correction made this session, the `aep:` paragraph or
   "the Claude adapter", fails the suite. Both seen to fail before being restored,
   which is what proves the assertions cover the cases that actually occurred
   rather than only the ones that were easy to write.
11. A repository-owned note at `.aep/skills/<skill>/<note>.md`, beside a skill
    the release ships, validates and survives an upgrade without being offered
    for pruning. A skill the release does not ship is still refused, so is a
    note answering to no shipped skill, so is one nested deeper, and no other
    protocol directory gains anything. Each seen failing before it was trusted.

10. `skills/plan.md` names `plan.md` as its output and no longer says it extends
    `spec.md`. Restoring the sentence that says it does fails `verify.mjs`, and
    the failure names the skill and the artifact it disagreed about rather than
    reporting an unmatched substring. Seen to fail before the correction, and to
    pass after.

# Constraints

- **The convention must survive being read out of order.** A skill is loaded by
  applicability and read from the middle, so a root stated once in a document's
  opening paragraph does not reach the person acting on line 77. Whatever is
  chosen has to work for a reader who arrived at the path directly.
- **Prose quality is not traded for mechanical safety.** A blanket prefix on
  thirty sites would satisfy the check and make the text worse to read.
  `[[policies/reporting]]` and `[[skills/prose]]` still apply; a repair that
  reads as machine-applied has half-solved the problem.
- **The stray check must not fire on a consuming repository's own files.**
  Requirement 4 exists because a false positive on install is worse than the
  defect: it teaches people that the validator is noise.
- **Where an artifact already sits outside the tree, the check reports and does
  not move it.** Relocating somebody's files without asking is a write nobody
  requested, and the correct destination is not always inferable.

# Out of Scope

- **Moving `.aep/`, or changing where efforts live.** The location is right; only
  the way it is written down and checked is wrong.
- **The wiki link convention.** Double-bracketed links relative to `.aep/` work,
  are stated, and are not implicated. This effort adds the missing sibling rule
  rather than revisiting the one that exists.
- **The `src/` and `.aep/` distinction in this repository.** It sharpened the
  ambiguity but did not cause it, and a consuming repository with no `src/` gets
  the identical text.
- **Auto-repair.** Detecting a misplaced artifact is this effort. Moving it,
  offering to move it, or migrating one on upgrade is not.
- **Every other path in shipped text.** Script invocations such as
  `node .aep/scripts/position.mjs` already carry their root and are correct. The
  sweep covers paths that name where an artifact lives.
- **A consuming repository's own `AGENTS.md`.** The seeded entrypoint is handed
  over on install and says so: "It is yours now, no upgrade will touch it."
  Requirement 7 covers this repository's entrypoint and the seed AEP ships, never
  a file somebody has since made theirs.
- **Prose-quality checks on entrypoints.** Requirement 7 is about claims being
  true, not about how they read. Whether `AGENTS.md` should also lose its
  `EXEMPT_DOCS` status for the four prohibitions in `[[policies/reporting]]` is a
  separate question with a separate answer.
- **Auditing every past release for drift it left behind.** AEP 3 is the release
  that did this, and its three known casualties are covered: two corrected by
  hand and asserted under requirement 7, one under requirement 10. A sweep of 2.x
  for the same class of stale claim is worth doing and is not this.

# Assumptions

- The population is 37 sites across 23 files, measured over `src/skills`,
  `src/policies`, `src/templates`, `src/agents`, `src/protocol.md`, and
  `src/seed`. It does not cover the committed adapters under `src/adapters/`,
  which are generated from the payload and should inherit the fix; the sweep
  confirms that rather than assuming it.
- No consuming repository has yet written an effort outside its `.aep/` tree in a
  way that matters. Unverifiable from here, and the reason requirement 4's check
  reports rather than moves.

# Risks

- **The sweep is applied mechanically and the prose degrades.** Shows up as
  thirty lines that all read as though a script wrote them, which
  `[[policies/reporting]]` governs against. Mitigated by the constraint above and
  by treating the convention choice as the work rather than the edit.
- **The stray check is too broad and fires on ordinary repositories.** Shows up
  on somebody else's install, where it is least recoverable. Mitigated by
  requirement 4 and by acceptance criterion 4 testing the false-positive case
  explicitly rather than only the true-positive one.
- **The convention is stated and then not followed by the next skill written.**
  Shows up as slow drift back to the current state. Requirement 5 is what makes
  that fail the suite rather than pass unnoticed.
- **The entrypoint assertions are written narrowly and only ever catch `aep:`.**
  Shows up as a green suite the next time a release retires something else, which
  is indistinguishable from today. Requirement 8 and criterion 8 exist to force
  the general case, and the fixture is what separates a real check from one
  written around a single known string.
- **`AGENTS.md` gains so many assertions that editing it becomes painful.** Shows
  up as somebody working around the suite rather than with it. The bound is that
  an assertion is written for a claim about the implementation, never for
  wording, which is what the exclusion above keeps separate.
