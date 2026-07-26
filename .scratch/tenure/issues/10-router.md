# feat(skills): router over the Tenure skill set

Status: ready-for-agent
Blocked by: 03, 06, 08, 09

## Problem

Tenure's user-invoked skills carry no description, so nothing but the human can reach them — and the human becomes the index. `ask-matt` solves this for matt's set; Tenure needs its own, and cannot reuse that one because the inventory and the flow both changed.

## Outcome

`./skills/<router>/` — user-invoked, replacing `ask-matt`.

Names every skill and when to reach for it, organised by how work actually arrives:

- **Main flow** — `/design` → `/implement` → `/code-review` → `/commit`, with `/research` and `/prototype` as gated detours. `/design` covers spec, tickets, and the foggy multi-session map; there is nothing else to reach for while planning.
- **On-ramps** — `/triage` for incoming issues, `/diagnosing-bugs` for something broken.
- **Knowledge** — `/configure`, once per repository and re-run for the periodic audit. Verification and healing are continuous and have no command.
- **Underneath** — `grilling`, `tdd`, `codebase-design`, `domain-modeling` as the vocabulary and discipline layers.
- **Crossing sessions** — `/handoff` vs `/compact`, and why the smart zone forces the choice.

Document the tier model here too: `max(Floor, Gates)`, chosen after the grill, overridable by the user in either direction.

## Acceptance

- Every skill in `./skills` appears exactly once.
- The router explains *when* to reach for each, not what each contains.
- The router is `/tenure`, reading as "ask the tenured engineer". Spine commands stay bare (`/design`, `/implement`, `/commit`), so the name appears only here and in prose.
