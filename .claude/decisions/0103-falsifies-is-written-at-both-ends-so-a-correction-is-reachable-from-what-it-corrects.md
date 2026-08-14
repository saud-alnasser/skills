---
owner: repository
status: accepted
load-when: how a finding that falsifies a frozen record reaches a reader of that record, or whether an ADR may be corrected without being superseded, is in question
sources: [.claude/evidence/drift/2026-08-15-adr-0089-s-measured-saving-needs-a-per-span-label-the-format-does-not-carry.md, .claude/evidence/drift/2026-08-15-adr-0091-s-frozen-set-names-a-ticket-and-omits-a-finding.md, .claude/evidence/drift/2026-08-15-adr-0095-has-the-repository-s-build-resolving-an-edge-into-a-store-it-cannot-see.md]
supersedes: []
superseded-by: []
---

# `falsifies` is written at both ends, so a correction is reachable from what it corrects

**A decision that a finding falsifies declares `falsified-by` naming that finding,
written in the same change and checked for symmetry by the build exactly as
supersession is.** Three findings this session each declared `falsifies` naming an
accepted ADR, and each ADR declared nothing back — so a reader who opens or queries
the decision gets the decision, and the correction is invisible from the only side
that needs it. That is structurally the failure the supersession rule already names
— *writing only the new end is the tempting half, because that is the file being
edited* — arriving in the one edge pair that had no opposite.

**Supersession is the wrong instrument for a wrong clause in a sound argument.**
An ADR's prose is frozen on commit, so a correction cannot be written into it; the
only mechanism that existed was a new file retiring the old. Two of the three
findings correct a single enumeration or a single verb in decisions whose reasoning
is entirely live, and retiring those decisions would move every surviving paragraph
into a new file so that one sentence could change — losing the record of what was
actually decided, which is the thing freezing exists to protect.

**The freeze rule is amended in the same change**: `falsified-by` joins `status`
and `superseded-by` as fields that move after commit. This does not weaken the
freeze, because the freeze is on **reasoning** — a pointer to a record that
contradicts this one is not reasoning, and adding it changes nothing about what was
decided or why.

**Depth is one hop**, on the same argument the forward edge takes: the finding that
falsified this record is wanted; what *that* finding cites is the finding's
business.

## Considered Options

- **One superseding ADR per finding** — rejected: it retires three live decisions
  for three wrong sentences, and each successor would have to carry the whole of
  what it replaced. ADR 0089 in particular is a large decision whose delivery
  measurements, chunking constraint and conflict rule are all current.
- **One superseding ADR for all three** — rejected: cheapest to write and worst to
  read. One file becomes the live home of three unrelated subjects, and a reader
  following any one supersession lands on two decisions they did not ask about.
- **Leaving the finding one-ended, as it is** — rejected: it is the status quo and
  the defect. The evidence index lists the finding as waiting, which reaches
  somebody who reads the index; the reader this exists for is the one who opened
  the ADR.

## Consequences

**A finding's `falsifies` becomes an obligation on both files.** A finding naming a
record that does not name it back fails the build, exactly as a half-written
supersession does — so filing a finding now includes writing the return edge. That
is the cost, and it is the same cost supersession already carries for the same
reason.

**A record may be falsified more than once**, and the field is a list from the
start. Nothing about a correction implies it is the only one.
