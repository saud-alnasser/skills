---
use-when: "the .aep/ tree has accumulated stale, contradicted, or orphaned artifacts"
---

# /prune — remove what is no longer true

Finds AEP artifacts that have gone stale, contradict the repository, or point
nowhere — and removes or repairs them. Deleting knowledge is destructive, so
this skill proposes and the human disposes.

**Posture.** Skeptical of the tree rather than of a diff: assume some of what
is written here stopped being true and nobody noticed. **What this gives up**
is the safety of leaving things alone — every proposal here is a proposal to
delete, and the human disposes.

## Procedure

1. **Read the position and the scope, then start from what is mechanically
   broken.**

   ```
   node .aep/scripts/position.mjs check
   node .aep/scripts/scope.mjs read
   ```

   Both quoted, then `node .aep/scripts/validate.mjs`. **Two questions, two
   answers, and never merged:** the marker says whether this surface moved since
   a run last read it, and the scope says which efforts this branch claims and
   what isolation is in force. This skill takes no surface and enters none, so
   the marker it checks here is the surface it works in and the one it stamps at
   step 7.

   A non-empty claim confines this run like any other, and a subject that is the
   whole tree buys no exemption (`[[policies/execution]]`): reaching another
   effort's artifact stops the run and names it, and a tree-wide sweep belongs on
   an unscoped checkout. The claim and the isolation go in `Position`, beside the
   marker's answer and what `validate.mjs` printed (`[[policies/reporting]]`).
2. **Sweep for the five staleness classes:**

   | Class | Test | Default disposition |
   | --- | --- | --- |
   | **broken link** | a wiki link resolving to nothing | **repair** — search for where the concept moved |
   | **contradicted context** | a `contexts/` claim the source falsifies | **repair** — the repository wins |
   | **orphaned effort** | `status: implemented`, no open tasks, nothing references it | keep; it is the record |
   | **abandoned effort** | `status: draft`, untouched for long, superseded | **ask** — draft is not the same as dead |
   | **dead reference** | describes a tool the repository no longer uses | **ask** |
   | **unreachable note** | a file under `.aep/skills/<skill>/` that no skill, rule, or context links to | **repair** — add the link, or ask. Depth nothing reaches is depth nobody has |
   | **empty scaffolding** | `evidence/` or `tickets/` with nothing in them | **remove** |

3. **Verify each candidate against the repository before proposing it.** A
   context is not stale because it is old; it is stale because the code disagrees
   with it. Read the code.
4. **Propose, grouped by class**, each with what it says, why it is a candidate,
   and the evidence.
5. **Apply only what the human approves.**
6. **Regenerate the index.**
7. **Stamp the marker** — `node .aep/scripts/position.mjs stamp --session <id>`,
   passing **the identifier your harness gave this session**. **Never invent
   one:** where the runtime exposes no identifier, drop the flag and stamp as
   before (`[[policies/execution]]`).

   A sweep stamps even where it deleted nothing, because the marker records the
   tree a run **read** and not the tree a run committed, and reading this tree
   end to end is the whole of what this skill does. Stamped last, so what it
   records is the tree the approved removals left behind.

## Constraints

- **Evidence is never pruned for age.** It records what was true when it was
  written and nothing revalidates it — that is what evidence *is*. Prune it only
  when its effort is gone entirely.
- **Never delete an effort's `spec.md`.** An implemented spec is the record of
  why the code looks like this.
- **Never delete an artifact the repository owns without the human's word** —
  anything under `rules/`, `contexts/`, `references/`, or `efforts/`.
- Repair beats removal wherever the artifact still has a subject. A broken link
  usually means something moved, not that the relationship ended.

## Done when

Every mechanical failure is fixed, every staleness candidate has a disposition,
and nothing was deleted that the human did not approve.
