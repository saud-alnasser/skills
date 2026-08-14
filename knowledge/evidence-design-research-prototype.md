---
owner: framework
type: norm
subject: evidence
fires-when: stage
stages: [design, research, prototype]
spans:
  - evidence-is-the-trail-showing-how-a-claim-was-earned: j2m6sc
  - the-five-kinds: 7g0okj
  - a-kind-exists-when-a-record-declares-it: zrq358
  - read-the-evidence-before-producing-more: hk75ad
  - declared-fields: kn8gy3
  - the-account-itself-is-frozen: 9ws5t8
  - a-drift-finding-records-what-was-checked: rj6qzv
  - drift-is-written-by-whoever-finds-it: 2rv11n
---


# Evidence

## Evidence is the trail showing how a claim was earned

**Evidence is the trail showing how a claim was earned.** It is not a knowledge layer: evidence records what was verified and when, and nothing revalidates it afterwards — Context is maintained against the Codebase, a finding is true of the moment it was taken. That shared property is what earns the five kinds one declared field.

## The five kinds

| Kind | Declares | Produced by |
| --- | --- | --- |
| research findings | `kind: research` | `/research` |
| prototype write-ups | `kind: prototypes` | `/prototype` |
| rejected requests | `kind: out-of-scope` | `/triage` |
| discussions | `kind: discussions` | `/design` |
| drift findings | `kind: drift` | whoever finds the drift |

## A kind exists when a record declares it

- **A kind earns its directory when it has a file** — an empty `prototypes/` is a claim that prototyping happened. The store carries the kind as a field rather than a directory, and the rule is unchanged by the move: a kind nothing declares is a kind nothing claims.

## Read the evidence before producing more

- **Read the directory before producing more** — a finding whose question matches and whose assumptions hold is the answer: cite it and move on; rebuilding a recorded experiment is the waste this rule exists to prevent.

## Declared fields

Every evidence record declares four fields:

```yaml
---
owner: repository
type: evidence
kind: drift
falsifies: [q7m2vk]
---
```

| Field | Holds | Read by |
| --- | --- | --- |
| `owner` | `repository` — a finding is the repository's record | the build |
| `type` | `evidence` — what admits the record to the store | the build, and precedence |
| `kind` | which of the five this is | the query |
| `falsifies` | what the finding contradicts — `[]` where it contradicts nothing | the build, and whoever heals it |

## The account itself is frozen

- **The account itself is frozen** — nothing about what was checked, when, or against which commit moves once a finding is written; the fields and the consumption line sit beside it rather than inside it, because editing the account destroys the only thing it was kept for.

## A drift finding records what was checked

- **A drift finding records what was checked, against which commit, and what it falsifies** — enough that a later reader can re-run the check without reconstructing it.

## Drift is written by whoever finds it

- **Written by whoever finds the drift, on whatever branch they stand on, without interrupting the work that surfaced it.**
