# feat(configure): the build lifecycle has a GitHub form

Status: resolved
Blocked by: —
Part of: fieldwork

## Problem

The tickets policy claims that on GitHub the build-lifecycle states are labels, but no file defines those labels — the tracker policy's table maps only triage roles, which the same tickets policy forbids build tickets from carrying. So `open`, `blocked`, `resolved`, and `obsolete` have no GitHub representation at all, and `obsolete` breaks hardest: the policy demands it never be deleted, while on GitHub closing reads as delivered and leaving it open invites someone to claim it. A correct implementation is currently not derivable; the field session invented one.

## Outcome

Shipped behaviour. The tickets policy replaces the false labels sentence with closure semantics: open is an open issue; blocked stays open with its reason under a `## Blocked` heading in the body, where the edges already live; resolved is closed as completed, by the merge, exactly as already specified; obsolete is closed as not-planned with a mandatory comment carrying the one-line reason. Zero new labels. The forge reference gains the close-as-not-planned invocation.

## Acceptance

- All four lifecycle states have a stated GitHub form requiring no label the repository does not already have.
- The claim that lifecycle states are labels is gone, and the suite guards against its return — guard confirmed to fail on reintroduction.
- The forge reference documents closing an issue as not-planned, including the reason flag.
- The recorded fallback if blocked tickets prove invisible in practice — a single `blocked` label — is noted in the spec's risk, not shipped.
- The suite passes.

Spec: ADR 0036 records the decision and the rejected label vocabulary.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. The `--reason` and `--comment` flags were confirmed against `gh issue close --help` before being documented. Review: Spec axis clean on all five criteria (the blocked-label fallback was already in the spec's risk, untouched); Standards' four findings all fixed — the pre-existing status-form guard re-anchored to the subject (`native state`) and plant-proven against a reworded restatement, the mandatory-comment assert bound to the obsolete mapping's own line, the labels regression pattern broadened across verbs and proven against "each state is a label", and the mapping-assert comment corrected. The installed `.claude/policies/tickets.md` still carries the old sentence by design: adoption is ticket 07 (ADR 0025). "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
