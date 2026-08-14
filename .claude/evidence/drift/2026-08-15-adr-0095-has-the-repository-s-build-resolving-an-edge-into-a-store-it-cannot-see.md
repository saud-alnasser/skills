---
owner: repository
kind: drift
falsifies: [.claude/decisions/0095-configure-installs-and-converts-the-build-checks-and-a-deviation-is-an-edge.md]
---

# ADR 0095 has the repository's build resolving an edge into a store it cannot see

Checked 2026-08-15 against `d4ffa93`, while building `conversion/05` — the ticket
whose third acceptance criterion is written from the same clause.

ADR 0095 makes a deviation a declared edge and then says what happens to it:
*"this makes the declaration an edge, so ADR 0090's build resolves it — **an
undeclared conflict fails and a deviation naming nothing fails**."* `conversion/05`
inherits the wording: *"a departure from framework law … as an edge that the build
resolves."*

The build that would resolve it cannot. The store builder ships as copied code and
runs inside the configured repository; a `deviates-from` edge names a record in the
**framework** store, which lives in the plugin package. The harness exports the
plugin's root to a hook process and to skill content, never to a stage's shell
(`specs.md` §22), so nothing the repository runs can locate the other store to
resolve against. The same is true of *"an undeclared conflict fails"*: telling a
repository norm that contradicts framework law from one that merely differs needs
both stores in one process.

Four surfaces already state the reachable rule, and they agree with each other:
`specs.md` §24, `skills/configure/SCRIPTS.md`, `skills/configure/policies/records.template.md`,
and `skills/configure/protocol.template.md` all say the edge is **reported on every
run rather than resolved**. `specs.md`'s own Part II said *"resolved by the build
against the framework store"* until this ticket healed it; the ADR is the remaining
end.

What survives the correction is the half `conversion/05` implemented: a
`deviates-from` **declared and empty** fails, because that fault needs nothing from
the other store to be visible, and removing the edge removes the report with no
other edit.

Two dispositions are open and neither is a build stage's to take. The clause can be
superseded — a deviation is reported, and the resolving half was never reachable
from a repository. Or resolution can be bought, by giving the builder a path to the
framework store's ledger; that is a new dependency from the repository into the
plugin package, which ADR 0083 makes admissible and nothing has yet argued for.

Re-run the check by declaring `deviates-from: [zzzzzz]` on any record in a
configured repository's store and running the builder: it reports the edge, names
the id, and exits zero, having compared it to nothing.

Consumed: ADR 0095 declares `falsified-by` naming this finding, so the clause about a build
resolving the edge is reachable from the record that carries it — corrections/01. The
disposition this finding left open was taken by ADR 0103: neither of the two it named, but a
third — the clause stays frozen and the contradiction becomes reachable, because retiring a
live decision to correct one sentence loses the reasoning freezing exists to protect.
