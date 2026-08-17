---
aep: 2.4.0
owner: protocol
date: 2026-08-17
kind: policy
paths:
  - .aep/**/*.md
use-when: "about to create, change, move, or remove anything under .aep/ — whose it is, where it belongs, and what shape it takes"
---

# Policy — AEP's own artifacts

Three questions, in the order they arrive: **whose is this, where does it go,
and what must it contain.**

## Whose it is

Every AEP artifact declares `owner:`, and the owner is read off that field —
**never inferred from a directory**. A directory tells you where a file sits; the
field tells you whose it is, and the two diverge the moment a repository adds a
rule beside a shipped one.

### `owner: protocol`

The artifact defines AEP itself.

- **MUST NOT be edited in a repository.** Not improved, not healed, not
  corrected in passing.
- Installed verbatim from the release; replaced or migrated by an upgrade.
- Its `aep:` field is the release it ships in, and **every release stamps every
  protocol-owned artifact** — not only the ones it changed. An upgrade compares
  that field against the release the tree declares; a stamp that disagrees means
  the file did not come from this release.
- A protocol-owned file that differs from its release is a **defect to
  reinstall**, never drift to heal. *Why: healing it locally makes the next
  upgrade a merge conflict against a file nobody agreed to fork.*

### `owner: repository`

The artifact describes this repository.

- Evolve it freely. It is yours.
- **An upgrade MUST preserve it** and MUST NEVER silently overwrite
  repository-owned governance.

### Which is which

| Path | Owner |
| --- | --- |
| `protocol.md`, `policies/`, `modes/`, `skills/`, `agents/`, `templates/`, `scripts/` | `protocol` |
| `rules/`, `contexts/`, `references/`, `efforts/` | `repository` |
| `index.md` | derived — regenerate with `scripts/index.mjs`, never hand-edit |

**`policies/` and `rules/` admit one owner each, with no exception.** A policy is
AEP's law and a rule is the repository's, so a file in the wrong directory is a
defect the validator reports rather than a case to decide. An installer still
reads the declared field before overwriting anything — it preserves such a file
and leaves the report to say so.

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
| `.aep/` | every AEP artifact: the protocol, policies, rules, modes, skills, agents, templates, contexts, references, efforts, scripts, position, worktrees |
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
aep: <release>
owner: protocol | repository
date: <YYYY-MM-DD>
---
```

Those three are required on every artifact, with no exceptions. `date` is the
last-modified date as `YYYY-MM-DD` — **update it when you change the file**, or
it becomes a claim about freshness that nothing checks.

Situational fields:

| Field | When | Contract |
| --- | --- | --- |
| `kind` | unless the directory makes it redundant | `agent` `context` `spec` `prototype` `research` `reference` `policy` `rule` `skill` `ticket` `protocol` `mode` |
| `mode` | when the artifact is relevant to particular ways of working | a YAML **array** of: `specify` `plan` `refine` `implement` `research` `prototype` `review` `test` |
| `paths` | when applicability follows repository paths | glob patterns |
| `status` | efforts and local tickets **only** | spec: `draft` `accepted` `implemented`; ticket: `open` `resolved` `obsolete` |
| `blocked-by` | tickets only | ticket identifiers this one waits on |
| `part-of` | tickets only | the effort this ticket belongs to |
| `use-when` | **required** on every policy, rule, reference, and context | one sentence |
| `report` | **required** on every skill; never on a note beside one | `full` or `short`, assigned by the test in `[[policies/reporting]]` |

### `use-when` states a trigger, never a topic

> `use-when: "working with database schema or migrations"` — a trigger.
> `use-when: "documentation about the database"` — a topic, and wrong.

*Why: a topic satisfies every mechanical check and still cannot be selected on,
so the artifact ends up loaded always or never — both defeat progressive
discovery.* This is the one failure the frontmatter contract cannot catch for you.

### `mode:` is applicability, not state

`mode: [implement, review]` means *this is relevant while implementing or
reviewing*. It does **not** mean the agent is in that mode. Your mode is set by
the skill you are running.

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

`.aep/` MUST NOT contain `decisions/`, `tools/`, a `grill/` directory, or any
effort's `plan.md`. Each was tried and retired; see `[[protocol]]` for what
replaced it. Do not reintroduce one because it seems locally convenient.

Run `scripts/validate.mjs` to check a tree against everything above.
