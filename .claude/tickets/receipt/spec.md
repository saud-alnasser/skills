---
status: implemented
sources:
  - .claude/protocol.md
  - .claude/tools/git.md
  - .claude/scripts/
  - skills/configure/SCRIPTS.md
  - skills/configure/SKILL.md
  - skills/commit/SKILL.md
  - scripts/verify.ps1
  - .claude/decisions/0060-the-regenerator-is-derived-from-a-behavioural-specification.md
  - .claude/decisions/0012-position-and-the-shared-local-line.md
  - .claude/decisions/0052-the-marker-records-the-tree-and-claims-only-that-drift-was-read.md
---

# feat(skills): the position is computed and attested, and the report says which half is which

## Problem

`.claude/protocol.md` says the verification report "is the only evidence the
discipline ran" and that reporting "is what makes a lapse visible rather than
silent." Neither is true, and the second is false in the direction that matters.

The report is prose the model writes. A run that read no drift, verified no
pointer, and printed a well-formed report is **indistinguishable** from one that
did all three. There is no artefact, no exit code, and nothing downstream that
could tell them apart. The claim describes an enforcement mechanism that was never
built, which is worse than describing none: it is the sentence a reader consults
to find out whether the discipline is enforced.

Underneath that, the report conflates two different kinds of statement. Its
opening lines are **position** — a marker read, an existence check, an ancestry
check, a tree fingerprint, and two drift reads. Everything after is **judgement**
— which contexts the work routes to, whether a pointer still resolves, whether a
claim contradicts source, and what was done about each. The first half is eight
git invocations reproduced from memory at the start of every stage; the second
cannot be mechanised at all. Presenting them as one block is why the whole report
reads as unenforceable: the half that could be checked was never separated from
the half that cannot.

## Goal

The position half of the report is computed and attested; the judgement half is
plainly the stage's own; and a stage that never computed the position cannot reach
a commit.

## Constraints

- **Nothing committed may assume AEP is installed.** A teammate who clones a
  configured repository without the plugin must still be able to follow every
  rule. The script is derived into the repository rather than shipped or pointed
  at inside the plugin.
- **AEP ships behavioural specifications, not code** (`0060`). What ships is a
  description of what the script must do; the implementation belongs to the
  repository, in whatever language it already uses.
- **The receipt is Position** (`0012`) — per-clone, never committed, defined by the
  category rather than added as an exception. Its absence must be survivable and
  the refusal it triggers recoverable: a deleted position directory and a skipped
  verification look identical from outside, and only one is a defect.
- **The run identity is observed, not documented.** It carries the correct value in
  a tool call today, but the documentation names only the effort level as reaching
  one, and names the session identifier only as JSON input to a hook. A shipped
  specification may depend on it **only** with a stated fallback.
- **Nothing about verification at use moves.** A computed position says which drift
  reads ran, never that any statement is correct — the narrowing `0052` made is
  untouched.

## Architecture

**The report has two halves and the boundary is what makes it enforceable.**

*Position* is computed: the marker's two facts against the live two, and the drift
lists when they differ. *Judgement* is the stage's: which contexts routed, which
pointers were checked, what was healed or discounted. The script emits the first
and never the second, and the stage prints its own half beneath.

**Two artefacts, one computation.** The script emits the position report on
standard output for the stage to quote, and in the same run writes a **Receipt**
recording what it saw — including **which mode it ran in**, because a downgrade
that is not stated is a downgrade nobody can detect.

`/commit` refuses when no receipt attests the current position. That is the
enforcement the protocol currently claims, relocated from a sentence into a check.

### The report, fixed here

Not taken from a prototype — fixed by this design, because every downstream
artefact quotes or checks this shape and a format settled mid-build is one nobody
reviewed. Aligned columns so the two comparisons read as the pair they are.

```
Position
  marker  b74df9e  HEAD b74df9e   commit match
  tree    9f1d2af  live 9f1d2af   tree match
  drift   reads skipped
  mode    session 468b4f04
```

When either identity differs, the drift lines carry the paths rather than a count
alone — a count says something moved and never what, which is the read the stage
is about to need:

```
Position
  marker  a3f91c2  HEAD b74df9e   14 commits ahead
  tree    9f1d2af  live 3a1c802   tree differs
  drift   6 committed, 2 uncommitted
            src/db/schema.ts
            src/db/migrate.ts
  mode    commit-only (run identity unavailable)
```

Three refusals, each stating what it does **not** license rather than only what it
found: a marker file that is absent, a marker commit that no longer exists, and a
marker that is not an ancestor of `HEAD`. Each ends the report with everything the
request touches unverified — which is a result, not an error.

### The receipt, fixed here

```json
{
  "run": "468b4f04-ab27-4249-8cd5-01e3ea341a84",
  "mode": "session",
  "head": "b74df9e8fa2a6cf4a446920efe3ce5a085060778",
  "tree": "9f1d2afa509f8cb582acf6f721d0c154104f56d1"
}
```

