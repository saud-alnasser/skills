# feat(tracker): hierarchy, relationships, labels, and title conventions

Status: resolved
Blocked by: 09

## Problem

`workflow.md` lines 3399–3665 define issue and PR conventions that ticket 09 doesn't place — it covers only where the tracker *config* lives. Most of this overlaps matt's `triage` and the ticket-splitting now inside `/design`, so the work is reconciling rather than writing.

Two failure modes to design against: the tracker becoming a knowledge store, and the tracker **booming** into hundreds of AI-generated micro-tickets nobody reads.

## Outcome

### Tracking only

Issues track work. Engineering knowledge lives in the codebase, context, and decisions — never in an issue body. No implementation diaries. Detailed engineering belongs in a spec under `.claude/docs/designs/`, referenced by the ticket, not pasted into it.

### Anti-booming

The checkable rule: **a ticket must have an outcome someone can observe when it closes.** If closing it produces nothing visible, it is a step inside another ticket, not a ticket.

- **Deepen, don't widen.** A small set of parent tickets, each with sub-tickets where the work divides — never a flat spray of siblings.
- **Every ticket after the first declares an edge.** `Part of:` or `Blocked by:`, at least one. A ticket with no edges is either the root of the effort or a stray, and this is checkable: scan the set, and any edgeless non-root ticket is a booming symptom caught before it spreads.
- Never create a ticket for: rename a variable, move a file, update a comment. Those live inside an existing ticket.
- Structure is carried by relationships, not by ticket count: `part of` (parent/child), `blocks` / `blocked by`, `related`.

Representation:

| Tracker | `part of` | `blocks` |
| --- | --- | --- |
| Local markdown | `Part of: NN` line | `Blocked by: NN, NN` line |
| GitHub | native sub-issues where available, else task list in the parent | native blocking links, else `Blocked by:` in the body |

### Build ticket lifecycle

Distinct from the triage roles, which describe *incoming* issues. A build ticket that `/design` created is already agent-ready and is never triaged.

```
open       created by /design, nothing set
claimed    /implement claims it BEFORE any work,
           and saves — this is what stops two
           sessions taking the same ticket
resolved   /implement sets it after the commit lands
obsolete   the work is no longer needed.
           requires a one-line reason. never deleted.
```

`obsolete` is not optional bookkeeping. On a multi-ticket effort, earlier tickets routinely make later ones unnecessary — ticket 3 removes the need for ticket 7. Without this state, ticket 7 stays open and unblocked forever, and `/implement` will eventually claim it and build something nobody needs. Set by `/design` when re-planning, or by `/implement` when it claims a ticket and finds the work already done or no longer required — in which case it sets the state, gives the reason, and stops rather than inventing work.

The **frontier** is every ticket that is open, unblocked, and unclaimed. **Lowest number wins** — `/implement` does not choose, so two sessions working the same effort stay deterministic.

### Labels — reuse first

1. **List what exists** — `gh label list`, or the configured local label file.
2. **Map onto an existing label** wherever one fits. This is the default outcome.
3. **Create only when nothing fits**, and match the repo's detected style: prefix convention (`type:` / `kind/` / bare), casing, separator, colour family.
4. Never create a label that duplicates workflow state already carried by `Status:`.

### Titles and PRs

Conventional Commits (`type(scope): summary`) is the **default, not a mandate** — applied when the repository is silent (ADR 0008). Detect first: read `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, and recent `git log`. Where the repo documents or demonstrates a different convention, follow it.

Scope names the engineering domain. Reject generic scopes (`misc`, `stuff`, `update`).

PR descriptions cover problem, solution, architectural impact, testing performed, related issues, and breaking changes — never a commit-by-commit account.

## Acceptance

- A ticket whose closure produces nothing observable is rejected rather than created.
- Labels are reused by default; any label created matches the style of the labels already in that repo.
- Conventional Commits is applied only after confirming the repo documents nothing else.
- Both trackers express `part of` and `blocks`.
- Nothing in this ticket contradicts `triage`'s existing role vocabulary — reconcile, don't fork.

## Comments

**Part of this landed early, in ticket 03.** `/design`'s `TICKETS.md` shipped
with `ready-for-agent` as a build-ticket status, conflating the triage roles
with the build lifecycle this ticket defines. Corrected to `open` / `claimed` /
`blocked` / `resolved` / `obsolete`, with the distinction stated in the file.
`verify.ps1` now asserts both halves — the lifecycle is defined, and no triage
role appears on a `Status:` line — and both assertions were mutation-tested.

**`blocked` is an addition to this ticket's list.** Ticket 03 requires
`/implement` to hand a ticket back as blocked, with the reason under
`## Blocked`, and the four states here have nowhere to put that. Fold it in
rather than treating it as a fork.

