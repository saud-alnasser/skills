---
status: draft
sources:
  - specs.md
  - .claude/tickets/streamline/spec.md
  - skills/
  - .claude/
  - scripts/verify.ps1
---

# refactor(aep): adopt the AI Engineering Protocol, and transition the framework onto its specification

## Problem

The framework was built as Tenure and was mid-way through the streamline effort when it was rethought as the **AI Engineering Protocol** and given a canonical, self-contained specification at `specs.md`. The repository now holds three descriptions of itself — the Tenure prose in what ships, the streamline spec's target architecture, and `specs.md` — and only the last is authoritative going forward.

Streamline is **superseded, not failed.** Its tickets 01–08 landed and their results conform to the specification (the tier model, the policies directory, the context split, declared dependencies, commit-after-review, the migration). Its remaining tickets described work the specification still wants, but anchored to a name and a shape this effort replaces. Executing them as written would land prose that ticket-for-ticket contradicts `specs.md`.

## Goal

The repository implements `specs.md` and nothing else describes the framework. The plugin, the namespace, and the prose say AEP. Every surviving obligation from streamline lands here, re-anchored to the specification, and the spec-evolution rule — every change conforms or amends, in the same change — is in force from the first ticket.

## What transitions from streamline

| Streamline ticket | Disposition here |
| --- | --- |
| 01–08 (landed) | Kept as-is; conform to spec §7, §8, §11, §21, §22 |
| 09 re-anchor suite, close coverage | → ticket 08, extended with spec-conformance assertions |
| 10–13 compression | → ticket 09, compressing to spec §6 density ("directive, not argument") |
| 14 confirm the budget | → ticket 08, the boot budget of spec §22/§24 |
| 15 (obsolete) | Stays obsolete; the fixture reasoning (ADR 0026) carries over unchanged |
| 16 adopt here through the migration | → ticket 07 |
| 17 discussions are evidence | → ticket 04, per spec §13 (unchanged in substance; ADR 0027 holds) |
| 18 stage postures | → ticket 03, generalized: posture becomes the declared **mode** of spec §9 |

## Architecture

The specification is the design; this effort is its adoption. The load-bearing moves:

**Modes become a system (spec §9).** The earlier rejection of a `modes/` directory (streamline spec) was a rejection of a *nominal* mode/workflow split — seven of ten modes duplicating same-named workflows. The specification resolves the duplication the other way: modes are few, shared across activities, and carry the tradeoffs once; workflows stay in the skills; each skill declares exactly one mode. Review-mode prose written once and declared by every reviewing activity is the single-home rule applied, not violated.

**The spec is normative, with a decided evolution rule.** `specs.md` outranks the tickets' descriptions of the framework, and divergence between spec and implementation is a decision point — defect or evolution, a human decides (spec preamble). This amends the role `tickets/tenure/spec.md` held in the precedence rule.

**The boot-tier reality is kept.** The specification adopts the protocol-as-operating-system framing *with* the bounded boot-tier exception (spec §5, §22), so ADR 0021's mechanism-based placement survives inside the AEP framing rather than being overturned by it.

**Rejected: executing streamline to completion first, then renaming.** Lands compression prose in the Tenure voice and rewrites it again for AEP — the same double-review cost streamline itself rejected in "compress first, then restructure."

**Rejected: a root spec that only points.** Considered and declined by the user: `specs.md` is deliberately self-contained, like a language specification. The drift risk that motivated pointer-only is answered by the evolution rule plus spec-conformance assertions in the suite (ticket 08), not by thinning the document.

## Approach

Ordered by edges; every structural ticket changes `skills/` only, and this repository adopts through the migration (ADR 0025, unchanged):

```
01  supersede streamline, record the adoption          (decisions + ticket hygiene)
02  rename tenure → aep                                (plugin, namespace, docs)
03  modes ship, skills declare theirs                  (absorbs 18)
04  discussions are evidence                           (absorbs 17)
05  the protocol file speaks the spec                  (routing gains modes; vocabulary aligns)
06  configure and the migration write the AEP shape    (templates + one more conversion)
07  adopt here, by running that migration              (absorbs 16)
08  re-anchor the suite: coverage, conformance, budget (absorbs 09 + 14)
09  compress to spec density                           (absorbs 10–13, sliced per context window)
```

## Acceptance criteria

- Nothing in the tree calls the framework Tenure except history, license attribution, and the migration rows whose job is recognizing the old name.
- Every skill declares a mode from spec §9, every mode states its tradeoffs once, and no skill restates them.
- Every obligation in the transition table above either landed or has a recorded reason it was dropped.
- `verify.ps1` asserts spec conformance where it is mechanical: boot budget, single-home guards, dependency declarations resolving, mode declarations present.
- The spec-evolution rule has been exercised at least once by this effort itself — any divergence found during adoption amended `specs.md` in the same change, visibly.
- `pwsh -NoProfile -File scripts/verify.ps1` passes at every ticket boundary.

## Risks

- **The rename has the widest textual blast radius of anything yet attempted** — plugin manifest, namespace, README, templates, migration self-recognition, and the user's global instructions all say tenure. Mitigated by doing it early (ticket 02), before compression rewrites the same prose.
- **The mode/workflow split regresses into the nominal duplication that got it rejected.** Mitigated by the acceptance rule: a mode restated in a skill is a build failure, same guard class as every other single-home rule.
- **A self-contained spec drifts from the tree.** The known cost of the chosen posture. Mitigated by the evolution rule and ticket 08's conformance assertions; detected, when those lapse, by the same verification-at-use discipline that governs contexts.

## Out of scope

- New engineering activities (release, incident, migration workflows). Spec §10 permits them; nothing here builds them.
- Multi-agent orchestration beyond assignment/claim (spec §20 describes; ADR 0013 already implements the coordination floor).
- Anything about publishing — push, PRs, and stack submission stay the human's call.
