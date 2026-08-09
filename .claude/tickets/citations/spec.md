---
status: implemented
sources:
  - skills/
  - agents/
  - .claude/rules/skills.md
  - .claude/policies/decisions.md
  - scripts/verify.ps1
---

# refactor(skills): shipped text cites only what resolves where it is read

## Problem

AEP ships sixty-six references to records that exist only in the repository that builds it. Forty-one are ADR numbers, ten are the specification or one of its sections, and fifteen more sit in this repository's copies of files it installs elsewhere.

Ten of them are written **verbatim into other people's repositories**. A repository configured by AEP receives a protocol file citing `ADR 0061`, an entrypoint citing `ADR 0008`, and a tickets policy citing `ADR 0058` — decision records that repository has never had and will never have. The numbers are not merely unhelpful there; they are indistinguishable from that repository's own ADRs, which are numbered from `0001` on the same scheme.

The rest are read by the model in whatever repository AEP is running in. They point at nothing, so they cannot be followed, and following a reference is the only thing a citation is for.

The decisions policy states the invariant these break, about AEP's own records: *"inbound references to `0007` must keep resolving."* Every one of these is an inbound reference that cannot.

## Goal

A reader of anything AEP ships — human or model, in any repository — can follow every reference it contains, or the reference is not there.

## Constraints

- **Attribution is a licence obligation and is untouched.** Forty-seven references to the upstream project stay exactly as they are; they are provenance the licence requires, not navigation.
- **A shipped file may still reference the paths AEP installs.** `.claude/policies/tickets.md` resolves in every configured repository; that is the whole point of installing it.
- **Derived guides are not copies.** The tracker and version-control guides are written per repository from that repository's own facts, so their citations here are read here and stay.
- **This repository's own knowledge keeps its citations.** Decisions, tickets, contexts, evidence, and the specification are never shipped, and a citation in them resolves for every reader they have.
- **A template and its installed copy move together**, as they already must.
- **Nothing is reworded beyond removing the reference.** A citation that was carrying reasoning has that reasoning stated; a citation that was carrying only provenance is deleted.

## Architecture

**One test decides every case: does the reference resolve in the repository where the text is read?** Not whether it is useful, not whether it is true — whether a reader can follow it. `.claude/policies/tickets.md` passes in any configured repository. `ADR 0058` passes only here.

That test partitions the tree without a list to maintain: what ships is governed, what this repository keeps for itself is not, and the boundary is the one the placement rule already draws.

**The rule lives in `.claude/rules/skills.md`**, which is already scoped by `paths:` to `skills/**` and `agents/**` — exactly the surface that ships, and it loads only when that surface is being worked on. The installed mirrors need no rule of their own: they are already required to match their templates, so a template that stops citing forces its copy to.

**The removal is deletion, not substitution.** Almost every citation is a parenthetical after a sentence that already states the rule; the number added provenance for a reader who could reach the record, and there is no such reader. Where a citation is doing real work — carrying a reason the prose does not — the reason is written out. That is judgement per site rather than a pass, and it is the only part of this that is not mechanical.

**The release changelog is not excepted.** Its subject is AEP's own history, which makes an exception tempting, and its recovery citations are exactly the kind of thing this rule exists to remove: a commit hash in AEP's repository is no more followable elsewhere than an ADR number. The provenance moves to the effort's own tickets, where a maintainer auditing an assignment can still reach it.

## Approach

The shipped bodies go first and the templates second, because only the second half has an installed consequence and keeping it separate makes that diff reviewable on its own.

The guard is the part that has to outlive the change. Written against the specific sixty-six it would go green the moment a sixty-seventh is added, so it matches the *shape* of a reference to this repository's records — the ADR numbering scheme, the specification's filename, a section sign — over everything under the shipped surfaces.

## Acceptance criteria

- No file AEP ships or installs contains a reference that resolves only in this repository.
- The suite fails when one is added, and the guard is confirmed against a deliberate reintroduction.
- Every upstream attribution is still present and unchanged.
- Every reference to a path AEP installs still resolves and is untouched.
- The derived guides, this repository's knowledge, and the specification keep their citations.
- No sentence lost a reason it was carrying; where a citation carried one, it is stated.
- Each template and its installed copy still agree.
- The rule is stated once, on the surface it governs.

## Risks

- **A citation was carrying the only statement of a reason**, and deleting it loses that reason silently — the prose still reads well, which is what makes it silent. Mitigated by treating each site as judgement rather than running a substitution, and by reading the sentence without the parenthetical before accepting it.
- **The guard matches this repository's own knowledge** and fails the build for citations that are correct. Detected immediately, since those files outnumber the shipped ones four to one; bounded by scoping the guard to the shipped surfaces rather than the tree.
- **An exception is argued for later** on the ground that some shipped file is "about AEP anyway" — the argument the changelog invites. The rule is stated as a test rather than a list so that argument has something to fail against.

## Out of scope

- **Upstream attribution.** Licence-required, and not navigation.
- **Any reference to an installed path.** Those resolve, which is the entire test.
- **This repository's own knowledge and specification.** Never shipped.
- **Removing the records themselves.** The Decisions stay; only the shipped pointers to them go.
