---
status: resolved
blocked-by: [01, 03, 04]
---

# test(verify): the install fixture upgrades a 2.1 tree end to end

## Outcome

The install fixture builds a tree shaped like 2.1, upgrades it, and proves the
whole path: the moved files are gone, the policies landed, a repository-owned
rule survived untouched, its links were repaired, and a 1.x tree is still
recognised as 1.x.

## Acceptance Criteria

- [ ] Fixture: the installed `rules/` contains only `owner: repository` files.
      *(spec criterion 2)*
- [ ] Fixture: a tree shaped like 2.1 — the nine rule filenames, protocol-owned —
      upgrades to a tree where every `from` is gone, `policies/` is complete, and
      a repository-owned rule placed beforehand is byte-identical. *(spec
      criterion 9)*
- [ ] Fixture: a repository-owned context linking `rules/engineering` links to
      `policies/engineering` afterwards, the tree validates, and the report names
      the file. *(spec criterion 10)*
- [ ] Fixture, the negative: a repository that kept its own `rules/evidence.md`
      has its link to `rules/evidence` left alone.
- [ ] Fixture: `.claude/policies/` is still refused as 1.x, and `.aep/policies/`
      installs without tripping the detector. *(spec criterion 11)*
- [ ] The existing collision fixture — today a repository-owned `rules/ownership.md`
      — becomes a repository-owned file standing in `policies/`, asserting that
      the upgrade preserves it *and* that `validate` then fails on it.
- [ ] Each new assertion was inverted or its subject deliberately removed, and the
      run was watched failing with the right name. *(spec criterion 12)*

## Relevant areas

`src/scripts/verify.mjs`: the install fixture, and the guard-fires section at the
end.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject.** This repository has shipped a guard that matched
  something travelling with the thing it checked; that is the failure mode to
  defend against here.
- Build the 2.1-shaped fixture from the nine real filenames and a real
  repository-owned file — not from a guess at what 2.1 looked like.
- The trigger-quality judgement stays out of the suite. `validate` keeps saying it
  is not checked mechanically.

## Notes

**Narrowed during implementation.** This ticket originally carried every
assertion in the effort, which contradicts `[[rules/authoring]]`: the suite moves
in the same pass as the change it checks, and a suite task standing behind four
code tasks leaves the tree red between them with no green checkpoint. Each of
01, 03, 04, and 07 now carries its own assertions. What is left here is the
cross-cutting part — a fixture that needs the policies, the scripts, and the
installer all present at once.

**Consequence for dispatch:** 01, 03, 04, and 07 now all edit `verify.mjs`, so
they are no longer path-disjoint. The task graph still declares them independent,
which it correctly is — an edge gates work and says nothing about files
(`[[policies/execution]]`). They must be serialised or given worktrees if ever
dispatched concurrently.
