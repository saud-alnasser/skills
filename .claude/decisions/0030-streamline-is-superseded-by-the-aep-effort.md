# Streamline is superseded by the aep effort, and its open obligations transition

The streamline effort is closed **superseded, not failed**. Its tickets 01–08 landed and conform to the specification adopted by ADR 0029 — the tier model, the policies directory, the context split, declared dependencies, commit-after-review, and the layout migration all survive as built. Its open tickets described work the specification still wants, anchored to a name and a framing the AEP rethink replaced; executing them as written would land prose that contradicts `specs.md`.

The dispositions, so no ticket's fate is implicit:

| Streamline | Disposition |
| --- | --- |
| 01–08 | resolved; kept as built |
| 09 re-anchor the suite | → aep/08 |
| 10–13 compression | → aep/09 |
| 14 confirm the budget | → aep/08 |
| 15 | already obsolete (ADR 0026); unchanged |
| 16 adopt here | → aep/07 |
| 17 discussions are evidence | → aep/04 |
| 18 stage postures | → aep/03, generalised into declared modes |

## Considered Options

**Finishing streamline first and renaming after** was rejected: the compression tickets would rewrite most shipped prose in the Tenure voice, and the rename would rewrite it again — the same double-review cost streamline itself rejected in "compress first, then restructure".

**Abandoning without absorption** was rejected because the open tickets carry obligations that hold under the specification regardless of framing — the coverage audit before compression and the asserted boot budget are not Tenure ideas, they are the fidelity floor.

## Consequences

Two effort directories now record one continuous intent, and the transition table above is the joint between them. The streamline spec stays as history; the aep spec is the live plan.

By user instruction, this effort lands as **one `aep` branch over `main`, one commit per ticket, each ticket's status updated as it lands** — overriding, for this effort only, the branch-per-ticket convention in `.claude/version-control.md`. The one-ticket-one-commit discipline and the landing order are unchanged.
