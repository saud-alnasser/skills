---
owner: framework
---

# Sub-agents

<!-- Installed by /configure at `.claude/policies/sub-agents.md`. Copied as-is. The contract between a dispatching stage and its children — a policy rather than a second router, because a child inherits the entrypoint hierarchy and reaches this file through the same pointer chain a session uses. -->

**A sub-agent is a child that an orchestrating stage dispatches to work part of what that stage was doing.** It runs in its own context and never speaks to the human.

**The part is either a portion of one ticket or a whole ticket**, and the unit is the only thing that differs between them: a portion child owns the files its brief names; a ticket child owns its ticket, and what *done* means for it is that ticket's own acceptance criteria — nobody hands it a file list, because a set never had one to hand.

**A ticket child that finds a fan-out declared on its ticket declines it and records the decline, then builds the whole ticket itself.** It cannot dispatch, so it cannot run the portions — the reason is that bound rather than a judgement about the work, which is why it says so rather than quietly building. Declining is not stopping, and it never divides the work some other way.

One contract, in four parts: what a child may use, what is closed to it, what it may ask for, and the two shapes that cross the boundary between it and its parent.

## A child arrives bound, not bare

- **A dispatched child inherits the entrypoint hierarchy the parent loaded, including the always-on rules.** What it does not get is the conversation: not the parent's messages, not the parent's tool results, not the parent's system prompt — stated because the opposite is the easier assumption, and has shipped before now.
- **Material reached by pointer is named in the brief, never quoted into it** — quoting spends the parent's window to buy what the child could have fetched itself.
- **So this policy narrows what a child may do.** It does not bootstrap what a child knows.

## What a child may use

- **It reads the Codebase, Context, and Decisions, and it verifies at use exactly as a session does.** That rule is the router's, and being inside a child does not soften it.
- **A knowledge statement it checks and finds false becomes a drift finding.** `.claude/policies/evidence.md` already admits one from whoever finds it, and a child is a finder like any other — nothing about the finding changes because a child wrote it.

## What is closed to it

Each of these is a rule, not a preference.

- **A child writes no knowledge layer.** No Context, no Decision, no spec. What it learned travels in its change record, and the orchestrator routes it from there.
- **A child claims nothing, commits nothing, pushes nothing, and integrates nothing.** The claim belongs to the parent and widens to cover every child beneath it; integration belongs to the orchestrator alone.
- **No agent's message is another agent's consent.** A child never approves a permission prompt for a parent, and a parent never approves one for a child. **A denial is not routed around** — not re-asked upward, not retried by a second child, not satisfied by a path the denial did not name.
- **A child dispatches nobody.** Orchestration is one layer deep — a bound this workflow sets rather than one the harness imposes: nesting is available and is not used, because a child that dispatched would be an orchestrator with no conversation to hold and no claim of its own to widen. A portion that turns out to need splitting again was scoped wrong: that goes in the record, and the parent re-cuts it.
- **A decision a child reaches is recorded and stopped on, never taken.** A child has no surface on which to ask a human, so a decision inside one cannot be put to anybody. It goes in the change record, and the child stops there — **or stops pending an answer**, where the orchestrator can carry the question. Stopping is the rule; whether the run ends there is the orchestrator's to decide, not the child's.
- **A ticket child neither creates nor commits to the branch it works on.** The parent created it — that is the claim — and the orchestrator commits what the child produced. Nor does it review its own work unasked: review dispatches, and dispatching is closed to it — the orchestrator runs it, on request.

## What a child may ask for

A child cannot dispatch, so it cannot run anything that fans out — and one of those is its own review. Rather than widen the depth bound, the child **requests**, the orchestrator performs, and the result comes back to the requester, which resumes where it stopped — the capability is dispatched at depth one, so nothing about the bound moves.

**Exactly two things may be requested**, and anything else is refused without being weighed:

| Request | What comes back |
| --- | --- |
| a capability that requires dispatch | what that capability produced |
| a question put to the human | the human's answer |

- **The menu is closed, and that is the whole safety property.** An open channel would make every prohibition above advisory — a child forbidden to commit could simply ask for a commit; a prohibition survives a menu, not discretion exercised by the party that wants the work done. A request outside the two rows is declined without being considered on its merits.
- **A request spends the brief's cap.** It costs what work costs, so a child that keeps asking runs out exactly as one that keeps working does, and there is no second budget to set or to get wrong.
- **No child can send anything to anyone.** The tool that would let one is withheld from every shipped role, so a child can be resumed and cannot originate a message — which is what makes child, orchestrator, child the only path and leaves no sibling traffic the orchestrator cannot see.

### Carrying a question is not answering it

The chain is **child → orchestrator → human → orchestrator → child**, and the party in the middle owes an obligation each way:

- **Outward, the question travels attributed** — which child is asking, and about which ticket. The orchestrator holds the only view in which that context exists, so a question arriving without it is answered without it.
- **Inward, the answer travels verbatim.** Not summarised, not resolved, not improved. A paraphrase is the orchestrator's answer wearing the human's authority, and it **fails silently**: the child never sees the original, so the one party who could detect the substitution is the one party who cannot.
- **An answer that cannot be relayed faithfully — it changes what the whole run is doing rather than what one child is doing — stops the child** instead of being reinterpreted for it. Ending a child is honest; answering on the human's behalf is not. Nothing about who answers moves: the human still answers, under the consent rule stated above.

## The brief — parent to child

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

**Incomplete is a defect in the dispatch, not a matter of style.** A child cannot ask what was meant, so an underspecified brief is not discovered as a question — it is discovered as a wrong result that took a full run to produce.

## The change record — child to parent

**The child writes a change record and returns only its path and a compressed summary.** The record stays on disk in the child's workspace, which is where the orchestrator reads it.

A return says which of four things happened — **done**, **failed**, **stopped**, or **waiting** — and `waiting` is the one that is not an ending: it is a child mid-conversation, holding its context until an answer arrives. Whatever reads a return distinguishes the two, because resuming a `waiting` child and re-dispatching a `stopped` one are different acts with different costs.

The record names four things:

- **what changed** — every path, and what was done to it
- **why** — the reasoning that cannot be recovered from the diff
- **what it could not do** — anything the brief asked for that is not finished
- **any decision it stopped on** — the question, and what answering it would have needed

**The record is a manifest, not a report.** The orchestrator navigates the child's workspace by it and integrates from it, and that sets the bar for the format: specific enough to be **reconciled against the child's actual diff**, path by path. A record too vague to reconcile is a **defect rather than a terse style** — an unreconcilable manifest still reads as a check that happened. What an orchestrator does when reconciliation fails belongs to the stage that dispatched, not here.

**A change record is Position.** Its subject is a diff about to be integrated, so it stops being true the moment it is used, and it goes under `.claude/position/` with everything else that would be wrong in another clone. `.claude/.gitignore` carries the membership test and already covers it; no new exception is argued for.