Four fields, each read by something, per the declared-field rule. `/commit` reads
`run` and `mode` to know whether this run attested it, and `head` to know it
attested *this* position; `tree` records the second fact the report was computed
from, without which the receipt holds half of what it saw. In the fallback, `run`
is null and `mode` is `commit-only`, and the refusal weakens accordingly rather
than silently passing.

**`head` and `tree` are what was observed**, never what the marker said. The
marker file carries a field called `commit`, so a receipt field of that name would
read as an echo of it — and the question the commit stage asks is the opposite
one: whether a receipt attests the position that is live now.

### What the receipt does not claim

It attests that the position was **computed**, never that the stage acted on it —
and now, precisely: the position is attested, the healing is the stage's. Both
verification at use and the judgement half stay outside this mechanism and are
stated as outside it rather than left for a reader to assume.

**The enforcement half of `0060` does not transfer, and the fixture is why.** An
index is a tracked file, so a derived regenerator is checked by regenerating and
comparing byte-for-byte. A position report is not in the tree and has nothing to
compare against, so a wrongly derived script produces a confident wrong fact that
a stage quotes as authority — worse than prose, which at least invites
re-derivation. The specification carries a **worked fixture and its exact expected
output**, as `0060` already requires for the regenerator and for the same reason:
it is the one check whose answer was not produced by the thing being checked.

## Approach

The specification and its fixture land first and alone. They are what every other
repository derives from, and `0060` rejected shipping a reference implementation
precisely because one becomes the de facto contract — so the contract is reviewed
before an implementation of it exists to be read instead.

This repository then derives its own from that page, as `0060`'s closing
consequence requires: a derived artefact like any other, reconcilable with the
description rather than the thing the description was written from.

The deriving stage and the refusing stage follow. Both gate on the specification
and on nothing else, so all three downstream tickets are independent of each other.

Rejected, with the reasons a reviewer would otherwise raise again:

- **A hook that emits the facts.** Genuinely unforgeable, and it loses on
  staleness: a session hook fires once, so any stage after the first commit quotes
  a position that has moved, and an authoritative-looking stale report is the
  failure being removed rather than a milder form of it. It also fails
  plugin-independence — a teammate without AEP gets no hook, where an environment
  variable needs nothing installed.
- **The script with no commit-time refusal.** Smallest change, and it leaves the
  false claim standing; the correction would then be made to the sentence instead
  of the mechanism.
- **A receipt carrying no run identity.** Drops the undocumented dependency, at the
  cost of attesting only that *somebody* verified at this commit — approximately
  what the Marker already says.
- **Computing the branch name and the stacking model too.** Single documented reads
  with no observed drift; folding them in makes the script the place everything
  mechanical accretes, which is how a script stops being reviewable.

## Acceptance criteria

- The specification states the reads, the exact report for both the matching and
  the differing case, all three refusals, the receipt's four fields, the fallback,
  and a worked fixture with its exact expected output.
- The script emits the position half only, and no acceptance anywhere requires it
  to produce the judgement half.
- A derived script run against the fixture produces the specified output exactly.
- The report names its mode, and the receipt records it, so a downgrade is visible.
- The configuration stage writes every specified script and its audit covers them.
- The commit stage refuses when no receipt attests the current position, and the
  refusal names what to run rather than only what is missing.
- A deleted position directory produces that recoverable refusal, not an error.
- `.claude/protocol.md` describes both halves, says what the receipt attests, and
  no longer claims reporting makes a lapse visible.
- The suite fails when the refusal is removed, when the mode is unstated, and when
  the derived script diverges from the fixture — each confirmed against a
  deliberate reintroduction, then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

- **The run identity disappears in a Claude Code release**, and every configured
  repository silently drops to the weaker check. This is what the stated-mode field
  exists for: the downgrade is announced in the report, recorded in the receipt,
  and a guard asserts the mode is stated. Likelihood is unknowable — it is
  undocumented, which is why the fallback is contract rather than comment.
- **The fixture encodes a wrong contract** and every derived script reproduces it
  faithfully. Detected only by review of the specification, which is why it lands
  as its own ticket with no implementation beside it.
- **The two halves blur back together** in a later edit, and the receipt is read as
  attesting the judgement half. The boundary is stated in the protocol and in the
  vocabulary, and the acceptance criteria name the script's half explicitly.
- **A guard that passes for the rule and its negation alike.** This repository has
  shipped several, most recently one matching line-wise while the defect it was
  written to catch sat on an adjacent line. Every guard here is confirmed to fail
  against a deliberate reintroduction before it is trusted.

## Out of scope

- **Enforcing the controlled vocabulary.** Its own design run — it shares no file
  and no failure mode with this one.
- **Computing tier, placement, or whether a spec is required.** Each is a
  judgement, not a derivation.
- **Mechanising the judgement half**, or widening the receipt to attest it. Named
  as out of reach so it is not proposed later as a small extension.
- **The tracker's tracked-intent declaration.** Adjacent, and already repaired
  against its falsified premise.
