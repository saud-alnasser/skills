---
status: implemented
---

# Problem

AEP has one governance directory and two governance layers inside it.

`rules/` holds nine protocol-owned artifacts that define AEP itself and cannot be
edited in a repository, sitting beside whatever rules the repository writes for
itself. The specification already states the hierarchy — `protocol rules →
repository rules → effort rules → ticket constraints` — so the two layers are
real and load-bearing. The only thing distinguishing them is the `owner:` field
inside each file.

Three costs follow:

1. **The directory carries no signal.** An agent listing `rules/` cannot tell law
   from local convention without opening every file. The index carries `owner`,
   which means the answer exists only in derived state.
2. **The word does two jobs.** "Rule" means both *AEP requires this of every
   repository* and *this repository decided this*. A sentence like "record it in a
   repository-owned rule under `[[rules]]`" has to say which kind it means, every
   time, because the word does not.
3. **The shipped set is nine files.** Nine protocol-owned files, each a separate
   discovery decision, several of which fire on adjacent triggers — deciding
   *where a file belongs*, *whether you may touch it*, and *what shape it must
   have* are three files answering one moment. That is sprawl in the layer least
   able to afford it, because governance is what an agent must find without
   already knowing it is there.

# Goal

Governance is two named primitives instead of one word wearing two hats.

**Policies** are AEP's law: protocol-owned, never edited in a repository,
outranking every repository rule. **Rules** are the repository's own governance:
repository-owned, evolving freely, preserved by every upgrade. The directory an
artifact sits in tells you which it is, with no exceptions and nothing to look
up — and the shipped governance set is roughly four files rather than nine.

# Scope

- A new primitive, **Policy**, and its directory `.aep/policies/`.
- Redefinition of **Rule** as repository-owned governance only.
- Consolidation of the nine shipped rules into the policy set.
- `specs.md` amended, including reversal of the §33 row that retired policies and
  the invariant that forbids the directory.
- The payload: `src/rules/` → `src/policies/`, `protocol.md`, the templates.
- The scripts: `contract.mjs`, `validate.mjs`, `index.mjs`, `install.mjs`,
  `verify.mjs`.
- The upgrade path from 2.1.x, including link rewriting.
- The 1.x migration note, where "policy" now means something inverted.

# Requirements

1. **Policy is a primitive.** Artifacts under `.aep/policies/` carry `kind:
   policy`, `owner: protocol`, and a required `use-when`. The primitive tables in
   `specs.md` and `protocol.md` list it.
2. **Rules are repository-owned governance.** After a clean install, `rules/`
   contains no protocol-owned artifact. The seeded version-control rule stays a
   rule and becomes the exemplar of the primitive.
3. **Directory equals owner.** Every artifact in `policies/` declares `owner:
   protocol`; every artifact in `rules/` declares `owner: repository`. A
   repository MUST NOT author a policy. Validation rejects either violation.
4. **Policy outranks rule, absolutely.** A rule may tighten or extend a policy; it
   MUST NOT soften, contradict, or opt out of one. A conflict a repository cannot
   resolve by tightening is a declared deviation or is surfaced to the human —
   never settled by an agent picking a side.
5. **Rigidity is authority, not loading.** Policies are selected by `use-when`
   exactly as every other conditional artifact is. No policy is loaded because it
   exists, and nothing moves from `rules/` into the always-loaded bootstrap.
6. **The shipped set consolidates to at most five policies**, targeting four. Each
   merged policy states a single genuine trigger. Where two rules cannot share one
   trigger without the `use-when` degrading into a topic, they do not merge.
7. **No normative sentence is lost.** Every requirement in the nine rules survives
   into a policy, or is dropped deliberately with the reason recorded in this
   effort.
8. **The template set does not grow.** No policy template ships — a repository
   never writes one. `rule.template.md` is reworded to describe repository
   governance.
9. **An upgrade from 2.1.x moves governance rather than duplicating it.** It
   installs `policies/`, removes the protocol-owned rule files whose content now
   ships as a policy, reports each move, and leaves every repository-owned rule
   untouched.
10. **Moved links are rewritten and reported.** A wiki link into `rules/`
    targeting a former shipped rule is rewritten to its policy destination inside
    repository-owned artifacts, and every rewrite is listed in the upgrade report.
