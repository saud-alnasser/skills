---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture

**This is four rewirings and two new files, not a rebuild.** Almost every
mechanism AEP 3 needs already exists and is consulted by the wrong thing.

1. **Ownership stops being declared and starts being looked up.** `payload.mjs`
   already declares `PAYLOAD_DIRS` and `REPOSITORY_DIRS`; `install.mjs` simply
   does not consult them, reading `fields.owner` instead in `repositoryOwned()`
   and in `copyDir()`'s retirement check. Those two functions change what they
   ask. The table moves to `contract.mjs`, which already ships to installed
   trees, and gains a generated exact-path manifest beside it. `protocol.md`
   states the directory rule for a human.

2. **`/implement` becomes a loop whose body is today's `/implement`.** The
   existing skill already dispatches a wave, reconciles, reviews, and commits.
   What is added is the loop around it, a computed frontier, and a converge stage
   at loop exit.

3. **The pull request becomes the run's memory.** Per-ticket criteria checkboxes
   and a collapsed run log, written as the run proceeds, which is what makes
   compaction harmless and resumption real.

4. **Frontmatter shrinks to `use-when`**, and `use-when` gains four mechanical
   checks in `validate.mjs`, because the cut concentrates discovery in the one
   field nothing verified.

## Alternatives that lost

| Rejected | Why |
| --- | --- |
| **A chain of efforts** rather than one | every part changes the same artifacts, so a chain migrates each file four times and each stage plans against a tree the next one moves |
| **Directory table alone** for ownership | cannot distinguish a repository file inside `skills/` from a shipped one, which is the failure `owner:` was catching |
| **Exact manifest alone** | a reader opening `protocol.md` learns nothing, which forfeits the token saving the change exists for |
| **Run log in a pinned comment** | keeps the body reviewable, but resumption then reads two objects and a comment can be deleted by anyone with write access |
| **The runner reading tickets itself** | puts the whole graph in the orchestrator's context every wave, and makes scheduling a judgement where `[[policies/execution]]` requires a computation |
| **A one-shot migrate script** | `update` has to detect the 2.x layout and route to it anyway, so the branch exists either way and this adds an entry point a human must know |
| **Rewriting `verify.mjs`** | fifteen of its twenty-one sections are untouched by this change |
| **A per-wave sub-orchestrator** | would need `[[policies/execution]]`'s one-layer rule relaxed, which it defends by name, and the durable-state answer makes a fresh window per wave unnecessary |

# Components

| File | Change |
| --- | --- |
| `protocol.md` | primitives twelve to seven; ownership table; workflow line seven commands to four; `version:` replaces `aep:` |
| `policies/execution.md` | tracker section becomes one issue per effort; the runner's loop duties; child return cap; three trip-wires; the spec-versus-ticket stop retained verbatim |
| `policies/reporting.md` | seven slots to four plus the ledger; the two-reader narrowing; the `report:` contract deleted |
| `policies/artifacts.md` | the frontmatter contract |
| `modes/` | eight files deleted; each Mindset and What this gives up folds into its skill |
| `skills/implement.md` | the loop, the computed frontier, wave-based integration, converge at exit, landing |
| `skills/implement/dispatch.md` | the child return cap |
| `skills/specify.md` | absorbs refine and research; performs the opening step |
| `skills/plan.md` | absorbs refine; writes `plan.md` |
| `skills/tasks.md` | traceability check; the labels ladder is gone |
| `skills/tasks/labels.md` | deleted |
| `skills/commit.md` | deleted; its conflict note moves to `implement/conflicts.md` |
| `skills/refine.md`, `research.md`, `review.md` | survive as files, unregistered as commands |
| `skills/install.md`, `update.md`, `update/migration.md` | entrypoints, label seed, the layout branch, tracker reshape |
| `agents/reviewer-correctness.md` | ticks the criteria it already checks |
| `templates/` | `spec.template` splits; `plan.template` is new; `ticket.template` loses `part-of` |
| `scripts/contract.mjs` | ownership table and generated manifest in; `KINDS`, `MODES`, `REPORT_FORMS`, `MODELESS_SKILLS`, `DIRECTORY_OWNERS` out |
| `scripts/frontier.mjs` | **new**, shipped |
| `scripts/validate.mjs` | frontmatter checks rewritten; four `use-when` checks; stray-file check |
| `scripts/index.mjs` | Modes column and the `date` computation removed |
| `scripts/install.mjs` | both classifiers rewired; entrypoint pointers; label seed |
| `scripts/payload.mjs` | `modes` leaves `PAYLOAD_DIRS`; `frontier.mjs` joins `PAYLOAD_SCRIPTS`; `MOVES` and `NOTICES` gain the 3 entries |
| `scripts/release.mjs` | the stamping pass deleted; one write to `protocol.md` |
| `scripts/adapters.mjs` | `TARGETS` gains `entrypoint`; the registered skill list shrinks |
| `scripts/verify.mjs` | six sections of twenty-one |
| `seed/labels.json` | **new**, the seeded label set |
| the specification | primitives, frontmatter, modes, skills, workflow, adapters, install, upgrade |

