---
status: accepted
load-when: what passes between an orchestrator and a child is being changed
sources: [.claude/policies/sub-agents.md]
supersedes: []
superseded-by: []
---

# The brief is a template, and the return is a change record

A sub-agent returns one text string. No first-party surface offers a schema-validated return except the `Workflow` tool, which ADR 0040 rejected for a different reason. The contract between parent and child therefore has to be carried as prose, which makes the prose a **template** rather than a habit: objective, inputs given as paths rather than pasted content, the files this child owns, the shape of what it returns, its done-criteria, and a cap.

A survey of ten agent frameworks found no brief template anywhere and nothing treating the parent-to-child brief as a checked interface. There is nothing to copy, so this is AEP's own, and the verification suite is what makes it checked rather than merely written.

The child returns a **pointer to a change record it wrote, plus a compressed summary** — not the record itself. `/research` already demonstrates the shape: the child burns its own window and hands back one small file. Anthropic's published recommendation for their own system is the same move — let specialised agents create outputs that persist independently rather than routing everything through the lead.

**The record is a manifest, not a report.** It is what the orchestrator navigates the child's workspace by and integrates from (ADR 0044), which sets the bar for the format: it enumerates what changed and why, specifically enough to be reconciled against the child's actual diff. A record too vague to reconcile is a defect, not a matter of style — an unreconcilable manifest still reads as a check that happened.

**The change record is Position, not Evidence.** Its subject is a diff about to be integrated; once integrated, the record describes a state that is no longer true. That is precisely why `/review` is never persisted, and the same reasoning lands the same way here. What is durable graduates by routes that already exist: the code carries the change, a knowledge statement found false becomes a drift finding, an accepted trade-off becomes an ADR.

## Considered Options

- **A sixth kind of evidence.** Rejected: evidence records what was verified and when, and nothing revalidates it. A change record is consumed inside one session and wrong immediately after — filing it beside research findings would put a disposable artifact in the one directory whose defining property is that its contents stay true of their moment.
- **Returning the record inline as the agent's final message.** Rejected: it spends the orchestrator's window on the material the isolation existed to keep out of it, which is the cost that motivated fanning out at all.
- **Forcing structure by asking the child to emit JSON.** Rejected: unvalidated JSON in a text channel is prose with worse ergonomics. Where the return must be machine-checked, the check belongs in the suite reading the written file.

Specification §20 is amended in the same change to name the brief and the change record as two of orchestration's three artifacts.
