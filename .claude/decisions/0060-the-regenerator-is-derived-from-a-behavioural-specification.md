---
owner: repository
status: superseded
load-when: something AEP ships needs to exist as code in a configured repository, or the regenerator's source of truth is in question
sources: [skills/configure/, .claude/decisions/0057-one-regenerator-enforced-by-comparison.md]
supersedes: []
superseded-by: [0097]
---

# The regenerator is derived from a behavioural specification, not shipped as code

A configured repository gets its index regenerator by **derivation from a page in the configure skill** that specifies what the script must do, not by receiving a copy of AEP's own script. The page states each index's exact output, its ordering, its refusals, and the byte-stability requirement; `/configure` writes the script in whatever language that repository already uses. This is the same trade `TOOLS.md` already makes for tool guides, one level over: the shipped artefact is the description, and the derived artefact belongs to the repository.

The alternatives were the two horns ticket 09 was blocked on. A **copy** in every repository forks the moment the shipped script changes, and nothing would reconcile them. A **pointer into the plugin** breaks the plugin-independence the framework rests on — a teammate without AEP would have a `/commit` step naming a file they do not have. A description is neither: it is authoritative without being present, and what it produces is the repository's own.

**Behaviour is the contract, not source text.** That is what makes a Python or Node repository possible at all, and it is already enforceable — ADR 0057 requires the suite to regenerate each index and compare byte-for-byte, so a correctly derived script passes in any language. The entry-comparison check that pairs a derived tool guide with its source does **not** transfer here and is deliberately not attempted: there is no text to compare between a specification and an implementation of it.

## Considered Options

- **Ship the script and copy it into each repository.** Rejected: the fork ticket 09 named. It also makes PowerShell a requirement of the framework rather than an implementation detail of the repository that happens to build it.
- **Ship the script and have `/commit` reach it inside the plugin.** Rejected: plugin-independence is the property that keeps a configured repository useful to someone who never installed AEP.
- **Specification plus a reference implementation as an appendix.** Rejected, though it is the closest call: a reference implementation becomes the de facto contract, ambiguities in the prose get settled by reading code nobody promised to keep aligned, and a repository in another language receives a transliteration reviewed against the wrong artefact.

## Consequences

`/configure` acquires its **first executable output**. Everything it writes today is markdown, so this is a new responsibility rather than a new file, and the audit branch has to be able to check it.

**A freshly configured repository has nothing to compare a first regeneration against** — the first run creates the indexes, so a mis-derived script produces a wrong-but-self-consistent result that regenerate-and-compare then agrees with forever. The specification therefore carries a **worked fixture and its exact expected output**, and the derived script is run against it before it is run against anything real. That is the one check whose answer was not produced by the thing being checked.

This repository's own script becomes a derived artefact like any other, and must be reconcilable with the specification rather than being the thing the specification was written from.
