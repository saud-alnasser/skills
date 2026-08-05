# feat(specs): the specification declares the second axis

Status: resolved
Blocked by: —
Part of: parallel-tickets

## Problem

`specs.md` §20 describes orchestration as one thing: a stage dispatching children and integrating what they return, with a fan-out dividing a ticket and a mismatch stopping the whole fan-out. Every sentence there is true of portions and several are false of whole tickets — most sharply the one that makes a failure stop everything, which for independently verifiable tickets is the opposite of what should happen.

Building the second axis against a specification that describes only the first would make every later ticket in this effort an amendment, and the framework's own rule is that a change conforms or amends in the same change.

## Outcome

The specification names two axes and keeps them apart: a **fan-out** divides one ticket, a **dispatched set** runs several. It states what differs — one commit versus one commit each, all-or-nothing versus siblings-land, declared file ownership versus none — so a reader cannot carry a rule across from the axis it belongs to.

It records that the parent holds every claim in a set, that a dispatched ticket's own fan-out is declined at depth, and that collisions are the orchestrator's to resolve. The version moves, and the three decisions this effort records are cited from the sections they amend.

## Acceptance

- The multi-agent section names both axes and states, for each, how work lands and what a failure costs.
- The section states that the parent creates and holds every branch in a set, and that a child still claims nothing.
- The section states that a fan-out on a dispatched ticket is declined by the child, not honoured recursively.
- The section states that resolving a collision belongs to the orchestrator, and that the mechanism is the repository's own.
- The section states that the orchestrator brokers what a child may not do, that the menu of requests is closed, and that a brokered capability is still dispatched at depth one.
- The section states that human authority is unmoved by brokering — the human still answers — and that a child's return has a `waiting` outcome as well as done, failed, and stopped.
- Nothing in the amended section makes a claim about portions that is false of sets, or the reverse.
- The version is bumped and each of ADRs 0046, 0047, 0048, and 0049 is referenced from the section it amends.
- The suite asserts each of the above, each guard confirmed to fail against its removal.
- The suite passes.

## What the cross-axis criterion caught

*"Nothing in the amended section makes a claim about portions that is false of sets, or the reverse."* The first pass added the second axis and left four pre-existing sentences unqualified, every one of them now false of it:

- the **brief** bullet declared "the files that child owns" — a set child owns a ticket and no files, which the amendment's own table says two paragraphs earlier and ADR 0048 rejects outright;
- the **claim-widening** sentence described one claim stretched over portions, where ADR 0047 has the parent holding N of them;
- the **isolated worktree** sentence lost "branched from the claim" altogether — deleted rather than scoped, which removed a normative rule ADR 0044 is titled for, with no Decision authorising it;
- **"records it and stops"** stood unqualified beside new text saying a child's question reaches the human, so §20 asserted both and said which governs nowhere.

All four scoped by axis. The fourth is the one worth remembering: ADR 0049 names that exact sentence as the one it amends, and the amendment had been written into the section without touching it.

Also removed: a sentence stating that the dispatch plan does not stop for approval. True, and neither this ticket nor any of ADRs 0046–0049 decided it — it is `04`'s, and the specification had legislated ahead of both.

## The guards had to be written twice

Four passed against real breaks, each proved by a review rather than argued:

- the failure-inversion row matched substrings *inside* two cells, so the row could be rewritten to say the opposite of itself while still quoting both phrases;
- `attributed` matched **un**attributed, passing on the exact inversion of the rule;
- the closed menu was guarded by its adjective and not its contents, so a commit and a push could be added to it;
- table rows were checked by label, so every cell could be blanked — and the repair failed twice more, because a character class excluding `|` still matches newlines and found its pipes on the row below.

Each is now anchored on the thing that would change if the claim went away: whole cells, the full phrase, the menu's members, the row's own line.

## Recorded, not fixed

ADRs 0046–0049 were committed without the sentence naming the section they amend, which `specs.md` rule 3 requires and ADRs 0041, 0044, and 0045 all carry. Added here rather than by rewriting the design commit — the same call made for ADRs 0041–0044 in `orchestration/05`. It is the second time this effort has shipped Decisions missing that line, which suggests the ADR template rather than the author.
