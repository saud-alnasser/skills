---
owner: repository
status: implemented
sources:
  - skills/configure/policies/tickets.template.md
  - skills/configure/policies/version-control.template.md
  - skills/configure/policies/maps.template.md
  - skills/configure/policies/evidence.template.md
  - skills/configure/policies/knowledge.template.md
  - skills/design/SKILL.md
  - specs.md
---

# feat(skills): protocol scaffolding is never its own unit of work

## Problem

The second field observation on an external repository — GitHub tracker, branch-bound tickets — shows a design effort whose tracker footprint is mostly the agent's own bookkeeping: under one map root, two open build tickets exist solely to produce files under the protocol directory (a performance baseline, a transcription of external design values — each with acceptance reading "no file outside `.claude/` is modified"), and a third issue is a drift report about a falsified ADR, filed rather than fixed.

The branch-bound test (ADR 0035) separates decisions from work, but it cannot tell product work from protocol scaffolding — any `docs:` commit produces a branch and passes it. Four harms follow at once: a shared tracker fills with items only the agent cares about, so the top level stops measuring anything; a pull request whose whole diff is protocol scaffolding gives a reviewer nothing to evaluate; evidence merged apart from the change it gates goes stale in the gap; and the protocol's internals leak onto a surface read by teammates who do not run it.

## Goal

No tracker item and no pull request the workflow creates has its entire effect under the protocol directory — except the design PR, one per design run, whose approval is approval of the plan. Everything else protocol-only rides the work that consumes it, and drift found in passing is filed as evidence and surfaces where the next planner will look.

## Constraints

- **Single home.** Each rule lands in exactly one file, and the suite's guards move in the same pass as every shipped change.
- **Conform or amend** (ADR 0029): the specification's evidence enumeration, layout, and multi-agent bounding change with ADRs 0038–0039 at design capture, so the build tickets conform rather than diverge.
- **Ship first, adopt second** (ADR 0025): every ticket but the last changes the shipped tree; this repository's installed copies move in one closing ticket.
- **The rule binds what the workflow creates on a shared tracker.** Humans may file anything, and triage routes it; on a local-markdown tracker the rule is vacuous, because tickets are protocol files and nothing publishes.
- **The rule keys on the diff, never the commit type.** Real documentation work — README, guides — stays legal under `docs:`; no new commit type is introduced.

## Architecture

**A shared tracker never carries protocol-only work.** The tickets policy gains the test: a ticket the workflow creates on a shared tracker must state an outcome outside the protocol directory. Work whose whole effect is scaffolding is consumed, not tracked: evidence gating a map decision is produced by the map session that needs it and lands in that session's design PR; evidence gating a build is a declared increment (ADR 0037) on the consuming build ticket, its answer and the code shipping in one commit.

**The design PR is the only protocol-only landing.** The version-control policy names the one exception: a pull request whose entire diff sits under the protocol directory is a design PR — the deliverable of a single design run, one per run, reviewable because approving it is approving the plan. A map effort spanning sessions lands one small design PR per session, so resolved decisions reach the default branch between sessions instead of accumulating on a long-lived branch. The maps policy's branch-bound landing path states this instead of the bare "`docs:` commit" it says today. (ADR 0038.)

**A drift finding is evidence, indexed on the live map.** A fifth evidence kind: the record that a knowledge statement was checked in passing and found false — what was checked, against which commit, what it falsifies — produced by whoever finds it, on whatever branch they are on. When a live effort owns the area, the map gains one task-list line linking to the finding, checked off when the healing lands — the map body, never a comment, because on GitHub the body is one call and comments are a paginated fetch. With no live effort, the finding waits in evidence. The knowledge policy points implementation at this path, because a falsified Decision is the one drift that is never healed inline — correcting an ADR is design's. (ADR 0039.)

**Design discovery surfaces what waits.** The design stage's discovery step reads the drift-finding directory for unconsumed findings in the area being planned, so an orphan finding is dormant only until the next plan touches its ground. And when the stage cuts a ticket set, protocol-only work routes to a map session or a declared increment — never to a ticket.

## Approach

The tickets rule and the drift kind land first and independently; the landing-path repair is independent of both; the design-stage wiring builds on the tickets rule and the drift kind, so it follows them; adoption closes, so the migration has a before-state to prove against.

Rejected, so review does not propose them again:

- **Comments on the parent issue for drift findings** — a comment is a separate paginated fetch every session must remember to make; the body is one call and is already the map.
- **Standalone drift issues** — reopens the noise channel the rule closes; "no live effort" is easy to satisfy and hard to police.
- **Healing ADRs inline wherever found** — an implement session rewriting a Decision mid-build skips the grill; frozen reasoning is corrected only by design.
- **One long-lived design branch per map effort** — resolved decisions invisible on the default branch for the life of the effort, and every session needs the branch fetched before it can continue.
- **Design output riding the first build PR** — weeks of plan mixed with an implementation, which is the unreviewable mix the rule exists to kill.
- **Binding the `docs:` commit type** — the type also carries real documentation; the diff is the fact, the type is a label.

## Acceptance criteria

- The shipped tickets policy states that a ticket the workflow creates on a shared tracker has an outcome outside the protocol directory, and routes protocol-only work to a map session or a declared increment.
- The shipped version-control policy names the design PR as the one pull request whose entire diff may sit under the protocol directory, one per design run; the shipped maps policy's branch-bound path lands map resolutions as one design PR per session.
- The shipped evidence policy carries drift findings as a kind with a directory, stating what one holds and who produces it; the shipped maps policy indexes findings on the live map as task-list lines; the shipped knowledge policy points implementation there for a falsified Decision.
- The design stage's discovery reads unconsumed drift findings, and its set-cutting never emits a protocol-only ticket.
- Each change moves the suite in the same pass, and the suite passes.

## Risks

- **Declared increments overload build tickets** — evidence gating many consumers, folded into one ticket, couples every consumer to that ticket's merge. Mitigated by the split: evidence gating *decisions* resolves during mapping and lands in a design PR; only evidence gating a *single build* becomes an increment. Detected at set-cutting: an increment two tickets wait on is on the wrong ticket.
- **Per-session design PRs boom instead** — many tiny PRs replace many tiny issues. Bounded by one per run, and visible on the PR list the same way roots are visible on the tracker; if a repository finds the cadence wrong, the version-control policy is per-repository and says so.
- **Recognising a design PR is judgment, not mechanism** — nothing mechanical marks one. Accepted: the diff being entirely under the protocol directory *is* the mechanical test, and the version-control policy states it.

## Out of scope

- The external repository's own cleanup — converting its open protocol-only issues to increments and re-editing its map body is that repository's design run, after this ships.
- Forbidding the `docs:` commit type or any label vocabulary.
- Local-markdown trackers — the rule binds shared surfaces only.
- Triage behaviour for human-filed protocol-only issues — humans may file anything; routing them is triage's existing job.
