---
name: survey
description: Survey a codebase for deepening opportunities and present them as a visual report, then hand the chosen one to /design. Use when the user wants to know where the architecture is costing them.
disable-model-invocation: true
---

# Survey

Surface architectural friction and propose **deepening opportunities** — changes that turn shallow modules into deep ones. The aim is testability and navigability.

This is a **survey**. It finds candidates and it stops; the chosen one goes to `/design`, which is where planning happens (ADR 0011). Running a grill here would rebuild the whole planning surface inside a survey command, and the second copy is the one that drifts.

Built on a shared vocabulary:

- `codebase-design` owns the architecture terms — **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality** — and the principles behind them, including the deletion test and *the interface is the test surface*. Use those words **exactly**. Do not drift into *component*, *service*, *API*, or *boundary*.
- `.claude/context.md` and its Domain Contexts give the **domain** names, which are what a good seam gets named after. If Context defines *Order*, the card says *the Order intake module* — not *the FooBarHandler*, and not *the Order service*.
- `.claude/decisions/` records what has already been settled and is not to be re-litigated here.

## 1 — Scope, then explore

**Decide where to look before looking.** Deepening pays off by making future changes easier, so weight the parts of the codebase that keep changing.

- If the user named a direction — a module, a subsystem, a pain point — take it and skip the inference.
- Otherwise walk back a good stretch of history to find the hot spots, the files that keep coming up, and let those pull first. The invocation is in [`tools/git.md`](../tools/git.md). Scattered changes with no hot spot mean widening the net, not guessing.

Read the routing table in `.claude/context.md` and load the Domain Contexts for the area, plus the ADRs covering it, before exploring.

Then walk the codebase with the `Explore` subagent — this is a survey, and reading every candidate file into the parent's context spends it on the ones that will not make the report. Note where you feel friction:

- Where does understanding one concept mean bouncing between many small modules?
- Where is a module **shallow** — its interface nearly as complex as its implementation?
- Where were pure functions extracted for testability, while the real bugs live in how they are called?
- Where do coupled modules leak across a seam?
- What is untested, or hard to test through the interface it has?

Apply the **deletion test** to anything that looks shallow: would deleting it concentrate complexity, or just move it? *Concentrates* is the signal.

## 2 — Present the candidates

Write a self-contained HTML file to the operating system's **temp directory**, so nothing lands in the repository. Resolve it from `$TMPDIR`, falling back to `/tmp` or `%TEMP%` on Windows, and give each run its own timestamped file rather than overwriting the last one. Open it — `xdg-open` on Linux, `open` on macOS, `start` on Windows — and give the user the absolute path as well, because the opener fails silently often enough to matter.

Each candidate gets a card: the files involved, the friction in one sentence, what would change in one sentence, the wins in glossary terms, a **before/after diagram**, and a strength badge — `Strong`, `Worth exploring`, or `Speculative`. Close with the one you would do first, and why.

The scaffold, the diagram patterns, and the styling are in [HTML-REPORT.md](HTML-REPORT.md).

**Where a candidate contradicts an ADR, surface it only when the friction is real enough to warrant reopening that decision**, and mark it plainly on the card. Listing every refactor an ADR forbids trains the reader to ignore the callouts.

**Propose no interfaces yet.** Ask which one they want to pursue.

## 3 — Hand it to `/design`

Once a candidate is chosen, it becomes a planning problem, and `/design` owns planning end to end — the grill, the options, the tier, the tickets, and the vocabulary and Decisions that crystallise along the way.

Hand over what the survey learned and nothing more:

- the candidate, in `codebase-design` terms — which module is shallow, which seam leaks
- the evidence: the deletion-test result, what is hard to test, the friction observed
- the ADRs in the area, including any this would contradict
- the Domain Contexts already loaded

Then stop. **Do not grill here, do not write vocabulary, do not open an ADR.** Those are `/design`'s, and a survey that starts planning has quietly become a second planning surface with none of the gates.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
