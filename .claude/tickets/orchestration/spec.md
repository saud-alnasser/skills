---
status: implemented
sources:
  - specs.md
  - skills/review/SKILL.md
  - skills/research/SKILL.md
  - skills/codebase-design/DESIGN-IT-TWICE.md
  - skills/implement/SKILL.md
  - .claude/policies/tickets.md
  - .claude/evidence/research/2026-08-05-claude-code-subagent-orchestration-primitives.md
  - .claude/evidence/research/2026-08-05-anthropic-first-party-orchestration-surfaces.md
  - .claude/evidence/research/2026-08-05-market-orchestration-patterns.md
---

# feat(skills): sub-agent orchestration becomes a system stages opt into

## Problem

Four shipped skills already spawn sub-agents, and each carries its own rules for doing it. The review stage states why its two axes must not see each other; the research stage states why isolation is not the same as not waiting; the design-it-twice pattern states how to build a brief; the survey stage reaches for a built-in explorer. Nothing states the rules once, so there are four homes for one standard — the failure this framework exists to prevent — and one of the four is already wrong: it instructs the author to quote vocabulary into a brief "rather than pointing at the file", on the belief that a child has no context of its own. A child inherits the whole entrypoint hierarchy, including the always-on rules. The instruction spends the parent's window to buy nothing.

Separately, the build stage cannot divide a ticket. A ticket sized to one context window is the only ticket that exists, and work that would divide cleanly across three isolated windows has to be either serialised into one or cut into three tickets whose edges are bookkeeping rather than real gates.

The specification describes multi-agent engineering as peer coordination — assignment, claim, the branch as the lock. It has no notion of a parent dispatching children, no brief, and no contract for what comes back.

## Goal

Orchestration is a system with one home: a policy stating what a child may and may not do with the framework's own systems, a template for the brief that reaches it, and a contract for what it returns. Existing stages opt in by pointing at that policy instead of restating it, and the build stage gains the ability to divide one ticket across children whose work it integrates.

## Constraints

- **Additive, not invasive.** Adopting orchestration must not require rewriting the capabilities being orchestrated. The budget for changes to existing systems is one optional section on the ticket format; anything beyond that is a design failure, not a scope increase.
- **A child cannot ask the user.** The question tool, plan mode, and the workflow tool are withheld from every sub-agent, and no agent's message is another agent's consent. Human authority cannot be delegated downward by instruction.
- **A child returns one text string.** There is no schema-validated return outside the workflow tool, which is rejected for a separate reason.
- **What ships is a plugin.** Plugin agent definitions silently ignore three of their frontmatter fields, so a shipped role can constrain itself only through its tool lists.
- **Fan-out is expensive.** Published first-party measurements put multi-agent work at roughly fifteen times the tokens of a chat, with token count explaining most of the variance in outcome, and single sessions named as more effective for sequential work, same-file edits, and work with many dependencies. Fan-out is opt-in, declared, and never a default.
- **Behaviour is version-bound.** Most of the harness behaviour this design rests on changed within the last fifty patch versions. The evidence carries its verified-against line; anything built on it re-checks rather than assumes.

## Architecture

Three artifacts, and one addition to an existing format.

**The sub-agent policy** is the contract, reached by the router exactly as every other policy is. Because a child inherits the entrypoint hierarchy, it follows the same pointer chain the parent does and arrives at the policy with nothing to bootstrap — which is why this is a narrowing rather than a second protocol. The policy says which knowledge layers are input to a child and which are closed to it: a child reads the Codebase, Context, and Decisions and verifies at use like anything else, and writes none of them. Knowledge a child finds false becomes a drift finding, which the evidence policy already permits from whoever finds it. A child does not claim, does not commit, does not push, and does not integrate — the last of those is enforced by the harness rather than agreed, since an isolated child's version-control commands fail if they reach into the main checkout.

**The brief** is the template a parent fills for one child: objective, inputs given as paths rather than pasted content, the files this child owns, the shape of what it returns, done-criteria, and a cap. The survey found no template of this kind anywhere and nothing treating the parent-to-child contract as checked, so this is the framework's own and the verification suite is what makes it checked.

**The change record** is what a child writes and the parent integrates by: what changed, why, what it could not do, and any decision it reached and stopped on. The child returns its path and a compressed summary, never its contents. It is per-clone state rather than evidence, for the same reason a review is never persisted — its subject is a diff about to be integrated.

It is a **manifest rather than a report**, which is what makes the file-ownership half of a declaration enforceable: a branch diff says what moved, and only the record says what the child believed it was doing. The orchestrator reconciles the two before anything lands, so a path the record does not declare — or one outside what that child was declared to own — is caught rather than merged.

**Roles** ship as agent definitions referenced by name. This is the mechanism every additive framework in the survey uses, and it is what lets an existing capability be fanned out without being rewritten: the orchestrator holds a name, not an import.

**The addition** is one optional section on the ticket format naming which roles run and which files each owns. That is the decomposition decision, and it is at design time because partitioning work into parallel units is architecture.

