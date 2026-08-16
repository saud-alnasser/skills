---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
paths:
  - .aep/**/*.md
use-when: "creating or editing any Markdown artifact under .aep/"
---

# Rule — artifact shape

## Frontmatter

Every Markdown file under `.aep/` MUST open with YAML frontmatter:

```yaml
---
aep: 2.0.0
owner: protocol | repository
date: 2026-08-16
---
```

Those three are required on every artifact, with no exceptions. `date` is the
last-modified date as `YYYY-MM-DD` — **update it when you change the file**, or
it becomes a claim about freshness that nothing checks.

Situational fields:

| Field | When | Contract |
| --- | --- | --- |
| `kind` | unless the directory makes it redundant | `agent` `context` `spec` `prototype` `research` `reference` `rule` `skill` `ticket` `protocol` `mode` |
| `mode` | when the artifact is relevant to particular ways of working | a YAML **array** of: `specify` `plan` `refine` `implement` `research` `prototype` `review` `test` |
| `paths` | when applicability follows repository paths | glob patterns |
| `status` | efforts and local tickets **only** | spec: `draft` `accepted` `implemented`; ticket: `open` `resolved` `obsolete` |
| `blocked-by` | tickets only | ticket identifiers this one waits on |
| `part-of` | tickets only | the effort this ticket belongs to |
| `use-when` | **required** on every rule, reference, and context | one sentence |

## `use-when` states a trigger, never a topic

> `use-when: "working with database schema or migrations"` — a trigger.
> `use-when: "documentation about the database"` — a topic, and wrong.

*Why: a topic satisfies every mechanical check and still cannot be selected on,
so the artifact ends up loaded always or never — both defeat progressive
discovery.* This is the one failure the frontmatter contract cannot catch for you.

## `mode:` is applicability, not state

`mode: [implement, review]` means *this is relevant while implementing or
reviewing*. It does **not** mean the agent is in that mode. Your mode is set by
the skill you are running.

## Links

A reference to another AEP artifact MUST use double-bracket wiki-link syntax,
relative to `.aep/`, without `.md`:

```
[[rules/security]]   [[contexts/authentication]]   [[efforts/auth/spec]]
```

- A link is a **relationship, not a copy**. Never follow a link with a summary of
  what it says — the summary is a second home and it drifts first.
- A link that does not resolve is **repaired or reported, never invented.** Search
  for where the concept moved; do not create a file to satisfy the link.
- `paths:` is a matching field, not a substitute for a link.

## Structures that must not exist

`.aep/` MUST NOT contain `decisions/`, `policies/`, `tools/`, a `grill/`
directory, or any effort's `plan.md`. Each was tried and retired; see
`[[protocol]]` for what replaced it. Do not reintroduce one because it seems
locally convenient.

Run `scripts/validate.mjs` to check a tree against everything above.
