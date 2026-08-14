---
owner: repository
---

# Tracker

<!--
  Installed by /configure at `.claude/knowledge/tracker.md`, derived per
  repository: the **one home** for which tracker this repository uses and how
  it is driven. Every skill that touches the tracker reads this record — a
  second copy of any of it is how two skills end up disagreeing about where the
  tickets are. What happens to a ticket once somebody builds it is
  `version-control.md`'s.

  The installed copy declares `owner: repository`, the firing condition that
  puts it on a stage's row, and the three facts below as frontmatter fields —
  the extension points through which a repository varies the framework's
  tracking defaults. A stage acts on the fields; the prose elaborates them.

  Every `##` heading below is one record's address, and the build mints the id
  it is bound by into `spans`. An author writes the headings and no ids.
-->

{The installed record's frontmatter — the declared repository facts, written by
/configure from the tree and confirmed with the user:}

```yaml
---
owner: repository
type: norm
subject: tracker
fires-when: stage
stages: [triage, design, implement, review, commit]
tracker: github | local-markdown
spec-home: flat | per-effort
ticket-model: branch-bound | tracked-intent
---
```

## Which tracker

**GitHub** and **local markdown** are both first-class; neither is a fallback. The `tracker` field declares which one this repository uses, and the prose says why where the choice is not obvious.

| Tracker | Tickets live in | Driven by |
| --- | --- | --- |
| **GitHub** | this repository's issues | `gh` — the invocations are in the forge reference |
| **Local markdown** | `.claude/tickets/<effort>/` | files, one per ticket |

{Delete whichever row this repository does not use. On GitLab the same shape
holds with `glab`, and the forge reference is that tool's.}

## A tracker operation with no reference is a docs fetch

- **Never guess the CLI** — a tracker operation with no entry in the tool references is a docs fetch, not an assumption.

## Where a spec lives

<!--
  The detect test lives here and nowhere else: a `spec.md` beside an effort's
  tickets is the per-effort layout; spec records in the store are the flat one.
  A tree holding neither takes flat — the shape a new repository starts in —
  never a blank, because something reads this answer whether or not a spec
  exists. A tree holding both is a defect to report, not a choice to make: a
  query built over one drops every row of the other. /configure answers from
  the tree at derivation and re-asks on every audit.
-->

{Declare in the `spec-home` field and name the path here. Keep the record that
applies; delete the other.}

This is the **one home** for the answer — the format guide, the stages that open a spec, and the query over them all read it here rather than assuming a path.

## Flat — one spec per file

**Flat.** One spec per file, as a `spec` record in the store: `.claude/knowledge/<slug>.md`.

## One per effort — beside the tickets it governs

**One per effort.** Each spec sits beside the tickets it governs: `.claude/tickets/<effort>/spec.md`.

## What a ticket is

<!--
  The detect test lives here and nowhere else: does the version-control record
  tie one ticket to one branch — one commit, one pull request? If it does, a
  ticket is branch-bound; if not, tracked intent. /configure answers it from
  `version-control.md` at derivation, and the build re-reads that record
  against the answer on every run.
-->

{Declare in the `ticket-model` field, citing the version-control line the
answer came from. Keep the record that applies; delete the other.}

## Branch-bound — one ticket is one branch

**Branch-bound.** One ticket becomes one branch, which lands as one unit of review. Work that produces no branch — a decision, an investigation — is not a ticket here; the record covering decision work says where it lives.

## Tracked intent — a ticket is a unit of tracked work

**Tracked intent.** A ticket is a unit of tracked work, branch or none. Decision tickets are tickets.

## Assignment

{How this repository records which human owns delivering a ticket — GitHub
assignees, a name in the ticket body, a board column. Say it once.}

- **AEP reads Assignment and never writes it unasked.**

## Roles

The five canonical **state** roles and the label strings this repository actually uses — the names on the left are what the skills say, the strings on the right are what the tracker holds:

| Canonical | Label in this repository |
| --- | --- |
| `needs-triage` | {label} |
| `needs-info` | {label} |
| `ready-for-agent` | {label} |
| `ready-for-human` | {label} |
| `wontfix` | {label} |

The two **category** roles, the same way:

| Canonical | Label in this repository |
| --- | --- |
| `bug` | {label} |
| `enhancement` | {label} |

- **These are triage roles — an incoming issue's vocabulary, never the build lifecycle** — that vocabulary is `/design`'s, and nothing carries both.

## External pull requests

{Whether this repository treats external PRs as a request surface, and who
counts as external. `/triage` uses this to decide which PRs appear
unasked-for; a PR named explicitly is always triaged.}

## Resolving a bare reference

{What `#42` means here — an issue, a PR, or ambiguous and resolved by looking.
Say it once, so no skill has to guess.}
