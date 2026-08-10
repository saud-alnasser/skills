---
owner: framework
---

# Evidence

<!-- Installed by /configure at `.claude/policies/evidence.md`. -->

**Evidence is the trail showing how a claim was earned.** It is not a knowledge layer: evidence records what was verified and when, and nothing revalidates it afterwards — Context is maintained against the Codebase, a finding is true of the moment it was taken. That shared property is what earns the five kinds one grouping directory.

## The five kinds

| Kind | Written to | Produced by |
| --- | --- | --- |
| research findings | `.claude/evidence/research/` | `/research` |
| prototype write-ups | `.claude/evidence/prototypes/` | `/prototype` |
| rejected requests | `.claude/evidence/out-of-scope/` | `/triage` |
| discussions | `.claude/evidence/discussions/` | `/design` |
| drift findings | `.claude/evidence/drift/` | whoever finds the drift |

- **A kind earns its directory when it has a file** — an empty `prototypes/` is a claim that prototyping happened.
- **Read the directory before producing more** — a finding whose question matches and whose assumptions hold is the answer: cite it and move on; rebuilding a recorded experiment is the waste these directories exist to prevent.

## Declared fields, and the one index

Every evidence file declares two fields:

```yaml
---
kind: drift
falsifies: [.claude/policies/tracker.md]
---
```

| Field | Holds | Read by |
| --- | --- | --- |
| `kind` | which of the five this is | the index |
| `falsifies` | what the finding contradicts — `[]` where it contradicts nothing | the index, and whoever heals it |

- **One index at `.claude/evidence/map.md`, spanning all five kinds** — the obligation it serves, *read the directory before producing more*, is cross-kind; a question research answered is not answered again by reading only `research/`. That width is what makes `kind` a column rather than a restatement of the path.
- **Rows sit in filename order — date order — with `kind` breaking ties** — chronology is what a reader of accumulated evidence wants first.
- **The index is generated, never hand-edited** — enforced by regenerating and comparing; a file declaring no fields cannot appear in a regeneration.
- **The account itself is frozen** — nothing about what was checked, when, or against which commit moves once a finding is written; the fields and the consumption line sit beside it rather than inside it, because editing the account destroys the only thing it was kept for.

## Consumption

- **A finding records its own consumption, and the obligation is the `falsifies` field's** — every kind owes it equally, and a finding declaring `falsifies: []` owes nothing, having named nothing to heal.
- **Once the falsified knowledge is healed, the finding carries a `Consumed:` line naming where the healing landed** — without it a healed finding and a waiting one are the same file, re-derived on every later design run by the one stage obliged to read this directory:

```md
Consumed: `.claude/policies/tracker.md`, "What a ticket is" — <effort>/NN
```

- **Whoever heals writes the line, in the same change as the healing** — marked in a later change, there is a window where it reads as waiting.
- **A finding whose consumption cannot be established stays unmarked and reads as waiting** — waiting is the safe direction, and inferring consumption from the healed knowledge is the guess this format exists to prevent.
- **The index carries `waiting` or `consumed` per finding, so a waiting one is seen without opening anything** — no sweep and no second mechanism: a stage already reads this index, and the state is a column on that read.
- **The index reports the line and decides nothing** — it repeats what the finding says about itself and never works out from the healed knowledge whether somebody acted; an unmarked finding shows as waiting.

## Discussions

- **A discussion records the grill that ended without a decision: what was asked, what was assumed, what was weighed, and what stayed open** — and the open half is required, not optional: a discussion with nothing open is a decision that has not been written down yet, and is filed as one instead.
- **A record, dated, never maintained** — kept current it would be a fourth knowledge layer with no rank in the truth hierarchy. Alternatives that produced a decision need no discussion; the Decision carries its considered options.

## Drift findings

- **A drift finding records what was checked, against which commit, and what it falsifies** — enough that a later reader can re-run the check without reconstructing it.
- **Written by whoever finds the drift, on whatever branch they stand on, without interrupting the work that surfaced it.**
- **Where a live design effort owns the area, the finding is indexed on that effort's map** (`.claude/policies/maps.md`); with no live effort it waits here for the next design run over the area. Which drift becomes a finding rather than being healed on the spot is `.claude/policies/knowledge.md`'s to say.
- **Throwaway prototype code is not evidence** — code goes to `.claude/position/prototypes/` and is deleted; the write-up goes to `.claude/evidence/prototypes/` and is kept. Ignoring the code is the intent; ignoring the record of what it proved is silent data loss.

## Gating

- **A gated evidence block stops the design; ungated evidence runs in the background** — gating everything makes the workflow serial for answers nobody was waiting on, and gating nothing builds the plan on an unchecked load-bearing assumption.

## Graduation

- **Durable findings graduate out of evidence into knowledge, and `/design` owns graduation** — how the repository behaves becomes Context, why an approach was chosen becomes a Decision; `/design` read the findings and nothing downstream will.
- **`/research` and `/prototype` never write Context directly** — a research finding is a versioned external fact: copied into Context it lands in a layer that has no version and nothing to re-verify it against. A prototype result is true of the thing that was built, under the constraints it was built with — restated in Context it becomes a claim about the repository, which is not what was demonstrated.
- **A discussion graduates the same way: when its parked question later resolves, `/design` writes the Decision** — the discussion stays where it is as the record of what was weighed.
- **Graduation is a copy of what is durable, never a move** — the evidence stays where it is; deleting it leaves the Context statement with no provenance.
