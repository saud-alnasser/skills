---
kind: drift
falsifies: [.claude/policies/tracker.md]
---

# The tracker's tracked-intent declaration rests on a falsified landing fact

Consumed: `.claude/policies/tracker.md`, "What a ticket is" — the declaration was re-argued from the unit rather than from the landing mechanism, and did not flip

Found in passing while adopting this effort's templates (ticket `scaffolding/05`). Filed
rather than healed: correcting the declaration changes how `/design` routes decision work,
which is `/design`'s call and not a build session's.

**Two ways this finding sits outside the machinery that was shipped to hold it**, both
recorded rather than worked around, because closing either is a design decision:

- **It is not indexed on a map.** `.claude/policies/maps.md` puts a `Drift found` line on
  the live effort's map. The `scaffolding` effort has no map — the fog gate never fired, so
  it produced a spec and tickets instead — and the spec format has no such section. A live
  effort therefore owns this area and there is still no index surface, which is neither case
  the policy anticipates.
- **No installed policy authorises filing it.** `.claude/policies/knowledge.md` exempts a
  falsified **Decision** from inline healing; what is falsified here is a policy sentence.
  ADR 0035 makes the tracker declaration Decision-like — frozen, and carrying its reasoning
  — but the exemption as written does not reach it, and widening it is not a build session's
  to do. Healing it inline instead was the alternative, and that is the routing change the
  exemption exists to prevent.

## What was checked

`.claude/policies/version-control.md`, "How work lands", claimed:

> The maintainer fast-forwards `main` from each ticket branch, in ticket order. There are
> no merge commits in this repository's history and no pull requests.

Checked against `d160737` (`main` at the time), by three reads:

- `git log main --format='%h %p %s' -6` — the two most recent commits carry `(#1)` and
  `(#2)`, the squash-merge subject form.
- `git log main --merges --oneline` — zero merge commits, so the "no merge commits" half
  is true and is not what falsifies the claim.
- `gh pr list --state merged` — pull requests 1 and 2, merged 2026-08-01 and 2026-08-03.

So the repository **does** land work by pull request, squash-merged. The no-pull-requests
half was true when written and stopped being true at PR 1. The fast-forward history below
`fc49348` is the earlier convention, not the current one.

That half was healed in place, in the same breath, in the commit for ticket
`scaffolding/01` — it is a policy statement about a fact, and the fact was readable.

## What it falsifies

`.claude/policies/tracker.md`, "What a ticket is", declares **Tracked intent**, and gives
this reasoning:

> The version-control policy ties one ticket to one branch and one commit, but work lands
> by fast-forward with no pull requests (`.claude/policies/version-control.md`, "How work
> lands"), so the one-ticket-one-pull-request test fails.

The premise is the sentence corrected above. With work landing by pull request, the detect
test in the tracker template — does the version-control policy tie one ticket to one
branch, one commit, one pull request — now appears to *pass*, which would make a ticket
here **branch-bound** rather than tracked intent.

Not healed, because the consequence is not editorial. Branch-bound routes decision work off
the tracker and into the design document (`.claude/policies/maps.md`), and this repository
has run map efforts under the tracked-intent reading. Whether the declaration flips, and
what happens to decision work already recorded as tickets, is a design question.

## What is not claimed

That the declaration is wrong. Only that the reasoning printed beneath it cites a fact that
is no longer true, so the conclusion is currently unsupported rather than currently refuted.
A design run may reach the same declaration for a different reason — `.claude/tickets/`
holds decision tickets that a flip would have to account for.
