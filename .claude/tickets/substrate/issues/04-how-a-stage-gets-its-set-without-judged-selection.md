---
owner: repository
title: "docs(protocol): settle how a stage gets its set without judged selection"
status: resolved
blocked-by: [01, 03]
part-of: substrate
type: grilling
---

## Question

How does a stage obtain exactly what it needs, when the delivery mechanism is a
query the model composes?

`ADR 0075` made every stage's load list mandatory and exact, and removed judged
selection because mis-loads were the observed cause of sessions re-asking
settled questions. A query the model writes is judged selection restored. A
query that returns the stage's whole row deterministically is the same load with
a round trip added and nothing bought.

Settle which of these 2.0 runs, or what beats them:

- **Deterministic assembly.** The tool takes a stage name and returns that
  stage's exact set. Preserves `0075` intact; the win is only that the set can
  be assembled and compressed server-side rather than read as whole files.
- **Norm-level retrieval.** The tool takes a question and returns the norms that
  settle it, with citations. The win is large and it is the shape the user asked
  for — but its correctness now depends on the index, and a query that fails to
  match is a settled question re-asked, which is the exact failure `crystallize`
  was built to fix.
- **Both, with the first mandatory.** The exact set still arrives unasked; the
  query is an accelerator over what is already loaded and cannot be the only way
  a norm is reached.

What must be settled either way: what happens on a miss, how a miss is made
loud rather than silent, and whether the index's completeness can be asserted
by the suite rather than trusted.

Graduated from `07`: **what the tool does when two returned records disagree.**
Precedence is computed rather than declared, so the tool can rank a result set —
but whether it returns both with their ranks or resolves and returns one is
retrieval behaviour, and it belongs here. Returning one hides that a conflict
existed; returning both hands the model a judgement `ADR 0075` was trying to
remove. Cross-store contradiction is out of scope for this question — that is a
deviation, and ADR 0086 settled it.

## Answer

**The row is delivered, never queried.** `` !`command` `` preprocessing assembles
a stage's exact row and inlines it before the skill content reaches the model —
zero model round trips and no judgement. This ticket's framing assumed
deterministic assembly meant *the same load plus a round trip*; `01` falsified
that. It is strictly cheaper than the N `Read` calls a row costs today, and
ADR 0075 is untouched.

**The query serves only what the row deliberately excludes** — path-scoped norms
when a covered file is touched, cross-store norms a repository norm cites by id,
and the mid-turn lookup when a question arises that the row does not settle. The
two paths have disjoint jobs, so neither can quietly substitute for the other.
Letting the query replace the row was rejected: that is judged selection restored
in full, and a query that fails to match is the re-asking failure in a new
mechanism. Dropping retrieval entirely was rejected because it would reopen
ADR 0088 — a path-scoped pointer is not a skill and has no preprocessing to fetch
what it points at.

**There is no search, only filters over declared fields** — `type`, `fires-when`,
`id`, and a declared subject vocabulary, with no free-text matching anywhere.
This is the load-bearing choice of the ticket. It makes a miss **a true statement
about the store rather than a failed search**, so the caller never has to
distinguish *nothing governs this* from *my query was wrong* — the distinction
that would otherwise be invisible at the call site and would let a stage decide
something the store already settled. Same computed-over-judged reflex as ADR 0078.

**Completeness is asserted rather than trusted**: the suite round-trips every
norm record in the ledger through at least one filter, so an unreachable norm
fails the build.

**Conflicts are returned, never resolved.** ADR 0086 made a decision-versus-norm
conflict productive — the norm is amended in the same change — so a tool that
applied the computed rank and returned one record would suppress the amendment
obligation. The tool returns both records with their computed ranks and labels
the conflict kind: a declared deviation across stores, an undeclared defect
within one. Settled by that norm rather than re-asked.

**Two costs, stated rather than discovered.** The field vocabulary becomes
load-bearing — a caller who does not know the right value gets an honest empty
answer to the wrong question, and `06` owns how the vocabulary is discoverable.
And `disableSkillShellExecution: true` disables preprocessing wholesale, so a
user or enterprise setting can switch off row assembly; 2.0 has no answer to that
and it is graduated as fog rather than absorbed.

Recorded as ADR 0089.

### Amended, before the map was committed

The first answer above optimised **round trips and called it context savings**.
It is not: the row's content was unchanged, so `/implement` still received ~62 KB
and the token goal went unmet. Caught by re-reading the effort against the stated
goals rather than by anything in the tree.

**The row is a filter, not a list of files** — every norm whose `fires-when`
matches this stage, assembled from the records ADR 0085 made addressable. Same
mechanism, one level down; nothing new is built, and no judgement is introduced.
A norm firing for `/design` never reaches `/implement` even from a shared file.

The measurement that made the gap concrete: `.claude/policies/tickets.md` is
15,677 chars and is loaded whole by both stages; its slicing section (3,710) and
its protocol-only rule (1,665) are design-time only. **34% of one file that
`/implement` pays for and cannot use.**

A third cost joins the two above: **`fires-when` becomes a silent-failure
surface.** A norm labelled for the wrong stage stops arriving and nothing
reports it. The suite can assert the field is present and drawn from the declared
vocabulary; it cannot assert the value is right — the same class as ADR 0085's
*smallest correct span*. A file's preamble is its own record with its own
`fires-when`, so shared orientation is delivered rather than implicitly
inherited.

ADR 0089 was amended in place rather than superseded: it is uncommitted, and
`.claude/policies/decisions.md` holds that an ADR is a draft until committed.
