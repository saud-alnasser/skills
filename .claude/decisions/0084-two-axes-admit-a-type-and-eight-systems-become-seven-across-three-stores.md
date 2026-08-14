---
owner: repository
status: accepted
load-when: what kind of record something is, or which store holds it, is in question
sources: [.claude/tickets/substrate/issues/02-which-record-types-survive-the-flattening.md, specs.md]
supersedes: [0032]
superseded-by: []
---

# Two axes admit a type, and eight systems become seven across three stores

A record type exists where **write authority and post-write mutability** differ,
crossed with whether the record **binds or describes**. Required field sets were
rejected as the test because fields are consequences of those two and testing on
them ratifies the current accident; retrieval was rejected as circular, since the
`substrate` effort is redesigning retrieval and a taxonomy resting on it could be
redefined by a downstream decision. Applying the two axes reproduced almost
exactly today's eight systems, which is the finding: they are principled, and the
simplification available is fewer *mechanisms* carrying the distinctions rather
than fewer distinctions.

The corpus resolves into seven types across three stores — framework (shipped in
the plugin), knowledge (this repository's files), and tracker (files or the
forge, behind a fixed query interface). `norm` exists in both the framework and
knowledge stores, and which store holds it is what makes it law or local; a
`fires-when` field — every-turn, path, stage, posture — replaces the split
across rules, policies, and modes, which the two axes cannot tell apart. **A
policy is thereby defined rather than assumed: a norm whose firing condition is
a stage.** `context`, `decision`, `evidence`, `reference`, and `spec` fill the
remaining cells; `ticket` and `map` are the tracker store's.

**The `fires-when` vocabulary is closed, and the value it deliberately lacks is
the point.** Amazon Kiro ships the same field under the name `inclusion` with four
values — `always`, `fileMatch`, `manual`, and `auto`, where "Kiro uses the
description to decide when the steering file is relevant." The first three are
deterministic and are AEP's every-turn, path, and posture; `stage` is AEP's own,
having no Kiro equivalent. **`auto` is refused**: a firing condition the model
judges is judged selection wearing a field's clothes, which ADR 0075 removed and
ADR 0089 designed out. An open vocabulary readmits it by accident, so the set is
closed and a value outside it fails the build. Kiro also supplies the failure to
avoid — its CLI "does not currently support" inclusion modes and loads every
steering file, which is the degradation ADR 0088's second face must not repeat.

Two consequences follow rather than being chosen. The byte-lock apparatus —
per-file version stamps, template-versus-copy comparison, and the audit's
coverage sweep — exists only because framework files are copied into a
repository, and under this model nothing is copied. And the `precedence.md`
clause explaining that one directory spans two ranks because loading mechanism
splits it becomes a comparison of a field.

**Status is `proposed`, as with ADR 0083 and for the same reason:** 1.x is the
live framework and its placement decisions still govern. ADR 0032, which put
modes in their own directory, is contradicted by the `fires-when` field and is
superseded at both ends when 2.0's spec is accepted. ADRs 0021, 0056, and 0073
are affected and read against this model then, not now.

## Considered Options

- **Five types, normative force dropped** — the largest collapse, rejected
  because it merges directives with facts: a session reading a boundary could
  not tell whether it was being told what is true or what to do, and `specs.md`
  §8's line that contexts contain facts and never instructions is load-bearing
  for how a context is written.
- **Keep the eight as first-class types** — rejected: it answers *what is a
  policy* with *what it already was*, and the concept count does not move.
- **One store with `owner` as a field** — rejected: it keeps the entire
  apparatus that exists only because framework files are copied, and every
  upgrade would rewrite rows in a store that also holds healed ones.
- **Tickets in the knowledge store** — rejected on tracker uniformity, since a
  GitHub-backed repository has no ticket files to index. A tracker store with a
  pluggable backing answers the objection the rejection rested on.
