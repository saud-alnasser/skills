---
owner: repository
status: accepted
load-when: the protocol file's ownership, the stage table's origin, or a wish to vary a stage row is in question
sources: [.claude/protocol.md, skills/configure/protocol.template.md, .claude/evidence/research/2026-08-10-the-variation-census-for-extension-points.md]
supersedes: [0054]
superseded-by: []
---

# The router is framework law, installed verbatim

ADR 0054 kept the stage-dependency set in two homes — a skill's dependency
line as the plugin's default, the protocol table as "this repository's actual
set, written by the configuration stage from those defaults plus whatever is
local" — and gave the configuration stage a derivation to produce it. The
crystallize effort's variation census falsified the premise: the one
configured repository showed **zero differing lines** between the router
template and the installed copy, so the derivation was producing a verbatim
copy while licensing local edits nothing used — and a healable router was
exactly the "law reads as negotiable" failure the effort exists to close.

Decided, at the user's direction: **the router installs verbatim as
`owner: framework`.** Its two extension points — the `aep-version` value and
the entries of a `## Deviations` section — are named by the file's own
opening paragraph, and they are the whole of what a repository may vary. A
repository whose needs differ from a stage row records a deviation rather
than editing the row, and the audit compares the file against the release's
template after setting aside the two named points, so deviations survive
reinstall and upgrade.

What survives from 0054: the precedence. The table still governs where a
skill's dependency line differs, and for 0054's own reason — the table is
the one committed statement a reader without the plugin can follow. What
falls: the derivation, and with it the "local rows" the 1.9.0 migration
preserved; a pre-crystallize repository's repository-specific rows re-enter
as deviations.

## Considered Options

- **Keep repository ownership.** Rejected: zero observed variation, and the
  healable router re-licenses the negotiable-law failure.
- **Derive, preserving local rows.** Rejected: a derived file with preserved
  local edits can be neither byte-audited nor re-derived, and forks the
  moment the release moves the table.

## Consequences

The configuration stage loses the derivation 0054 gave it and gains the
reinstall-plus-deviation disposition. A repository that genuinely needs a
different row now says so loudly, every audit, until the framework grows the
row or the repository conforms — which is the deviation channel doing what
it was built for.
