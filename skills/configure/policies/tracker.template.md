# Tracker

<!--
  Installed by /configure at `.claude/policies/tracker.md`. This is the **one home** for
  which tracker this repository uses and how it is driven.

  Every skill that touches the tracker reads this file — /design when it cuts
  tickets, /implement when it claims one, /triage when it works incoming
  issues. A second copy of any of it is how two skills end up disagreeing
  about where the tickets are.

  Delete the rows that do not apply. Keep the file short: it answers "which
  tracker, and how", and nothing else. What happens to a ticket once somebody
  builds it — the model, the branch convention, how work lands — is
  `.claude/policies/version-control.md`'s, and branch naming lived here only because
  that file did not exist yet.
-->

## Which tracker

**GitHub** and **local markdown** are both first-class here. Neither is a
fallback for the other, and a repository may use either.

| Tracker | Tickets live in | Driven by |
| --- | --- | --- |
| **GitHub** | this repository's issues | `gh` — the invocations are in `.claude/tools/github.md` |
| **Local markdown** | `.claude/tickets/<effort>/` | files, one per ticket |

{Delete whichever row this repository does not use, and say why in one line if
the choice is not obvious — a repository with GitHub issues disabled, say.}

On GitLab, the same shape holds with `glab`; see `.claude/tools/gitlab.md`.

**Never guess the CLI.** A tracker operation with no entry in `tools/` is a
docs fetch, not an assumption.

## Where a spec lives

<!--
  The detect test lives here and nowhere else: which of the two shapes does the
  tree already hold? A `spec.md` sitting beside an effort's tickets is the
  per-effort layout; spec files sitting directly in the designs directory are
  the flat one.

  A tree holding neither — a repository that has written no spec yet — takes
  flat, the shape a new repository starts in, and never a blank: something reads
  this answer whether or not a spec exists, and a blank sends it guessing.

  A tree holding both is a defect to report rather than a choice to make,
  because an index built over one of them drops every row of the other.

  /configure answers this from the tree when the file is derived, and asks the
  tree again on every audit run.
-->

{Declare one of the two, naming the path a spec is written to. Keep the
paragraph that applies; delete the other.}

**Flat.** One spec per file, in the designs directory:
`.claude/designs/<slug>.md`.

**One per effort.** Each spec sits beside the tickets it governs:
`.claude/tickets/<effort>/spec.md`.

This is the **one home** for the answer. Anything that needs to know where a
spec is written reads it here rather than assuming a path — the format guide,
the stages that open a spec, and the script that regenerates the index over
them.

## What a ticket is

<!--
  The detect test lives here and nowhere else: does the version-control policy
  tie one ticket to one branch — one commit, one pull request? If it does, a
  ticket is branch-bound; if not, a ticket is tracked intent. /configure
  answers it from `.claude/policies/version-control.md` when this file is
  derived, and its audit re-reads that policy against the answer on every run.
-->

{Declare one of the two, and cite the version-control line the answer came
from. Keep the paragraph that applies; delete the other.}

**Branch-bound.** One ticket becomes one branch, which lands as one unit of
review. Work that produces no branch — a decision, an investigation — is not
a ticket here; `.claude/policies/maps.md` says where decision work lives.

**Tracked intent.** A ticket is a unit of tracked work, branch or none.
Decision tickets are tickets.

## Assignment

{How this repository records which human owns delivering a ticket — GitHub
assignees, a name in the ticket body, a project board column. Say it once.}

AEP reads Assignment and never writes it unasked.

## Roles

The five canonical **state** roles, and the label strings this repository
actually uses for them. The names on the left are what the skills say; the
strings on the right are what the tracker holds, and they are often different.

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

These are **triage roles** — they describe an issue somebody else opened, and
what has to happen before it can be worked. They are not the build lifecycle a
ticket moves through once `/design` has cut it; that vocabulary is `/design`'s.
Nothing carries both.

## External pull requests

{Whether this repository treats external PRs as a request surface, and who
counts as external — a non-member, a non-collaborator, anyone outside a named
team. `/triage` uses this to decide which PRs appear unasked-for; a PR named
explicitly is always triaged regardless.}

## Resolving a bare reference

{What `#42` means here — an issue, a PR, or ambiguous and to be resolved by
looking. Say it once, so no skill has to guess.}
