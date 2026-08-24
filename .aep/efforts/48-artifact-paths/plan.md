---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture

Four repairs, landing independently. The spec establishes they are one defect in
several costumes; the approach below keeps them separable, because each has its
own false-positive risk and coupling them would make one bad guard block the
rest.

## Repair 1 — the path convention

The population is measurable rather than estimated. A path that instructs
somebody to write or read a file always has **two or more segments**
(`efforts/<effort>/spec.md`, `skills/<skill>/<note>.md`,
`contexts/<project>/<area>.md`). A path that names a primitive area always has
**one** (`policies/`, `efforts/`, `rules/`). Across `src/skills`, `src/policies`,
`src/templates`, `src/agents`, `src/protocol.md`, and `src/seed`, that split
separates 37 write-target sites from every area name with no residue: no
multi-segment site is an area name, and no single-segment site is a write target.

That is what makes the convention choosable rather than arbitrary.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A — multi-segment paths carry `.aep/`; area names stay bare** | Unambiguous exactly where the ambiguity is. Costs 10 bytes in `protocol.md`. Guard is one regex with no exception table. Nothing to learn: the prefix is the answer to the question the reader is asking | Two forms in the corpus, so a reader must notice which they are looking at | A future write-target path with one segment would slip. There is no such path today and the tree has no depth-1 artifacts | One regex, no allowlist |
| **B — a root sigil, `/efforts/<effort>/spec.md`** | Shortest. Visually distinct from a repository-relative path | Invents notation for one corpus. A leading slash reads as filesystem-absolute to most readers, which is a *worse* wrong answer than the current one | Somebody resolves it against `/` and writes outside the repository | The sigil needs teaching in every template |
| **C — prose states the root, no notation** | Reads best | Not mechanically checkable, so requirement 5 cannot be satisfied | Decays back within two releases, which is how it arrived | None, and that is the problem |
| **D — every tree path carries `.aep/`, area names included** | One rule, zero exceptions, simplest possible guard | **Does not fit.** 120 bytes of prefixes against 149 bytes of `protocol.md` headroom leaves 29 for the convention sentence | Forces either a budget raise or compression of the bootstrap to satisfy a mechanical rule | Flat grep, but the budget becomes a standing tax |

**Recommended: A.** D is the tidier rule and the measurement kills it: `protocol.md`
stands at 8043 bytes of a 8192-byte budget, the prefixes cost 120, and the
sentence that has to accompany them costs about 85. Raising the budget to buy
uniformity would be trading the bootstrap's size limit for a regex's simplicity,
which is the wrong direction — the budget exists because the bootstrap is read on
every turn.

A is also not a compromise. `efforts/` on its own never misled anybody, because
nobody writes a file *to* `efforts/`. The defect was always multi-segment write
targets, and A is the convention aimed at the defect rather than at the character
class.

**The reason is recorded in `[[policies/artifacts]]`**, under "Where it goes",
beside the ownership table that already answers the neighbouring question. That
is the site requirement 6 names: somebody authoring a new artifact reaches it,
and it ships to every consuming repository. `[[protocol]]` carries the one-line
statement (requirement 2) and points there.

### The two tables

`protocol.md`'s primitives table and its ownership table hold single-segment
names in cells, and `skills/update/migration.md` holds a five-row mapping table
of multi-segment paths. Under A the first two need nothing. The migration table
does, and it takes the prefix on both columns: its left column is 1.x layout and
its right column is 3.x, and a reader consulting a migration table mid-upgrade is
precisely the reader who cannot afford to guess a root.

**Corrected 2026-08-24, after review.** The claim about the first two tables is
false of the primitives table. Its "Lives in" column holds `efforts/<e>/`, which
is two segments and therefore in the sweep, and `skills/<skill>/` sits in the
prose below it. What is true is the narrower thing the argument needed: the
*ownership* table holds single-segment names and needs nothing. Ticket 05 carries
the instruction; this is the reasoning it would otherwise have been read against,
and a ticket closes while a plan is what the next reader of repair 1 finds.

## Repair 2 — the stray check

