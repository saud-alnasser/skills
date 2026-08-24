---
status: resolved
blocked-by: [03]
---

# docs(specs): the specification describes more than one adapter

## Outcome

`specs.md` stops describing the adapter in the singular. §29 says a runtime
target is a named renderer, §32.1's layout shows what the distribution actually
holds, and §32.2's assertions read over every adapter rather than over Claude's.

## Acceptance Criteria

- [ ] §29 states that a runtime target is one entry among several, and that a
      target's tree is committed exactly when that directory is itself what a
      user registers (criterion 13).
- [ ] §29 keeps every existing MUST and MUST NOT for an adapter unchanged — a
      pointer, never the source of truth, never a copy that can drift.
- [ ] §32.1's distribution layout shows `adapters/<runtime>/` holding more than
      one runtime, and says which shape a committed tree carries (criterion 13).
- [ ] §32.2's adapter assertion reads over **every** adapter, and gains the
      claims this effort adds that are mechanically checkable — the prefix, the
      per-runtime frontmatter key sets, and the fallback resolving onto a file
      that exists (criterion 13).
- [ ] The version of record at the top of `specs.md` is untouched here; the
      release ticket owns it.

## Relevant areas

`specs.md` — §29 (Runtime adapters), §32.1 (The distribution), §32.2 (The suite).

## Constraints

- **The specification is amended in the same change as the implementation.** A
  shipped surface that conforms to no written claim is what this repository has
  a specification to prevent.
- `specs.md` is never installed, so it may cite itself freely — but nothing under
  `src/` may cite it back.

## Notes

Sequenced before the verify task because that task asserts these sections by
their content. Writing the assertions first would pin text that does not exist
yet.
