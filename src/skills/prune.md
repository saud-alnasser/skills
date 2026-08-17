---
aep: 2.2.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [review]
use-when: "the .aep/ tree has accumulated stale, contradicted, or orphaned artifacts"
---

# /prune — remove what is no longer true

Finds AEP artifacts that have gone stale, contradict the repository, or point
nowhere — and removes or repairs them. Deleting knowledge is destructive, so
this skill proposes and the human disposes.

**Enters `[[modes/review]]`.**

## Procedure

1. `node .aep/scripts/validate.mjs` — start from what is mechanically broken.
2. **Sweep for the five staleness classes:**

   | Class | Test | Default disposition |
   | --- | --- | --- |
   | **broken link** | a wiki link resolving to nothing | **repair** — search for where the concept moved |
   | **contradicted context** | a `contexts/` claim the source falsifies | **repair** — the repository wins |
   | **orphaned effort** | `status: implemented`, no open tasks, nothing references it | keep; it is the record |
   | **abandoned effort** | `status: draft`, untouched for long, superseded | **ask** — draft is not the same as dead |
   | **dead reference** | describes a tool the repository no longer uses | **ask** |
   | **unreachable note** | a file under `skills/<skill>/` that no skill, rule, or context links to | **repair** — add the link, or ask. Depth nothing reaches is depth nobody has |
   | **empty scaffolding** | `evidence/` or `tickets/` with nothing in them | **remove** |

3. **Verify each candidate against the repository before proposing it.** A
   context is not stale because it is old; it is stale because the code disagrees
   with it. Read the code.
4. **Propose, grouped by class**, each with what it says, why it is a candidate,
   and the evidence.
5. Apply only what the human approves.
6. Regenerate the index.

## Constraints

- **Evidence is never pruned for age.** It records what was true when it was
  written and nothing revalidates it — that is what evidence *is*. Prune it only
  when its effort is gone entirely.
- **Never delete an effort's `spec.md`.** An implemented spec is the record of
  why the code looks like this.
- **Never delete a `owner: repository` artifact without the human's word.**
- Repair beats removal wherever the artifact still has a subject. A broken link
  usually means something moved, not that the relationship ended.

## Done when

Every mechanical failure is fixed, every staleness candidate has a disposition,
and nothing was deleted that the human did not approve.
