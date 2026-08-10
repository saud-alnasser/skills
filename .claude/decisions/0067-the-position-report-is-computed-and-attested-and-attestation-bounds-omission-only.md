---
owner: repository
status: accepted
load-when: the verification report's enforcement is in question, or what a receipt attests is
sources: [.claude/protocol.md, skills/configure/SCRIPTS.md, skills/commit/SKILL.md, .claude/scripts/]
supersedes: []
superseded-by: []
---

# The position report is computed and attested, and attestation bounds omission only

The verification report becomes the output of a script derived into the repository
rather than prose a stage narrates, and the same run writes a **Receipt** — a
Position record of what was seen — that the commit stage refuses to proceed
without. The protocol previously claimed that reporting "makes a lapse visible
rather than silent"; a well-formed report is producible without doing any of the
work, so the claim described an enforcement that did not exist, and this builds
the mechanism rather than softening the sentence.

**The report splits into a computed half and a judged half, and that boundary is
what makes any of it enforceable.** Position — the marker's two facts against the
live two, and the drift lists when they differ — is mechanical. Which contexts
route, whether a pointer still resolves, whether a claim contradicts source, and
what was done about each is judgement, and no script can produce it. Presenting
them as one block is why the whole report read as unenforceable: the half that
could be checked was never separated from the half that cannot.

**The attestation is therefore deliberately narrow: the position is attested, the
healing is not.** A receipt proves the position was derived, never that the stage
read it or acted on it. Verification at use stays outside this mechanism, and
saying so is part of the decision — a guard whose claim is read wider than it
holds is the failure this repository has shipped more than once.

## Considered Options

- **A hook that emits the facts.** The only genuinely unforgeable option, and it
  loses on staleness: a session hook fires once, so every stage after the first
  commit would quote a position that has moved, and an authoritative-looking stale
  report is the failure being removed rather than a milder form of it. It also
  fails plugin-independence — a teammate without AEP gets no hook, where an
  environment variable needs nothing installed.
- **The script with no commit-time refusal.** Smallest change, and it leaves the
  false claim standing; the correction would then be made to the sentence instead
  of to the mechanism. The gap was never the deriving, it was the remembering.
- **A receipt carrying no run identity.** Drops an undocumented dependency
  entirely, at the cost of attesting only that *somebody* verified at this commit
   — approximately what the Marker already says, so the new file and the new
  refusal would narrow almost nothing.
- **Computing the branch name and the stacking model as well.** Both are single
  documented reads with no observed drift, and folding them in makes the script
  the place everything mechanical accretes, which is how a script stops being
  reviewable.

## Consequences

**The run identity is observed, not documented.** The session identifier carries
the correct value in a tool call today, but the documentation names only the
effort level as reaching one and names the session identifier only as JSON input
to a hook. The dependency is taken with a stated fallback: without the identifier
the script produces the weaker commit-matched attestation and **says which mode it
ran in**, so a downgrade is announced rather than silent. That field is the whole
mitigation, and a guard asserts it is stated.

**`0060`'s enforcement half does not transfer.** An index is a tracked file, so a
derived regenerator is checked by regenerating and comparing. A position report is
not in the tree and has nothing to compare against, so the worked fixture is the
only check on a derived implementation — the same remedy `0060` already prescribes
for the first script, load-bearing here in a way it was not there.

**`0060` is generalised, not superseded.** Its conclusion — AEP ships behavioural
specifications and the implementation belongs to the repository — is unchanged and
still live; it was stated of the regenerator because the regenerator was the only
script. A second one applies the same reasoning rather than revising it, so the
page grows a section and neither ADR contradicts the other.

**Position gains a member by the category rule**, which is what `0012` named the
category for. Nothing shared loses information when it is deleted; what a deletion
costs is the ability to commit until the script is run again, so the refusal names
what to run rather than only what is missing.
