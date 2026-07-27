# feat(implement): on a stack, blocked means stacked

Status: resolved
Blocked by: 18

## Problem

`Blocked by: 01` means *wait until 01 is resolved*. On a repository using stacked changes it means *stack on top of 01*, and waiting is exactly what the tool exists to avoid.

Under the current rule a Graphite repository stalls. Tenure commits but never merges, so a blocker sits committed-and-unmerged until the human acts; every dependent ticket is off the frontier, the frontier empties, and `/implement` has nothing to do. The tool bought to remove that wait makes the framework strictly slower than plain git.

ADR 0016 decides it.

## Outcome

On a stacking repository a ticket joins the frontier once its blockers are **committed**, not merged, and the new branch is created on top of the blocker's. Work keeps flowing while the whole stack waits on the human to submit and merge.

The Claim's unit becomes the stack rather than one branch, because restacking rewrites every descendant — an instance working one branch rewrites the branches above it, which are other tickets' Claims. A stack belongs to one instance; parallel instances need separate stacks off trunk. `/implement` says so rather than leaving it to be discovered.

The closing keyword moves into the commit body here, reversing the split ticket 18 establishes for plain git: a branch's commit reaches trunk only by merging its own pull request, so the hazard that pushed it out does not exist — and it has to move anyway, because the submit path prompts for metadata interactively and offers no way to supply a body from a file.

The cost being accepted on the user's behalf is stated when a stack is created: a rejected review low in a stack invalidates every branch above it.

Whether the submit path prefills a pull request description from the commit message is **not yet verified**. It is a docs fetch before anything relies on it, not an assumption.

## Acceptance

- On a stacking repository, a ticket whose blockers are committed but unmerged is buildable, and the branch is created on the blocker rather than on trunk.
- On a plain repository the existing meaning is unchanged, and which meaning applies is read off the repository rather than guessed.
- The amend path used mid-stack leaves no descendant pointing at a replaced commit.
- The stack-belongs-to-one-instance constraint and the rejected-review cost are both stated where the user sees them before the stack exists.
- Nothing relies on the submit path's prefill behaviour until it has been verified against the documentation.

## Comments

**The open question is now answered, and the answer is "nowhere says".**
Checked against the installed CLI (`gt submit --help`, gt 1.8.6) and against
Graphite's command reference: `gt submit` has **no `--title`, `--body`,
`--body-file`, or stdin** — its metadata flags are prompts (`--edit`,
`--edit-title`, `--edit-description`) and their negations, plus `--ai`. Whether
it prefills the description from the commit message is **documented in neither
place**, so nothing may rely on it, and `tools/graphite.md` records the absence
rather than staying silent — silence would read to a later editor as a check
nobody needed.

That strengthens ADR 0016 rather than merely confirming it. The closing keyword
moves into the commit body not only because the cherry-pick hazard vanishes,
but because the commit body is the only text Tenure controls that reaches the
pull request at all.

**The keyword rule has one home, in `/commit`**, as a two-row table: which form
a commit carries depends on how it will reach the default branch. `/implement`
selects the case and points; restating it in the stacking section would have
been a second home for a rule that already drifted once.

**`gt create --onto` is how a ticket stacks on its blocker**, with the name
passed explicitly — `gt` generates one from the commit message otherwise, which
would break ticket 17's convention and leave two names for one ticket.

**Both misdetection directions are stated**, because only one of them is loud.
Assuming plain git on a stacking repository empties the frontier silently and
makes the tool a net slowdown; assuming stacking on a plain repository builds
on unmerged work that was supposed to wait.

**Five mutations run against the new assertions**, all caught: dropping the
unverified marker, dropping the one-instance rule, un-closing the stacked case,
gating the frontier on merge, and renaming `gt modify` throughout the reference.
