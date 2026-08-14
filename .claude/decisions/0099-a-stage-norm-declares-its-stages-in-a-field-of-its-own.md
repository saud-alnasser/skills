---
owner: repository
status: accepted
load-when: how a norm names the stage it fires at, or how the store query filters on it, is in question
sources: [skills/configure/policies/records.template.md, skills/configure/SCRIPTS.md, specs.md, scripts/build-knowledge-store.js]
supersedes: []
superseded-by: []
---

# A stage norm declares its stages in a field of its own

The record format requires a norm whose firing condition is `stage` to name which
stage, and nothing stated the form. It becomes a **list field of its own**, beside
the firing condition rather than inside it: the firing condition says which *kind*
of condition, and the list says which stages.

**The query decides this, not the record.** The store is reached by filters on
declared fields, and a filter naming a field no record declares is refused
precisely so that a miss is a fact rather than a guess. Asking *which norms fire
at this stage* against a value like `stage:implement,commit` means matching inside
a field — the loose match the query exists to refuse, readmitted at the one place
it would be most convenient. A list field is the only form that answers the
question by exact match on a declared field, which is the whole mechanism.

**The residue is what rules out the cheaper form.** Several policies being
converted are read by four stages each. One stage per record turns one rule into
four copies, at conversion scale, in a framework whose stated purpose is that a
rule has exactly one home.

## Considered Options

- **A colon qualifier carrying one stage**, `fires-when: stage:implement`. The
  only form the corpus has ever written, and the cheapest to check. Rejected: it
  duplicates every multi-stage norm, and the duplication arrives during a
  conversion of twenty-one templates rather than one at a time.
- **A colon qualifier carrying a comma list**, `fires-when: stage:implement,commit`.
  A one-line change, and it handles the residue. Rejected on the query argument
  above — it is the form that looks cheapest and costs the most, because the cost
  lands on every future consumer rather than on the author.
- **A judged condition — the model decides which stages.** Rejected before it was
  considered seriously: the firing vocabulary deliberately has no judged value,
  because a firing condition the model decides is judged selection wearing a
  field's clothes.

## Consequences

**A norm declaring the kind and no list is a new refusal**, and so is one naming a
stage the router does not carry. The second is the failure this design is most
exposed to — the label is legal, the build is green, and the norm simply never
arrives anywhere, with a row that should have carried it indistinguishable from a
row that never had it.

**Two fields must agree**, and disagreement is a third refusal: the list is
meaningless on a record whose firing condition is not `stage`.

**The conversion of the departing policies unblocks on this.** It was blocked on
nothing else.
