---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: ticket
status: resolved
part-of: runtime-adapters
blocked-by: [02, 03]
---

# feat(install): `--adapters` takes a list, and says what it wrote

## Outcome

An install writes any combination of the shipped adapters, each into the
directory its runtime reads, and reports each one. An unknown name stops the run
before anything is written; the pair that overlaps inside OpenCode is written
with a warning that names the reason.

## Acceptance Criteria

- [ ] `--adapters <a,b,c>` resolves every name through `TARGETS` **before writing
      anything**, so an unknown runtime fails with nothing half-written; it exits
      non-zero with the unknown name in the message (criterion 7).
- [ ] Each named target is written in the **repository** shape into
      `<repo>/<target.dir>`, and every file lands in the install report
      (criterion 7).
- [ ] `--adapters claude,opencode,agents` writes `.claude/`, `.opencode/`, and
      `.agents/`, and lists all three (criterion 7).
- [ ] `--adapters opencode,agents` **emits a warning** naming the duplication and
      the race; passing either one alone emits no warning (criterion 8).
- [ ] `--dry-run` reports what each adapter would write without writing it, as it
      does for the rest of the install.

## Relevant areas

`src/scripts/install.mjs` — the `--adapters` read in `main`, the write near the
end, and the report block below it.

## Constraints

- The warning is **not** a refusal. A repository driven through T3 Code with a
  non-OpenCode provider has a real use for `.agents/` beside `.opencode/`.
- Resolution happens before the first write. A run that writes `.claude/` and
  then dies on a typo in the third name has left the repository in a state
  nobody asked for.
- Adapters are written after seeds, and the OpenCode seed's detector must not see
  a `.opencode/` this run just created — the detector is `opencode.json` or
  `opencode.jsonc` and nothing else.

## Notes

Today the flag is compared as `adapters === 'claude'`, so any other value is
silently a no-op. That silence is the defect this task removes; keep the failure
loud even for a name that merely looks plausible.
