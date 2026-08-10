---
owner: repository
status: implemented
sources:
  - skills/configure/protocol.template.md
  - skills/configure/SKILL.md
  - scripts/verify.ps1
  - .claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md
  - .claude/decisions/0080-a-framework-file-declares-the-release-that-last-changed-it.md
---

# feat(configure): framework-owned files carry the release that last changed them

## Problem

A reader of an installed framework-owned file — human or model — cannot tell when its content last moved without consulting something else. The installation-level `aep-version` field says which release configured the repository, never which release last touched the file being read; the migration changelog records repairs, never provenance; and the byte-lock comparison answers *has this file drifted from its template*, never *how old is what I am reading*. The provenance of any one file is recoverable only by archaeology in the repository that builds AEP, which a configured repository cannot perform.

## Goal

Every framework-owned file declares, in frontmatter, the release of this workflow that last changed its content — an indication that routes a reader's attention and settles nothing.

## Constraints

- **The stamp routes attention and never settles it.** The audit's content comparison runs regardless of what any stamp says; the release hook keeps comparing `aep-version` alone. A cheap signal that can short-circuit the check it supplements becomes the check, which is the failure mode this design was grilled on.
- **Framework-owned files only.** The derived policies and the merged root entry file are repository-owned once installed; a framework stamp there would be a claim nothing keeps true.
- **The field is not an Extension Point.** Repositories never vary it; it is fixed content inside the byte-lock, so the router's declaration of what a repository may vary is untouched.
- **The stamp must be enforced or it must not exist.** An indication that can rot silently misleads the exact reader it exists for, so the suite must catch a changed template whose stamp did not move. This is the machinery an earlier Decision declined for a different fact, and the new Decision records why it is bought here.
- **Shipped text cites only what resolves where it is read** — the audit wording that explains the stamp states its reason inline and cites no record of this repository's.

## Architecture

The field is named `version` and sits beside `owner` in the frontmatter of every framework-owned template. Its value is the release in which that file's content last changed. Because the field is part of the file's content and framework-owned files install verbatim, the stamp flows into every configured repository through the existing byte-lock — no installation step, no re-stamping, no per-repository state. It is a Declared Field acted on by exactly one thing: the suite's release check.

On the router, `version` sits beside `aep-version`, and the two answer different questions with different owners: `aep-version` is the release that configured *this repository*, set by the configuration stage and re-stamped by audits; `version` is the release that last changed *this file's template*, fixed at authoring time and varied by nobody. The router's own section on its release field gains the sentence that distinguishes them, so the one file where both appear explains both.

Enforcement lives in the suite, which already compares each installed framework-owned file byte-for-byte with its template. The new check bounds it in time: releases are marked by release commits in history, so any template whose content differs from the most recent release must carry a stamp newer than that release's version and no newer than the currently declared one. A template unchanged since the release keeps its stamp by construction, because the stamp is part of the compared content.

## Approach

Stamping comes first, enforcement second — the check has nothing to read until the field exists.

Initial values are recovered from history rather than stamped uniformly: each template's stamp is the release in or immediately after which its content last changed, following renames. Stamping everything with the current release would assert that every file just changed, which is false and visible — the one thing a provenance field must not do on arrival is lie.

The audit's wording in the configuration skill gains the constraint as a bullet: the stamp may order or motivate attention, and the content comparison runs regardless.

Rejected along the way:

- **A stamp without enforcement** — rots silently; rejected in the grill on the same logic that motivated the field.
- **Relying on the migration changelog for provenance** — it records repairs grouped by release, which is neither per-file nor exhaustive; a file can change in a release that needs no repair.
- **Extending the stamp to repository-owned files** — the writer would have to know and remember the running release on every edit, with no check able to fire; the stamp becomes the unverified claim the framework-owned variant was designed not to be.
- **Reusing `aep-version` as the field name** — the two facts have different owners and lifecycles, and audits re-stamp one but must never touch the other.

## Acceptance criteria

- Opening any installed framework-owned file shows, in frontmatter, which release of the workflow last changed it.
- The suite fails when a framework-owned template lacks the field, and when a template's content changed since the most recent release without its stamp moving into the range that release opens.
- The suite still passes when a template is genuinely unchanged since the most recent release, whatever its stamp says about older releases.
- The audit's documented procedure states that the stamp routes attention and that the content comparison runs regardless.
- The router distinguishes its two version fields where they sit together.
- The full suite passes.

## Risks

- **The stamp gets read as settling what it only routes.** Detected by the audit wording being the first thing a reviewer of the configure skill reads; the constraint is stated where the audit is defined, not in a record only this repository holds.
- **Recovered initial values mis-assign a release.** Detected by spot-checking recovered stamps against history during review; where evidence is thin the earliest plausible release wins, since an over-old stamp invites a look and an over-new one forecloses it.
- **The release check false-fails when the declared version moves mid-effort without touching a template.** Avoided by the range rule: a changed template's stamp must be newer than the last release and at most the current declared version — never exactly equal to the current one.
- **No release commit found in history** — a shallow clone or a rewritten history leaves the check unbounded. The check names the condition and fails rather than guessing, matching how the suite treats an unknown ticket id.

## Out of scope

- The release hook — it keeps comparing `aep-version` alone and does not read the new field.
- The audit's cursor into the migration changelog — unchanged, still `aep-version`.
- The migration changelog — no dated repair is added; the verbatim replacement an audit already performs carries the stamps into stale repositories on its own.
- Repository-owned files, derived policies, and the merged root entry file.
- Any per-repository variation of the field — it is not an Extension Point and never appears in a Deviations section.
