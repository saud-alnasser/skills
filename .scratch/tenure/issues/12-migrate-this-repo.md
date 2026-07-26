# test(configure): migrate this repository onto Tenure

Status: ready-for-human
Blocked by: 11

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