`resolveAepRoot` returns the directory holding `protocol.md`, and every walk
starts there, so *outside the root* is not a state any current script can
represent. The check has to look one level up.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A — scan the repository root's immediate children, gated on artifact shape** | Catches the observed failure exactly. Bounded cost: at most nine `readdir` calls. Cannot reach `node_modules`, `src/`, or anything nested | A stray written to `docs/efforts/` is missed | A repository with a root `templates/` of Markdown-with-frontmatter trips it. The shape gate below is what closes this | One directory list |
| **B — walk the whole repository, minus ignored directories** | Catches strays at any depth | Needs a `.gitignore` reader to stay tolerable, and false positives grow with repository size. **This repository would flag its own `src/skills/`** without a hand-written exclusion, which is the exact shape of guard `[[rules/authoring]]` warns about | Fires on somebody else's install, where it is least recoverable, and teaches them the validator is noise | An exclusion list that grows per consumer |
| **C — the writing skills check before they write** | Prevents rather than detects | Every skill needs it, and an agent writing a file directly bypasses all of them. Does not make `validate.mjs` honest, which is what requirement 3 asks for | The green "no failures" stays possible | Duplicated across nine skills |

**Recommended: A**, with C noted as complementary and out of this effort. B is
rejected on the concrete evidence that it would flag this repository's own
source tree, so its first act would be to need an exception for the repository
that wrote it.

### The shape gate

Requirement 4 turns on what counts as AEP-shaped, and "Markdown with frontmatter"
is too loose — it would catch a Jekyll `_posts` clone renamed. The gate is
**recognition by the contract**, not by file type:

- a root `efforts/` is a finding only where some child directory holds a
  `spec.md` whose `status:` is in `SPEC_STATUSES`;
- a root `policies/`, `skills/`, `agents/`, or `templates/` is a finding only
  where some file inside it carries a `use-when`, which is the same test the
  arm below uses, because those four ship Markdown artifacts and nothing else;
- a root `scripts/` is a finding only where some file inside it is byte-identical
  to the script this release ships at that path. A script carries no frontmatter,
  so identity is the only content this arm can read;
- a root `rules/`, `contexts/`, or `references/` is a finding only where some
  file inside it carries a `use-when` and sits at the depth
  `[[policies/artifacts]]` allows for its kind.

A consuming repository's `templates/` of Handlebars files, or `references/` of
citations, satisfies none of these. The gate asks a question only an AEP artifact
answers yes to.

**Corrected 2026-08-24, after review.** The protocol-directory arm was specified
as `isProtocolPath`, which is `PROTOCOL_FILES.includes(relative)` and reads no
content, so it fired on an ordinary repository's root `scripts/index.mjs` and
even on an empty one. That is the false positive the spec calls the case that
decides whether the check ships, and the remediation it printed sent the reader
to a protocol-owned path the next update overwrites. The evidence is
`[[efforts/48-artifact-paths/evidence/research/protocol-directory-shape-gate]]`.
Every arm now reads content, which is what makes the sentence above true rather
than merely intended. Rejected on the way: identity in every arm, which would
miss an artifact authored at a bare path, the defect this effort exists to fix;
and dropping the arm, which trades a false positive for a blind spot.

**It reports and does not move** (spec constraint), and it names three things:
what was found, where it sits, and where it belongs.

## Repair 3 — the entrypoint's claims

The failure was not that a word appeared. It was that `AGENTS.md` asserted
something about a mechanism and no check tied the two together. Two shapes can
close that.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **Assert — check the prose against the implementation** | Keeps the entrypoint prose, which is what it is for. Works identically for this repository's `AGENTS.md` and the seed | One assertion per claim, written by hand. Generalises only as far as the assertions reach | Assertions written narrowly around `aep:` and nothing else, which is spec risk 4 | Grows with the file |
| **Generate — derive the volatile parts, the way `adapters.mjs` does** | Staleness becomes structurally impossible. Matches an existing pattern here, including `generated:protocol-files` in `contract.mjs` | **The seed is handed over on install** — "It is yours now, no upgrade will touch it" — so generation could only ever apply to this repository's copy, splitting the two files' natures. And the claims that went stale were sentences, not lists: generating them produces a manifest where prose belongs | The entrypoint stops reading like something a person wrote, and people stop reading it | A generator plus a staleness check |

