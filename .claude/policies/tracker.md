---
owner: repository
tracker: local-markdown
spec-home: per-effort
ticket-model: tracked-intent
---

# Tracker

The one home for which tracker this repository uses and how it is driven. The three frontmatter fields above are the declared repository facts; the prose elaborates them.

## Which tracker

**Local markdown** (`tracker` above). Tickets live as files under `.claude/tickets/<effort>/`.

| Tracker | Tickets live in | Driven by |
| --- | --- | --- |
| **Local markdown** | `.claude/tickets/<effort>/` | files, one per ticket |

The GitHub remote (`saud-alnasser/skills`) is a code remote only. Issues are enabled there and empty, and that is deliberate: this repository's ticket history *is* the build record of the framework, and it is read far more often than it is filed against.

- **Never guess the CLI** — a tracker operation with no entry in `tools/` is a docs fetch, not an assumption.

## Where a spec lives

**One per effort** (`spec-home` above). Each spec sits beside the tickets it governs: `.claude/tickets/<effort>/spec.md`.

Read off the tree rather than chosen: every effort directory here holds its spec beside its `issues/`, and there is no `.claude/designs/` directory at all. This is the **one home** for the answer — anything needing to know where a spec is written reads it here, including the script that regenerates the index over them, which writes to `.claude/tickets/map.md` because under this layout the index spans every effort while each spec belongs to one.

## What a ticket is

**Tracked intent** (`ticket-model` above). A ticket here is a file recording work to be done — the file, not a branch, is the ticket. The detect test asks whether the version-control policy ties one ticket to one branch, one commit, and one pull request; it ties none of the three — the unit is the **effort** (`.claude/policies/version-control.md`, "The unit is the effort, not the ticket") — so a ticket exists and resolves as a file, the Claim is the effort's branch rather than the ticket's, and decision tickets are tickets exactly as `.claude/policies/maps.md` describes.

The reasoning here previously rested on the *absence* of pull requests, which `.claude/evidence/drift/2026-08-03-tracked-intent-rests-on-a-falsified-landing-fact.md` recorded as false — work does land by pull request. The finding stays as the dated record; the conclusion did not flip: it was unsupported rather than refuted, and now rests on the unit instead of the landing mechanism.

- One effort per directory: `.claude/tickets/<effort>/`; the spec is `<effort>/spec.md`
- Tickets are one file each at `<effort>/issues/NN-<slug>.md`, numbered from `01` — never a combined file
- Every lifecycle fact is a **declared field**: `title`, `status`, `blocked-by` on every ticket; `part-of` and `superseded-by` where they apply. The format is `.claude/policies/tickets.md`'s
- The title is the `title` field, Conventional Commits form; there is no `# ` heading — the id is the filename, so a ticket opens at its first section (ADR 0058)
- Conversation appends at the bottom under `## Comments`, and is where a deviation from the ticket is recorded
- `blocked-by: []` means nothing blocks it; blockers are bare two-digit ids within the same effort

## Assignment

Not recorded — single maintainer, no assignee field, no board. Where a ticket needs a human rather than an agent it says so in `status`, which is about the *work*, not who owns it.

- **AEP reads Assignment and never writes it unasked.**

## Roles

The five canonical **state** roles and the label strings this repository actually uses — the names on the left are what the skills say, the strings on the right are what the tracker holds:

| Canonical | Label in this repository |
| --- | --- |
| `needs-triage` | *unused* |
| `needs-info` | *unused* |
| `ready-for-agent` | *unused* |
| `ready-for-human` | *unused* |
| `wontfix` | *unused* |

The two **category** roles, the same way:

| Canonical | Label in this repository |
| --- | --- |
| `bug` | *unused* |
| `enhancement` | *unused* |

- **These are triage roles — an incoming issue's vocabulary, never the build lifecycle** — that vocabulary is `/design`'s, and nothing carries both.

## External pull requests

The repository is public with no collaborators and no PR history. Nothing is treated as an external request surface yet; a PR named explicitly is triaged like any other work.

## Resolving a bare reference

A bare two-digit number is a **ticket** in the current effort — `blocked-by: [09]`, "ticket 12". It is never a PR or a GitHub issue, because neither exists here.
