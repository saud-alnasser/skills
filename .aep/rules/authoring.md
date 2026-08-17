---
aep: 2.1.1
owner: repository
date: 2026-08-17
kind: rule
mode: [implement, review]
paths:
  - src/**
use-when: "changing anything under src/ — the protocol's own shipped surfaces"
---

# Rule — authoring what ships

## Every change to `src/` moves the suite in the same pass

There is no compiler and no test runner here. `src/scripts/verify.mjs` asserts
the shipped surfaces against `specs.md`, and it is the only thing that catches a
broken build.

```
node src/scripts/verify.mjs
```

**A change that adds a checkable claim without an assertion is untested by
construction**, not merely under-tested.

## Confirm a new guard would actually fire

The recurring failure is a guard that matches something travelling *with* the
thing it checks rather than the thing itself — it passes while what it existed to
catch sits in the tree.

**Write the guard, then break the thing deliberately and watch it fail with the
right name.** A green run proves nothing until you have confirmed the
perturbation actually removed the subject.

## Shipped text cites only what resolves where it is read

A file under `src/` is read inside whatever repository AEP is installed in. So it
may name only what exists there.

- `[[policies/artifacts]]` resolves in every configured repository. **`specs.md`,
  a section number, or anything else that exists only here does not** — and there
  it is worse than a dead link, because it is indistinguishable from a reference
  to something of theirs.
- Where a citation was carrying a reason the prose does not state, **state the
  reason.** A citation doing real work leaves a hole when it goes, and the hole
  is invisible because the sentence still reads well.

The suite asserts this over the shipped surfaces.

## Regenerate the adapter whenever a skill or agent changes

```
node src/scripts/adapters.mjs
```

The adapter is **generated from the payload** and never hand-edited — its
descriptions are derived from each artifact's own heading and `use-when`, so the
text a runtime matches on cannot disagree with the text the protocol declares.
The suite fails if the committed adapter is stale.

## `.aep/` here is output

Change the protocol in `src/`, then reinstall. Editing `.aep/`'s protocol-owned
files changes nothing that ships and is overwritten by the next install
(`[[contexts/repository]]`).

## Vendored text carries attribution; borrowed shapes do not

**Nothing currently shipped is vendored.** Every file under `src/` was written
for this protocol, so no upstream licence reaches the distribution and there is
no third-party notice to carry. That is a fact about today, not a permanent one.

**The test is whether text was copied.** If text is ever brought in from another
project:

1. the file says so, in the file, and that line survives rewrites of the prose
   around it;
2. whatever notice the licence requires ships beside it — restore a `NOTICE` at
   the repository root and reproduce the terms in full;
3. the suite gains a guard pinning that file by name, so the attribution cannot
   be lost by a later rewrite.

**A structure borrowed from upstream is not a copy.** A two-axis review, a core
loop, a branch discipline: copyright protects expression rather than shape, so a
file that derived only a shape carries no obligation and states none.
**Attributing anyway is not free caution** — it asserts a licence requirement
that does not exist, which misstates the licence exactly as omitting a required
one does. Acknowledging influence in `README.md` and `specs.md` is honesty, and
it is not the same act.
