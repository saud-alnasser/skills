---
status: accepted
load-when: AEP needs a field of its own on something it ships, or a shipped fact is stated as a body line
sources: [skills/, agents/, .claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md]
supersedes: []
superseded-by: []
---

# AEP's own fields ride the harness's `metadata` map

A fact that `/configure` or `scripts/verify.ps1` reads off a shipped skill or agent is declared under the frontmatter `metadata:` map, never as a prose body line and never as a bare top-level key. `Mode:` and `Policies:` become `metadata.mode` and `metadata.policies`; `agents/`'s top-level `mode:` moves under the same map.

The harness documents `metadata` as a *"free-form YAML map for your own key-value data … read by your own tooling"* that it does not act on, against a closed set of nineteen accepted `SKILL.md` fields — so a bare key is outside the contract and this one is inside it. The subagent table has no such row, and AEP has been relying on that undocumented gap for `mode:` since agents shipped; consolidating both surfaces on one map does not remove the dependency but reduces it to a single asserted place.

This is not ADR 0002 reversing. That decision rejected `tags` — a *subject* declared for discovery, read by grepping. These fields are read by the derivation ADR 0054 already assigns to `/configure` and by the suite, which is the Load-Bearing Frontmatter bar in `contexts/skill-authoring.md`, not an exception to it.

## Considered Options

- **Bare top-level `mode:` on skills, matching what `agents/` does today.** Rejected: the skills reference states the accepted set and `mode` is not in it, so this would extend an undocumented dependency to twelve more files rather than contain it.
- **Leave the facts as body lines and keep parsing prose.** Rejected: the suite matches `'(?m)^Mode:\s*(\S+)\s*$'` against running text, and the same file already carries a comment explaining that a hard-wrapped paragraph defeats a literal-space match. The format is one reflow from silent breakage.
- **Generate `protocol.md`'s stage table from the declared fields.** Rejected by ADR 0054 before this run reached it: `skills/` is absent from the tree in every repository but this one, so a table derived at read time leaves a plugin-less teammate with no committed answer. The fields feed the derivation `/configure` performs; the table stays committed and authored.
- **Settle the agent question by experiment first.** Deferred rather than rejected: the evidence establishes that agents already work with an unlisted key, and an experiment would date a version-specific fact this decision does not turn on.

## Consequences

`metadata` values must be maps — the harness *"drops a value that isn't a map"* silently, so the suite asserts the shape rather than trusting it, and key names avoid the nineteen reserved ones (`paths` above all, which this repository uses for a different purpose in `.claude/rules/`).

Per ADR 0025 the `skills/configure/` templates change before this repository adopts the result, so a configured repository and this one never disagree about the format. The specification is amended in the same change, per ADR 0029.

The `agents/` half remains undocumented behaviour by choice, recorded here so a future reader finds a decision rather than an oversight. If the harness ever validates subagent frontmatter strictly, this is the file that says where to look.
