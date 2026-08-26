---
use-when: "the repository carries a 1.x layout — a protocol file, policies, decisions, designs, or a map.md in every directory, under the runtime's own directory rather than .aep/"
---

# Update — migrating a 1.x repository

1.x kept AEP inside the runtime's own directory and selected knowledge by
**stage**. 2.0 keeps it in `.aep/` and selects by **applicability**. No 1.x file
upgrades in place: the directories differ, the governance layer differs, and the
fields that decide what loads did not exist.

So this is a **conversion**. 2.0 installs fresh, and everything 2.0 has a
representation for is rewritten into that shape.

## Recognise it by content

Any of these means 1.x, whatever the directory is called: a `protocol.md` outside
`.aep/`; a `policies/`, `decisions/`, or `designs/` directory **outside `.aep/`**;
a `map.md` sitting in several directories; frontmatter declaring `owner:
framework`.

**A bare `version:` is not evidence of anything.** 1.x used it, and so does 3 —
on `protocol.md`, the one artifact that declares a release. A classifier reading
it would send a current tree here, and this skill installs a fresh layer beside
the one already running.

**`.aep/policies/` means the opposite.** AEP ships policies of its own, and they
are protocol law — a current tree, not a 1.x one. The two uses of the word are
inverted, which the conversion below depends on.

**Confirm with the human before starting.** This rewrites where their knowledge
lives.

## The three outcomes

Every 1.x file gets exactly one, and the question is **what does this file hold**
— never who owned it.

- **Converted** — 2.0 has a representation. Rewrite it into that shape.
- **Superseded** — the file *is* framework text and this release ships what
  replaces it. Drop it; the installed copy is newer than anything a conversion
  could produce.
- **Unrepresented** — 2.0 retired the concept. Report it, leave it, delete
  nothing.

**`owner: framework` does not mean superseded.** 1.x put repository content
inside framework-owned files at named extension points: a **declared deviation**
in the protocol file, the two policies derived per repository, the entrypoint
describing the repository itself. The file was framework text; **the content
inside it never was**, it has a 2.0 home, and dropping it because of the owner
field is the largest way this operation can silently lose knowledge.

## 0 — Inventory first, move nothing

Write the inventory down before touching anything: every file, its outcome, and
its target. Read framework-owned files too — you are looking for the extension
points above, not skipping them.

**A file that fits no outcome is a finding, not a default.** List it and ask.

## 1 — Install 2.0

```
node <distribution>/scripts/install.mjs --into <repository> --migrate
```

`--migrate` is required and is the point: without it the installer **refuses** a
repository running 1.x, because a fresh install beside a live 1.x tree orphans
everything in it and still reports success. Passing the flag is the statement
that the conversion below is actually happening.

Fresh, into `.aep/`. Seeds install as usual — the version-control rule, the
repository context, the entrypoint, and any tool references detected. **The
seeds are drafts, and 1.x already knew better**: step 2 overwrites them with what
the repository actually documented.

## 2 — Convert

Which directory 1.x lived in is the one thing about a 1.x tree that varied, so
where a row names a path, the column names a placeholder rather than a directory: `<runtime>` is whichever
one the runtime owns — `.claude`, `.cursor`, `.codex`.

