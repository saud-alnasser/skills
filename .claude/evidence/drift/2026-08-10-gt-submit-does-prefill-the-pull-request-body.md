---
owner: repository
kind: drift
falsifies: [.claude/tickets/downstream/issues/01-the-tool-references-stop-asserting-false-facts.md]
---

# gt submit does prefill the pull request body from the commit

Consumed: `.claude/tickets/downstream/issues/01-the-tool-references-stop-asserting-false-facts.md`, the paragraph stating what a submit does to the body — rewritten to the observation below before the ticket was built

**What was checked.** Submitting a six-branch stack from this repository at
commit `1e9a633`, with `gt submit --publish --no-edit --no-ai --no-interactive`
on `gt 1.8.6`, then reading the created pull request back with
`gh pr view 20 --json body`.

**What was found.** The body came back as the commit message body, in full,
including its `Refs:` and `Co-Authored-By:` trailers. The title came from the
commit subject. No pull request template was involved.

**What it falsifies.** Ticket `downstream/01` recorded, from a session in a
repository this framework configures, that on the same `gt 1.8.6` the body is
*the repository's pull request template left unfilled* and *the commit body
reaches neither*. That is the opposite of what happened here, and the ticket
would have shipped it into `skills/configure/tools/graphite.md` as a corrected
fact.

**What it does not falsify.** The shipped reference's current wording — *whether
it prefills the description from the commit message is not documented… treat the
body as unknown* — survives both observations, and is the only statement
consistent with both. Two runs of one version disagreeing is itself the argument
for the wording that is already there.

**The likely reason they disagree, unverified.** `gt submit --help` on 1.8.6
says submit behaviour is configurable through `gt config`'s *Submit settings*
menu, and neither observation recorded what that repository's settings held. So
this is a difference in configuration until somebody checks, not a difference in
the tool. Nobody has checked.

**Why this is filed rather than fixed in the shipped page.** The page is right as
it stands. What needed correcting was the ticket that planned to change it, and
that correction rides this same commit.
