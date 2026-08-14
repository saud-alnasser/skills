---
owner: framework
type: norm
subject: tickets
fires-when: stage
stages: [implement]
spans:
  - there-is-no-claimed-state: zfkaj1
  - assignment-is-a-tracker-fact-and-it-is-theirs: 5t6nne
  - assignment-is-not-the-claim: hqzgiw
---


# Tickets

Every `/design` run leaves at least one ticket, numbered from `01` in dependency order — blockers first.

## There is no `claimed` state

**There is no `claimed` state, and a tracker never records one.** Which instance is building a ticket right now is agent-level bookkeeping on a surface reserved for human-level facts, and a status written into a file cannot stop two instances writing it at the same moment. The Claim is the ticket's branch; `/implement` owns it and states the naming.

## Assignment is a tracker fact and it is theirs

- **Assignment — which human owns delivering a ticket — is a tracker fact, and it is theirs**, set by people in the tracker's own way; AEP reads it and never writes it unasked.

## Assignment is not the Claim

- **It is not the Claim and does not overlap it.** Assignment separates humans, so the Claim only ever arbitrates between one person's own instances — the small problem a branch is enough to solve.