| 1.x | 2.0 | Outcome |
| --- | --- | --- |
| `<runtime>/contexts/repository.md` | `.aep/contexts/repository.md` | converted — replaces the seeded draft |
| `<runtime>/contexts/<domain>.md` | `.aep/contexts/<domain>.md` | converted |
| the entrypoint's repository-describing prose | `.aep/contexts/repository.md` | **converted** — 2.0's entrypoint only points, so this content moves rather than dying with the file |
| the entrypoint file itself | a pointer at `.aep/protocol.md` | **converted, and not optional** — the runtime auto-loads it, so a 1.x entrypoint left in place keeps describing 1.x on every turn. Install writes `AGENTS.md`; a runtime's own entrypoint is rewritten to point, never deleted |
| `<runtime>/tools/<tool>.md` | `.aep/references/<tool>.md` | converted — wins over any seed for the same tool |
| `<runtime>/policies/version-control.md`, `<runtime>/policies/tracker.md` | `.aep/rules/version-control.md`, a rule or `references/` | converted — these two were derived per repository |
| other `<runtime>/policies/<concern>.md` | a **rule**, or nothing | see below — never a policy |
| `<runtime>/rules/<name>.md`, repository-authored | `.aep/rules/<name>.md` | converted |
| `<runtime>/rules/<name>.md`, framework | — | superseded by the shipped `policies/` and the bootstrap's invariants |
| `<runtime>/protocol.md` § Deviations entries | a repository rule per deviation | **converted** — each keeps its reason and the release it was declared under |
| `<runtime>/protocol.md`, the rest | `.aep/protocol.md`, installed | superseded |
| `<runtime>/decisions/NNNN-*.md` | a rule, or left in place | see below |
| `<runtime>/designs/<slug>.md` | `.aep/efforts/<slug>/spec.md` | converted |
| `<runtime>/tickets/<effort>/spec.md` | `.aep/efforts/<effort>/spec.md` | converted — collides with the row above where both exist |
| `<runtime>/tickets/<effort>/issues/NN-*.md` | `.aep/efforts/<effort>/tickets/NN-*.md` | converted, fields and all |
| `<runtime>/evidence/research/*.md` | `.aep/efforts/<effort>/evidence/research/*.md` | converted once an effort is known |
| `<runtime>/evidence/prototypes/*.md` | `.aep/efforts/<effort>/evidence/prototypes/*.md` | converted once an effort is known |
| `<runtime>/evidence/out-of-scope/*.md` | a `[[contexts]]` entry | converted — `[[skills/specify/out-of-scope]]` has the shape |
| `<runtime>/evidence/discussions/*.md` | the spec it concluded into | converted where it concluded something; a conclusion nobody applied is a finding |
| `<runtime>/evidence/drift/*.md` | — | unrepresented. Drift is read live now |
| `<runtime>/*/map.md` | `.aep/index.md` | superseded — every index is derived |
| `<runtime>/modes/*.md` | — | superseded by 2.0's eight |
| `<runtime>/scripts/*` serving AEP | `.aep/scripts/` | superseded |
| `<runtime>/scripts/*` serving the repository | wherever the repository keeps its own | **moved, never claimed** — it was never AEP's |
| `<runtime>/settings.json` | runtime configuration | unrepresented here; it stays the runtime's |
| `position/`, `worktrees/` | recreated, gitignored | superseded. Per-clone; nothing carries |

### Policies

**A 1.x policy becomes a rule, never a policy.** The word survived into AEP and
means the opposite of what it meant here:

| | 1.x policy | the policy AEP ships |
| --- | --- | --- |
| whose | this repository's, derived per repository | AEP's, identical everywhere |
| may the repository edit it | yes — that was the point | **never** |

So everything in a 1.x `policies/` is the repository's knowledge, and the
destination for repository knowledge is `rules/` in the new tree. **Converting
one into a shipped policy would hand the repository's own decisions to the
protocol, and the next upgrade would overwrite them.** That is the single worst
outcome available in this operation, and the matching name is what makes it
reachable.

Each policy resolves three ways:

- **conditional** — it applies on a trigger → a `rules/` file, `use-when` naming
  that trigger.
- **already stated** — a shipped `[[policies]]` or `protocol.md` already says it
  → superseded. Keeping it is a second home for one norm, and the shipped copy is
  the one that stays current.
- **repository-specific** — version control, review conventions, release process
  → a rule this repository owns.

### Decisions

2.0 has no decisions database. Each record is one of three things:

- **still governing** → converted to a rule, in the present tense, stating the
  norm rather than the deliberation.
- **already reflected** in the code and the rules → history.
- **history** — why something was chosen once, and nothing depends on reading it.

The last two **stay where they are, outside `.aep/`.** They are the repository's
own documentation, and deleting an append-only record is not this operation's
call. Report every one with the kind it was judged to be.

### Evidence, and the effort it belongs to

