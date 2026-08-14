---
owner: repository
title: "chore(release): the release is declared before the work that ships it, and every version literal agrees"
status: resolved
blocked-by: []
part-of: substrate
---

## Problem

Every framework-owned file declares the release that last changed it, and the build refuses a
file whose content moved while its stamp did not. The currently declared release is the one
1.x shipped under, so a file this effort rewrites has no stamp it can honestly take: the old
release is false, and the release this work belongs to does not exist yet. The declaration
that would resolve it sits at the end of the chain, behind the migration — so every ticket
between here and there either writes a false stamp or is blocked on work four tickets away.

Declaring the release also exposes a defect in the build that has nothing to do with this
effort. Fifteen assertions select a changelog entry by reading whichever release the manifest
names, then check that entry describes a repair that shipped two releases ago. The entry is
correct and the repair is correctly filed; the guards read a frozen subject through a moving
reference, so the first release declared after that repair fails all fifteen. Satisfying them
as written would mean filing an old repair under a new release, which the changelog's own
rules forbid — a repair filed later than the release that caused it never fires on the
repositories that need it, and reports success while not firing.

## Outcome

The release is declared, and every literal that carries it agrees: the plugin manifest, the
canonical specification, the router template, and the installed router that template is held
byte-identical to. A framework-owned file this effort changes can then declare the release
that actually changed it.

**The release is declared, not cut.** The window a stamp may legally fall in opens at the last
released version and closes at the declared one. Cutting the release here would close that
window onto a single point and leave every later ticket in this effort unable to stamp
anything it changes — the front-loaded declaration would block the chain it exists to unblock.
Declaring a release well ahead of cutting it is already how this repository works.

The migration changelog gains its entry for the declared release. It is **opened here and
completed by the migration**, which is the ticket that knows what a 1.x repository needs
repaired; an entry freezes when its release ships, and this one has not.

Each changelog guard reads the entry for the release its own subject shipped in, so a
declaration stops breaking guards that were never about it.

## Acceptance

- The plugin manifest, the canonical specification, and the router template all report the
  same release, and the installed router is byte-identical to the template it came from.
- The migration changelog carries an entry for the declared release, filed above every earlier
  one.
- No changelog guard selects the entry it checks by reading the manifest; each names the
  release its subject shipped in.
- Every re-pointed guard still fails when the entry it checks is removed — checked by
  reintroducing the absence, not by reading the guard.
- No assertion is deleted or weakened to make the declaration land.
- A framework-owned file this effort has changed declares the newly declared release; one it
  has not touched keeps the stamp it already had.
- No release commit exists for the declared version, and a framework-owned template changed by
  a later ticket in this effort can still take a stamp the build accepts.
- A session started against the plugin reports no version mismatch.
