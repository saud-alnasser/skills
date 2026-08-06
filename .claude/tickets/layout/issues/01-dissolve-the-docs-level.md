---
title: refactor(layout): dissolve the docs level in the shipped layout
status: resolved
blocked-by: []
---

## Problem

`.claude/docs/` groups four artifact kinds, of which only decisions exists in a repository that has not yet run `/design` or `/research`. It also buries Decisions one directory below Context, when `CLAUDE.md`'s own knowledge-layers table presents them as peers — so the layout Tenure installs contradicts the model it teaches, on the first page a reader sees.

## Outcome

The layout Tenure ships and installs puts decisions and designs beside Context and groups research and prototype write-ups under `evidence/`. Every shipped skill that writes to or reads from one of those locations names the new one, and a repository already running Tenure on the old layout is carried across rather than left behind.

## Acceptance

- No file under `skills/` names a `.claude/docs/` path.
- The shipped migration branch converts an existing Tenure repository's layout, preserving each decision record's number and slug.
- `/configure` still pre-creates none of these directories — each is created by whichever command first has something to put in it.
- The verifier's legacy-path table rejects the pre-change paths, and a deliberate reintroduction of one fails the build.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Four deviations from the ticket as written, each forced rather than chosen.

**Out-of-scope records moved too.** The spec's tree names four occupants of `docs/`; there are five. Leaving the fifth would have resurrected `docs/` for a single tenant and failed the first acceptance criterion. `OUT-OF-SCOPE.md` already argued it sat "with the other evidence", so `evidence/out-of-scope/` is where its own reasoning put it. `.claude/context.md`'s Evidence entry was widened to match.

**Verifier ticket ids are now `<effort>/NN`.** A second effort reusing `01`–`06` collided with the bare two-digit `-Ticket` filter, so a `layout/01` section could not be added without it. Chosen by the user from three options. Existing sections became `tenure/NN`; `README.md` and `.claude/rules/skills.md` were repaired to match.

**The shipped `.gitignore` had a live defect.** `prototypes/` is unanchored, and git applies such a pattern at every depth — so it also matched `evidence/prototypes/` and silently ignored the write-ups that are meant to be kept. Verified against a scratch repository rather than reasoned about. ADR 0018 expects moving the write-up to resolve the code/write-up collision "as a side effect"; it does not, and the anchor is what does. Fixed in the template and in this repository's copy. **ADR 0018 is not edited** — its reasoning is frozen, and the correction lives here and in the assertion.

**A single-home breach was introduced and then caught.** `MIGRATION.md` restated the number-and-slug rule `ADR-FORMAT.md` already owned, and the `$rulePattern` guard written beside it matched only the new wording, so the build passed with both copies present. This is the second recorded instance of the failure `.claude/rules/skills.md` warns about, and it argues that guard is written *before* the rule it guards, against the existing wording. The rule is a pointer now and the guard matches the subject.

Nineteen assertions cover this ticket. Every new guard was tested by deliberate reintroduction before being trusted, per `.claude/rules/skills.md`.

`/review` ran both axes as two sequential independent passes rather than parallel subagents, because this session's harness bars spawning agents unasked. Spec: 0 findings. Standards: 4 hard violations, all fixed before the commit.