1.x filed evidence globally; 2.0 files it under the effort that produced it, so
each file needs an effort and the attribution is only sometimes derivable.

Where the file names its effort, or its content plainly belongs to one design,
convert it. **Where it does not, stop on it** — list the unattributable files and
let the human place them. Do not invent an effort to hold them: an effort with no
spec fails validation, which is the correct outcome and a confusing one to debug.

## 3 — Convert the fields

**Derive everything derivable. Propose exactly one thing.**

| 2.0 field | Where it comes from |
| --- | --- |
| `aep:` | the release being installed — read it from the `aep:` of the `protocol.md` this migration just wrote, never from memory — replacing 1.x's `version:` |
| `owner:` | `repository` on everything converted — a converted file is the repository's by construction |
| `date:` | the file's own last real change: `git log -1 --format=%ad --date=short -- <path>`. **Never today's date**, which would claim every carried artifact was reviewed during the migration |
| `kind:` | where it lands |
| `mode:` | the stage map below, as a top-level array — 1.x nested it under `metadata:` |
| `paths:` | carried unchanged |
| `status:` | the state map below |
| `part-of:`, `blocked-by:` | carried unchanged from a 1.x ticket |
| `use-when:` | **proposed from the content and marked unconfirmed** |

**Stages → modes.** `design` → `plan`, `discussion` → `refine`, `implementation`
→ `implement`, `prototype` → `prototype`, `research` → `research`, `review` →
`review`. `maintenance` has no 2.0 equivalent — its work is `implement`. 2.0's
`specify` and `test` are new and nothing maps onto them.

**Ticket states.** `open` → `open`. `resolved` → `resolved`. `obsolete` →
`obsolete`, keeping its one-line reason. Two need real conversion:

- `blocked` → **`open`**. 2.0 has no blocked state because the edge already says
  it: the ticket is open with a non-empty `blocked-by`. Where the 1.x body
  carried a `## Blocked` reason and no edge names it, that is a missing edge —
  add it, or report it.
- `superseded` → **`obsolete`**, its reason naming what replaced it, converted
  from `superseded-by`. The forwarding pointer is the whole content of that
  state, and losing it loses the trail.

**Ticket body.** 1.x's `title:` becomes the `#` heading; `## Problem` and
`## Outcome` fold into `## Outcome`; `## Acceptance` becomes
`## Acceptance Criteria`. `[[templates/ticket.template]]` is the target shape.

**A spec keeps its own statuses** — `draft`, `accepted`, `implemented` — read
from where the 1.x design had got to.

## 4 — Stop the old layer governing

Whatever the runtime auto-loaded in 1.x **must not still be auto-loading 1.x
governance.** A repository running both layers is governed by two documents that
disagree, and it has no way to notice — every turn is governed by whichever the
runtime happened to load first.

So the old auto-loaded governance is **moved, not left**: converted per the
table, or moved out of the auto-loaded location. This is the one step of the
migration that is not the human's to defer.

The rest of the 1.x tree stays where it is. **Nothing is deleted here.** Once the
human has read the report and is satisfied, `[[skills/prune]]` removes it.

## 5 — Finish, and prove it

```
node .aep/scripts/index.mjs
node .aep/scripts/validate.mjs
```

**`validate.mjs` must pass with no exemption.** A converted artifact that fails
the contract has not been converted — it is a file that looks migrated, and it
cannot participate in discovery. Fix it here, or report it as unconverted.

## 6 — Report

The conversion is only trustworthy if what it assumed is visible:

- **every file, with its outcome** — converted (and where to), superseded (and by
  which shipped file), or unrepresented;
- **every proposed `use-when`**, as one list the human confirms in a single pass;
- every deviation converted out of the old protocol file, with its reason;
- every collision that stopped: two specs for one effort, evidence with no
  effort, a 1.x policy that could be a rule or could be already-covered;
- every decision record left in place, with which of the three kinds it was
  judged to be;
- every repository script moved out of the old AEP directory.

**Do not commit.** This is a large change to where knowledge lives, and it is
read before it lands.