**The `obsolete`-on-claim branch also landed early, in ticket 04.**
`/implement` claiming a ticket and finding the work already done or no longer
required sets the state, gives the reason, and stops rather than inventing
work — asserted in `verify.ps1` under ticket 04.

**Still open for this ticket:** `/design`'s `TICKETS.md` and `MAP.md` are
written local-markdown-only — they hardcode `.claude/tickets/` and file-based
`Status:` lines, with no branch on tracker choice. Decision 35 makes GitHub and
local markdown both first-class, so the representation table above has to reach
those two files. Ticket 09 places `.claude/tracker.md`; this ticket has to make
`/design` read it.

**Ticket 09 has now shipped `configure/tracker.template.md`**, so the file this
ticket needs exists. `/implement` reads it as of ticket 09 — its §1 names the
config as the source for where tickets live and how claiming is expressed.
`/design` is the remaining reader, and `verify.ps1`'s reader list under ticket
09 is where to add it so the criterion cannot pass on an empty list again.

**The label *vocabulary* is placed; the label *procedure* is still this
ticket's.** Ticket 09 folded the five state roles and two category roles into
`tracker.template.md` as a canonical-name-to-label-string mapping. The reuse
procedure above — list what exists, map onto it, create only when nothing fits,
match the repository's prefix and casing — is not written anywhere yet.

---

**Resolved.** The remaining four items landed: `blocked` was already folded in
by ticket 03, and `TICKETS.md`, `MAP.md`, and the label procedure are done.

**The label procedure went to `/triage`, not to `tracker.template.md`.**
Ticket 09's split decides it: the template is a *form a repository fills in*,
so a Tenure procedure written there becomes user-editable config. `/triage` is
the skill that creates a label, and the per-repository strings stay where 09
put them. `verify.ps1` asserts both halves — the procedure in the skill, the
mapping still in the template and the procedure *not* copied into it.

**The GitHub column promised a subcommand that does not exist.** The first
draft of the representation table offered *"native blocking links"*.
`tools/github.md` states plainly that `gh` has **no blocking or sub-issue
subcommand** and gives two routes, neither of them that. A format file
promising a native invocation is exactly the guessed CLI decision 34 forbids,
and the table now says only what the tool reference documents. Asserted
negatively too: the table must not contain the phrase.

**`related` and the booming scan were in the ticket and missing from the
build.** The Outcome names three relationship types and this shipped two; and
decision 37's *checkable* half — *"scan the set, and any edgeless non-root
ticket is a booming symptom"* — is the whole reason edges are mandatory, but
nothing said to run the scan. Both added.

**The `Status:` branch was half-landed.** The paths branched on the tracker;
the *status form* did not, so `MAP.md` still said `set Status: resolved`
unconditionally and `TICKETS.md` showed a `Status:` block with no caveat.
Found by review. Both branch now — and the fix immediately produced a second
home, because `/implement` already carried the same mapping near-verbatim from
ticket 09. `TICKETS.md` owns the ticket format, so it owns which tracker
expresses a state which way; `/implement` points, and a `$rulePattern` guard
stops it coming back.

**The PR description shape moved out of `tools/github.md`.** It was placed
there because `gh pr create` is where someone drafting one is standing — but
`tools/` is a task-to-command reference for one CLI, and ADR 0008 classes the
PR description shape as a Tenure *convention*. It sits in `CLAUDE.md`'s
Conventions beside Conventional Commits, where it also reaches `glab`.

**`gh label list` had no entry, and ticket 15's own guard caught it** — the
same shape as ticket 09's `git bisect`. Added with the gotchas that earn an
entry: `create` fails on an existing name rather than editing it, and
`--color` takes a bare hex.

**Five assertions were weaker than they read**, each found by review or by
mutation: the never-ticket list matched *"rename a column"* from the
wide-refactor section; the tracker-config check passed on any mention while
the step needing the branch stayed local-only; the commit-convention guard
banned one word rather than the rule; the GitHub-edge alternation was
satisfied by whichever column survived; and `not a ticket` as a bare
alternation branch subsumed the redirect it was meant to require.

**The Standards axis died on an API session limit**, as it did in ticket 09.
Those checks were run inline instead: an `_Avoid_` sweep over every added line
against all of `CONTEXT.md`'s lists (three hits, all different senses of the
word — *implementation diary*, the map as an *index*, the tools *reference*),
a sediment sweep of every added sentence against all seventeen skills, and a
pass over the new block for subsuming alternations and array `-match`.

329 assertions, 36 mutations. All seven harnesses re-run clean — 298 mutations.
