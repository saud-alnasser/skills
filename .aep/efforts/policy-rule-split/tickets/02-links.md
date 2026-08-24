---
status: resolved
blocked-by: [01]
---

# refactor(links): every shipped link into rules/ points at its policy

## Outcome

No file under `src/` links to one of the nine moved rules. The 116 links across
88 files point at the policy that absorbed each, and the 22 bare links to the
governance directory say which layer they mean.

## Acceptance Criteria

- [ ] `grep -rno "\[\[rules/" src/` returns only links to `rules/version-control`,
      which has not moved.
- [ ] Every bare link to `rules` under `src/` has been read in context and
      resolved to `policies`, to `rules`, or to both — whichever the sentence
      actually means.
- [ ] `node src/scripts/verify.mjs --section links` passes.
- [ ] The rewrite was performed by a script over the mapping, not by hand.

## Relevant areas

88 files: `src/seed/references/` (63 links), `src/skills/`, `src/agents/`,
`src/templates/`, `src/protocol.md`, `src/seed/contexts/repository.md`,
`src/scripts/contract.mjs` (one link in a comment).

## Constraints

- **Write the sweep as a throwaway script and run it.** A hand sweep across 88
  files misses one, and the missed one is a dangling link inside a shipped seed
  that installs into somebody else's repository.
- The bare-link decisions are the part a script cannot make. Do those by reading,
  after the mechanical pass.
- `src/rules/artifacts.md` carried an example link inside a fenced block; the
  fence content is illustrative syntax and follows whatever the merged policy
  needs, not the mapping.
- Do not edit `specs.md` here — it has its own task and uses no wiki links.

## Notes

The nine-to-four mapping is in `[[efforts/policy-rule-split/spec]]` under
Architecture — Decision 2, in the form the installer will also use.
