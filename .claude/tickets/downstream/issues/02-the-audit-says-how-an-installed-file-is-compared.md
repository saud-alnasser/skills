---
title: 'fix(configure): the audit says how an installed file is compared against its template'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

The audit tells a run to re-check several derived surfaces against their sources
— the tool references, the scripts against the page they are specified by, the
tracker policy's declarations against the tree — and never says how any of them
is compared. There is no bullet about comparing installed policy files against
their templates at all, so the run that needs the comparison invents one.

The one that did compared raw bytes. The plugin's checkout was CRLF and the
configured repository pinned LF, so every file reported as differing in full. The
conclusion available from that evidence is *every installed file has drifted*,
and the action it licenses is re-deriving all of them from templates — which
silently reverts exactly the repository-specific corrections that are the most
valuable thing in the directory.

**This is the default on Windows rather than an edge case**, and it is the only
failure mode on this page whose correction is destructive rather than merely
wrong. Nothing in the audit warns that whole-file drift is a property of the
comparison before it is a property of the files.

## Outcome

The audit states how an installed file is compared against its template, and the
comparison is on content rather than on bytes, so a line-ending difference between
a plugin checkout and a configured repository is not a finding.

It also states the tell: **drift reported across every file at once is a fault in
the comparison until proven otherwise.** A finding that shape is checked before it
is acted on, because the action it points at cannot be undone by re-running the
audit — the derivations it overwrites are gone.

The bullet says what to do with a genuine difference, which is not the same as
what to do with all of them: an installed file that has drifted is a finding
reported with the file named, and re-derivation is the repair for a file nobody
corrected on purpose.

## Acceptance

- The audit states the comparison method for an installed file against its
  template, and the method does not depend on the two agreeing about line
  endings.
- The audit states that drift across every file at once is a comparison fault
  before it is a finding.
- The audit distinguishes a file that drifted from a file that was deliberately
  corrected, and does not prescribe re-derivation for the second.
- The suite fails when the audit branch carries no comparison method, confirmed
  against a deliberate removal and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.


## Reopened by review

The acceptance line is met literally and the root cause named in the Problem is not.
`skills/configure/SKILL.md` now says "Several checks above compare an installed file
against what AEP ships", but no §5 bullet does — the bullets compare tools against the
repository, scripts against `SCRIPTS.md`, and the tracker policy against the
version-control policy. The comparison method still attaches to nothing, which is the
gap this ticket was cut to close. The Outcome also asked for a bullet; it was delivered
as trailing prose.

## Comments

The reopen is closed by giving §5 the bullet: **Re-check the installed copies against
the templates that wrote them** — the rules, the modes, the copied policies, and the
protocol file, the set no other bullet's comparison can see. The trailing prose now
opens by binding its method to that bullet rather than to "several checks above". The
suite gained the guard the reopen implied: an assertion that some audit bullet performs
the installed-against-template comparison, matched on the subject rather than this
wording, and confirmed red against the pre-fix text before the bullet was written.

Review noted, without raising it as a violation: the guard matches word co-occurrence
on a bullet line rather than parsing that the bullet's instruction is a comparison, so
an unrelated future bullet containing both words would satisfy it. Left as-is — the
tightening is available if a false pass ever materialises.
