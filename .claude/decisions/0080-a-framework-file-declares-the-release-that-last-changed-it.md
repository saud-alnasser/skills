---
owner: repository
status: accepted
load-when: a version or provenance field on shipped or installed files is proposed, or the release check's scope is in question
sources: [skills/configure/, build/verify.js, .claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md]
supersedes: []
superseded-by: []
---

# A framework file declares the release that last changed it

Every framework-owned template carries `version` in frontmatter — the release in which that file's content last changed — flowing verbatim into installed copies through the byte-lock. It is provenance for the reader of one file, and it settles nothing: the audit's content comparison runs regardless, and the release hook keeps comparing `aep-version` alone. ADR 0064 rejected a stamp variant, and this is not it: that option copied *one* fact — the running release — into many homes as a comparison mechanism, where this field records a *distinct* fact per file and compares nothing. What 0064 priced as the rejection's cost, "a release script and a cross-file agreement assertion", is knowingly bought here — a suite check that a template changed since the last release moved its stamp — because an unenforced indication rots into a lie aimed at the exact reader it exists for.

## Considered Options

- **A stamp without enforcement.** Rejected: silent rot; the field's whole value is that it can be trusted as far as "routing attention" goes, and nothing else keeps that true.
- **Extending the stamp to repository-owned files.** Rejected: the writer would need to know and remember the running release on every edit, no check can fire, and the field becomes an unverified claim — the failure the framework-owned variant is shaped to avoid.
- **Reusing `aep-version` as the name.** Rejected: different fact, different owner, different lifecycle — audits re-stamp one and must never touch the other, and a shared name invites exactly that.
- **Relying on the migration changelog for provenance.** Rejected: it records repairs grouped by release, neither per-file nor exhaustive — a file changes in releases that need no repair.

## Consequences

The field is fixed content, not an Extension Point — repositories never vary it, and the router's "aep-version and Deviations, and nothing else" line stands. Initial values are recovered from history rather than stamped uniformly, on the same recovered-evidence footing ADR 0065 established, with the earliest plausible release winning where evidence is thin — an over-old stamp invites a look, an over-new one forecloses it.
