---
owner: framework
type: norm
subject: sub-agents
fires-when: stage
stages: [implement, review, research]
spans:
  - a-sub-agent-is-a-child-an-orchestrating-stage-dispatches: n6xmou
  - a-child-inherits-the-entrypoint-hierarchy: cjfvgx
  - material-reached-by-pointer-is-named-never-quoted: c73nx7
  - this-contract-narrows-it-does-not-bootstrap: ei1tym
  - a-child-reads-and-verifies-as-a-session-does: f6rlk9
  - a-false-statement-a-child-checks-becomes-a-drift-finding: qbqdw8
  - a-child-writes-no-knowledge-layer: 88yzi7
  - a-child-claims-commits-pushes-and-integrates-nothing: 2ondmb
  - no-agent-s-message-is-another-agent-s-consent: o98sed
  - a-child-dispatches-nobody: vcdumz
  - a-decision-a-child-reaches-is-recorded-and-stopped-on: llfs30
  - what-a-child-may-ask-for: zbei82
  - the-menu-is-closed: 0k84wf
  - a-request-spends-the-brief-s-cap: 67bxpp
  - no-child-can-send-anything-to-anyone: fqjsm9
  - carrying-a-question-is-not-answering-it: j5w9rb
  - outward-the-question-travels-attributed: inkaeq
  - inward-the-answer-travels-verbatim: ggxbo6
  - an-answer-that-cannot-be-relayed-faithfully-stops-the-child: zrjfvw
  - the-brief-is-the-only-channel-that-opens-unasked: 9rpfbw
  - an-incomplete-brief-is-a-defect-in-the-dispatch: 1bkawf
  - the-child-writes-a-change-record-and-returns-its-path: jnypcw
  - the-record-is-a-manifest-not-a-report: guzwnw
  - a-change-record-is-position: 7thzbv
---


# Sub-agents

The contract between a dispatching stage and its children — a norm rather than a second router, because a child inherits the entrypoint hierarchy and reaches this record through the same chain a session uses.

## A sub-agent is a child an orchestrating stage dispatches

**A sub-agent is a child that an orchestrating stage dispatches to work part of what that stage was doing.** It runs in its own context and never speaks to the human.

## A child inherits the entrypoint hierarchy

- **A dispatched child inherits the entrypoint hierarchy the parent loaded, including the always-on rules.** What it does not get is the conversation: not the parent's messages, not the parent's tool results, not the parent's system prompt — stated because the opposite is the easier assumption, and has shipped before now.

## Material reached by pointer is named, never quoted

- **Material reached by pointer is named in the brief, never quoted into it** — quoting spends the parent's window to buy what the child could have fetched itself.

## This contract narrows, it does not bootstrap

- **So this policy narrows what a child may do.** It does not bootstrap what a child knows.

## A child reads and verifies as a session does

- **It reads the Codebase, Context, and Decisions, and it verifies at use exactly as a session does.** That rule is the router's, and being inside a child does not soften it.

## A false statement a child checks becomes a drift finding

- **A knowledge statement it checks and finds false becomes a drift finding.** `evidence.md` already admits one from whoever finds it, and a child is a finder like any other — nothing about the finding changes because a child wrote it.

## A child writes no knowledge layer

Each of these is a rule, not a preference.

- **A child writes no knowledge layer.** No Context, no Decision, no spec. What it learned travels in its change record, and the orchestrator routes it from there.

## A child claims, commits, pushes, and integrates nothing

- **A child claims nothing, commits nothing, pushes nothing, and integrates nothing.** The claim belongs to the parent and widens to cover every child beneath it; integration belongs to the orchestrator alone.

## No agent's message is another agent's consent

- **No agent's message is another agent's consent.** A child never approves a permission prompt for a parent, and a parent never approves one for a child. **A denial is not routed around** — not re-asked upward, not retried by a second child, not satisfied by a path the denial did not name.

## A child dispatches nobody

- **A child dispatches nobody.** Orchestration is one layer deep — a bound this workflow sets rather than one the harness imposes: nesting is available and is not used, because a child that dispatched would be an orchestrator with no conversation to hold and no claim of its own to widen. A portion that turns out to need splitting again was scoped wrong: that goes in the record, and the parent re-cuts it.

## A decision a child reaches is recorded and stopped on

- **A decision a child reaches is recorded and stopped on, never taken.** A child has no surface on which to ask a human, so a decision inside one cannot be put to anybody. It goes in the change record, and the child stops there — **or stops pending an answer**, where the orchestrator can carry the question. Stopping is the rule; whether the run ends there is the orchestrator's to decide, not the child's.

