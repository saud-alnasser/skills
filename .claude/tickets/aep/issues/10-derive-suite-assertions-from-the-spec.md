# test(verify): derive the suite's general assertions from specs.md

Status: resolved
Blocked by: 09
Part of: aep

## Problem

`specs.md` is normative (ADR 0029), and the evolution rule says every framework change conforms to it or amends it in the same change. The suite enforces that in exactly one place — the layout agreement that parses §21 against the generated tree, which is how ADR 0031's divergence was found. Everywhere else the suite hard-codes what the spec also states: the mode set, the spine, the evidence kinds, the conventions defaults. A hard-coded copy cannot catch the spec moving, so a spec amendment today changes nothing until someone remembers every assertion that restates it.

## Outcome

Where the specification states an enumerable fact about what ships, the suite reads the fact *from the specification* and asserts the shipped files against it. Amending the spec then fails the build until the skills follow — the evolution rule with teeth in both directions, and the progressive-migration path for future spec changes.

## Acceptance

- The mode set is parsed from §9 and the shipped mode templates match it exactly, in both directions.
- The spine's workflows are parsed from §10 and each ships as a skill.
- The evidence kinds are parsed from §21's layout block and the evidence policy carries a row for each.
- The PR-description covers list is parsed from §23 and asserted against the version-control policy template, replacing the hard-coded list.
- A deliberate spec mutation makes the relevant assertion fail before the derivation is trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

The §21 layout agreement (aep/06) already works this way and stays where it is; this ticket extends the pattern rather than moving it. Enumerable facts only: prose principles (verification at use, single home) keep their hand-anchored assertions, because parsing prose for meaning is a guess wearing a regex.

**Landed.** Four derivations: the mode set from §9 (both directions, against the shipped mode templates), the spine from §10 (every bolded workflow must ship as a skill), the evidence kinds from §21's layout line (each must be a row in the evidence policy, found by its directory), and the PR-description covers list from §23 (replacing the hard-coded six in the tenure-era assertion). All four were confirmed to fail against a deliberately mutated spec — a fake mode, a fake workflow, a fifth evidence kind, and an extra covers item each produced the intended failure — before the mutation was reverted. Suite at 604.
