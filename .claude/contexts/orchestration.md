---
owner: repository
load-when: the work dispatches sub-agents, or reads what one returned
sources: [agents/, .claude/policies/sub-agents.md, skills/implement/SKILL.md]
---

# Orchestration

These terms were cross-cutting until this file existed, which meant every stage
paid for nine of them and most turns touch none. `.claude/policies/context.md`
routes a term by where it is used, and two of its rows can be read to fit:
orchestration vocabulary appears in several stages, but it is used only by
*orchestration work*, which is one domain that happens to span them. The more
specific row wins, and the domain clears the test for a file of its own — its
own vocabulary, its own principles (one layer deep, a closed request menu, the
orchestrator as sole integrator), and its own ownership in `agents/` and the
sub-agent policy.

## Boundaries

- **`agents/` is flat, and that is load-bearing.** A plugin's sub-directories become part of an agent's identifier, so a role filed one level down would be named by its path — which is exactly what a Role is defined not to be.
- **Both axes live in this file, and the second earns no file of its own.** A Fan-out and a Dispatched Set are each defined by what the other inverts, so a second Domain Context would put that contrast across a file boundary and leave whichever file a session loaded stating half of it. Routing cannot separate them either: the question that reaches this file is whether the work dispatches at all, and which axis it is becomes knowable only once the ticket has been read — after routing has already run.

## Language

**Orchestration**:
A stage dispatching sub-agents and integrating what they return. Distinct from the peer coordination of assignment and claim, which arbitrates between instances that dispatch nobody. Its contract is a policy; its dispatch belongs to whichever stage does the dispatching (ADR 0040).
_Avoid_: delegation, parallelism, multi-agent (unqualified)

**Orchestrator**:
The stage holding the conversation with the human while children run. The only party that may integrate, and the only one that can raise a decision — a child has no surface to ask on (ADR 0041).
_Avoid_: parent, lead, coordinator

**Role**:
A shipped agent definition a brief names. The reusable half of orchestration: identity is the definition's name, so an orchestrator holds a name rather than a path or an import. Distinct from a Skill, which is a capability a session enters, and from a Mode, which is a posture (ADR 0043).
_Avoid_: agent type, persona, worker

**Brief**:
The only channel from a parent to a child that opens unasked, and the only thing a child knows that it was not born with. Composed at dispatch rather than declared at design time, because only the dispatch has read the code; its parts are `.claude/policies/sub-agents.md`'s (ADR 0042). The one other thing travelling that way is the answer to a Brokered Request, which exists only because the child asked.
_Avoid_: prompt, task, instructions

**Change Record**:
The manifest a child writes and the orchestrator integrates by, of which the child returns only a path and a compressed summary — what it holds is `.claude/policies/sub-agents.md`'s. Position rather than Evidence: its subject is a diff about to be integrated, so it stops being true the moment it is used (ADR 0042).
_Avoid_: report, summary, handoff, glossary

**Fan-out**:
A ticket's optional declaration that its work divides — which roles run, and which files each owns. The decomposition decision, made at design time because it is architecture; the one section this system adds to an existing format (ADR 0043). Divides **one** ticket: the other axis is a Dispatched Set, and the two invert each other's failure rule (ADR 0046).
_Avoid_: split, parallelisation, decomposition

**Dispatched Set**:
The frontier tickets that gate none of each other, computed from declared edges and worked one child per ticket. The second axis of orchestration, and not a Fan-out: each ticket lands as its own commit on its own branch, and a failed sibling leaves the rest landed. The parent creates and holds every branch in it before dispatching, which is how a child still claims nothing (ADRs 0046, 0047).
_Avoid_: batch, parallel run, fan-out (of tickets)

**Brokered Request**:
A child asking the orchestrator to do what the child may not — run a capability that dispatches, or put a question to the human — and receiving the result back. The menu is closed to exactly those two, because an open one would make every prohibition on a child advisory. For a question the chain is child, orchestrator, human, orchestrator, child: the question travels attributed, the answer travels verbatim, and the orchestrator never becomes the answer (ADR 0049).
_Avoid_: escalation, callback, delegation upward, proxy

**Collision**:
Two children of one Dispatched Set writing the same path. Not what an edge records — `Blocked by` says what gates what, and file overlap is not a gate — so it is discovered at integration and resolved by the orchestrator, with both change records read and the mechanism taken from the version-control policy (ADR 0048).
_Avoid_: conflict (unqualified), merge conflict, overlap
