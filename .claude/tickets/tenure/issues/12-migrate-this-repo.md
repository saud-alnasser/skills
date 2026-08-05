---
title: test(configure): migrate this repository onto Tenure
status: resolved
blocked-by: [11]
---

## Problem

This repository was deliberately built using mattpocock's conventions so that `/configure` would have a genuine migration to perform rather than a no-op on an empty repo (ADR 0006). This ticket is that test.

## Outcome

Run `/configure` here. It should find and convert real content:

| Present now | Expected after |
| --- | --- |
| `CONTEXT.md` — Tenure glossary + routing table | `.claude/context.md` |
| `docs/adr/0001–0006` | `.claude/docs/decisions/` |
| `docs/agents/{domain,issue-tracker,triage-labels}.md` | folded into `CLAUDE.md` + `.claude/`, originals removed |
| `.scratch/tenure/` — this spec and these tickets | `.claude/tickets/` |
| `CLAUDE.md` — pre-implementation description, matt's Agent skills block | rewritten as entrypoint, <200 lines |
| `workflow.md` | **removed.** Its content now lives in the skills, and the reasoning behind every departure from it lives in the ADRs. Keeping it would leave a second, contradicting description of the workflow in the repo |
| `skills/` | the source of the installed skills |

## Acceptance

- Every ADR survives with its reasoning intact; none is rewritten.
- `.claude/context.md` carries a routing table, and `contexts/*.md` exists only where a domain genuinely earned one.
- `.claude/marker.json` is created and gitignored.
- Running `/configure` a second time reports "already migrated" and changes nothing.
- The whole migration is a single reviewable commit — this is also the first real test of `/commit`.

## Comments

The honest risk: `/configure` is being tested on the repository that defines it, which is the friendliest possible case. A second migration against an unrelated repo — ideally one with Cursor or Copilot rules rather than matt's — is what will actually find the bugs.

### The run — deviations from this ticket

Run as a real `/configure` invocation. What it did that this ticket did not say, and what it did not do that this ticket asked for:

**`.claude/marker.json` was not created**, against this ticket's acceptance. ADR 0005 and the shipped `commit` skill both hold that only the commit stage advances the Marker, and a marker written here would assert a verification that never happened. `.claude/.gitignore` covers it and the first commit creates it. **This ticket's acceptance line is the thing that is out of date**, not the run.

**`workflow.md` was already gone**, removed in `8a21732` before this ran. The migration row for it was a no-op.

**`docs/agents/domain.md` was discarded, not folded.** Every path in it — matt's `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/` — is one this migration removes, and the knowledge-layer rules replacing it are already template text in `CLAUDE.md`. Nothing in it survived to a destination.

**`issue-tracker.md`'s "Wayfinding operations" section was discarded**, as superseded: it drives `/wayfinder`, which Tenure does not have.

**The tracker stayed local markdown** despite a GitHub remote now existing. Ambiguous by the template's own test — the remote does not match where work is tracked — so it was asked rather than inferred, and the answer was local. Recorded with the reasoning in `.claude/tracker.md`.

**The status narrative left `CLAUDE.md`** for `.claude/tickets/tenure/STATUS.md`. It is ticket state, and the always-on file is paid for on every turn.

**One knowledge loss was found rather than created.** The old `CLAUDE.md` named `writing-great-skills` as the authoring standard, "in the user's skill set". It is not: `~/.claude/skills/` is empty. `.claude/contexts/skill-authoring.md` defines the terms this repository's own artefacts demonstrate and names the rest as unresolvable, rather than paraphrasing a document that cannot be read.

**The naming rule moved to `.claude/rules/skills.md`** — it is a discovered standard that fires only when a skill is authored, so the always-on file was the wrong home for it. `verify.ps1`'s guard moved with it. The suite caught this: the guard still pointed at `CLAUDE.md` and failed, which is the single-home discipline working as designed. It also caught a duplication introduced during the run, where the rule had been stated in both the rules file and the Domain Context.

### Not verified

**Idempotence is untested.** This ticket's acceptance asks that a second run report "already migrated" and change nothing. `/configure` has been run exactly once. Re-running it is the test, and it has not happened.

**`/review` was not run.** The migration was committed unreviewed, as a deliberate call rather than an oversight — `/commit` reported the missing stage and was told to proceed. So this ticket's "single reviewable commit" is reviewable but unreviewed, and the first real exercise of `/review` is still ahead alongside the dogfood checkpoint.