# Interfaces

**`scripts/frontier.mjs`**, shipped, run by the orchestrator, which quotes its
output rather than holding the graph:

```
node .aep/scripts/frontier.mjs <effort>

  ready     <id> <slug>            unblocked, unclaimed, open
  blocked   <id> <slug> by <ids>   waiting, and on what
  parked    <id> <slug> <reason>   review cap reached, or contradicts the spec

exit 0  work remains
exit 1  nothing unresolved
exit 2  the effort or its tickets are unreadable
```

**`contract.mjs`** gains `PROTOCOL_DIRS`, `REPOSITORY_DIRS`, and a generated
`PROTOCOL_FILES` of exact shipped paths. `install.mjs` and `validate.mjs` consult
it, and nothing reads a frontmatter field for ownership again.

**The pull request body**, which is the run's durable state:

```
## Approach          from plan.md
## Tickets           one section each, criteria as checkboxes, ticked on verify
<details> Run log    ledger, recorded items, converge round, review attempts
Closes #<issue>
```

**The turn report**: `Position` and `Assuming`, the ledger, `State` and `Next`.
One line per slot.

# Technical Approach

Order within the effort, chosen so each step lands against a tree the next one
does not move:

1. **`contract.mjs` first.** Ownership table and generated manifest, replacing
   `DIRECTORY_OWNERS`. Nothing else can be rewired until the thing they consult
   exists. The other four enums move with the checks that consume them, in step
   2, because removing an export and its only consumers is one atomic change.
2. **The classifiers.** `install.mjs`'s two functions, `validate.mjs`'s
   frontmatter and stray-file checks, `release.mjs`'s stamping pass.
3. **The installer stops reading what step 4 removes.** Corrected during
   implementation, after `install.mjs` was found reading three fields the strip
   deletes: `applyMoves` and `rewriteMovedLinks` read `owner:`, and the move and
   notice gating reads the bootstrap's `aep:`. All three failed silently, and the
   suite could not catch them because its own fixtures still carried the fields.
   Ownership of a move source is now decided by content, so `MOVES` carries the
   hash of the text it replaced.

4. **The artifacts.** Frontmatter stripped across the payload, `modes/` deleted
   into its skills, `commit.md` and `tasks/labels.md` deleted, templates split.
   One mechanical pass, because step 2 built the tree that validates it.
5. **The bootstrap and the specification**, which describe what steps 1 to 3
   built rather than what was intended.
6. **`frontier.mjs`, then the runner.** The loop, converge, integration, the run
   log, landing.
7. **`update`.** Entrypoints, labels, the layout branch,
   tracker reshape. Last, because it migrates into a target the earlier steps
   define.

`verify.mjs` moves in the same pass as whatever it asserts
(`[[rules/authoring]]`), never at the end.

# Integration

