---
owner: repository
status: accepted
load-when: a generated index or a fog map needs a path, or `.claude/tickets/map.md` is in question
sources: [.claude/policies/maps.md, specs.md, .claude/tickets/]
supersedes: []
superseded-by: []
---

# A per-effort map lives in its effort's directory; the shared path carries the repository-wide index

A fog map is one per effort — its title is `# map: <effort name>` and its Notes hold that effort's standing preferences — so it belongs at `.claude/tickets/<effort>/map.md`, beside the `spec.md` and `issues/` that same effort already owns. `.claude/tickets/map.md`, which names no effort, carries the **design index**: one row per effort's spec, with the status that says which are live.

The maps policy had assigned the shared path to the per-effort artefact, which is a collision between two fog maps before any index existed — two concurrently mapped efforts would contend for one file. The normative layout in `specs.md` §21 names `spec.md` and `issues/` under each effort and never named the map at all, so the policy was claiming a path the specification had not granted it. Placing an artefact by its scope resolves both: what is per-effort goes in the effort's directory, what spans the repository goes at the root of `tickets/`.

## Considered Options

- **The design index at `.claude/designs/map.md` in every repository**, with rows pointing back at `../tickets/<effort>/spec.md` where specs are partitioned. Rejected: it leaves the map-versus-map collision standing, makes "the index lives beside the specs" false wherever the effort layout is used, and grows a `designs/` directory whose only content is an index — which the no-empty-directories rule sits badly beside.
- **The design index at `.claude/tickets/designs.md`.** Rejected: it collides with nothing and repairs nothing, and it costs the one naming rule a reader can currently rely on — that a generated index is called `map.md`.
- **Leaving the fog map where it is and treating one-map-at-a-time as a constraint.** Rejected: nothing in the maps policy states that constraint, so it would be a limit discovered by whoever hit it rather than one anybody chose.

## Consequences

The shipped `maps.template.md` and the installed `maps.md` both change, so a configured repository holding a map at the old path needs a migration row — mechanical, and of the kind whose risk is a reference left pointing where a file no longer is.

`specs.md` §21 gains both entries, because a layout that named neither is what let the two artefacts arrive at one path without anyone noticing.

The contradiction the `declared-fields` spec recorded as out of scope — that the maps policy forbids listing open tickets on staleness grounds ADR 0053 dissolved for generated files — is **untouched**. This decision places an index over *specs*, which are not tickets; the ban on listing open tickets stands exactly as written, and reopening it remains its own Decision.
