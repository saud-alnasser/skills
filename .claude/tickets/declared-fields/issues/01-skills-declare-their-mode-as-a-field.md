---
title: refactor(skills): every skill declares its mode as a field, not a body line
status: resolved
blocked-by: []
part-of: declared-fields
---

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

## Comments

**ADR 0025 did apply, and an earlier version of this note said it did not.** That claim rested on a survey that stopped at the stage table; `/review` found two shipped files still describing the removed form — `configure/protocol.template.md` and `configure/SKILL.md` — the first of which installs into every configured repository. Both are corrected in this change, so the template order ADR 0025 requires is satisfied rather than waived. `.claude/protocol.md` carried the same sentence as this repository's installed copy and is corrected with them. The withdrawn claim is recorded rather than deleted: it failed `.claude/rules/engineering.md`'s verify-before-claiming, and a waiver that was never checked reads in the record exactly like one that was.

**The first mode guard did not check the thing it existed to check.** It matched any indented `mode:` anywhere in the frontmatter, so renaming `metadata:` to `aep:` left the suite green — the containment ADR 0055 exists to enforce was the one property unasserted. Caught by `/review`, which demonstrated it with that mutation rather than describing it. The parse now reads the `metadata:` block first, through one reader shared by all three sites that ask.

**An exemption that could never fire was removed.** The prose-line guard skipped `configure/modes/*` for a `# Mode:` heading its anchor cannot match — a branch no mutation could confirm, defended by a comment explaining *what* it did.

**Four guards were confirmed against deliberate reintroductions** rather than trusted: a prose `Mode:` line, a scalar `metadata`, `paths` reused as a metadata key, and `metadata:` renamed so the map is absent. Each fired on its own mutation and only that one, and the tree was restored after each.

**A frozen spec now reads against this change, and is deliberately not edited.** `.claude/tickets/mechanics/spec.md` ruled the move out of scope — *"`Mode:` and `Policies:` stay prose lines: §11 mandates it, the suite already parses them, and moving them buys nothing the harness would read."* That was true of what was known then; the research this effort ran found the harness does document a map for exactly this, which is the fact that reverses it. A spec is superseded by a later one and never rewritten, so it stands as the record of what was decided at the time, and this line is where a reader who greps for it learns what overtook it: ADR 0055.

**Accepted, by the user's decision rather than the reviewer's or mine:** both axes flagged the branch-prefix paragraph in `.claude/policies/version-control.md` — Spec as scope creep beyond this ticket, Standards as a machine-specific fact written into a shared policy. The second half was correct and is fixed: the machine anecdote is gone and only the durable rule remains, that the effort identifies the claim and both `refs/heads/<effort>` and `refs/heads/*/<effort>` must be read. It stays in this commit rather than becoming its own ticket because the user chose that disposition when the finding was surfaced, and because protocol scaffolding rides its consumer rather than becoming a unit of work (ADR 0038).

**Routed to ticket 02, not fixed here:** `/review` reported `specs.md:170` — *"Dependency declarations are prose lines in the skill body"* — as falsified. Checked: `specs.md` names no `Mode:` line anywhere, and "dependency declarations" are the `Policies:` lines, which are still prose until ticket 02 moves them. The finding is real and early, and now sits on that ticket's acceptance.
