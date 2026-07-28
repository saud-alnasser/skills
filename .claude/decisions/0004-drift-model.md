# Drift is detected from two sources and repaired only where the request touches

Context is maintained **inline**: while doing the work, Claude updates what moved and `/commit` records it. Pre-flight exists as a safety net for changes made outside Claude's sessions, so it is deliberately cheap.

`CONTEXT.md` carries `last_sync_commit`, the commit the knowledge was last verified against. Pre-flight checks two independent sources:

- **Committed drift** — `git diff --name-only <marker>..HEAD`, excluding knowledge paths (`CONTEXT.md`, `contexts/*`, `docs/adr/*`). A commit that touched only knowledge is already reflected in the knowledge, so it is not drift.
- **Working-tree drift** — `git status --porcelain`, excluding files Claude wrote this session.

When the marker is not an ancestor of `HEAD` (branch switch, rebase), the diff is meaningless and the touched domains are treated as unverified.

Repair is request-scoped: domains the request touches are verified against source and their Source Pointers repaired; drift elsewhere is left alone. The Marker advances only in `/commit`.

## Considered Options

- **Reconcile every drifted domain at pre-flight.** Knowledge is never stale anywhere, but a large merge produces a long prelude before Claude engages with the request, and the reconciliation crowds the request for attention.
- **Report drift, never repair.** Fastest, but Claude then reasons from knowledge it just called stale — stale context still reads as verified once the warning scrolls away.

## Consequences

Excluding knowledge paths from the drift diff is what makes the marker implementable at all. Without it, `/commit` records a marker pointing at the parent of the commit it is creating, so `HEAD` never equals the marker and every session opens with a phantom sync.
