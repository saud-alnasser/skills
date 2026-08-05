---
status: accepted
load-when: a stage's dependencies are stated in more than one place
sources: [.claude/protocol.md]
supersedes: []
superseded-by: []
---

# The stage-dependency set has two homes, and the protocol table wins

Which guides a stage reads stays stated in two places — the protocol file's stage table and each skill's own dependency line — with a declared precedence rather than a deletion. **The table governs where they differ.**

Single home says a rule has one home chosen by when it must fire. This is not one rule in two homes; it is a **default** and an **instance**, and naming them removes the ambiguity that let them drift:

- A skill's dependency line is the **workflow's default**. It ships in a plugin that cannot know any repository's local guides, so it can only ever state what AEP supplies.
- The protocol table is **this repository's actual set**, written by the configuration stage from those defaults plus whatever is local to it.

They had already diverged before anyone looked: the table names the tool guides and the forge reference, the skill lines do not. That divergence was invisible precisely because nothing said the two were meant to relate, so there was no statement for it to contradict.

## Considered Options

- **Table canonical, skills declare only their mode.** The strict single-home answer in one direction. Rejected because a repository partway through configuration would have no dependency set at all, and because the specification's own statement that a skill declares its dependencies would have to go with it.
- **Skills canonical, the table keeps only the mode column.** The strict answer in the other direction, and the more tempting one, since the table is always read *after* the skill that pointed at it — within a session the guides column is genuinely redundant. Rejected on a fact outside the session: in every repository but the one that builds AEP, `skills/` ships in the plugin and is absent from the tree. Without the table, a teammate with no plugin has no committed file that answers what a stage reads, which breaks the guarantee that nothing committed assumes the plugin.
- **Heal the current divergence and leave the structure.** Cheapest, and it fixes today's symptom while preserving the condition that produced it.

## Consequences

The configuration stage acquires a derivation it did not have: the table is written from the skill defaults plus local additions, rather than authored. A guide named by a skill's default and missing from that stage's row is a build failure unless the row records the omission deliberately — so dropping one stays possible and stops being silent.

The precedence is stated with its reason rather than as a bare verdict. The table wins because the table is the one that knows where it is; a reader who has only the rule can re-derive the reason, and a reader who has only the verdict cannot.

Two homes for one fact remains a thing to be suspicious of. What makes it survivable here is that each home can state something the other cannot — the plugin cannot know the repository, and the repository cannot ship to the plugin. Where that asymmetry does not exist, the duplication is not a default and an instance, and this decision is not a precedent for it.