This repository is its own consumer, so `src/` changes and the installed tree is
rebuilt from it. The 2.x tree here is migrated by the same `update` path every
other repository takes, which is how the migration gets exercised before it
reaches anything else.

`MOVES` and `NOTICES` in `payload.mjs` are the existing mechanism for a release
that relocates files and has to tell a human why. The deletions in step 3 are
declared there rather than invented.

# Migration

`update` recognises the layout by content, as it already does for 1.x:

| Tree carries | Classified by |
| --- | --- |
| `owner:` on its artifacts | the field, as today |
| no `owner:` | the manifest in `contract.mjs` |

The 2.x branch reads `owner:` off the tree it is replacing, writes the 3 layout
without it, and splits any `spec.md` carrying `# Architecture` into `spec.md` and
`plan.md`. Tracker reshaping covers efforts in flight only, proposed as one set
with exact strings.

The branch lives as long as 2.x repositories do, and its removal condition is
stated: when no repository the maintainer knows of still declares a 2.x layout.

# Testing Strategy

Every acceptance criterion lands in a `verify.mjs` section. Six of twenty-one
move; fifteen are untouched.

| Section | Covers |
| --- | --- |
| `manifest` | the ownership table and the generated manifest agree with the payload; criteria 40, 42 |
| `stamps` | hashes unchanged by the field removal; criterion 39 |
| `frontmatter` | `use-when` only, the four checks, no removed field survives; criteria 38, 43, 44 |
| `modes` | **deleted**; criterion 29 |
| `skills` | four registered commands, the utilities and sub-skills present; criteria 29, 30, 31 |
| `reporting` | four slots, the ledger, `Next` naming what would clear a stop; criteria 26, 27 |
| `install fixture` | entrypoint pointers, the label seed, a stray file in a protocol directory failing by name, the migration; criteria 11, 32, 33, 34, 35, 36, 37, 41 |
| `the guard fires` | each new guard is broken deliberately and watched to fail with the right name (`[[rules/authoring]]`) |
| `manifest`, closing | criterion 45, the suite asserts every claim above |

Runtime behaviour no static suite reaches is checked by running one real effort
end to end in this repository and asserting the artifacts it leaves:

| Behaviour | Criteria |
| --- | --- |
| the effort shape, the opening step, labels | 1 to 10 |
| the loop, scheduling, integration, commits | 12 to 15 |
| converge and its cap | 16 to 19 |
| trip-wires, the review cap, criteria ticking | 20, 21 |
| the run log, resumption, compaction | 22 to 25 |
| converge correcting a falsified context | 28 |

# Operational Considerations

The runner pushes and opens a pull request at requirement 6, which is the first
irreversible act AEP performs. `[[rules/version-control]]` here currently forbids
it outright, and must state the permission before the runner can run in this
repository at all. That edit belongs to step 6 rather than to an afterthought.

# Technical Risks

- **A guard can be dead and green, and only breaking it deliberately says so.**
  Two written during this effort could never have fired: one used `` inside a
  template literal, where it is the backspace character rather than a word
  boundary, and one keyed on a word the installer does not print. Both passed
  every run. `[[rules/authoring]]` already requires breaking a new guard and
  watching it fail with the right name, and this is the second and third instance
  of what that rule exists for.

- **Step 4 is a mechanical pass over every shipped artifact**, and a mechanical
  pass is where a hand-edit gets reverted silently. Mitigated by step 2 landing
  first, so the tree that validates the result exists before the result does.

- **`verify.mjs` is 2297 lines and six sections move.** A section rewritten to
  match the new shape can pass while asserting nothing, which is why
  `[[rules/authoring]]`'s break-it-deliberately rule is named in the testing
  strategy rather than assumed.

- **The 2.x branch in `update` has no test repository but this one.** Once this
  repository is migrated, the only 2.x tree left to exercise it is a fixture
  somebody has to build and keep accurate.

- **`frontier.mjs` is new shipped code in a distribution that has no unit tests.**
  It is asserted through `verify.mjs` like everything else, which checks its
  output shape rather than its scheduling behaviour on a real graph.