## What a child may ask for

A child cannot dispatch, so it cannot run anything that fans out — and one of those is its own review. Rather than widen the depth bound, the child **requests**, the orchestrator performs, and the result comes back to the requester, which resumes where it stopped — the capability is dispatched at depth one, so nothing about the bound moves.

**Exactly two things may be requested**, and anything else is refused without being weighed:

| Request | What comes back |
| --- | --- |
| a capability that requires dispatch | what that capability produced |
| a question put to the human | the human's answer |

## The menu is closed

- **The menu is closed, and that is the whole safety property.** An open channel would make every prohibition above advisory — a child forbidden to commit could simply ask for a commit; a prohibition survives a menu, not discretion exercised by the party that wants the work done. A request outside the two rows is declined without being considered on its merits.

## A request spends the brief's cap

- **A request spends the brief's cap.** It costs what work costs, so a child that keeps asking runs out exactly as one that keeps working does, and there is no second budget to set or to get wrong.

## No child can send anything to anyone

- **No child can send anything to anyone.** The tool that would let one is withheld from every shipped role, so a child can be resumed and cannot originate a message — which is what makes child, orchestrator, child the only path and leaves no sibling traffic the orchestrator cannot see.

## Carrying a question is not answering it

The chain is **child → orchestrator → human → orchestrator → child**, and the party in the middle owes an obligation each way:

## Outward, the question travels attributed

- **Outward, the question travels attributed** — which child is asking, and about which ticket. The orchestrator holds the only view in which that context exists, so a question arriving without it is answered without it.

## Inward, the answer travels verbatim

- **Inward, the answer travels verbatim.** Not summarised, not resolved, not improved. A paraphrase is the orchestrator's answer wearing the human's authority, and it **fails silently**: the child never sees the original, so the one party who could detect the substitution is the one party who cannot.

## An answer that cannot be relayed faithfully stops the child

- **An answer that cannot be relayed faithfully — it changes what the whole run is doing rather than what one child is doing — stops the child** instead of being reinterpreted for it. Ending a child is honest; answering on the human's behalf is not. Nothing about who answers moves: the human still answers, under the consent rule stated above.

## The brief is the only channel that opens unasked

**The brief is the only channel from parent to child that opens unasked.** Anything the child needs from the *conversation* is written into it; anything that lives in a file is named by path. The one other inbound thing is an answer to something the child asked for, and it exists only because the child asked.

Six parts, and **a brief missing any one of them is incomplete**:

| Part | What it carries |
| --- | --- |
| objective | the one outcome this child exists to produce |
| inputs | paths, never pasted content — the child can read |
| what it owns | the files, for a portion; the ticket, for a whole one |
| return shape | what the final message has to contain |
| done-criteria | how the child knows it has finished |
| cap | the bound on how far it may go before returning |

## An incomplete brief is a defect in the dispatch

**Incomplete is a defect in the dispatch, not a matter of style.** A child cannot ask what was meant, so an underspecified brief is not discovered as a question — it is discovered as a wrong result that took a full run to produce.

## The child writes a change record and returns its path

**The child writes a change record and returns only its path and a compressed summary.** The record stays on disk in the child's workspace, which is where the orchestrator reads it.

A return says which of four things happened — **done**, **failed**, **stopped**, or **waiting** — and `waiting` is the one that is not an ending: it is a child mid-conversation, holding its context until an answer arrives. Whatever reads a return distinguishes the two, because resuming a `waiting` child and re-dispatching a `stopped` one are different acts with different costs.

The record names four things:

  - **what changed** — every path, and what was done to it
  - **why** — the reasoning that cannot be recovered from the diff
  - **what it could not do** — anything the brief asked for that is not finished
  - **any decision it stopped on** — the question, and what answering it would have needed

## The record is a manifest, not a report

**The record is a manifest, not a report.** The orchestrator navigates the child's workspace by it and integrates from it, and that sets the bar for the format: specific enough to be **reconciled against the child's actual diff**, path by path. A record too vague to reconcile is a **defect rather than a terse style** — an unreconcilable manifest still reads as a check that happened. What an orchestrator does when reconciliation fails belongs to the stage that dispatched, not here.

## A change record is Position

**A change record is Position.** Its subject is a diff about to be integrated, so it stops being true the moment it is used, and it goes under `.claude/position/` with everything else that would be wrong in another clone. `.claude/.gitignore` carries the membership test and already covers it; no new exception is argued for.
