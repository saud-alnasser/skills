---
owner: framework
type: norm
subject: specs
fires-when: stage
stages: [design, commit]
spans:
  - status: 6pvrxw
  - only-the-status-field-ever-moves: x0obyi
  - implemented-is-set-outside-conversation: i7lpl4
  - status-is-a-field-because-a-stage-writes-it: 92v0mw
  - frozen-reasoning-holds-from-the-moment-it-is-written: n5b5zm
---


# Spec Format

Standard and above. **Where a spec is written differs per repository, and the tracker record declares which** — read the path there rather than assuming one.

## Status

`draft` while the grill is still running, `accepted` when the user approves it and the tickets are cut, `implemented` when a commit completes the last acceptance criterion, `superseded by <path>` when a later spec replaces it, `abandoned` when the work is dropped. A spec that shipped stays on disk — it is the record of why the tickets looked like that.

## Only the status field ever moves

- **Only the status field ever moves.** The reasoning is frozen the moment the spec is accepted: a spec edited afterwards to match what shipped stops being evidence of what was intended, which is the only thing it was kept for. Correct a spec by superseding it, never by rewriting it.

## `implemented` is set outside conversation

- **`implemented` is the one status set outside conversation** — `/commit` writes it, because only the last commit of a change knows every criterion is met.

## Status is a field because a stage writes it

- **It is a field rather than a line because a stage writes it** — a stage that writes by matching running text breaks the first time somebody reflows the paragraph around it, the same reason contexts and decisions declare theirs.

## Frozen reasoning holds from the moment it is written

- **The frozen-reasoning rule holds from the moment it is written**: a reconstruction is corrected by superseding it, never by rewriting.
