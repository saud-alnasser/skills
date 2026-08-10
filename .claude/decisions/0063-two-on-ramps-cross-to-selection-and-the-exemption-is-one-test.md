---
owner: repository
status: accepted
load-when: which invocation axis a skill sits on is in question, or a skill is proposed as exempt from selection
sources: [skills/triage/SKILL.md, skills/survey/SKILL.md, .claude/protocol.md, .claude/tickets/entry/spec.md, scripts/verify.ps1]
supersedes: []
superseded-by: []
---

# Two on-ramps cross to selection, and what stays typed is held by one test

Triage and survey become model-invoked. This reverses a line in an accepted spec — `.claude/tickets/entry/spec.md`, under Out of scope: *"Configuring, surveying, triaging, and handing off stay typed; they are deliberate acts."* That spec's reasoning is frozen and stays exactly as written; this is the change of mind, recorded where a change of mind belongs.

The reversal is forced by something the same effort shipped. Its destination table routes work arriving from outside to triage, and its boot-tier rule requires the named stage to be *entered* rather than handed to the user as a command. A withheld destination cannot be entered, so the two halves of one change contradicted each other — and the contradiction was invisible because nothing compared an entry destination against the axis its skill sits on. Moving the skill repairs the table without editing it.

**What stays typed is now held by one test rather than by a list.** Configuring and handing off are exempt because **their subject is not the repository**: configuring acts on the workflow's own installation, handing off on the conversation. Neither has a problem description that could select it, because the thing it operates on is not the thing the user is describing. A list invites a sixth entry that resembles the others; a test can be failed.

## Considered Options

- **Repair the table row instead of the skill** — mark the outside-arrival row as typed, the way the question row already routes to nothing. Rejected: it preserves exactly the round trip the entry rule exists to remove, and it makes one of five rows behave unlike the rest for a reason the reader has to hold in their head.
- **Cross all five**, which was the first reading of the request. Withdrawn once the two acts were separated from the three descriptions: a session forked into a handoff file on the model's own reading of *this thread is getting long* is a loss the user cannot undo, and no description of a repository problem implies it.
- **Keep the flag and sharpen the descriptions.** Rejected for the same reason it was rejected for planning in ADR 0061: a description cannot make a withheld skill selectable, so it addresses nothing.
- **Enforce the exemption twice** — in the description and again as the skill's first step. Considered seriously for handing off, and rejected here because the flag already does it: a skill that is never offered for selection needs no runtime guard against being selected. The two-home argument only arises for a skill that crosses, and neither of the two that stay typed does.

## Consequences

Two more descriptions sit in the selection list on every turn, and each can misfire. The survey is the expensive one, and the mitigation is the one the entry rule already provides — the route is stated before it is taken, so a wrong selection costs a line rather than a report nobody wanted.

**The router's stage table gains a row it should always have had.** Triage declares a guide and had no row, and the containment check that would have caught it iterates the spine, which triage is not part of. Both are repaired: the row exists and the check covers it.

**The entry table now has a standing guard.** Every destination it names must be one the model may select, asserted rather than assumed — the check that would have prevented this Decision from being necessary.
