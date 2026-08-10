---
owner: repository
status: accepted
load-when: /configure would write, or an audit would check a write, outside the protocol directory
sources: [skills/configure/, .claude/decisions/0033-configure-writes-the-formatter-exclusion-outside-dot-claude.md]
supersedes: [0033]
superseded-by: []
---

# What /configure writes outside the protocol directory is a bound, not a count

ADR 0033 asserted the formatter exclusion was the *only* file `/configure`
writes outside `.claude/` and `CLAUDE.md`; the regenerate-and-compare check
falsified the count, and a drift finding records that the guard was patched
while the Decision behind it stayed wrong. Decided: the rule is a bound —
`/configure` writes outside the protocol directory only what the specification
names for that release, each write planned and listed, and the audit asserts
the written set equals the specified set. A count is re-falsified by every
legitimate addition; the bound survives them and still catches the unplanned
write, which is what the count existed to catch.