11. **The 1.x name collision is handled explicitly.** A 1.x `policies/<concern>.md`
    converts to a **repository rule**, never to a policy, because 1.x policies were
    derived per repository and 2.2 policies are protocol law. Legacy-layout
    detection stays scoped to runtime directories, so `.aep/policies/` never reads
    as a 1.x tree.
12. **The tooling knows the primitive.** `policies` leaves `FORBIDDEN_DIRS`;
    `kind: policy` becomes legal; the index gains a Policies section; `validate`
    and `verify` assert requirements 1–11.
13. **The release is stamped.** The version bumps and every protocol-owned
    artifact carries it, whether or not its prose moved.

# Acceptance Criteria

1. A tree containing `.aep/policies/*.md` with `kind: policy` passes
   `validate.mjs`; `specs.md` and `src/protocol.md` both list Policy in their
   primitive tables.
2. Installing into an empty repository produces a `rules/` directory whose only
   contents are seeds declaring `owner: repository`. `grep -l "owner: protocol"
   .aep/rules/` returns nothing.
3. `validate.mjs` fails on a `policies/` artifact declaring `owner: repository`,
   and fails on a `rules/` artifact declaring `owner: protocol`. Both failures are
   demonstrated by deliberate perturbation, not asserted.
4. The authority order in `specs.md` §4 and in the precedence policy places policy
   above rule, and states what a rule may and may not do to a policy.
5. No shipped policy is loaded unconditionally: every file under `src/policies/`
   declares a `use-when`, and no skill, mode, or `protocol.md` instruction directs
   an agent to read the policy set.
6. `src/policies/` contains four or five files. Each `use-when` names a moment at
   which an agent would reach for it, and none is a subject area.
7. A mapping from each of the nine rules to its destination policy — or to a
   recorded deletion with its reason — exists in this effort and is checked at
   review.
8. `src/templates/` contains no `policy.template.md`; `rule.template.md` names
   repository governance in its heading and `use-when`.
9. The install fixture upgrades a 2.1.x tree and afterwards: `policies/` holds the
   shipped set, no protocol-owned file remains under `rules/`, a repository-owned
   rule placed beforehand is byte-identical, and the report names every removal.
10. In the same fixture, a repository-owned context whose link targets
    `rules/engineering` targets `policies/engineering` afterwards, the tree's
    links all resolve, and the report lists that file. *(Written without bracket
    syntax deliberately: a link naming the before-state is data, and the
    rewriter cannot tell that from navigation — it rewrote this very line on the
    first run.)*
11. The fixture also proves: a `.claude/policies/` tree is still detected as 1.x,
    and an `.aep/policies/` tree is not.
12. `node src/scripts/verify.mjs` passes, every new assertion has been shown to
    fail against a deliberately broken tree, and `index.mjs` output over the
    building repository is byte-identical on a second run.
13. Every artifact under `src/` declares the new release, `protocol.md` included,
    and `protocol.md` is still under 8 KB.

# Constraints

- **Progressive discovery is not weakened.** It is a core principle; a change that
  buys tidiness by loading governance eagerly costs more than the problem it
  solves.
- **`protocol.md` stays under 8 KB.** Its governance table shrinks from nine rows
  to four or five, so the budget should get easier rather than harder.
- **Shipped text cites only what resolves where it is read.** No policy may cite
  `specs.md` or a section number — those exist only in this repository.
- **Every checkable claim gains an assertion in the same pass**, and every new
  guard is proven to fire by breaking the thing it checks. A green suite over a
  guard that cannot fail is the failure mode this repository has already hit.
- **The consolidation is editorial, not a rewrite.** Merging nine files into four
  is an opportunity to lose a requirement quietly; the mapping in criterion 7 is
  what makes that visible.
- **Nothing about the primitive is inferred from a path.** `owner:` remains the
  declared field, and requirement 3 is an additional constraint on top of it — not
  a replacement that lets tooling stop reading the field.

# Out of Scope

- **Repository-owned policies.** A repository's most non-negotiable local law is
  still a rule. The moment `policies/` can hold either owner, the directory stops
  being a signal and this change has bought nothing.
- **Always-loaded governance.** The invariants that hold on every turn stay in
  `protocol.md` and do not become policy files.
- **Renaming or removing `rules/`.** The directory survives with a narrower
  meaning.
- **Any other primitive.** References, contexts, evidence, efforts, modes, agents,
  worktrees, and position are untouched.