**Recommended: assert.** Generation is the stronger mechanism and it is
unavailable here for a structural reason rather than a taste one: the one file it
could apply to is the one file that is not shipped, and the shipped one is
explicitly the consumer's to edit. Recording it as rejected matters because it is
the obvious idea and it will be proposed again.

Three assertion families, and the spec's requirement 8 is why the first exists at
all rather than a single hand-check on `aep:`:

**The retired-field scan (general).** `RETIRED_FIELDS` already lists all seven in
`contract.mjs`. For each, scan the payload, the seeds and the entrypoints,
outside fences, for the field named as frontmatter — the token with its colon,
`` `aep:` ``, which is what distinguishes the field from the English word.

The next field a release retires is caught by adding it to `RETIRED_FIELDS`,
which the release already has to do. No new assertion.

**Corrected 2026-08-26, during implementation.** The rule above was *a hit must
sit in a file whose subject is retirement*, allowlisting `skills/update.md`,
`skills/update/migration.md`, `scripts/contract.mjs`, `scripts/validate.mjs`, and
`specs.md`. Run against the corpus it would ship against, it reports the
corrected `AGENTS.md`: the sentence requirement 9 exists to protect says
`` `aep:` `` in order to say the field was retired, and the ticket forbids
allowlisting the file that failed. A file-scoped allowlist can excuse the defect
and its repair or neither, because both are the same token in the same position.
The evidence is
`[[efforts/48-artifact-paths/evidence/research/retired-field-scan-corpus]]`.

**The scope moves from the file to the sentence.** A retired field may be named
only in a sentence that also says it is gone — retired, removed, no longer, used
to, or belonging to 1.x or 2.x. The corrected `AGENTS.md` passes on its own
words, the sentence it replaced fails, and no entrypoint is exempt from anything.
A file allowlist survives beside it and shrinks to two: `skills/update.md` and
`skills/update/migration.md` each state the retirement in a **table**, where a
cell is not a sentence and the marker has nowhere to sit. `scripts/*` and
`specs.md` leave the list because they leave the corpus — a script's object keys
collide with field names, `scope.mjs` alone holding five `kind:`, and `specs.md`
is the specification rather than shipped text.

Rejected, with the human choosing on 2026-08-26: **scoping to the `##` section**
rather than the sentence, which needs no allowlist at all and is looser, since a
section carrying the word for an unrelated reason silently excuses every live
claim inside it; and **keeping the file allowlist with `AGENTS.md`'s sentence
pinned by a hand-written assertion**, which is the one-claim-one-assertion
pattern this repair exists to replace and breaks on any reword of a sentence
somebody is meant to be able to reword.

**A second discriminator, and it is not a fork.** `seed/references/github.md`
writes `` `aep:effort/x` `` to show a tracker label namespace nobody should
create. That is `aep:` outside fences and in backticks, and a colon alone does
not separate a field from a label prefix. The colon must be followed by a space
or the end of the token.

**The corpus is dirty and the scan lands red.** Ten sites in eight shipped files
describe the retired `owner:` field as current — five templates, `skills/install`,
`skills/prune`, `agents/reviewer-standards`, and the version-control seed. The plan's
premise that retirement is discussed in few places counted where it is
*discussed* and not where a retired field is *described*. The scan therefore
lands reporting all ten, deliberately red, and a sweep ticket clears them — the
shape repairs 1 and 2 already use, where the guard going green is what verifies
the sweep rather than anybody reading ten diffs.

**The path-existence net (general).** Every backticked token in an entrypoint
that looks like a repository path — contains a `/` or ends in a known extension —
must exist. Zero maintenance, and it catches the whole class of *the entrypoint
names a file that moved*.

**The named claims (specific).** `AGENTS.md` leaves `EXEMPT_DOCS` for claim
checking. Each remaining factual claim gets an assertion against the thing it
describes: the adapter sentence must not name a single runtime while `TARGETS`
holds more than one; `src/stamps.json` must exist and be what `release.mjs`
writes; each command shown must name a script that exists.

**`EXEMPT_DOCS` is not deleted.** It keeps its second job, exempting `AGENTS.md`
and `specs.md` from the four prohibitions in `[[policies/reporting]]`, which the
spec puts out of scope. The constant splits: `EXEMPT_FROM_PROSE_RULES` keeps both
files, and claim checking stops consulting it. Doing this as a rename rather than
a flag keeps the two exemptions from being confused again, which is how one file
ended up exempt from everything by inheriting an exemption written for prose.

