# refactor(skills): every skill declares its mode as a field, not a body line

Status: open
Blocked by: —
Part of: declared-fields

## Problem

Seventeen skills declare their reasoning posture as a prose line in the body, and the suite recovers it by matching `'(?m)^Mode:\s*(\S+)\s*$'` against running text. The same file already carries a comment explaining why that class of match is fragile — a literal-space pattern survives only until somebody reflows the paragraph it sits in.

The harness accepts a closed set of `SKILL.md` frontmatter fields and documents one free-form `metadata:` map for third-party data. The posture belongs there: AEP's own tooling reads it, the harness promises not to act on it, and it stops being one reflow from silent breakage.

## Outcome

Every shipped skill declares its posture under `metadata.mode`. The `Mode:` body line is gone from all of them. The suite reads the field, and fails when the map is present but is not a map — the harness drops a non-map value silently, so nothing downstream would notice.

Per ADR 0025 the `skills/configure/` templates carry the format before this repository's own copies adopt it.

The router's stage table is untouched. Its mode column still cross-checks against what each skill declares — the check reads a field instead of a prose match, and ADR 0054's precedence is unchanged.

## Acceptance

- No file under `skills/` contains a `Mode:` body line, and the suite fails if one is reintroduced.
- Every skill's frontmatter carries `metadata.mode`, and its value is one of the seven postures — asserted from the frontmatter rather than a hand-kept list, so a skill added later is held to the rule.
- The suite fails when `metadata` is present with a scalar value. Confirm the assertion fails against a deliberate scalar before trusting it.
- No key inside `metadata` collides with a name in the harness's accepted field set.
- The existing cross-check between the router's stage table and each stage's declared mode still passes, now reading the field.
- The guard is confirmed to fail against a deliberate reintroduction of the old prose line, per `.claude/rules/skills.md`.
