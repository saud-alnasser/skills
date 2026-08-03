# chore(repo): adopt the changed templates into this repository's installed protocol

Status: resolved
Blocked by: 01, 02, 03, 04, 05, 06
Part of: fieldwork

## Problem

This repository's configuration tree. Once the shipped templates move, the installed copies here still carry the pre-field text — including the false claim that lifecycle states are GitHub labels — and the repository that builds the protocol would be the last one running it correctly.

## Outcome

This repository's own tree, not the shipped one. The installed policies and tool references are healed from the changed templates: the tracker declaration (tracked intent here — tickets are files, no branch is implied), the closure-semantics text, the map-template repairs, the declared-increments section, and both tool-reference additions. This repository's recorded deviations survive the pass — the tracker's single-status wrinkle stays recorded as a wrinkle, exactly as written.

## Acceptance

- Every installed policy and tool reference the effort's shipped tickets changed carries the new text, and the tracker declares what a ticket is here.
- The recorded deviations in the installed tracker policy are preserved verbatim.
- The suite passes.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. Adoption notes: the tracker declares **tracked intent**, derived from the version-control policy's "How work lands" — the one-ticket-one-pull-request conjunct fails because work lands by fast-forward with no pull requests; the branch and commit legs hold and the declaration says so. The installed `github.md` keeps its recorded filter — all issue entries deliberately absent on a repository whose issues are empty on purpose — so the effort's issue-operation additions apply vacuously here; `git.md` had already adopted its entry in the ticket-05 pass under the derived-match assert. Review: Spec axis clean, judging the filtered forge reference as satisfying the outcome through its own deviation clause; Standards' one leaning-violation fixed (the declaration's "claimed as a file" clause contradicted the Claim-is-the-branch rule and now defers to it), and its remaining judgement call — the tracked-intent verdict hanging on the PR leg of the detect test — recorded here as the design's transparent, cited derivation, flagged to the user at hand-back. "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