- **The skill and mode sets.** Seventeen skills, eight modes, unchanged in count
  and in name.
- **Adapter shape.** Adapters wrap skills; they never wrapped rules and will not
  wrap policies.
- **Reintroducing anything else 2.0 retired.** No `decisions/`, no `tools/`, no
  `plan.md`. This change reverses exactly one row of that table and says so.
- **Deciding the exact membership of each policy file.** The count and the
  trigger-quality bar are settled here; which rule lands in which file is
  `/plan`'s.

# Assumptions

- The 2.1.x installed base is small enough that a one-time upgrade sweep is
  acceptable. If AEP is installed in repositories not visible from here, the link
  rewriting in requirement 10 is doing more work than assumed.
- Four themed policies can be found whose triggers are genuinely single. The
  proposed grouping — file-authoring concerns together, engineering and evidence
  together, effort execution and sub-agents together, precedence and boundary
  together — is a starting point, and the fourth is the weakest of the four.
- Reversing a documented retirement is acceptable because the concept returning is
  not the concept that left: 1.x policies were derived per repository, and these
  are protocol law. The specification's own words allow it — a 1.x concept may
  survive where it "earned its place again under this model".

# Open Questions

Both questions this spec opened are answered in `# Architecture` below.

- ~~Does `boundary` earn a fifth file?~~ No — it merges with `precedence` into
  `policies/authority.md`. Both are rare-firing and both answer *what may I treat
  as authoritative, and what may I act on*. Named as the weakest of the four in
  the alternatives table, with the five-file variant recorded there.
- ~~Does the authority policy restate what `specs.md` §4 says?~~ It is not a
  restatement. `specs.md` is never installed, so it is not a second home an agent
  can read: it prescribes the protocol, and the policy is the artifact that
  implements it. That is the relationship every shipped file already has with the
  specification.

# Risks

- **The split reads as cosmetic.** If a policy is only a rule in a different
  directory, the next release reverses this the way 2.0 reversed 1.x. Requirement
  4 is what makes it structural; if it ends up soft, the change is not worth
  making.
- **A merged `use-when` degrades into a topic.** This is the one failure the
  frontmatter contract cannot catch — the artifact validates and is then loaded
  always or never. Requirement 6 exists for this and needs judging by reading, not
  by tooling.
- **The upgrade writes into repository-owned files for the first time.** Link
  rewriting is mechanical and has one correct answer, but a bug there corrupts
  files the protocol has always promised not to touch. It needs the narrowest
  possible match and a report of every edit.
- **"Policy" now means the opposite of what it meant in 1.x.** A human reading an
  old migration report, or an agent carrying 1.x habits, will map a 1.x policy
  onto a 2.2 policy — which is precisely backwards, since 1.x policies were the
  repository's. Requirement 11 addresses the tooling; the prose has to address the
  human.
- **A requirement is lost in consolidation.** Nine files into four, edited for
  flow, is where a MUST quietly becomes a SHOULD.

---

# Architecture

Three decisions carry this change. Each had a real alternative, and the ones that
lost are named.

## Decision 1 — the policy set is four files, grouped by the moment they fire

| | Absorbs | Trigger |
| --- | --- | --- |
| `policies/authority.md` | `precedence`, `boundary` | two sources disagree, or the work reaches a repository other than this one |
| `policies/engineering.md` | `engineering`, `evidence` | writing code, or about to state something about this repository you have not verified |
| `policies/execution.md` | `change-control`, `sub-agents` | an effort is in progress — deriving tasks, dispatching, implementing, or reviewing |
| `policies/artifacts.md` | `artifacts`, `ownership`, `placement` | about to create, change, move, or remove anything under `.aep/` |

The grouping is by **the moment an agent needs it**, never by subject. Two of the
four are already evidenced in the current text: `evidence` opens by conceding
that *how a claim is made at all* belongs to `engineering`, and `ownership`
closes by handing the reader to `artifacts`. A rule that has to point at another
rule to be complete is one file split into two.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **Four files** *(recommended)* | one discovery decision per moment; the two cross-referencing pairs stop pointing at each other; the bootstrap table drops from ten rows to five | a session that triggers `execution` pays for delegation doctrine it may not use | a merged `use-when` reads as a subject area rather than a moment | four files to keep coherent as the protocol grows |
| **Five files — `sub-agents` stands alone** | the largest single rule (111 lines) stays behind its own narrow trigger, and runtimes without sub-agents never load it | the sprawl this effort exists to reduce is only 9→5; delegation is separated from the effort lifecycle it only ever happens inside | `change-control` and `sub-agents` drift apart on task-splitting, which both currently state | five files |
| **Five files — `boundary` stands alone** | keeps the weakest merge unmade; boundary's trigger stays sharp | boundary is 41 lines behind a rare trigger — the cheapest thing in the set to carry inside a larger file | none material | five files |
| **Nine files, renamed** | zero editorial risk; nothing can be lost in a merge | does not address the stated goal at all | the change reads as cosmetic and gets reversed | nine files |

