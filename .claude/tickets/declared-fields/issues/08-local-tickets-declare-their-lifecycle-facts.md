---
title: refactor(knowledge): a local ticket declares its lifecycle facts as fields
status: resolved
blocked-by: []
part-of: declared-fields
---

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

## Comments

**Scoped but not started.** Tickets 04 and 05 were built and landed in the same invocation; this one was left for a run of its own, because it rewrites 112 files and a conversion abandoned half-way leaves a tree that no ticket describes. Two findings from scoping it, so the next run does not rediscover them:

**`Status: superseded` is in use on nine ticket files and is defined nowhere.** Not in `.claude/policies/tickets.md`, not in the shipped template, not in `.claude/policies/tracker.md`'s role table, and not in the lifecycle list `scripts/verify.ps1` already asserts against — which is `open`, `blocked`, `resolved`, `obsolete`. The census across all 112 files is 97 `resolved`, 9 `superseded`, 4 `open`, 1 `blocked`, 1 `obsolete`; no file carries a triage role today, and none carries a `Type:` line.

This blocks the acceptance criterion about permitted values, which cannot be written until the union is known. It is a real fork rather than an oversight to tidy: either the vocabulary gains `superseded` because the repository demonstrably uses it — which is what ADR 0008 says to do when the repository's own convention differs from the workflow's — or those nine are wrong and become `obsolete`, which rewrites the recorded outcome of nine closed tickets. **Do not decide it inside the conversion.**

**The prose form is legitimate in several shipped files, so the sweep needs scoping rather than a tree-wide match.** `skills/configure/policies/tickets.template.md` shows it because it is the format; `skills/configure/policies/maps.template.md` shows it for decision tickets, which are sections of a design document rather than files, and which that policy already says the claiming and `Status:` machinery does not reach; `skills/implement/SKILL.md` and `skills/configure/policies/version-control.template.md` quote `Blocked by: 01` while explaining what the edge means. A guard anchored on `(?m)^Status:` across `skills/` would fire on all four. The subject is a ticket *file* under a local-markdown tracker, and the sweep should say so.

**`Blocked by:` carries twelve distinct shapes** across the tree, from `—` through `01, 02, 03, 04, 05, 06`, so the conversion to a list is mechanical but the sentinel appears in 39 files.

## Answered before the conversion

Both questions above were put to the user and answered. **Do not re-litigate them in the build; the census that produced them is recorded here so the reasoning is checkable rather than remembered.**

**`superseded` is documented, not converted away.** The nine are not scattered drift: **all nine sit in the `streamline` effort**, each carries a `Superseded by: <ticket> (ADR 0030)` line naming its replacement, and ADR 0030 sanctioned the supersession. So the tickets policy gains `superseded` as a fifth terminal state — *replaced by a named ticket*, distinct from `obsolete`, which is *dropped outright*. ADR 0008 is the ground: where the repository's own convention differs from the workflow's default, the repository wins. Rewriting the nine to `obsolete` was the alternative and was rejected — it would restate nine closed tickets' outcome and collapse a distinction their own `Superseded by:` line draws.

**There is a fifth prose line this ticket's acceptance never named, and it converts too.** `Superseded by:` appears on those nine and on nothing else. The acceptance lists `Status:`, `Blocked by:`, `Part of:` and `Type:`; leaving this one as prose would put both forms in a single file, which is the state the effort was cut to end. It becomes `superseded-by`, matching what `.claude/policies/decisions.md` already declares for ADRs. The symmetric `supersedes` half was offered and declined: no ticket declares the forward direction today, and a field nothing uses is sediment.

**The full census, so the conversion can be checked against it rather than against a memory:** 112 files — 101 `resolved`, 9 `superseded`, 2 `open` (this ticket and one other at the time of counting), 1 `obsolete`. No file carries a triage role, and no file carries a `Type:` line, so `type` ships as a format-level field for decision tickets and no build ticket declares it.

## Built

113 files converted by script — the count moved from 110 as the effort grew — with the dry run inspected before anything was written. Every hunk is header-only; no body line moved.

**What `/review` found, and what happened to it. The worst was a data defect in the conversion itself:**

- **22 files carried the id inside `title` — fixed.** `title: 01 — feat(specs): …`, because 22 originals used the `# <NN> — type(scope)` heading form and the converter took the whole heading. The *same diff* wrote "the id is the filename, so it is not restated inside". Stripped, and now asserted.
- **Nothing asserted `title` or `part-of` at all — fixed for `title`, and the claim corrected for `part-of`.** Deleting either field left all six assertions green, which is exactly what let the defect above land. `title` is now required and checked for a restated id. `part-of` is genuinely absent on 27 tickets, so the tracker policy's new sentence — which claimed every ticket declares it — was the thing that was wrong, and it now says which fields are on every ticket and which are on the tickets they apply to.
- **The template's fifth state was unasserted — fixed.** Deleting the whole `superseded` block from the *shipped template* left 1042 passing, because only the installed copy was read. ADR 0025 makes the template the copy that leads.
- **"the four states" was false in both copies — fixed**, and `superseded` gained the forge mapping it lacked: closed as not planned, like `obsolete`, but with the comment naming the replacement rather than a reason.
- **The frontier still read and wrote the prose form — fixed.** This is acceptance criterion 5 and neither axis found it met. `skills/implement/SKILL.md` computes the frontier and still said `Blocked by: 01`, `Status: blocked`, `Status: resolved`; so did `/commit`, `/triage`, and both version-control copies. All moved onto the fields.
- **The retired form survived in the maps policy — resolved by stating why it stays.** A decision ticket is a *section of the design document*, not a file, so it has nowhere to put frontmatter. That is now said in both copies rather than left as a contradiction with the format it points at.
- **The forge-frontmatter guard checked one line — widened, then corrected again.** Review moved the offending sentence one line down and it passed. Widening it file-wide then fired on the paragraph that *forbids* forge frontmatter, because a prohibition necessarily mentions both. It now requires every sentence naming the forge and frontmatter together to also negate — which is the difference between a prohibition and a claim.
- **The roles half of the vocabulary was collected but never checked non-empty — fixed.** No ticket carries a triage role today, so a derivation that silently collapsed would have narrowed the union invisibly.
- **The two sweeps disagreed on fenced blocks — reconciled.** The H1 sweep masked fences and the prose sweep did not, so a ticket quoting the retired form inside an example would have been a false positive in one and invisible to the other.

**One criterion rests on something outside the diff.** *"converted by a script whose output is verified"* — the script is in the session scratchpad rather than the tree, so a reader cannot check it. What is checkable is the output, and that is what the assertions do.

**Why this ticket was left for a run of its own, twice.** It rewrites 112 files, and the second attempt stopped before the conversion when a scripted edit to the two policy copies mangled them — restored from git, nothing lost, but a mechanical slip part-way through rewriting every ticket in the repository is the one that is expensive to unpick. The format change and the conversion belong in one uninterrupted pass.
