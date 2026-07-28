# feat(configure): the templates and the migration write the new layout

Status: open
Blocked by: 05, 06, 07
Part of: streamline

## Problem

Onboarding writes the old shape. Its templates generate the entrypoint and the protocol file as they were, know nothing about the guide directory or path-scoped rules, and its migration branch converts other workflows onto a layout that no longer exists. A repository configured after this effort would be born on the superseded structure.

## Outcome

Onboarding generates the new layout: a pointer entrypoint, a routing protocol, rules split by loading mechanism, and one guide per workflow concern. The migration branch gains the conversion from this repository's own previous layout, alongside the conversions it already performs. Re-running it on a repository already migrated recognises the new shape rather than duplicating it.

## Acceptance

- A freshly configured repository has the layout this effort defines, with no file from the superseded shape.
- A repository on the superseded layout is migrated to the new one, and the migration is listed in the move plan before anything is touched.
- Re-running onboarding on an already-migrated repository reports what exists rather than duplicating it.
- Nothing shipped names a pre-migration path except the files whose job is detecting and converting them.
- The generated entrypoint stays within its line budget, asserted rather than assumed.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This ticket has the widest blast radius in the effort. The templates are what every future repository is born from, so an error here is not visible in this tree at all — it appears in somebody else's. The existing template assertions are the detection and need extending to the new file set rather than repointing.
