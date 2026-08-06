# refactor(knowledge): a local ticket declares its lifecycle facts as fields

Status: open
Blocked by: —
Part of: declared-fields

## Problem

A ticket on a local-markdown tracker states its title as an `# ` heading and its status, edges, and effort as prose lines beneath it. Every one of those is machine-read: the title is the Conventional Commit subject the ticket's commit writes from and the source of the branch name, the status drives the lifecycle, and `Blocked by:` is what the frontier computation reads to decide what is claimable.

110 ticket files carry them today. Nothing parses them structurally.

## Outcome

A local ticket declares `title`, `status`, `blocked-by`, `part-of`, and `type` as frontmatter fields. The `# ` heading is dropped — ADR 0058 has the reasoning and names the cost, which is that a ticket file now opens with its first section.

The shared-forge form is untouched: on a forge the lifecycle rides native issue state and the edges stay in the issue body, because a forge owns those facts natively. That asymmetry is the decision, not a gap to close later.

`type` ships as a field for decision tickets even though no ticket in this tree uses one today — the format carries it, so the field carries it.

All 110 existing files convert. The transformation is deterministic, so it is scripted and its output checked, rather than hand-edited at that scale.

Templates first, per ADR 0025.

## Coordination

**This ticket rewrites every ticket file in the tree, including the other seven in this effort.** Within the effort's single branch that is sequencing rather than conflict — `.claude/policies/version-control.md` makes the effort the unit and does not dispatch a set here, so nothing runs alongside it. Take it **last**, once its siblings have resolved, so their files convert in the same pass as the other 102 rather than being written in one format and rewritten in another.

## Acceptance

- No ticket file under a local-markdown tracker carries `Status:`, `Blocked by:`, `Part of:`, or `Type:` as a prose line, and the suite fails if one is reintroduced.
- No ticket file carries an `# ` heading; the title is read from the field.
- The permitted status values are asserted, and the triage-role strings this repository actually uses are among them — the union in the tracker policy, not a narrowed set.
- `blocked-by` is a list, so an empty list means unblocked and the `—` sentinel disappears rather than being parsed.
- Whatever computes the claimable frontier reads the fields, and the suite fails if it still matches a prose line.
- All 110 files are converted by a script whose output is verified, not by hand.
- The forge form is provably unchanged: the suite fails if the tickets policy describes frontmatter on a shared tracker.
- The guard is confirmed to fail against a deliberate reintroduction of the old prose form.
