---
owner: repository
status: accepted
load-when: a routing table or a declared field is being changed
sources: [.claude/policies/context.md]
supersedes: []
superseded-by: []
---

# A routing table is generated from fields the routed file declares

Contexts and Decisions each declare two fields — when to load this file, and where its subject lives — and the routing table is **generated** from them rather than written by hand. Decisions gain routing for the first time; Contexts keep the table they have and lose its authorship.

ADR 0002 rejected frontmatter for context loading, so this needs to say what the difference is or it reads as a reversal. It is not one. That decision turned on two arguments, and both survive intact:

- *"Tags describe what a file is about; the agent's actual question is when to load it. A trigger sentence answers that; a keyword list does not."* The field declared here **is** the trigger sentence. It is the table's own column, moved to the file it describes. Nothing becomes a keyword list.
- *"The table also sits where the agent already is."* The table still exists and is still read at startup. Routing still costs no extra tool call.

What ADR 0002 compared was a hand-written table against tags **instead of** a table. It did not weigh a table **derived from** declared trigger sentences, because at three contexts the hand was not the expensive part. At fifty-one Decisions it is.

And it closes that decision's own recorded cost. ADR 0002 accepted that "the table is a central index and can drift when a Domain Context is added without updating it," and assigned an audit to catch it. A generated table cannot drift, because it is not a second statement of the directory's contents. An impossibility replaces an obligation.

## Considered Options

- **A hand-written decisions map, mirroring the contexts map.** Consistent, one mechanism, nothing new to learn — and it reproduces by hand, on a directory that only grows, exactly the drift ADR 0002 recorded as its price.
- **Contexts naming the Decisions in their area**, which is a plain reading of the specification's own claim that a context answers which decisions are relevant. Rejected on coverage rather than on principle: most Decisions here are about the protocol rather than about a domain, and this repository has two Domain Contexts to hang them on. It would route a minority of the weight and leave the majority where it is.
- **Narrowing the review stage to read only the Decisions a diff implicates**, leaving the directory unindexed. Rejected because *implicates* has no mechanism without the scope field this decision adds; without it the stage degrades to grepping titles, which is subject matter again.
- **Leaving Decisions unrouted.** Rejected because the cost is monotonic. Every accepted ADR enlarges the unrouted read and nothing ever shrinks it.

## Consequences

**A generated file is never hand-edited, and this is enforced rather than requested.** The check is a regeneration compared against what is on disk, so a hand edit fails in the same pass that made it — and so does a file added without fields, since it cannot appear in a regeneration.

Decisions declare supersession at **both ends**, which makes a graph that can be checked for symmetry. Today two ADRs claim to be superseded and nothing verifies that the superseding files agree; several more discuss supersession in prose, which is not a claim. One-sided claims become build failures naming both files.

**The conversion has a failure nothing mechanical detects, and it scales.** A load condition written as a description of subject matter passes every check this decision adds and silently reintroduces the thing ADR 0002 rejected. Fifty-one files here; an arbitrary number in any repository the configuration stage carries across. So the conversion is shown in the plan file by file rather than as a count — a human reading the sentences is the only check there is, and that is a property of the decision rather than an implementation detail of one migration.

The existing hand-written routing tables are the conversion's **input**, not its casualty: their trigger sentences were written for this exact purpose and move onto the files they describe. Only where no such sentence exists anywhere is one being authored, which is where the hazard actually lives.

ADR 0002's note that frontmatter shrinks to load-bearing fields only is unchanged and is the test every field here had to pass. `status` on ADRs, which that decision already listed as load-bearing and optional, becomes required and acquires a reader.