## Repair 4 — the skill's declared output

`specs.md` already carries the answer in a form a script can read. Its skill
table has a column naming what each command produces:

```
| `plan` | HOW | `plan.md` | typed, when the approach is not obvious |
```

That is the authority, and it is the thing `skills/plan.md` disagrees with. The
check writes itself from the table rather than from a list somebody maintains
beside it.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A — drive the assertion from the specification's own skill table** | General by construction. A release that reassigns an output edits the table, and the table is what fails the skill. No second list to keep in step | Depends on the table's shape staying parseable, so a reformat of `specs.md` breaks the check rather than the claim | The table is reformatted and the check silently matches nothing — a parse that finds zero rows must fail loudly, not pass vacuously | The parser, and nothing else |
| **B — a hand-written assertion on `skills/plan.md`** | One line, lands today | Catches this file and no other. **It is the pattern this effort exists to end**: a claim checked because somebody happened to notice it | The next reassignment is caught by nobody, exactly as this one was | One assertion per skill, added on discovery |
| **C — skills declare their output in frontmatter, validated against the table** | Checkable in `validate.mjs` too, so it reaches consuming repositories rather than only this suite | AEP 3 removed six frontmatter fields on the argument that each one's answer already lives somewhere else. Adding one back needs that decision superseded on the record, not worked around | A field nothing reads at runtime, which is what the six removed ones were | A field on every skill, forever |

**Recommended: A.** C is the strongest mechanism and it is a bigger change than
this effort: reversing the frontmatter decision is its own argument, made
explicitly against the release that made it, not slipped in as a checking detail.
B is what the effort is against.

**The vacuous-pass guard matters more here than usual.** A table parser that
finds no rows returns an empty map, and asserting over an empty map passes. The
parse asserts a minimum row count first, so a reformat of `specs.md` fails as a
broken check rather than as a clean run.

The assertion itself: for each skill the table names, that skill's `## Output`
section names the artifact assigned to it, and names no other effort artifact.
`skills/plan.md` fails both halves today, since its Output section opens "The
same `spec.md`, gaining whichever of these apply".

**The correction is more than the Output section.** The skill's opening sentence
says it extends `spec.md`, its step 7 sends the approach there, and its Output
block reproduces the ten headings that `templates/plan.template.md` already
holds. That reproduction is the reason the drift survived:
`[[policies/artifacts]]` says a link is a relationship rather than a copy, and
that "the summary is a second home and it drifts first" — which is exactly what
happened, since the template moved to `plan.md` in AEP 3 and its copy inside the
skill did not. The corrected skill points at the template rather than restating
it, which removes the second home instead of updating it.

# Components

| Component | Becomes responsible for |
| --- | --- |
| `src/scripts/contract.mjs` | exporting `outsideFences(body)`, extracted from `wikiLinks`, which is the only fence-stripper today and is currently private to it. Both the path guard and the retired-field scan need it, and three copies of one regex is how they drift |
| `src/scripts/validate.mjs` | `checkStrays(root)`, called from `main` beside `checkStructure`. Owns the repository-root scan and the shape gate |
| `src/scripts/verify.mjs` | the path-convention guard, the retired-field scan, the entrypoint path net, the named entrypoint claims, the `EXEMPT_DOCS` split, and the skill-output check with its vacuous-pass guard |
| `src/skills/plan.md` | naming `plan.md` as its output, sending step 7 there, and pointing at the template rather than reproducing its headings |
| `src/protocol.md` | one sentence stating the path convention beside the link convention, pointing at the policy for the reason |
| `src/policies/artifacts.md` | the convention and **why this form** rather than a sigil or prose, under "Where it goes" |
| 23 payload files | the prefix, at 37 sites |
| `specs.md` | the convention as a normative statement, and the stray check as a conformance requirement on a validator |

# Interfaces

```
// contract.mjs — new export, extracted not invented
export function outsideFences(body)   // body with ```-fenced blocks removed