**Chosen: four**, by the human, with the five-file variants on the table. The
`execution` merge is the one carrying the accepted cost, and it is named again
under `# Technical Risks` so a later reader knows it was priced rather than
missed.

Two consequences of merging, accepted deliberately:

- **`mode:` is dropped from every policy.** The mode union of each merge covers
  six or seven of the eight modes, and a field matching nearly everything selects
  nothing — it would cost an index column to say *always*. `use-when` carries the
  applicability instead. Only `policies/artifacts.md` keeps `paths:`
  (`.aep/**/*.md`), which stays narrow and true.
- **Each merged policy keeps a `##` section named for the rule it absorbed**, so
  the content stays findable by the name it had.

## Decision 2 — moves are declared, not inferred

`install.mjs` today reports a protocol-owned file that is no longer shipped as
**retired** and never deletes it, because deciding a file is obsolete is a
human's call. That is right for a retired concept and wrong for a moved one: an
upgrade that leaves `rules/precedence.md` beside `policies/authority.md` leaves
the tree governed by two copies of one policy, and the stale one still resolves.

So the release declares its moves, in `payload.mjs`:

```js
export const MOVES = [
  { from: 'rules/precedence.md',     to: 'policies/authority.md',   since: '2.2.0' },
  { from: 'rules/boundary.md',       to: 'policies/authority.md',   since: '2.2.0' },
  { from: 'rules/engineering.md',    to: 'policies/engineering.md', since: '2.2.0' },
  { from: 'rules/evidence.md',       to: 'policies/engineering.md', since: '2.2.0' },
  { from: 'rules/change-control.md', to: 'policies/execution.md',   since: '2.2.0' },
  { from: 'rules/sub-agents.md',     to: 'policies/execution.md',   since: '2.2.0' },
  { from: 'rules/artifacts.md',      to: 'policies/artifacts.md',   since: '2.2.0' },
  { from: 'rules/ownership.md',      to: 'policies/artifacts.md',   since: '2.2.0' },
  { from: 'rules/placement.md',      to: 'policies/artifacts.md',   since: '2.2.0' },
];
```

One declaration drives three things — the removal, the link rewrite, and the
verification — so they cannot disagree with each other.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **Declared manifest** *(recommended)* | deterministic; one home for the mapping; the suite can assert every entry resolves | a list that grows at every future move | an entry gets stale after the release nobody runs from anymore | entries may be dropped once no supported tree predates them |
| **Redirect stubs left in `rules/`** | no deletion at all; old links keep resolving | a protocol-owned stub in the repository-owned directory — it breaks *directory equals owner* on the very release that introduces it | the stub is indistinguishable from a repository's own rule | forever |
| **Prose instruction in `[[skills/update]]`** | no script change | a nine-file mechanical rename left to judgement, differently each run | a missed file leaves two governing copies silently | none, and that is the problem |
| **Infer from content similarity** | no manifest | guessing, which the protocol forbids where a declaration is possible | wrong match deletes governance | unbounded |

## Decision 3 — the directory is an invariant, but ownership is still read off the field

Requirement 3 (*directory equals owner*) and the standing rule that ownership is
**never inferred from a directory** are not in conflict, and the resolution
matters because it is where a bug would destroy repository knowledge.

They compose as **preserve, then report**:

1. `install.mjs` decides what to overwrite exactly as it does today — by reading
   each existing target's declared `owner`. Its promise never to overwrite a
   repository-owned file is unchanged, including for a repository-owned file
   sitting inside `policies/`.
2. `validate.mjs` then **fails** on that file, because `policies/` may hold only
   `owner: protocol`.

So the illegal state is preserved rather than silently corrected, and reported
rather than silently accepted. The human resolves it. Enforcing the invariant in
the installer instead — by deleting or overwriting the offending file — would
make the tidier tree at the cost of the one promise the protocol has always kept.

