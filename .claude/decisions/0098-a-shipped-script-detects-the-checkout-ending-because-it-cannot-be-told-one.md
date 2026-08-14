---
owner: repository
status: accepted
load-when: the working tree's line endings are in question, or what a shipped script may emit
sources: [scripts/report-position.js, skills/configure/SCRIPTS.md, .gitattributes, .claude/scripts/regenerate-indexes.ps1]
supersedes: [0069]
superseded-by: []
---

# A shipped script detects the checkout ending, because it cannot be told one

This repository still pins its checkout to one ending for every contributor, and
that half of ADR 0069 is carried forward unchanged. What changes is the other
half: a script the plugin copies byte for byte into every repository **detects**
the checkout's ending at runtime rather than being told it, because there is no
longer anywhere to tell it.

**0069 is superseded rather than scoped because its subject is retiring.** It is
titled for a *derived* script — one each repository re-implemented from a
behavioural page, and therefore one that could carry a per-repository fact in its
own source. ADR 0097 abolished that category: a shipped script is one file, copied
everywhere, identical in every clone. A fact that differs per repository cannot be
written into a file that is the same in all of them, so the rule 0069 rejected is
the only rule available.

**0069's objection is answered rather than outranked, and this is the part worth
recording.** It rejected detection because *"a detector reading a file that
happens to be absent produces a confident wrong ending"* — a real failure, and one
this detector does not have: it asks git for the attributes **in force**, which
needs no file to exist. That matters concretely, because the file whose ending is
in question is absent by definition on a first run. Where the attributes say
nothing the chain falls through the clone's conversion setting, then its ending
setting, then the platform. That order is git's own precedence rather than a
plausible one, and it was established by building repositories in each state and
comparing what git reports against what it puts on disk — the conversion setting
is asked first because git ignores the ending setting whenever it is set.

**One split is deliberate: what the script writes takes the checkout's ending,
and what it prints keeps the platform's.** Printed output never reaches disk; it
is captured through whatever console the shell has. Naming the two separately in
the code is what keeps this readable as a choice rather than an inconsistency.

## Considered Options

- **Hardcode one ending into the shipped script.** Rejected: correct in
  repositories that pin that ending and silently wrong in every other, and the
  script has no way to learn which it is in.
- **Keep 0069 accepted and narrow it in a new record.** Rejected: 0069's clause is
  part of what it decided, so a reader would have to traverse two records to learn
  whether a script may detect — and the older one would keep reading as a live
  prohibition.
- **Pass the ending in as an argument the configuration stage writes.** Rejected:
  it reintroduces per-repository derivation through the back door, on the one
  category 2.0 kept byte-identical precisely so a copy could be checked against
  its source.

## Consequences

**The pin stays, and stays load-bearing.** Contributor divergence is what it
removes: with nothing pinned, the bytes in a working tree are a function of each
clone's local setting. Nothing here weakens it, and the shipped script running in
this repository reads it and agrees with it.

**The remaining script ports inherit this.** Four shipped scripts are still
unwritten, and any of them that writes a file writes it this way.

**A tool guide gained an entry it did not have.** The detector asks git a question
no guide here documented; using an undocumented one is the configuration gap the
engineering rule names, and closing it is part of using it.