// validate.mjs — new, internal
function checkStrays(root)            // root is the .aep/ directory; scans path.dirname(root)
```

`checkStrays` reports through the existing `fail(where, message)`, so a stray
lands in the same failure list, the same exit code, and the same output shape as
every other finding. Nothing about the command's contract changes except that a
previously-passing tree can now fail — which is requirement 3.

**`where` for a stray is the path as found, relative to the repository root**,
not to `.aep/`. Every other `where` in this file is tree-relative, and a stray's
whole problem is that it is not in the tree; printing `efforts/47-x/` for a
directory at the repository root would name the correct location while reporting
the incorrect one.

# Technical Approach

The three repairs are independent and land in this order, which is by blast
radius rather than by dependency:

1. **`outsideFences` extracted.** Pure refactor, no behaviour change, and both
   later repairs import it. Landing it alone keeps the extraction reviewable as
   an extraction.
2. **The stray check.** Self-contained in `validate.mjs`, with the two fixtures
   criteria 3 and 4 name. Nothing else depends on it.
3. **The convention.** The policy text and the `protocol.md` sentence first, then
   the guard, then the 37-site sweep. **The guard lands before the sweep**, so
   the sweep is verified by the guard going green rather than by reading, and the
   guard is verified by the sweep being red before it runs.
4. **The skill-output check.** Independent of the other three, and it can land
   at any point. Placed here because its correction to `skills/plan.md` touches a
   file the convention sweep also touches, and doing the sweep first means the
   output correction is written against text that is already in its final form.
5. **The entrypoint assertions.** Last, because criteria 9 and 10 revert
   corrections to watch them fail, and doing that while other repairs are
   mid-flight makes a red suite ambiguous about which guard fired.

`specs.md` moves in the same pass as whichever repair changes a normative claim,
never in a sweep at the end — the repository's own invariant is that the
specification and the implementation change together.

## How the work is arranged

Each ticket is a branch carrying one commit, cut from the branch of the
ticket its `blocked-by` names, so `blocked-by` means *branch on top of*
(`[[rules/version-control]]`). Where a ticket names nothing it is cut from the
effort branch and can be built beside the others.

**A ticket branch is a build claim rather than a level of the stack.** It is
named `48-artifact-paths/<id>-<slug>`, it is built in its own worktree under
`.aep/worktrees/`, and it is not tracked in Graphite: it exists so git refuses a
second run the same ticket, and it holds nothing once the orchestrator has
integrated its work into the effort branch, which is the step that deletes it.
The reviewable unit is `artifact-paths` itself, one commit amended in place, and
it is the only branch here carrying a pull request.

**This effort is its own stack, based on `main`.** Effort 47 sat on top of it
until 2026-08-25 and no longer does, so the two build at the same time and
neither restacks when the other moves. What they still share is `verify.mjs`,
`payload.mjs`, `specs.md`, and `.aep/index.md`; whichever merges second restacks
on `main` and resolves there, and `index.md` is regenerated rather than merged
by hand. This one ships 3.4.0 and merges first, which is what
`[[efforts/48-artifact-paths/tickets/09-release]]` pins. Both numbers moved up a
minor on 2026-08-26, when effort 56 shipped 3.3.0 from `main` while the two
siblings were still building and took the number this effort had pinned.

# Testing Strategy

Every criterion maps to a named check. `[[rules/authoring]]` requires each guard
to be seen failing with the right name before it is trusted, and the recurring
trap it names — a guard that matches something travelling *with* the subject
rather than the subject — applies twice here, marked below.

| Criterion | Check | Fire-check |
| --- | --- | --- |
| 1 | `verify.mjs`: no multi-segment tree path outside fences lacks the prefix, across the payload | the sweep's own red-to-green transition |
| 2 | `verify.mjs`: `protocol.md` states the path convention | delete the sentence, watch it fail by name |
| 3 | `validate.mjs` against a fixture: valid `.aep/` tree plus a valid effort at the repository root | **run it against the same fixture with the stray removed and confirm it passes.** A stray check that fires on the valid tree too would look identical from the failing run alone |
| 4 | `validate.mjs` against a fixture whose root holds `templates/` of ordinary files | must report nothing; this is the false-positive case and it is the one that decides whether the check ships |
| 5 | add a bare `efforts/<effort>/x.md` to a shipped surface | fails; remove it, passes |
| 6 | `verify.mjs`: `policies/artifacts.md` carries the convention and a reason | remove the reason paragraph, watch it fail |
| 7 | `AGENTS.md` absent from claim-check exemption, and asserted beyond the `.aep/protocol.md` substring | count the assertions naming the file; the old state had one |
| 8 | restore the `aep:` paragraph → fails. **Then a fixture with a second retired field**, so the assertion is not shaped around one string | **the fixture is the fire-check that matters.** Passing on `aep:` alone is indistinguishable from a check written around `aep:`. The scan also has to *pass* the corrected `AGENTS.md`, which names `aep:` in order to say it is retired, so the retirement sentence is a second fixture in the other direction |
| 8 | the ten live `owner:` sites move, and the scan the ticket before it left red goes green | the red-to-green transition, as in criterion 1. Watching one guard flip is the verification; reading ten diffs is not |
| 9 | `git revert` each hand-correction from `59133ea` in a scratch checkout, run the suite | both must fail. This is the only evidence the assertions cover what actually occurred |
| 10 | `verify.mjs`: each skill in the specification's skill table names its assigned artifact in `## Output` and no other effort artifact | restore "The same `spec.md`, gaining" to `skills/plan.md`, watch it fail naming the skill and both artifacts. **Separately, assert the parsed table is non-empty**, since a parser matching nothing passes every row it does not have |

