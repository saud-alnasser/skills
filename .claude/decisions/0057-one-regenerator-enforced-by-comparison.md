---
status: accepted
load-when: a generated index needs to be produced, or something proposes to maintain one
sources: [.claude/scripts/, .claude/policies/context.md]
supersedes: []
superseded-by: []
---

# One regenerator, enforced by comparison — never a role and never a hook

Every generated index is produced by a single deterministic script, invoked by the commit stage, and the suite regenerates each index and compares it against what is committed. A stale index fails the build.

Producing a table from fields the indexed files declare is a total function of the directory's contents. A sub-agent executing it would introduce nondeterminism into the one artefact whose whole value is that it cannot disagree with its directory — and would spend a model on a transformation with no judgement in it. Comparison is the enforcement the existing indexes already assume: the context format states that a generated file is never hand-edited and that the prohibition holds *by regenerating and comparing rather than being requested of whoever opens it*. This gives that sentence something to be true of.

## Considered Options

- **A harness hook on writes beneath the indexed directories.** Rejected on two grounds. It rewrites files mid-session, so a reviewer reads a diff that grew while they were reading it; and it lives in the harness settings rather than in what AEP ships, so a repository that declines the hook loses the guarantee silently — the failure mode this framework treats as worse than a loud one.
- **The writing stage regenerates.** Rejected: it is one obligation restated in several skills, which is the single-home failure the framework exists to prevent, and it fails at whichever stage forgets rather than at the build.
- **A sub-agent role that maintains indexes.** Rejected as above — deterministic work, wrong executor.

## Consequences

The commit stage acquires an invocation it did not have. That is deliberate: commit is the last point at which the tree is known complete, and an index regenerated earlier can be falsified by a later edit in the same change.

The script is committed and runnable without the plugin, like the suite it is checked by. A repository configured by AEP gets the script, not a promise that some agent will remember.

Regeneration must be **byte-stable** — same inputs, same output, including ordering and whitespace — or comparison reports drift that is only formatting. The first ticket to build it proves this against the two indexes that already exist, by reproducing them exactly.
