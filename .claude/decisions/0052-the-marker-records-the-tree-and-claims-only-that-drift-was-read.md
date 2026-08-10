---
owner: repository
status: accepted
load-when: the Marker's contents, or what a match licenses, is in question
sources: [.claude/protocol.md]
supersedes: []
superseded-by: []
---

# The Marker records the tree, and claims only that the drift was read

The marker file gains a second fact — a fingerprint of the working tree — and its claim is simultaneously **narrowed**: a match on both facts licenses skipping the two drift reads, and nothing else. It no longer means context is trusted with no reading at all.

The two halves of the old check were different kinds of test. `commit == HEAD` is an identity test; *the tree is clean* is a liveness test, and a liveness test cannot be satisfied again once it fails. So a single uncommitted edit invalidated the cache until a commit landed, and every stage in between re-read drift that the stage before it had already read and dealt with. Recording the tree makes both halves identity tests, and the clean-versus-dirty branch disappears from the rule entirely — a fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one.

The narrowing is what makes the field worth having. With the old claim, only a stage that had verified everything could write the marker, which is why it had exactly one writer; and after a commit the tree is clean, so a commit-only writer would leave the new field inert. Under the narrowed claim, re-stamping the tree asserts only *this tree's drift has been read and dealt with* — which any stage that read drift and healed or discounted what it found has genuinely done. That stage may write the tree fact alone. The commit stage still writes both.

The permission is conditional on the **dealing**, not on the reading. A stage that read drift and neither healed nor discounted it has established nothing and re-stamps nothing.

## Considered Options

- **Keeping the old claim and adding the field anyway** — rejected as nearly inert. The only writer that could honestly stamp "context is trusted" is the commit stage, and the tree is clean when it runs.
- **Letting any stage stamp under the old claim** — rejected as false trust. A stage verifies what it touches, so a design run that checked three statements would stamp the whole tree as verified, and the next stage would trust parts nobody checked. Over-invalidation costs reads; false trust costs correctness, and they are not comparable.
- **Leaving the marker alone and making the drift read cheaper** — rejected as attacking the symptom. The read is already two commands; what recurs is that its *result* has nowhere to live.
- **`git stash create` as the fingerprint** — rejected on its own usage line, which takes no `-u`. It cannot see untracked files, so a newly added file would leave the fingerprint unchanged. That is false trust in exactly the case the drift read exists for.
- **A digest of `git status --porcelain` output** — rejected as unsound. The output records which files changed, never what they contain, so a second edit to an already-dirty file leaves it byte-identical.
- **Hashing only the dirty set** — sound, and cheaper, since the dirty set is normally a handful of files and `git status` is a read the workflow takes anyway. Rejected for uniformity: it needs a special case for the clean tree and a third command to capture staged blobs, where a real tree object needs neither.

## Consequences

The fingerprint is a git tree object built through a throwaway index seeded from the repository's own. The seeding is not an optimisation detail — without it the temporary index has no stat cache and every file in the worktree is re-hashed on every stage, which would make the check cost more than the read it replaces. Because it is seeded, the cost lands near `git status`.

**A marker carrying no tree fact means the tree is unknown**, and the check falls back to the live clean test. No repository needs migrating, and a clone that never adopts this loses only the shortcut. The configuration stage does not write one either: stamping asserts that a drift read happened and was dealt with, and that stage did neither — the fallback corrects itself the first time a stage that *did* advances the marker.

Nothing about verification at use moves. A matching marker has never meant a statement is correct and now says so explicitly; every statement about to be relied on is still checked against the Codebase at the moment of reliance.

The re-stamp is the one place false trust can enter this system, so it is stated as a conditional obligation rather than a capability, and its guard is written against the inversion rather than the absence — this repository has already shipped guards that passed for a rule and for its negation alike.
