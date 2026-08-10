---
kind: drift
falsifies: [.claude/decisions/0033-configure-writes-the-formatter-exclusion-outside-dot-claude.md]
---

# ADR 0033 claims /configure writes exactly one file outside the protocol directory

Found by the standards review of the `downstream` effort, against the commit that
falsified it. Filed rather than healed: `.claude/policies/knowledge.md` says a
falsified Decision is the one drift nobody heals inline, because an ADR's reasoning
is frozen and superseding one is `/design`'s pen rather than a build session's.

## The claim, and what makes it false

`0033:11`, `status: accepted`, `superseded-by: []`:

> `/configure` does that, and it is the only thing it writes outside `.claude/` and
> `CLAUDE.md`.

Ticket `downstream/04` gave the generated-index prohibition a regenerate-and-compare
check, wired into whatever already fails the repository's build — which is a file the
repository owns, outside the protocol directory. `/configure` now writes two things
there, and `skills/configure/SKILL.md` says so: *"beside the regenerate-and-compare
check it is the only thing `/configure` writes outside `.claude/` and `CLAUDE.md`.
Two edits, both planned, and no third."*

`.claude/rules/precedence.md` ranks an accepted ADR above a skill file, so the
authoritative record is the one that is now wrong.

## Why this was not caught while it was being made

The guard on the ADR pins the phrase `only thing /configure writes outside`, and the
reworded sentence still contains it. The session saw the weakening — the replacement
guard's own comment says the old one "still matches while asserting something weaker
than it did" — and patched the guard without checking whether the Decision behind it
carried the same claim. It did.

That is the letter-versus-check shape `.claude/rules/engineering.md` gained a standard
against in this same commit: what the guard existed to protect was the count, the count
changed, and satisfying the guard's wording is not keeping it. The count is now
asserted directly, but only in the skill.

## What would close it

A design run that decides whether 0033 is bounded — two writes, both named, set closed
— or superseded by a decision stating the rule as a bound rather than a number. Either
way the specification is amended in the same change, per `.claude/rules/precedence.md`.
