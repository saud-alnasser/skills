# Skill authoring

Sources: `skills/`, `.claude/decisions/`

How a skill in this repository is shaped, named, and placed. This is the domain with the most vocabulary of its own, because the product here *is* skills — a decision about where a sentence goes is an engineering decision, not an editorial one.

## Language

**Model-Invoked Skill**:
A skill Claude selects on its own, recorded by the absence of `disable-model-invocation` in its frontmatter. Its `description` is load-bearing — it is the whole basis on which the skill gets selected.
_Avoid_: automatic skill, implicit skill

**User-Invoked Skill**:
A skill reached only by the user typing it, marked `disable-model-invocation: true`. Its name is what somebody types; its description is read by a human deciding, not by a model selecting.
_Avoid_: command-only skill, manual skill

**Load-Bearing Frontmatter**:
The rule that a frontmatter field exists only if something acts on it. Fields that were merely descriptive — `tags` above all — were removed rather than maintained, because a field that has to be read to be useful loses to a table that is read once.
_Avoid_: metadata, header

**Progressive Disclosure**:
Keeping a skill's entrypoint to what every run needs and putting the rest behind a pointer, so a branch that does not fire is not paid for. A pointer earns its place when the branch behind it is genuinely conditional.
_Avoid_: lazy loading, splitting, chunking

**Sediment**:
Text that accumulated because it was worth writing once and was never worth deleting. The characteristic failure of a knowledge layer, and the reason the compression test is applied before writing rather than during review.
_Avoid_: cruft, bloat, legacy text

**Single Home**:
The property that a rule is stated in exactly one place, chosen by *when the rule must fire* rather than by what it is about. A rule that must hold unconditionally can only live in the always-on file; one restated in a skill fires only when that skill runs, which is a silent failure rather than a loud one.
_Avoid_: canonical location, source of truth (for rules)

## Boundaries

- **When a rule fires decides where it lives**, and nothing else does. Unconditional rules belong in the root `CLAUDE.md`; a rule that governs one stage belongs in the skill enforcing that stage; a standard discovered in this repository belongs in `.claude/rules/`. Topic similarity is not a placement argument.
- **A name's audience decides its length**, not its subject matter. The two audiences are the keyboard and the selector, and they want opposite things; `.claude/rules/skills.md` carries the rule that resolves it.
- **Vendored skills are altered, not rewritten.** The derivation from mattpocock/skills stays visible in the file, and the attribution is a licence obligation rather than a courtesy.

## Constraints

- **A skill's own tests are assertions in `scripts/verify.ps1`.** There is no test runner here, so a skill change that adds a checkable claim and no assertion is untested by construction.

## The external authoring standard

This repository's skills were written against `writing-great-skills`, which supplies the fuller vocabulary — the information hierarchy, context load versus cognitive load, and the named failure modes beyond Sediment.

**It is not currently installed** — `~/.claude/skills/` is empty and no marketplace carries it. The terms above are the ones this repository's own artefacts define and demonstrate; the rest are named here so their absence is visible, and are deliberately not paraphrased from memory.
