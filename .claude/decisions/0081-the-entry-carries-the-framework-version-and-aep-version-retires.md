---
owner: repository
status: accepted
load-when: the hook's comparison, the audit's cursor, or a second version field on the router is in question
sources: [hooks/check-version.js, skills/configure/protocol.template.md, skills/configure/migration-changelog.md, .claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md, .claude/decisions/0065-the-audit-is-bounded-by-a-version-cursor.md, .claude/decisions/0079-the-router-is-framework-law-installed-verbatim.md, .claude/decisions/0080-a-framework-file-declares-the-release-that-last-changed-it.md]
supersedes: []
superseded-by: []
---

# The entry carries the framework's version, and aep-version retires

One version field everywhere: `version` on the entry file means the framework's release — because every release stamps the router's template, so "last changed" and "the release" coincide there by construction — and `aep-version` retires. ADR 0064's placement stands untouched (the check remains a hook, for the reasons that forced it there) and ADR 0065's cursor mechanics survive verbatim; both merely read the surviving field, and the audit's explicit re-stamp step dies because verbatim replacement of the entry *is* the re-stamp. The router's extension points shrink to the Deviations section alone — which changes the enumeration ADR 0079 recorded as two points while its framework-law holding stands whole. Two of ADR 0080's supporting claims retire with the field — the hook no longer compares `aep-version` alone, and the vary-line it cited names Deviations only now — while its decision, per-file provenance enforced by the suite, is the untouched foundation this one stands on. What made a repository-level field necessary was the release nobody would otherwise notice — one touching no installed file — and the entry-stamp invariant closes that gap by construction: a release must change the entry, so a behind installation always has one file that differs.

## Considered Options

- **The bare collapse** — per-file stamps only, the hook sweeping every template pair. Rejected: a template-silent release prompts nobody, and repairs to derived surfaces wait for an unrelated release — the exact failure ADR 0064 was written to end.
- **Keeping both fields** — what the provenance effort shipped. Workable, but permanently carries two lifecycles, a re-stamp discipline, and a second extension point on the most-read file.
- **Dropping the legacy read** — a simpler hook, with every 1.13–1.18 repository silent until someone audits unprompted. Rejected at the grill; the fallback is a few lines and is dead code only when no such repository exists, which nothing can prove.

## Consequences

The entry's stamp has a defined exception to last-changed semantics, stated in the router's release section where the field lives — the price of one field serving two readers. The release process gains one machine-checked obligation: the suite asserts the entry template's stamp equals the specification's declared version, so forgetting the bump fails the build rather than starving the warning. Repositories carrying the orphaned field are repaired by a dated changelog entry, because the audit's extension-point preservation would otherwise carry the value forever.
