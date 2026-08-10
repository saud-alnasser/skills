---
owner: repository
status: accepted
load-when: a derived reference is found wrong in a configured repository, or the refresh path between plugin and repository is in question
sources: [skills/configure/TOOLS.md, skills/configure/tools/, .claude/decisions/0070-work-for-another-repository-leaves-as-a-report.md, .claude/tickets/downstream/spec.md]
supersedes: []
superseded-by: []
---

# A correction verified downstream returns upstream as evidence, not as an edit

Refreshing a derived reference gains a second direction. A repository that checks
an entry against a real tool version and finds it wrong writes the correction up
as a record and hands it back; the shipped reference is corrected from that
record, by whoever maintains it.

**One direction was all there was.** The audit re-checks an installed reference
against the repository it describes, and that was stated as *the only refresh
path*. The reasoning was sound for what it covered — a repository whose tooling
has not changed does not need the shipped text's changes — but it left no route
for the opposite case, where the repository is right and the plugin is wrong.

**That case is not hypothetical and not rare.** A configured repository's
references were found to be ahead of the plugin's on two entries, each corrected
against a version that was actually installed. The shipped text meanwhile denied
capabilities the tool has had for releases. Real, version-tested knowledge was
stranded downstream while the framework kept asserting the false version, and this
will recur for every tool the framework references.

**It returns as evidence because the boundary rule requires exactly that.** A
finding about another repository is a report handed back, never a change landed
there. Making the return an edit — a session in the configured repository editing
the plugin's reference — would be the crossing that produced this whole effort,
sanctioned. The two rules interlock instead of competing: one says findings leave
as reports, and this says where the report goes and what is done with it.

**Evidence is the right shape for a second reason.** A tool fact is true of a
version, and evidence is dated and never maintained — what was observed on
`gh 2.96.0` stays true of `gh 2.96.0`. A correction that arrived as a patch would
lose the version it was checked against, which is the only thing that lets a later
reader tell a stale fact from a wrong one.

## Considered Options

- **A formal upstream-contribution path** — a pull request from the configured
  repository against the plugin. Rejected: it is publishing, which is the human's
  call, and it puts a session that is not this project's in the position of
  landing changes here, which ADR 0070 forbids for good reasons.
- **Leave the path one-directional and rely on the maintainer noticing.** That is
  the arrangement that produced two false shipped facts and left them standing.
  Rejected as the status quo, restated.
- **Have `/configure`'s audit push corrections upstream automatically.** Rejected:
  the audit cannot tell a deliberate local derivation from a correction of general
  value — the same ambiguity that makes it report rather than repair elsewhere —
  and an automatic push would propagate one repository's local fit to everyone.

## Consequences

**The two directions answer different questions and both are kept.** Downward, the
audit asks whether the installed reference still describes this repository's
tooling. Upward, a repository asks whether the shipped text is true of the version
it just ran. Neither subsumes the other, and a refresh section naming only one
reads as though it named both.

**A correction that lands only in a project's memory is the failure this
replaces.** Two such corrections were saved to one project's memory directory,
which reaches no other project — the same one-directional gap in a second place.
A record handed back is what makes a correction reach every repository rather than
the one it was found in.
