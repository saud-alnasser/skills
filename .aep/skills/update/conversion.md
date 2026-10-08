---
use-when: "converting a 1.x repository's files and fields into the running release's shape, during a 1.x migration"
---

# Update — the 1.x conversion map

Part of `[[skills/update/migration]]`. `<runtime>` is whichever directory 1.x
lived in: `.claude`, `.cursor`, `.codex`.

## Paths

| 1.x | Now | Outcome |
| --- | --- | --- |
| `<runtime>/contexts/<area>.md`, `repository.md` included | `.aep/contexts/<area>.md` | converted; replaces a seeded draft |
| the entrypoint's prose describing the repository | `.aep/contexts/repository.md` | converted |
| the entrypoint file | a pointer to `AGENTS.md` | converted, not optional: rewritten, never deleted |
| `<runtime>/tools/<tool>.md` | `.aep/references/<tool>.md` | converted; wins over a seed |
| `<runtime>/policies/version-control.md`, `tracker.md` | `.aep/rules/version-control.md`, or a reference | converted |
| other `<runtime>/policies/<concern>.md` | a rule, or nothing | see below |
| `<runtime>/rules/<name>.md`, repository-authored | `.aep/rules/<name>.md` | converted |
| `<runtime>/rules/<name>.md`, framework | none | superseded |
| `<runtime>/protocol.md` § Deviations entries | one repository rule each, with reason and release | converted |
| `<runtime>/protocol.md`, the rest | `.aep/protocol.md` | superseded |
| `<runtime>/decisions/NNNN-*.md` | a rule, or left in place | see below |
| `<runtime>/designs/<slug>.md`, `<runtime>/tickets/<effort>/spec.md` | `.aep/efforts/<effort>/spec.md` | converted; both for one effort is a collision |
| `<runtime>/tickets/<effort>/issues/NN-*.md` | `.aep/efforts/<effort>/tickets/NN-*.md` | converted |
| `<runtime>/evidence/research/`, `prototypes/` | `.aep/efforts/<effort>/evidence/…` | converted once an effort is known |
| `<runtime>/evidence/out-of-scope/*.md` | a `[[contexts]]` entry (`[[skills/specify/out-of-scope]]`) | converted |
| `<runtime>/evidence/discussions/*.md` | the spec it concluded into | converted; a conclusion nobody applied is a finding |
| `<runtime>/evidence/drift/*.md` | none | unrepresented |
| `<runtime>/*/map.md`, `modes/*.md`, AEP's `scripts/*` | `.aep/index.md`, the shipped skills and scripts | superseded |
| `<runtime>/scripts/*` serving the repository | where the repository keeps its own | **moved, never claimed** |
| `<runtime>/settings.json` | stays the runtime's | unrepresented |
| `position/`, `worktrees/` | recreated, gitignored | superseded |

**A 1.x policy becomes a rule, never a policy**: it was the repository's;
AEP's are protocol law, replaced on upgrade. Conditional on a trigger: a rule
with that `use-when`. Already stated by a shipped policy or the protocol:
superseded. Repository-specific: a rule.

**A decision record** still governing becomes a rule in the present tense. One
already reflected in code and rules, or plain history, **stays where it is,
outside `.aep/`**, reported with its kind.

**Evidence** goes under the effort that produced it. Where the file names its
effort, or its content plainly belongs to one design, convert it there.
Otherwise **stop on it** and let the human place it; never invent an effort.

## Fields

Only the current contract's fields are written (`[[policies/artifacts]]`):

| Field | From |
| --- | --- |
| `use-when:` | **proposed from the content, marked unconfirmed** |
| `paths:` | carried unchanged |
| `status:` | a spec keeps `draft`, `accepted`, `implemented`, from where its design had got to; a ticket: below |
| `blocked-by:` | carried unchanged |
| `lane:` | `full` on a spec still in flight |

Every other 1.x field (`version:`, `owner:`, `date:`, `kind:`, `mode:`,
`part-of:`, `metadata:`) is dropped.

**Ticket states.** `open`, `resolved`, `obsolete` (keeping its reason) carry.
`blocked` → `open`, with the blocker as a `blocked-by` edge; a `## Blocked`
reason no edge names is a missing edge to add or report. `superseded` →
`obsolete`, its reason naming what replaced it.

**Ticket body.** `title:` becomes the `#` heading; `## Problem` and
`## Outcome` fold into `## Outcome`; `## Acceptance` becomes
`## Acceptance Criteria` (`[[templates/ticket.template]]`).
