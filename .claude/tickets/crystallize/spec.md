---
owner: repository
status: implemented
sources:
  - specs.md, Parts II and IV
  - .claude/protocol.md
  - .claude/rules/
  - .claude/policies/
  - skills/configure/
---

# feat(protocol): instructions split by owner, compress to norm form, and load exactly

## Problem

Sessions ask the user what to do in situations the protocol already settles. The
failure recurs despite a personal memory note against it, so it is structural, and
it has three observed shapes: the settling text was not loaded at the decision
moment (loading is judged per stage, so it mis-loads); the text was loaded but its
imperative sat inside essay prose and was read past; or the text was genuinely
ambiguous. A fourth, structural cause licenses all three: every installed file is
repository-owned and healable, so framework law reads as negotiable — a session
that may edit a policy may also argue with it.

Separately, the corpus is expensive. The always-on tier is cheap (~2.3k tokens),
but a stage load reaches ~20k tokens of guides in which the norm, the mechanism,
and the rationale are interleaved, with rationale at 60–70% of volume. The token
cost and the read-past failure share one root: the norm and its apology live in
the same sentence.

## Goal

A session can tell law from policy by reading one field; framework law is followed
to the teeth because it is structurally immutable; every norm is a checkable
imperative carrying its one-line reason; each stage loads an exact, mandatory,
small set; and loaded tokens drop by roughly half with no norm lost.

## Constraints

- Nothing committed may assume AEP is installed — the fixed core is still
  committed text a plugin-less teammate can follow.
- Root `CLAUDE.md` stays under 200 lines.
- Templates change before this repository adopts (ADR 0025).
- Frozen records — accepted ADRs, resolved tickets, landed specs — are not
  rewritten to the new form.
- Clarity is never traded for compression. The audience is the model alone, so
  human-comfortable prose may be dropped — but a norm must stay unambiguous and
  complete at any density, and where the two conflict, clarity wins. The
  one-line why is that floor made concrete.

## Architecture

Four decisions, each an ADR this design run wrote:

**Ownership (ADR 0073).** Every instruction file AEP installs declares its owner
in frontmatter. `framework`-owned files are law: installed verbatim from the
release, version-stamped, compared byte-for-byte by the audit — drift there is
always a bug, never healing — and never edited, healed, or debated in a session.
Repository variation enters only through extension points the owning file names:
a structured declaration for facts, an ADR for variation that needs reasoning. A
variation with no point to enter through is a declared deviation — allowed, but
surfaced by every audit until the framework grows the point or the repository
conforms. Contexts, decisions, evidence, and derived tool guides remain
repository-owned and healable exactly as today.

**Norm form (ADR 0074).** A framework-owned normative file states each norm as a
checkable imperative or table carrying a one-sentence reason. The essays —
history, what-it-does-not-mean, failure stories — live in this repository's spec
and ADRs and are not installed. Mechanism (how to type a thing) stays with the
norm when short, in the tool guide when long.

**Exact loading (ADR 0075).** The stage table's load lists become mandatory and
exact: a stage loads its whole list, small enough to always load fully, and
judged selection disappears. The always-on core is selected by one test — would
its absence on a turn cause behavioral drift — and gains, in norm form: the entry
table, the no-ask rule (a loaded norm that settles a question is acted on, citing
the line; asking is for genuine forks), the fixed-owner rule, and the
verification core.

**Determinism (ADR 0078).** A fixed-core procedure is computed, or it names its
judgement: whatever a script can compute ships as a derived script step whose
output the stage quotes, and an irreducible judgement states its inputs and its
one question. Three applications carry this effort's risk reduction. Conversion
is manifest-driven: a numbered norm inventory is extracted before a file is
rewritten, every row gains a fire-checked suite guard, and the first conversion
proves the mechanism by seeding a norm deletion and watching the failure name
it. Extension points are derived from a variation census — the observed diff
between templates and installed copies, plus the per-repository facts the
specification names — never invented. And a deviation carries the release it
was declared under, so the audit computes its age and forces a disposition
after one release.

