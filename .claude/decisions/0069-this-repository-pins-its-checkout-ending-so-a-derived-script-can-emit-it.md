---
owner: repository
status: superseded
load-when: the working tree's line endings are in question, or what a derived script may emit
sources: [.claude/scripts/regenerate-indexes.ps1, skills/configure/SCRIPTS.md, .claude/tickets/declared-fields/issues/05-the-index-regenerator-and-its-comparison.md, .claude/tickets/line-endings/spec.md]
supersedes: []
superseded-by: [0098]
---

# This repository pins its checkout ending so a derived script can emit it

The working tree is pinned to one line ending for every contributor, and the
derived index regenerator emits that ending rather than the platform's.

**The pin exists to make a rule implementable, not to express a preference.** The
scripts specification requires a derived script to write the checkout's ending,
and says that where nothing pins one, the checkout's ending is the platform's.
This repository pinned nothing, so the script took the second clause as
permanent and hardcoded the platform's. That is correct under exactly one
configuration — automatic conversion enabled, on Windows — and wrong under
conversion set to input, where the checkout holds one ending and the script
writes the other. The byte comparison guarding every generated index then fails,
and it fails *as a stale index*, which is the misdiagnosis the script's own
comment claims to prevent.

**The limitation was recorded as environmental and is not.** It was written down
as a live limitation of the repository, closable by an attributes file nobody had
asked for. Framed that way nothing ever acted on it. It is a defect in the
script: the specification asks for a value the script cannot obtain, and the pin
is what makes the value obtainable.

**Contributor divergence is what this removes.** With nothing pinned, the bytes
in a working tree are a function of each clone's local conversion setting —
three reachable states for the same commit, and the suite gives a different
verdict in each. An explicit ending overrides that setting, so every contributor
on every platform materialises the same file. The alternative is not "no change";
it is divergence that already exists and is invisible until someone's suite
disagrees.

## Considered Options

- **Harden the assertions and pin nothing.** Fixes the failing assertion and
  nothing else. Rejected as the whole answer, though adopted as half of it: the
  regenerator stays defective under a configuration nobody has run, the recorded
  limitation stays open, and the divergence between clones stays. Kept as the
  first change because it is what makes the tree green before a diff touching
  every file is judged.
- **Pin only the generated indexes.** The byte comparison reads exactly those
  files, so pinning them is sufficient for the defect that exists today. Rejected
  for leaving two ending regimes in one tree: which files are pinned becomes a
  fact somebody has to know, and the next byte comparison written against an
  unpinned file reintroduces the bug with no guard against it.
- **Teach the script to detect the checkout's ending at runtime.** Reads an
  existing tracked file, or the effective attributes, instead of being told.
  Rejected as answering a question the repository is free to settle: detection
  adds a failure mode per invocation to avoid stating one fact once, and a
  detector reading a file that happens to be absent produces a confident wrong
  ending.
- **Pin to the other ending.** Symmetrical on this machine and hostile
  everywhere else, since the tooling this repository is built with runs on
  platforms where it is not native.

## Consequences

**Nothing AEP ships changes.** The specification already covers both the pinned
and unpinned cases, and its rule was right while this repository's derived script
was wrong. A configured repository that pins nothing keeps the behaviour the page
describes, and its derived script keeps emitting the platform's ending correctly.

**The hardening is not made redundant by the pin.** It keeps assertions
indifferent to what the tree holds, which is what keeps the suite green across
the renormalisation and what protects any file the pin does not reach. Two
guards, and neither is the other's fallback.

**Stored bytes do not move.** Normalisation on commit was already producing the
pinned ending, so the pin rewrites no history; what changes is only what checkout
materialises, which is why the renormalisation is a working-tree event rather
than a migration of content.

**A reverting contributor loses one commit, not the fix.** The pin lands
separately from the hardening, so tooling that objects to the pinned ending can
be accommodated without restoring the failing assertion.
