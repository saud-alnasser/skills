---
paths:
  - .aep/**/*.md
use-when: "about to create, change, move, or remove anything under .aep/ — whose it is, where it belongs, and what shape it takes"
---

# Policy — AEP's own artifacts

Three questions, in the order they arrive: **whose is this, where does it go,
and what must it contain.**

## Whose it is

**Ownership is a fact about location, and no artifact declares it.** A release
ships an exact set of paths, that set is what the installer and the validator
both consult, and a file is the protocol's if and only if it is in it.

*Why not a field: a declaration can be wrong, and the case it can never catch is
a file that simply omits it. A file with no owner had to be guessed at, and every
guess was a directory lookup performed badly. Location was always the answer.*

### The protocol's

The artifact defines AEP itself.

- **MUST NOT be edited in a repository.** Not improved, not healed, not
  corrected in passing.
- Installed verbatim from the release; replaced or migrated by an upgrade.
- **The release is named once**, in the bootstrap's `version:`. No artifact
  carries a stamp of its own, and the distribution keeps a content baseline
  instead, which is what catches an edit that never shipped.
- **An upgrade establishes provenance by comparing content**, not by reading a
  claim: a protocol-owned file whose content differs from the release is the
  defect to report (`[[skills/update]]`). *Why content: a field saying "this came
  from that release" is written by the same act it is supposed to attest to, so
  it agrees with itself no matter what happened to the file.*
- A protocol-owned file that differs from its release is a **defect to
  reinstall**, never drift to heal. *Why: healing it locally makes the next
  upgrade a merge conflict against a file nobody agreed to fork.*

### The repository's

The artifact describes this repository.

- Evolve it freely. It is yours.
- **An upgrade MUST preserve it** and MUST NEVER silently overwrite
  repository-owned governance. It cannot reach one: the installer writes only
  paths the release ships, and none of them is yours.
- **A file of yours standing where the protocol ships is a defect the validator
  names**, not one an upgrade corrects. Rules go under `rules/`, orientation
  under `contexts/`, and tool operation under `references/`.

### Which is which

| Path | Owner |
| --- | --- |
| `protocol.md`, `policies/`, `skills/`, `agents/`, `templates/`, `scripts/` | protocol |
| `rules/`, `contexts/`, `references/`, `efforts/` | repository |
| `index.md` | derived — regenerate with `scripts/index.mjs`, never hand-edit |

**`policies/` and `rules/` admit one owner each, with no exception.** A policy is
AEP's law and a rule is the repository's, so a file in the wrong directory is a
defect the validator reports rather than a case to decide. An installer writes
only the exact paths the release ships and so cannot reach such a file at all
— which is why the validator has to name it, and why nothing is lost by the
installer staying silent.

### When the protocol does not fit

Variation enters a protocol-owned artifact only through an extension point that
artifact names. Variation with nowhere to enter is a **declared deviation**:

1. Record it in a repository-owned rule under `[[rules]]`.
2. State what differs, **why**, and the release it was declared under.
3. Expect `[[skills/update]]` to report it on every run until the protocol grows
   the point or the repository conforms.

*Why the escape hatch is loud rather than absent: fixed protocol text with no
declared way to differ pressures a repository into editing it quietly, and a
silent fork is worse than a recorded disagreement.*

## Where it goes

**Everything AEP owns lives under `.aep/`, plus the entrypoint and whatever
adapter a runtime needs.** Nothing else.

| Lives where | What |
| --- | --- |
| `.aep/` | every AEP artifact: the protocol, policies, rules, skills, agents, templates, contexts, references, efforts, scripts, position, worktrees |
| repository root | the entrypoint — `AGENTS.md`, and a runtime's own equivalent — which **points at** `[[protocol]]` and never restates it |
| a runtime's directory | adapters only, such as `.claude/skills/` wrappers. Never canonical state |

**The test: ask of any file — were AEP removed, would this still have a reason to
exist?** If yes, it is not AEP's to place, and it stays where the repository
keeps it.

That test decides by **whose process the file serves** — never by what the file
is made of, and never by whether it is executable:

- a script that regenerates AEP's index serves AEP → `.aep/scripts/`
- a script that builds or tests what the repository exists to produce serves the
  repository → wherever that repository keeps its scripts, **neither moved nor
  claimed**

Consequently:

- **A runtime directory MUST NEVER hold canonical AEP state.** `.claude/`,
  `.cursor/`, `.codex/` hold pointers. A repository has one AEP state, not one
  per agent.
- **Never reference `.aep/` from source comments or from the repository's own
  documentation.** AEP is protocol machinery; code that cites it acquires a
  dependency on a tool that may be removed.
- **Per-clone state stays per-clone.** `position/` and `worktrees/` are
  gitignored, and nothing shared may depend on them.
- **An artifact is placed by its scope.** What belongs to one effort — its spec,
  its evidence, its tickets — lives in that effort's directory. What spans every
  effort lives at the root of `.aep/`.

## What it must contain

Every Markdown file under `.aep/` MUST open with YAML frontmatter:

```yaml
---
use-when: "<the occasion on which this is the thing to read>"
---
```

That is the whole of it on most artifacts. **Frontmatter carries what decides
whether to load the file, and nothing else.** A field describing the file to a
reader who has already opened it is a field the body should be saying, and a
field nothing reads is a claim nothing can falsify.

Situational fields:

| Field | When | Contract |
| --- | --- | --- |
| `paths` | when applicability follows repository paths | glob patterns |
| `status` | efforts and local tickets **only** | spec: `draft` `accepted` `implemented`; ticket: `open` `resolved` `obsolete` |
| `blocked-by` | tickets only | ticket identifiers this one waits on |

### `use-when` states a trigger, never a topic

> `use-when: "working with database schema or migrations"` — a trigger.
> `use-when: "documentation about the database"` — a topic, and wrong.

*Why: a topic satisfies every mechanical check and still cannot be selected on,
so the artifact ends up loaded always or never — both defeat progressive
discovery.* This is the one failure the frontmatter contract cannot catch for you.

### Links

A reference to another AEP artifact MUST use double-bracket wiki-link syntax,
relative to `.aep/`, without `.md`:

```
[[policies/authority]]   [[contexts/authentication]]   [[efforts/auth/spec]]
```

- A link is a **relationship, not a copy**. Never follow a link with a summary of
  what it says — the summary is a second home and it drifts first.
- A link that does not resolve is **repaired or reported, never invented.** Search
  for where the concept moved; do not create a file to satisfy the link.
- `paths:` is a matching field, not a substitute for a link.

## Structures that must not exist

`.aep/` MUST NOT contain `decisions/`, `tools/`, a `grill/` directory, or
`modes/`. Each was tried and retired; see `[[protocol]]` for what replaced it.
Do not reintroduce one because it seems locally convenient.

Run `scripts/validate.mjs` to check a tree against everything above.
