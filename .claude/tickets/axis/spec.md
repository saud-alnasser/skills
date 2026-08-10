---
owner: repository
status: implemented
sources:
  - skills/help/SKILL.md
  - skills/triage/SKILL.md
  - skills/survey/SKILL.md
  - .claude/contexts/skill-authoring.md
  - .claude/rules/skills.md
  - .claude/protocol.md
  - scripts/verify.ps1
  - .claude/tickets/entry/spec.md
---

# feat(skills): the work describes itself, and only deliberate acts are typed

## Problem

The entry rule shipped in 1.12.0 states where a request enters and then enters
it. Its destination table has five rows, and one of them names a destination
that cannot be entered: a request arriving from outside routes to the triage
stage, which is marked user-invoked and is therefore absent from the set the
model may select. The only behaviour available at that row is handing the human
a command to type — the exact round trip the rule was built to remove,
reappearing one row lower in the same table.

That row is not an oversight. The effort deliberately settled it: triaging,
surveying, configuring and handing off "stay typed; they are deliberate acts."
The decision and the table were written in the same change and contradict each
other, and the contradiction is invisible because nothing compares an entry
destination against the axis its skill sits on.

Behind it sits a second, larger inconsistency. Skills here divide into a spine,
primitives, and a third group the tickets call **on-ramps** — the ways work
arrives that are not a plan. That third group is split down the middle on the
invocation axis for no stated reason: two of its five fire from a description of
the problem, and three are typed. Nothing records why the same category answers
the same question two ways, because the category itself is never defined in the
knowledge layer — only in a ticket and a status file.

The router skill compounds it. Its stated purpose is routing a human to the
right command, organised by how work arrives. That is now, precisely, what the
boot-tier entry rule does, so the same job is stated in two places — the failure
this framework exists to prevent. Its own text already records the drift: it
says only two commands are typed by habit, and one of the two stopped being
typed by habit when planning became selectable.

## Goal

Work that describes a problem reaches the stage that handles it, whatever kind
of problem it is. What remains typed is typed because invoking it is itself the
deliberate act, and that reason is recorded rather than assumed.

## Constraints

- **Crossing the axis is additive.** Removing the flag adds model selection and
  removes nothing: a skill without it is still reachable by typing its name.
  Verified in this repository's own session — a flagged skill was typed and an
  unflagged one was handed over in the same conversation.
- **Selection is paid for on every turn.** A model-invoked skill's description
  sits in the selection list whether or not it fires, so each crossing has a
  standing cost and the descriptions have to earn it by being short.
- **An accepted spec is superseded, never rewritten.** The out-of-scope line
  this reverses stays exactly as written; a Decision records the change of mind.
- **Nothing committed may assume the framework is installed.** A reader without
  it follows the same pointers; only invoking a stage needs it.
- **The shipped surface moves before this repository's installed copy.**
- **The specification is amended in the same change.**

## Architecture

**The axis is decided per skill by one question, and the answer is recorded.**
The test already exists: must this fire from a description of the problem? What
is missing is that it was never applied to the on-ramps as a group. Applied, it
splits them — two describe problems, two are acts performed on something other
than the repository.

| Skill | Fires from | Axis |
| --- | --- | --- |
| `triage` | "look at issue #14" — work arriving from outside | model-invoked |
| `survey` | "where is the architecture costing us" | model-invoked |
| `help` | "how does this workflow fit together" | model-invoked |
| `configure` | joining a repository to the workflow | typed |
| `handoff` | forking this conversation | typed |

The two that stay typed stay for the same reason, stated once rather than per
skill: **their subject is not the repository.** Configuring acts on the
workflow's own installation; handing off acts on the conversation. Neither has a
problem description that implies it, because the thing they operate on is not
the thing the user is describing.

**The triage row becomes correct without being edited.** The defect is repaired
by moving the skill, not the table, which is what the reversed decision buys.

**The router becomes an explanation.** With routing owned by the boot tier, what
is left is the part no other file carries: what this workflow is, which skills
the human still types and why, and how the rest arrives on its own. It stays a
skill rather than becoming documentation because it answers a question a user
asks in conversation, which makes it selectable by the same test as the others.

**The third category is named in the knowledge layer.** "On-ramp" is load-bearing
vocabulary already in use and defined nowhere Context can reach, which is why an
inconsistency inside the category went unnoticed. Naming it also fixes the
`Primitive` definition, which today reads as "a model-invoked skill with no stage
of its own" and enumerates four — a definition two on-ramps satisfy and the
enumeration excludes.

**The version stamp is designed but not built here.** Recording the workflow
version in the protocol file and warning when the running plugin has moved past
it requires a running stage to read its own version. No verified mechanism for
that exists: the environment exposes no plugin root, the CLI reports no plugin
installed for a directory source, and the standing Decision forbids the protocol
pointing into the plugin. It is cut as a blocked ticket with the question stated.

## Approach

The two on-ramps cross together, because they share a mechanism and a guard and
because the first of them is what makes the entry table honest. The router
crosses inside its own ticket instead of with them: its description cannot be
written before its content is, since what it fires on and what it contains are
the same decision. Nothing gates anything — the three tickets are independent
and the effort's single commit orders them.

The riskiest crossing is the router's, because its description has to fire on
"how does this workflow work" and not on "how does this repository's cache work".
A description that over-fires is caught the first time a code question opens an
explanation, and the correction is the description rather than the axis.

Options rejected, recorded in the Decision: crossing all five, which was the
first reading of the request and was withdrawn once the two acts were separated
from the three descriptions; keeping the router typed, which leaves routing
stated twice; and repairing the table row instead of the skill, which preserves
a round trip the whole effort exists to remove.

## Acceptance criteria

- A request describing work that arrived from outside reaches the triage stage
  without a command being typed.
- Every destination the entry table names is one the model may select, and the
  suite fails if a row names one it may not.
- Configuring and handing off remain unreachable by selection, and each records
  the reason it is exempt.
- Asking how the workflow is used produces an explanation of it; asking how this
  repository's code works does not.
- No file states which command a human should type for work the entry rule
  already routes.
- The knowledge layer defines the third skill category, and every skill belongs
  to exactly one of the three.
- A guard that no longer matches anything in the tree is removed rather than
  left passing.
- The specification and the plugin manifest carry the same version.

## Risks

- **A crossed skill fires when it was not wanted**, and the expensive one is the
  survey. Detected the first time a passing remark about code quality opens a
  report; mitigated by the stated route, which caps a misfire at one line, and
  corrected in the description before the axis is reconsidered.
- **The router over-fires on ordinary questions**, since "how do I use this" and
  "how does this work" are one sentence apart. Detected the same way; the
  description carries the exclusion explicitly rather than relying on tone.
- **The axis guard is written from the new wording** and passes while an old
  claim sits elsewhere in the tree. The named recurring failure for guards here;
  caught by confirming each guard fails against a deliberate reintroduction.
- **The exemption reason erodes.** Two typed skills with a shared justification
  invite a third that borrows it without meeting it. Detected at review of any
  future skill; the reason is stated as a test rather than as a list.

## Out of scope

- **The version stamp and the staleness warning.** Blocked on an unverified
  mechanism, cut as a ticket, and researched before it is designed.
- **Any change to what the crossed skills do.** They move across the axis and
  keep their behaviour; only the router's content changes, and only because its
  job moved.
- **The spine's own axis.** Every spine stage is already model-invoked except
  configuring, which this keeps typed.
- **Runtime independence and the second-harness adapter**, still a later effort.
