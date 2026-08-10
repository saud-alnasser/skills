---
owner: repository
kind: research
falsifies: []
---

# Which repository variations do the installed instruction files actually carry?

Verified against: this repository's working tree during the crystallize effort, 2026-08-10 — the templates under `skills/configure/` against their installed copies, re-runnable with `Compare-Object` per pair in any clone of the effort's branch. AEP at 1.17.0; the only configured AEP instance available.

## Answer

Almost none. Of the installed instruction files, only four carried repository
variation, and every observed variation is a repository *fact*, not a reworded
norm — which is what licenses the extension points the crystallize effort
ships and forbids inventing any others.

## Findings

The census compared every template against its installed copy
(`Compare-Object` per file), plus the per-repository facts the specification
names:

- knowledge family (context, decisions, evidence, knowledge, maps): **zero
  differing lines** in all five — no extension point ships for the family.
- delivery trio (specs, tickets, sub-agents): **zero differing lines** — no
  extension point ships.
- tracker: **wholly derived** (121 differing lines of 133) — the variation is
  the tracker choice, the spec home, and the ticket model → three declared
  fields: `tracker`, `spec-home`, `ticket-model`.
- version-control: **wholly derived** (105 differing lines against a 101-line
  template) — the variation is the model and the commit unit → two declared
  fields: `model`, `unit`; the remaining prose is repository convention,
  repository-owned.
- rules (precedence, engineering, placement, boundary): identical except
  **precedence**, where this repository had appended one authority paragraph
  (specs.md is normative here) → one extension point: repository authority facts declare in `CLAUDE.md`, which ranks beside the rule.
- CLAUDE.md: derived per repository by design — the entrypoint carries
  repository sections — so it stays `owner: repository`.
- the protocol file: **zero differing lines** against its template — the
  observation behind flipping it to `owner: framework` at adoption; its two
  named extension points are the `aep-version` value and the entries of a
  `## Deviations` section.
- tool guides (`.claude/tools/`): wholly derived per repository, as ADR 0073
  already enumerates — `owner: repository`, no extension point to name because
  the whole file is the repository's.

## Limitations

One configured repository observed — the census sees the variation that
exists, not the variation other repositories may need; the deviation channel
with its one-release aging is the detector for what this census could not see.
