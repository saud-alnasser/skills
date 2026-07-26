# feat(rules): distribute the engineering rules across the workflow

Status: ready-for-agent
Blocked by: —

## Problem

`workflow.md` lines 4229–4598 carry Repository Philosophy, Instruction Precedence, the Truth Hierarchy, and nineteen Engineering Principles. Nothing in tickets 01–12 says where any of it lands, and roughly half of it duplicates the user's global `~/.claude/CLAUDE.md`.

ADR 0007 settles ownership: Tenure owns these rules, the global file is trimmed, and each rule lives where it fires.

## Outcome

**1 — The `CLAUDE.md` template** that `/configure` writes. Always-on, so it stays small:

- Truth hierarchy — Codebase > Context > Decisions. Documentation changes to match reality, never the reverse.
- Verify before claiming — inspect source before any repository-specific claim. Names are not proof.
- The compression test — *will this improve future engineering decisions?* If no, don't store it.
- Claude never silently decides architecture — options, tradeoffs, a recommendation, then the user chooses.
- Instruction precedence: system → developer → user → `CLAUDE.md` → `.claude/context.md` → matching `contexts/*.md` → `CONTRIBUTING.md` → `README.md` → decisions → previous conversation. **`CONTRIBUTING.md` outranks `README.md`** (ADR 0007).
- Repository conventions outrank Tenure's defaults — detect before asserting (ADR 0008).
- Automation never writes repository knowledge. CI may validate; it must not modify `.claude/context.md`, `contexts/*`, or `docs/decisions|research|designs/*`. Those change only through `/design`, `/implement`, and `/configure`.
- Context is verified where it is used and healed where the break is found (ticket 02). This must be in `CLAUDE.md`, not in a skill — it has to hold on turns where no skill runs, which is most turns.
- **The cold-request path.** Most requests arrive without a command typed, and the compounding claim does not survive being opt-in. For a request that would **change code** — not for a question — `CLAUDE.md` requires: the Marker check, routing to the matching contexts, verifying what is relied on, and naming the classification out loud with a note that `/design` would grill it. Capture still happens: a concept that moves gets written. A question gets context loading and nothing else — no classification, no ceremony.
- Routing to `.claude/context.md`.

**2 — Rules inside the skills that enforce them:**

| Rule | Skill |
| --- | --- |
| Never guess APIs — verify version, signature, limits before use | `/research`, `/implement` |
| One concept per file · directories over verbose filenames · clear naming | `codebase-design`, `/implement` |
| Self-explanatory code · comments explain *why* · document public APIs | `/implement`, `/code-review` |
| Test layout matches repo convention; no unnecessary test structure | `tdd` |
| Root-cause over workaround; a required workaround records why, alternatives, and removal conditions | `/design` |

**3 — `.claude/rules/`** for standards `/configure` discovers in the repository, path-scoped where they apply to part of the tree.

**Cut:** "architecture over convenience" and "leave the repository better" — neither is checkable, both are no-ops against the model's default. Reinstate only if made concrete.

**Not restated:** "context provides orientation", "decisions preserve reasoning", "knowledge has layers" are definitions and live in `context.md`'s glossary. "Synchronize understanding" and "scale process with risk" are embodied by the verification discipline and the tier gates.

## Acceptance

- Every one of the nineteen principles is accounted for — placed, cut, or identified as embodied elsewhere. None silently dropped.
- No rule appears in two homes.
- The `CLAUDE.md` template is under 200 lines with routing included.
- A rule that must hold unconditionally is in `CLAUDE.md`, not in a skill — a rule inside a skill only fires when that skill runs.
