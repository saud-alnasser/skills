# Tracker

## Which tracker

**Local markdown.** Tickets live as files under `.claude/tickets/<effort>/`.

| Tracker | Tickets live in | Driven by |
| --- | --- | --- |
| **Local markdown** | `.claude/tickets/<effort>/` | files, one per ticket |

The GitHub remote (`saud-alnasser/skills`) is a code remote only. Issues are enabled there and empty, and that is deliberate: this repository's ticket history *is* the build record of the framework, and it is read far more often than it is filed against.

**Never guess the CLI.** A tracker operation with no entry in `tools/` is a docs fetch, not an assumption.

## What a ticket is

**Tracked intent.** A ticket here is a file recording work to be done — the file, not a branch, is the ticket. The detect test asks whether the version-control policy ties one ticket to one branch, one commit, and one pull request. It ties none of the three: the unit is the **effort**, and a ticket is one of several amending its single commit (`.claude/policies/version-control.md`, "The unit is the effort, not the ticket"). So a ticket exists and resolves as a file, the Claim is the effort's branch rather than the ticket's, and decision tickets are tickets exactly as `.claude/policies/maps.md` describes.

The reasoning here was previously the *absence* of pull requests, which `.claude/evidence/drift/2026-08-03-tracked-intent-rests-on-a-falsified-landing-fact.md` recorded as false — work does land by pull request. That finding is the dated record of the check and stays as it is; what it falsified is repaired above. The declaration did not flip, and the finding was careful to say it might not: the conclusion was unsupported rather than refuted, and it now rests on the unit instead of on the landing mechanism.

- One effort per directory: `.claude/tickets/<effort>/`
- The spec is `.claude/tickets/<effort>/spec.md`
- Tickets are one file each at `<effort>/issues/NN-<slug>.md`, numbered from `01` — never a combined file
- The title is the `# ` heading, in Conventional Commits form: `chore(skills): vendor the primitives and rewrite their paths`
- `Status:` and `Blocked by:` are lines near the top
- Conversation appends at the bottom under `## Comments`, and is where a deviation from the ticket is recorded

`Blocked by: —` means nothing blocks it. Blockers are bare two-digit ids within the same effort.

## Assignment

Not recorded. Single maintainer, no assignee field, no board. Where a ticket needs a human rather than an agent it says so in `Status:`, which is about the *work*, not about who owns it.

AEP reads Assignment and never writes it unasked.

## Roles

The canonical roles and the strings this repository actually uses:

| Canonical | String here |
| --- | --- |
| `needs-triage` | *unused* |
| `needs-info` | *unused* |
| `ready-for-agent` | `ready-for-agent` |
| `ready-for-human` | `ready-for-human` |
| `wontfix` | `obsolete` |

Category roles are not recorded separately — the Conventional Commits type in the ticket title carries it: `fix(...)` is a bug, `feat(...)` is an enhancement.

**One deviation from the standard shape, recorded rather than tidied away.** The tracker template holds that triage roles and the build lifecycle are separate vocabularies and that nothing carries both. Here, one `Status:` line carries both: `ready-for-agent` and `ready-for-human` are triage roles, `resolved` is the build lifecycle's terminal state, and `blocked` is derived from the `Blocked by:` line rather than written.

Treat the union above as the vocabulary and the split as a known wrinkle in this repository — not as licence to introduce a second field. Which of those strings are in the tree at any moment is a census rather than a convention: read it off the tickets, and do not record it here, where it is wrong again the next time one closes.

## External pull requests

The repository is public with no collaborators and no PR history. Nothing is treated as an external request surface yet; a PR named explicitly is triaged like any other work.

## Resolving a bare reference

A bare two-digit number is a **ticket** in the current effort — `Blocked by: 09`, "ticket 12". It is never a PR or a GitHub issue, because neither exists here.
