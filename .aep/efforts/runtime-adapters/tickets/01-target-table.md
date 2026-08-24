---
status: resolved
---

# refactor(adapters): route the Claude adapter through a target table

## Outcome

`adapters.mjs` describes a runtime as data rather than as the shape of its own
functions, and the Claude adapter is the first entry in that table. Nothing it
emits changes: this task is a pure refactor whose proof is an empty diff over
`src/adapters/claude/`.

## Acceptance Criteria

- [ ] `TARGETS` carries a `claude` entry with the fields Interfaces names in
      [[efforts/runtime-adapters/spec]] — `dir`, `prefix`, `committed`, `shapes`,
      and the per-kind `path`, `frontmatter`, and `fallback` hooks.
- [ ] `renderAdapter(distributionRoot, target, shape)` and `writeAdapter(...)`
      replace `renderClaudeAdapter` / `writeClaudeAdapter`. **No exported name
      makes Claude the general case** (criterion 1).
- [ ] Both callers are updated: `verify.mjs` — the `adapter` section and the
      note-as-a-command assertion — and `install.mjs`.
- [ ] `node src/scripts/adapters.mjs` leaves the committed Claude adapter
      byte-identical: `git status --porcelain src/adapters/claude` is empty.
- [ ] `node src/scripts/verify.mjs` passes, with an assertion count no lower than
      before this task.
- [ ] The CLI accepts `--target <name>`, `--shape <shape>`, and `--to <dir>`, and
      with no arguments regenerates every target whose `committed` is non-null.

## Relevant areas

`src/scripts/adapters.mjs` — the whole file. `src/scripts/verify.mjs` — the
`adapter` section and the note assertion. `src/scripts/install.mjs` — where the
adapter is written near the end of `main`.

## Constraints

- **This task changes no shipped output.** An adapter file that differs after
  regeneration means the refactor changed behaviour, and the diff is the report.
- `describe()` is not touched. Wrapper descriptions stay derived from each
  canonical artifact's heading and `use-when`.

## Notes

`PAYLOAD_FROM_PLUGIN_ROOT` (`'../..'`) already encodes the distance from an
adapter's own root to the payload. It is the value the later distribution
fallback derives its depth from, so keep it as one named constant rather than
folding it into the Claude entry.