# Components

| Path | Change |
| --- | --- |
| `src/policies/{authority,engineering,execution,artifacts}.md` | **new** — the four policies, `kind: policy`, `owner: protocol` |
| `src/rules/` | **deleted** — the directory ships nothing |
| `src/seed/rules/version-control.md` | unchanged in content; now the only thing that lands in `rules/` |
| `src/protocol.md` | primitives table gains Policies; the load-when table becomes four policy rows plus one line placing repository rules beside them |
| `src/scripts/payload.mjs` | `PAYLOAD_DIRS`: `rules` → `policies`. `REPOSITORY_DIRS`: gains `rules`. New export `MOVES` |
| `src/scripts/contract.mjs` | `KINDS` gains `policy`; `FORBIDDEN_DIRS` loses `policies`; `USE_WHEN_REQUIRED_DIRS` gains `policies`; new export `DIRECTORY_OWNERS = { policies: 'protocol', rules: 'repository' }` |
| `src/scripts/validate.mjs` | enforces `DIRECTORY_OWNERS`; nothing else changes |
| `src/scripts/index.mjs` | `SECTIONS` gains a Policies section, ordered before Rules |
| `src/scripts/install.mjs` | applies `MOVES` under `--update`: removes the protocol-owned source, rewrites links, reports both |
| `src/scripts/verify.mjs` | the `rules` section becomes `policies`; new assertions; the fixture's rule-collision case moves to `policies/` |
| `src/templates/rule.template.md` | reworded to *repository* governance |
| `src/templates/protocol.template.md` | the line calling the bootstrap "not a policy database" now reads as being about `policies/`; reworded |
| `src/skills/update.md`, `src/skills/update/migration.md` | 1.x `policies/` is disambiguated from `.aep/policies/`; the Policies conversion section is rewritten |
| 88 files under `src/` carrying a wiki link into `rules/` | rewritten to their policy target — 116 links, of which 63 are seed references |
| `specs.md` | §3, §4, §5, §7, §8, §10, §28, §32.2, §33, §35 |
| `.aep/` | reinstalled from `src/` |

# Interfaces

**Frontmatter.** A policy declares `aep`, `owner: protocol`, `date`, `kind:
policy`, `use-when`. `mode:` is omitted from all four; `paths:` appears only on
`policies/artifacts.md`.

**The directory–owner table**, exported once from `contract.mjs` and consumed by
`validate.mjs`:

```js
export const DIRECTORY_OWNERS = { policies: 'protocol', rules: 'repository' };
```

**The link rewriter**, in `install.mjs`, is deliberately the narrowest thing that
can work:

- it runs only under `--update`;
- it considers only `.md` files under `.aep/` whose declared `owner` is
  `repository` — protocol-owned files are overwritten wholesale anyway;
- it matches only a wiki link whose target is `rules/<name>` — bare, aliased, or
  anchored — where `<name>` is one of the nine in `MOVES`;
- it **skips any name for which `rules/<name>.md` still exists after the moves**
  — that file is the repository's own, the link correctly points at it, and
  rewriting it would break a live link to redirect it at a policy the repository
  never referenced;
- it replaces only the target, preserving any alias or anchor the link carried;
- it reports every file and every replacement.

Links are rewritten to the plain policy path — a link to `policies/authority`,
never to `policies/authority#precedence`. The anchored form was considered and
rejected: it is more precise, but it puts anchor-construction inside the one
piece of code that writes into repository-owned files, and precision there is
worth less than a smaller blast radius. Shipped prose, which is hand-edited, uses
an anchor where the sentence is about one absorbed section.

# Migration

**From 2.1.x**, under `--update`, in this order:

1. install the payload as today — `policies/` lands, `rules/` is no longer a
   payload directory and is created as a repository directory if absent;
2. for each `MOVES` entry whose `from` exists: if it declares `owner: protocol`,
   delete it and report `moved`; if it declares `owner: repository`, leave it and
   report a **collision** — the repository wrote its own rule under a name the
   protocol has now vacated, which is legal and needs a human to look at;
3. rewrite links per the interface above;
4. regenerate the index; validate.

An upgrade run twice is a no-op: after the first, no `from` exists and no link
matches.

