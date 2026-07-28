# Instructions load in three tiers, and the tier is a mechanism rather than a topic

Instructions are placed by *how the harness selects them*, not by what they are about. `.claude/rules/` without `paths:` frontmatter loads on every turn and holds only what fires unconditionally. `.claude/rules/` with `paths:` loads when Claude reads a matching file and holds standards owned by part of the tree. `.claude/policies/` is reached by pointer and holds one repository aspect or workflow concern each.

The third tier exists because `paths:` cannot express "when `/implement` runs". A workflow stage is not a file pattern, so a stage-triggered guide cannot be a rule and has to be pointer-read.

This extends the placement rule the repository already held — that when a rule fires decides where it lives, and topic similarity is not a placement argument — from a discipline into a mechanism. Each tier now has a loading behaviour that is observable, so a misplaced instruction shows up as a measurable cost rather than as a matter of taste.

## Considered Options

**Splitting by subject matter** — engineering standards in `rules/`, repository aspects in `policies/` — was rejected. It reads naturally and it is a judgement call at every edge: the context policy is about both, and so is commit discipline. It also contradicts the placement rule above, which the repository adopted precisely because topic-based placement is how a rule ends up restated in two files that both look like the right home.

**Collapsing to one pointer-read directory**, with the unconditional rules staying inline in `CLAUDE.md`, was rejected because it gives up path-scoped loading entirely. A standard that applies only to `skills/**` would then either live in the always-on file and be paid for everywhere, or not exist.

## Consequences

`.claude/rules/skills.md` was loading unconditionally despite carrying `Scope: skills/**` as prose — 3,405 chars on every turn, including turns that never open `skills/`. Under this decision that scope becomes `paths:` frontmatter and the cost becomes conditional.

Adding a file to `rules/` without `paths:` is now a permanent always-on tax, which makes that directory something to keep small rather than something to fill. This is the opposite of the instinct that a directory for rules should accumulate rules.

Claude Code's behaviour around `paths:` has changed across several recent versions, so this decision depends on a mechanism that is documented but young. The `InstructionsLoaded` hook is the check when it is in doubt.
