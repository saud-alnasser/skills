---
owner: repository
kind: drift
falsifies: [.claude/decisions/0091-frozen-records-get-one-id-and-the-migration-is-fixture-proven-and-resumable.md]
---

# ADR 0091's frozen set names a ticket and omits a finding

Checked 2026-08-15 against `adfa898`, while building `conversion/07` — the ticket
whose third acceptance criterion is written from the same sentence.

ADR 0091 opens: *"**A frozen record — an accepted ADR, a resolved ticket, a landed
spec — gets one id for the whole file and is not decomposed**."* `conversion/07`
inherits it: *"An accepted decision, a resolved ticket, and a landed spec each come
through with their prose unchanged and one id each."*

The set is wrong at both ends, and everything else already says so.

**A resolved ticket gets no id.** `specs.md` Part II puts `ticket` in the tracker
store, whose backing is pluggable behind a read-only interface *"because a
forge-backed repository has no ticket files and needs none"* — and a forge issue
has no frontmatter to carry an id in. The store builder reads `.claude/knowledge/`
and nothing else, so nothing would mint one. The migration's own destination table
says it plainly: `.claude/tickets/**` is *"the tracker store — untouched; `ticket`
is not a type in this store"*.

**An evidence finding does get one, and the ADR does not name it.**
`FROZEN_ACCOUNTS` in `scripts/build-knowledge-store.js` is
`['decision', 'spec', 'evidence']`, and the migration entry's frozen section names
the same three: *"An accepted decision, a landed spec, and an evidence finding are
accounts of what was decided, agreed, or observed."* A finding is frozen by the
same argument the ADR makes for the other two — nothing queries its third heading —
so its absence from the list reads as a decision that it decomposes, which no
surface performs.

What was built is the reachable set: `conversion/07` demonstrates one id and a
byte-identical body for a `decision`, a `spec`, and an `evidence` record, one
fixture each.

The disposition is a supersession or a scoped correction, and it is a design call
either way — the ADR's reasoning is frozen, and a build stage does not write
decisions. Worth noting for whoever takes it: the ADR's *argument* is sound and
only its enumeration is wrong, which is the kind of drift that survives a reading
because the sentence around it is right.

Re-run the check by reading `FROZEN_ACCOUNTS` against the ADR's opening sentence,
or by putting a `ticket` type into a store: the build refuses it as a type outside
the closed set.

Consumed: ADR 0091 declares `falsified-by` naming this finding, so its enumeration of the
frozen set is reachable from the record that carries it — corrections/01 (ADR 0103). The
reachable set the finding established — `decision`, `spec`, `evidence` — is unchanged and
still what `FROZEN_ACCOUNTS` and the migration entry carry.
