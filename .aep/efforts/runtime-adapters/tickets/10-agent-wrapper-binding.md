---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: ticket
status: resolved
part-of: runtime-adapters
blocked-by: [01]
---

# fix(adapters): an agent wrapper sends sub-agents to a file that does not exist

## Outcome

Every agent wrapper points at governance that exists. Today all four say *"Then
read `.aep/rules/sub-agents.md`, which binds you"*, and the distribution ships
nothing in `rules/` — that binding moved into `policies/execution` when
governance split. A sub-agent following the wrapper reads nothing and is bound by
nothing.

## Acceptance Criteria

- [ ] No rendered agent wrapper names `.aep/rules/sub-agents.md`.
- [ ] Each names the artifact that actually binds a sub-agent, and that artifact
      exists in an installed tree — checked against a fixture, not against a
      recollection of where the split landed.
- [ ] The committed Claude adapter is regenerated, and the change to it is the
      only output change in the diff.
- [ ] An assertion pins it: every path a rendered wrapper names resolves in an
      installed tree. This is the guard whose absence let the split break the
      wrappers silently.

## Relevant areas

`src/scripts/adapters.mjs` — the agent wrapper body. `src/adapters/claude/agents/`
— the committed output. `src/policies/execution.md` — where the binding lives now.

## Constraints

- **Found during review of [[efforts/runtime-adapters/tickets/01-target-table]]**,
  which required its own diff to change no output. It is a defect that predates
  this effort.
- The new assertion is the point. Fixing the four files without it leaves the
  next move of a policy free to break them the same way.

## Notes

Gates [[efforts/runtime-adapters/tickets/09-release]]: the release would otherwise
ship the same broken pointer under a new version number. Drop that edge if the
fix should land separately instead.