**From 1.x**, unchanged in outcome and clarified in wording. A 1.x
`policies/<concern>.md` converts to a **repository rule** or to nothing — never
to a policy — because 1.x policies were derived per repository and 2.2 policies
are protocol law. The two words are inverted across the boundary, and the
migration note says so in those terms. Legacy detection stays scoped to
`.claude/`, `.cursor/`, and `.codex/`, so `.aep/policies/` cannot read as 1.x.

# Testing Strategy

Every acceptance criterion, against the assertion that checks it. Each new guard
is proven by breaking the thing it checks and watching it fail with the right
name — a green run over a guard that cannot fire is this repository's known
failure mode.

| Criterion | Checked by |
| --- | --- |
| 1 — the primitive exists | `verify` reads Policy from the `specs.md` primitives table and from `src/protocol.md` |
| 2 — `rules/` ships nothing | fixture: every `.md` under the installed `rules/` declares `owner: repository` |
| 3 — directory equals owner | fixture writes `policies/x.md` with `owner: repository`, asserts `validate` fails; then `rules/y.md` with `owner: protocol`, same |
| 4 — policy outranks rule | `verify` asserts the ordering appears in `policies/authority.md` and in `specs.md` §4 |
| 5 — nothing loads unconditionally | every `src/policies/*.md` declares `use-when`; no skill, mode, or `protocol.md` text directs reading the set |
| 6 — four or five files, real triggers | `verify` counts the directory; the trigger judgement is a review finding, not a check, and `validate` keeps saying so in its summary |
| 7 — nothing lost | the nine→four mapping table lands in this effort; correctness review reads it against the old files |
| 8 — no policy template | `verify` asserts `templates/policy.template.md` is absent and that `rule.template.md` names repository governance |
| 9 — the upgrade moves rather than duplicates | fixture: install 2.1-shaped `rules/`, upgrade, assert every `from` is gone, `policies/` is complete, and a pre-placed repository-owned rule is byte-identical |
| 10 — links rewritten and reported | fixture: a repository-owned context linking `rules/engineering`; after upgrade it links `policies/engineering`, the tree validates, the report names the file. Plus the negative: a repository that kept its own `rules/evidence.md` has its link to `rules/evidence` left alone |
| 11 — 1.x is still 1.x | fixture: `.claude/policies/` is refused as 1.x; `.aep/policies/` installs cleanly |
| 12 — the suite is honest | existing guard-fires section, extended to one new assertion |
| 13 — stamps and budget | existing release-readiness section; `protocol.md` has 1,274 bytes of headroom today and the change should return some |

# Operational Considerations

- **The `.aep/` tree here is reinstalled, not hand-edited.** `node
  src/scripts/install.mjs --into . --update` after `src/` settles, then
  `index.mjs`, then `validate.mjs`, then `adapters.mjs`.
- **The 116-link sweep is mechanical and must be done by script, not by hand.** A
  hand sweep across 88 files will miss one, and the missed one is a dangling link
  in a shipped seed. Write it as a throwaway, run it, then let `validate` prove
  the tree.
- **Order matters within the implementation**: policies written → links swept →
  scripts updated → `specs.md` amended → reinstall → verify. Amending `specs.md`
  before the surfaces exist leaves the suite asserting against a specification
  the tree does not yet meet, which is a confusing intermediate state rather than
  a wrong one.

# Technical Risks

- **The link rewriter is the dangerous component.** It is the first code that
  writes into repository-owned files. The mitigations are all narrowness: nine
  known names, `owner: repository` only, skip-if-still-present, target-only
  replacement, and a report of every edit. It gets the closest reading in review.
- **Consolidation widens applicability.** Dropping `mode:` means an artifact that
  was declared relevant to four ways of working is now relevant to any of them.
  That is honest for `engineering` — its trigger already fired during `specify`,
  where its `mode:` did not list it — and least honest for `execution`, whose
  delegation half is genuinely narrow. It is the strongest argument for the
  five-file variant.
- **`MOVES` is a permanent-looking structure for a one-release job.** It earns
  itself only if the protocol moves files again. If it does not, a future release
  should drop the entries rather than carry them, and the `since:` field is what
  makes that decidable.
- **The install fixture grows a 2.1-shaped tree.** Building one by hand inside
  `verify.mjs` risks testing against a shape 2.1 never actually produced. It is
  built from the nine real filenames and a real repository-owned file, not from a
  guess at what 2.1 looked like.