Criteria 3, 8, and 10 are called out because all three are cases where a green run
and a broken guard look the same from the outside: a stray check that fires on
everything, an assertion shaped around one known string, and a table parse that
finds no rows.

# Operational Considerations

**A consuming repository can start failing on upgrade.** Repair 2 means a tree
that validated yesterday fails today if it has a stray. That is the intent, and
it needs the release notice `[[skills/update]]` gives a behaviour change: what
the new failure means, and that the fix is to move the directory, which AEP will
not do (spec constraint).

**Nothing auto-migrates.** A repository with a stray gets a report on the next
validate and a human decides.

**The `protocol.md` budget has 149 bytes of headroom and repair 1 spends about
95 of them.** That is worth stating in the ticket, because the next addition to
the bootstrap meets a much tighter ceiling than the one this effort found.

# Technical Risks

- **The path guard fires on a legitimate bare path this survey missed.** The
  survey covered `src/skills`, `src/policies`, `src/templates`, `src/agents`,
  `src/protocol.md`, and `src/seed`. It did not cover the committed adapters
  under `src/adapters/`, which are generated from the payload and should inherit
  the fix — but the guard must be run over them before the sweep is called
  complete, not after.
- **The five-file retirement allowlist becomes a hiding place.** An allowlisted
  file can still make a false live claim about a retired field, and the guard
  will not see it. Bounded by the allowlist being small and each entry carrying
  its reason; not eliminated. The alternative, no allowlist, fails on
  `migration.md`, which exists to discuss exactly these fields.
- **The shape gate is tight enough to miss a real stray.** An effort written
  outside the tree with a malformed `spec.md` — no frontmatter, or a `status:`
  outside `SPEC_STATUSES` — is not recognised and not reported. Deliberate: the
  false positive is the expensive failure here, and a malformed spec inside the
  tree already fails for its own reasons.
- **`outsideFences` changes `wikiLinks` behaviour by accident.** It is an
  extraction of live code and the link checker runs over the whole corpus, so a
  regression shows up immediately and loudly. Landing it as its own step is what
  keeps that signal clean.
- **The skill-output check binds the suite to a table's formatting.** Repair 4
  reads a Markdown table out of `specs.md`, so a reformat that a person would
  call cosmetic breaks the parse. The non-empty assertion converts that from a
  silent pass into a named failure, which is the difference between a check that
  is brittle and one that is dishonest. Accepting brittleness here is deliberate:
  the alternative, a list of outputs maintained beside the specification, is a
  second home for the same fact and would drift the way the skill did.
- **The corrected `skills/plan.md` is the file the runner reads next.** Every
  `/plan` invocation between now and this effort landing reads the stale text and
  is settled by `specs.md` instead, as this one was. That is a working
  arrangement rather than a safe one, and it is the argument for repair 4 landing
  rather than waiting on the other three.