Each child works an isolated worktree branched from the claimed branch. The orchestrator navigates that workspace by the child's record, reconciles record against diff, and squashes in so that one ticket stays one commit. The claim's unit widens to cover the children, the way it already widened for stacks.

## Approach

The specification moves first, so every later ticket conforms to a document that already describes the system rather than amending it eight times. Then the policy, which everything else points at. Roles, the ticket declaration, and the configuration obligation are independent of each other and gate the build stage's dispatch. The existing spawners conform in parallel with all of it, since they depend only on the policy — and that ticket is the proof the design is additive, because if conforming them requires changing what they do, it was not.

Adoption here comes last, as it always does.

```
01  the specification declares orchestration
02  the sub-agent policy ships
03  roles ship as named definitions
04  a ticket may declare a fan-out
05  configure writes the isolation obligation
06  the build stage dispatches, isolates, and integrates
07  the existing spawners conform
08  adopt here
```

**Rejected: the workflow tool as the substrate.** It is the only surface with schema-validated returns, resume, and budget accounting, and giving those up is a real cost. Rejected because its sub-agents always run with edits accepted regardless of the session's permission mode, and it offers no mid-run human checkpoint — the documentation's own workaround is one workflow per stage. Recorded as ADR 0040.

**Rejected: full decomposition declared at design time.** The heaviest change to the ticket format, and no surveyed framework does it — a split authored before the code is read rarely survives being read. Recorded as ADR 0043.

**Rejected: children sharing the parent's working directory with declared file ownership.** No merge step at all, which is genuinely attractive. Rejected because nothing enforces the disjointness: two children owning different files still collide on a shared import or test helper, and the loser's edit vanishes with no error. Recorded as ADR 0044.

**Rejected: filing the change record as a sixth kind of evidence.** Evidence records what was verified and nothing revalidates it; a change record is wrong immediately after use. Recorded as ADR 0042.

**Rejected: squashing each child's branch blindly.** The obvious mechanism, and the first one chosen here. Rejected because git alone cannot distinguish a change the child was asked for from one it wandered into, which would leave declared file ownership as a comment rather than a constraint. Recorded as ADR 0044.

## Acceptance criteria

- The specification describes orchestration, and no later ticket in this effort amends it again.
- One policy states the sub-agent contract, and the router reaches it. No skill restates any part of it.
- A brief written from the template names its objective, its inputs as paths, the files the child owns, the return shape, the done-criteria, and a cap.
- A child that reaches a decision stops and records it, and the orchestrator raises it. No path exists by which a child decides.
- A ticket can declare a fan-out; a ticket without one behaves exactly as it does today.
- A dispatched child works in a worktree branched from the claimed branch, and nothing it does can reach the main checkout.
- A change record is specific enough to reconcile against a diff, and the orchestrator integrates by it rather than by the branch alone.
- A child whose diff touches a path its record does not declare, or a path it was not declared to own, stops the whole fan-out and is named.
- A fan-out that loses a child integrates nothing, names the portion that failed, and leaves the successful children's work in place.
- A fanned-out ticket produces one commit, indistinguishable in history from a ticket built without fan-out.
- The four existing spawners point at the policy, and none of them changed what it does.
- The falsified brief-construction instruction is gone from what ships.
- Every mechanically checkable claim above has an assertion in the verification suite, each confirmed to fail against its removal.
- The suite passes at every ticket boundary.

## Risks

- **The system is built and never used.** The published evidence says coding has fewer genuinely parallel tasks than research, and a fan-out declaration nobody writes is dead weight in a format everybody reads. Detected at the first three tickets a design run considers fanning out and does not — if the declaration stays empty across a whole effort, the ticket-format change should be reverted and roles kept.
- **Reference-by-name means the same definition resolves differently in different runtimes.** A backgrounded child gets a narrower built-in tool set, and the removal reports no error. Detected by asserting each shipped role's tool list against the set a background child actually retains, rather than trusting the definition to mean one thing.
- **Silent integration against trunk.** If the base-ref obligation is missed or a repository is configured without it, children branch from the default branch and produce plausible code against the wrong tree. Detected by the build stage checking the child's base before integrating, not by trusting configuration to have happened.
- **The token cost is not worth it on this repository's own work.** Fifteen times the tokens for work that is mostly prose editing is a bad trade. Detected by using it here first, on this effort's own tickets, before recommending it.
- **The specification and the build diverge again.** The framework's own evolution rule is the mitigation, and it is exercised by putting the amendment first rather than last.

## Out of scope

- **Agent teams, background sessions, and the workflow tool.** Named as neighbouring surfaces in the evidence, deliberately not built on. The workflow tool's rejection is recorded; the other two are simply not this.
- **Nested fan-out.** A child does not dispatch children. The harness permits three layers; this design uses one, and the roles deny the tool rather than relying on a rule.
- **Peer coordination.** Assignment and the claim are unchanged. This system is about a parent and its children, which is a different relationship and does not touch that one.
- **Automatic decomposition.** Nothing infers a fan-out from a ticket that did not declare one.
- **Anything about publishing.** Push, pull requests, and stack submission stay the human's call.
