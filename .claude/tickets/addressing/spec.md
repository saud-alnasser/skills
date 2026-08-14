---
owner: repository
status: accepted
sources:
  - specs.md
  - skills/
  - agents/
  - .claude/decisions/0083-aep-2-takes-the-plugin-dependency-and-the-readability-promise-ends.md
  - .claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md
  - .claude/decisions/0105-the-router-table-keeps-a-per-stage-column-and-the-build-holds-it-to-the-store.md
  - .claude/tickets/conversion/issues/12-a-shipped-template-stops-naming-a-departed-directory.md
---

# fix(skills): shipped text names a record by subject, because location stopped being how one is reached

## Problem

Every shipped surface still addresses the corpus by file path. `skills/implement/SKILL.md`
sends a reader to `.claude/policies/tickets.md` eleven times and to `.claude/tools/` ten
more; `skills/design/SKILL.md` nine; all five agent definitions open by instructing the
child to read a file. Across `skills/`, `agents/`, and the configure templates, 28 files
carry 248 such references — and after conversion not one of those paths exists.

The specification already says why: the store tier arrives delivered or pulled, and nothing
in it "is loaded by opening a file the model chose". A path in shipped prose is therefore
not merely stale, it instructs the one behaviour the delivery mechanism was built to remove.

The build did not catch it because the guard that exists checks a narrower thing — where an
instruction says a run *writes*, not where prose sends a reader to *read*.

## Goal

No shipped file addresses a store record by location, and the build refuses one that does.
A reader of any shipped file can still tell which record governs a passage, and a child
still reaches its contract — by asking the store rather than by opening a path.

## Constraints

- **`.claude/rules/` is not departed and its references stay.** The boot tier remains files
  because the harness is the only channel that reaches a clone without the plugin.
- **Frontmatter does not move.** Every skill already declares bare subjects in
  `metadata.policies` and every agent a bare posture in `metadata.mode`. This is prose.
- **The pages whose subject is the conversion keep their paths** — `MIGRATION.md`,
  `migration-changelog.md`, and `SKILL.md` under `configure/` describe a tree with those
  directories in it, and a guard that cannot tell description from instruction would force
  them to stop describing what they convert.
- **The suite never reads this repository's `.claude/`.** This repository stays on 1.x and
  is converted last; a guard coupling shipped text to what this repository runs on inverts
  that order.

## Architecture

Three kinds of reference, distinguished by what the record's type does at delivery, because
that is what decides whether a pointer still has a job:

| Kind | Where it appears | What it becomes |
| --- | --- | --- |
| a delivered norm named as a file | most of the 248 | the path goes, the subject stays — the norm is already inlined ahead of the skill's own content |
| a `reference` named as a file | tool guides, throughout | the path goes, the pointer stays — a `reference` carries no firing condition, is never delivered, and is pulled by query at the operation |
| an instruction to open a file | the five agent definitions | the child queries the store for its contract; this is the only kind whose behaviour changes |

Naming the subject rather than dropping the pointer keeps §11's "a skill NEVER restates what
a policy owns; it points" true, and keeps a prose counterpart to the containment check that
already binds a skill's declared guides to its router row.

### Addressing a record

Naming by subject needs a subject to name, and the store has none. Its declared fields are
`type`, `owner`, `fires-when`, `stages`, `postures`, `paths`, and the derived ones the build
mints; nothing carries what a record is *about*. The only filter that isolates one record is
`file`, and the format says in as many words that a filename is not an address — *"it names
a norm rather than a filename, so files keep readable names and a rename costs nothing."*

So **every record declares `subject`**, and the query filters on it like any other field.
This is not a new concept: every skill already declares its dependencies as bare subjects,
the router's column names them, and the build reconstructs them by stripping a stage suffix
off a filename. Three places recover by parsing what one field can state.

Rejected: **citing the record's ids in the brief.** It adds no field and uses the
cross-store-citation case the query was built for, but a definition read on its own still
could not say how a child obtains its contract — which is the thing that has to be written
down.

**Filenames stay as they are, and the asymmetry is written down rather than removed.** A
repository's record keeps whatever readable name it would have had; a framework stage norm
encodes the stages it serves, because the split that produced those files needs the name
checkable against the field. Both are already true and only one was stated.

## Approach

The rule and the specification amendment land first, so every later ticket is applying one
statement rather than each inventing its own. Then one ticket per surface, because a surface
is what a reviewer can hold at once and the surfaces share no text. The guard lands last,
blocked by all of them: a guard that lands earlier fails against the sites not yet corrected,
and the only ways out of that are weakening it or holding the tree red.

Rejected: **correcting the paths to `.claude/knowledge/`.** It is the cheapest edit and it
preserves the defect — the specification's objection is to addressing a record by location,
not to which location. Rejected: **dropping the pointers entirely.** It removes about 150
sites rather than rewording them, but leaves a reader of a skill outside a running stage
with nothing in the text saying which record governs.

## Acceptance criteria

- No shipped file addresses a store record by location, and reintroducing one fails the
  build naming the file and the line.
- The guard's subject is the departed concept rather than one spelling of a path, so a file
  naming the departed set in prose is caught as surely as one naming a path.
- The guard's exemptions are enumerated by filename with the reason each is exempt, and an
  exemption with no stated reason fails the build.
- Every passage that lost a path still names the record that governs it, by subject.
- A dispatched child obtains its contract by querying the store, and the definition says so
  rather than naming a file to open.
- `specs.md` no longer resolves a skill's declarations against directories the release
  deletes.
- Every record declares a `subject`, a record declaring none fails the build naming the file,
  and a query filtering on `subject` returns that record and no other.
- No shipped script recovers a subject by parsing a filename.
- The record format states both filename conventions and which store each belongs to.
- Entering a stage still resolves that stage's posture from the router table, unchanged.

## Risks

- **A guard broad enough to catch prose is broad enough to catch the pages that describe the
  conversion.** Detected by the exemption list being enumerated with reasons rather than
  granted as a directory-wide skip — an unexplained exemption is itself a build failure.
- **248 rewordings is 248 chances to change a norm's meaning while changing its address.**
  Detected by review on the Spec axis, which reads the diff against what the ticket asked
  for rather than against whether the prose reads well.
- **The subject a passage names may not match the record's actual subject.** Detected by the
  existing containment check between a skill's declared guides and its router row, which the
  reworded prose now has to agree with.

## Out of scope

- This repository's own `.claude/`, which stays on 1.x until it is converted.
- Records are not added, split, or renamed here. Every record gains a `subject`, for the
  reason under **Addressing a record** above, and nothing else about the corpus moves.
- The release stamps on framework templates, which stay `conversion/13`'s.
