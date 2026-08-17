---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: spec
status: implemented
---

# Problem

`aep:` is required on every artifact, means two different things depending on who
owns the file, and is maintained by hand.

**Nothing reads it except on `protocol.md`.** `validate.mjs` checks only that it
is a non-empty string. `install.mjs` and `index.mjs` read `protocol.md`'s and no
other. `/update` compares `protocol.md`. The stamp on the remaining ~124
artifacts is checked once, at build time, against a value that is identical
across all of them by construction — so it distinguishes nothing and answers no
question anybody asks.

**It already carries two meanings, and the specification documents one.** In this
tree today:

```
protocol-owned    policies/*.md, modes/*.md      aep: 2.3.0   swept every release
repository-owned  rules/authoring.md            aep: 2.1.1   when it last changed
                  contexts/repository.md        aep: 2.1.1
```

§8 says *the release the artifact ships in*. That is true of the first group and
false of the second, and nothing declares the split.

**Keeping the first group correct is a manual sweep.** Release 2.3.0 restamped
125 files with a hand-run substitution. `verify.mjs` catches a miss, which is the
only reason that is survivable — but the sweep is a step a human performs, and the
field it maintains is one nothing consumes.

The cost is not effort. It is that **a file edited without being restamped is
undetectable today**, because the sweep restamps everything regardless of whether
it changed. The field is expensive and it does not answer the question it appears
to answer.

# Goal

`aep:` means one thing everywhere — **the release in which this file's content
last changed** — and for everything the distribution ships, it is computed rather
than typed. `date:` answers the same question by the same mechanism.

A release states what actually moved in it.

# Scope

The meaning, the mechanism that maintains it, the check that guards it, and the
specification that defines it.

# Requirements

1. **One meaning.** `aep:` is the release in which the artifact's content last
   changed, for both owners.

2. **`protocol.md` is the stated exception.** It always declares the current
   release, because it is not merely an artifact — it is the tree's release
   marker, and `install.mjs` and `index.mjs` read it as such. The exception is
   written into the specification rather than left as behaviour.

3. **A release script computes the stamps.** For every artifact the distribution
   ships, it compares content against the last release's and stamps `aep:` and
   `date:` **only where the content actually changed.**

4. **The baseline is a committed manifest, not git history.** A hash per shipped
   artifact, updated by the release script. *Not tags: `verify.mjs` is the only
   thing that catches a broken build here, and making it depend on tags being
   present in whatever checkout runs it puts the suite at the mercy of how the
   repository was cloned.*

5. **The manifest is build-time only** and MUST NOT be installed into a
   repository.

6. **`verify.mjs` checks what the sweep could not**: every shipped artifact's
   content matches its manifest hash, so **an artifact edited without being
   restamped fails**. Plus: `aep:` parses as a release and never exceeds the one
   being built, no manifest entry is orphaned, and `protocol.md` still equals the
   release exactly.

7. **The release script does the whole release** — version, stamps, manifest,
   plugin manifest, adapter — so the steps cannot be performed in part.

8. **The specification defines all of it**, and gains a conformance line.

# Acceptance Criteria

- [x] R1 — §8 defines `aep:` as last-changed, for both owners, and `date:`
      likewise.
- [x] R2 — §8 and §6 state the `protocol.md` exception and why it exists.
- [x] R3 — `node src/scripts/release.mjs <version>` stamps only artifacts whose
      content changed, and reports which.
- [x] R3 — an artifact that did not change keeps **both** its `aep:` and its
      `date:`.
- [x] R4 — the hash covers content **excluding** the `aep:` and `date:` lines, so
      stamping does not itself change the hash and the computation converges.
- [x] R5 — the manifest is not installed; a fixture install does not contain it.
- [x] R6 — `verify.mjs` fails when a shipped artifact's content is edited and its
      stamp is not, **observed failing** with that perturbation.
- [x] R6 — `verify.mjs` fails on an `aep:` ahead of the release being built, and
      on an orphaned manifest entry.
- [x] R6 — `protocol.md` equal-to-release is still asserted separately.
- [x] R7 — one command performs version, stamps, manifest, plugin version, and
      adapter; running it twice in a row changes nothing the second time.
- [x] R8 — a conformance line, and `node src/scripts/verify.mjs` passes.

# Constraints

- **Dependency-free ESM, run by a bare Node runtime.** The hash comes from
  `node:crypto`.
- **The manifest is machine-written.** It is not a place to record intent, and
  nothing reads it at runtime.
- Existing stamps are the starting state: this release's sweep already set most
  protocol-owned artifacts to 2.3.0, so the first manifest records the tree as it
  stands rather than trying to reconstruct history that was never recorded.

# Out of Scope

- **Reconstructing true last-changed releases for existing artifacts.** The
  information was never recorded — every protocol-owned file was swept every
  release — so it cannot be recovered, only invented. The manifest starts from
  now, and stamps become meaningful from the next release forward.
- **Release tags.** Worth having, and not what this depends on (R4).
- **Changing `validate.mjs`.** It checks an installed tree, where the manifest
  does not exist; a stamp there is a claim about the distribution it came from.
- **Repository-owned artifacts under `.aep/`.** Already last-changed in practice.
  This makes the specification agree with them rather than changing them.
- **Automating the changelog or the notices.** Both are prose and stay written.

# Architecture

```
src/stamps.json          { "<path>": "<sha256 of content sans aep:/date:>" }
        │
release.mjs <version>
        │  for each shipped artifact:
        │    hash(content sans aep:/date:) != manifest[path]
        │        yes -> aep: <version>, date: today, manifest[path] = hash
        │        no  -> untouched
        │  protocol.md -> always <version>
        │  specs.md, plugin.json, adapters.mjs
        ▼
verify.mjs   hash == manifest[path]          <- catches an edit without a restamp
             aep parses, and <= <version>
             no orphaned manifest entries
             protocol.md == <version>
```

Excluding `aep:` and `date:` from the hash is what makes it converge: stamping a
file changes those two lines and nothing else, so a stamped file hashes the same
as it did before it was stamped, and a second release run finds nothing to do.

# Testing Strategy

| Criterion | Assertion |
| --- | --- |
| R6 | every shipped artifact's hash matches the manifest |
| R6 | no manifest entry names a file that is gone |
| R6 | no artifact declares a release ahead of the one being built |
| R2 | `protocol.md` equals the release exactly |
| R5 | the fixture install has no `stamps.json` |
| R7 | a second `release.mjs` run with the same version is a no-op |

The load-bearing perturbation: **edit a shipped artifact's prose without touching
its stamp, and confirm the suite fails.** That is the defect the current scheme
cannot detect at all, so it is the one that proves this was worth doing.

# Technical Risks

- **A hash mismatch reads as alarming when it is routine** — it fires on every
  legitimate edit before the release script runs. The failure message must say
  *run release.mjs*, not merely *hash mismatch*, or it will be worked around.
- **The manifest and the tree drift** if an artifact is added without running the
  release script. The orphan and missing-entry checks are both asserted for that
  reason.