**Reconciliations.** ADR 0076 supersedes 0033: what `/configure` writes outside
the protocol directory is a specified bound, not a count. ADR 0077 narrows the
set-dispatch prohibition to landing and gives the worktree-removal rule a
disposition for children that never commit — closing the two waiting drift
findings this run raised.

## Approach

Spec first (ticket 01), because every surface derives from it. Then the four
surfaces in parallel where independent: the always-on core (02), the policy
families (03, 04), the router (05). Then the consumers: skills (06) and
`/configure` (07), which install and audit the ownership model. Adoption here is
last (08), per ADR 0025.

The risky part is the compression itself — a norm dropped during conversion is
invisible until it fails in the field. So conversion is manifest-driven, per the
determinism decision: inventory first, one guard per row, guards fire-checked,
and the pilot conversion gates every other conversion so the mechanism is proven
before anything else depends on it. Stability is bought with sequencing here —
the conversion frontier serializes behind the pilot, deliberately.

Options considered and rejected: a fixed *directory* instead of frontmatter
(visible in the tree, but forces a layout migration and splits rules from rules);
fixed content read live from the plugin, never installed (zero drift by
construction, but breaks the plugin-independence constraint); pure norms with the
why stripped entirely (maximum compression, but unreasoned rules get lawyered at
edges the reason would have caught); keeping the essays (no token win, and the
re-asking fix would rest on tiering alone).

## Acceptance criteria

- Every instruction file AEP ships or installs declares its owner, and the audit
  detects a byte of drift in a framework-owned file as a defect.
- A repository-specific fact that today lives inside policy prose lives in a
  declared extension or an ADR, and the policy names the point it enters through.
- A deviation is visible in every audit run without anyone remembering to look.
- Each stage's load list is exact; following it loads every norm that stage's
  decisions depend on; nothing in the corpus tells a stage to judge which guides
  to open.
- The always-on tier contains the entry table, the no-ask rule, the fixed-owner
  rule, and the verification core, and stays under the CLAUDE.md line budget.
- Total tokens loaded by a `/design` turn and an always-on turn are measured
  before and after, and the after is materially smaller with no norm lost.
- The two drift findings this run raised are consumed, each recording where it
  was healed.
- Every converted file has a norm manifest, every manifest row a fire-checked
  suite guard, and the pilot's seeded-deletion proof is recorded.
- Every extension point traces to a row in a committed variation census; a
  point with no row does not ship.
- A deviation's age in releases is computed by the audit, and one release
  without a disposition fails it.
- Every fixed-core procedure is classified computed or judged; computed ones
  are script steps whose output the stage quotes, and no procedure instructs
  unstructured judgement.

## Risks

- **A norm lost in compression.** Detection is mechanical, not judged: the
  manifest inventories norms before rewriting, each row is guarded, each guard
  is fire-checked, and the pilot proves the chain by a seeded deletion before
  any other conversion runs.
- **Extension points under-provide** and repositories fork policy prose again.
  Bounded at the source — points are census-derived, never invented — and
  detected mechanically after: deviation age is computed per release, and one
  release without a disposition fails the audit.
- **Density past the drift floor** — text so compressed the model misbehaves.
  Detection: the one-line why is mandatory per norm; a norm whose why cannot be
  stated in a line is not understood yet and does not ship.
- **The framework repository's own dual role blurs** — here the installed copies
  are also the product. Mitigation: ownership frontmatter makes the boundary
  explicit per file for the first time; the adopt ticket asserts it.

## Out of scope

- Long-session handling — compaction, handoff, re-anchoring after a clear. Real,
  but a separate design; nothing here depends on it.
- Rewriting frozen records to the new form.
- Any change to the Marker/Receipt mechanics; they are re-homed and compressed,
  not redesigned.
- New stages, new skills, or changes to what any stage does — this changes how
  instructions load and read, not what the workflow is.
