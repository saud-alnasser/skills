---
aep: 2.2.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [specify, refine]
use-when: "the words the problem is described in are doing the damage — a fuzzy term, or one word meaning three things"
---

# /domain — sharpen the domain model

A sub-skill. Reached from inside `[[skills/specify]]` and `[[skills/refine]]`
rather than started on its own.

## When the words are the problem

The tells are specific:

- **one word, several meanings** — "order" is a cart, a database row, and a
  fulfilment record, and each part of the conversation means a different one
- **several words, one meaning** — user, account, customer, member
- **a word nobody can define** without giving an example
- **a word the code and the humans use differently**, which is where the next
  bug is
- **an entity that is really a state** — a "pending order" is an order

Each of these produces requirements that look agreed and are not.

## Procedure

1. **Collect the vocabulary actually in use** — from the request, the spec, the
   code, and the humans. Note where they differ; that difference is the finding.
2. **For each contested term, ask for a definition that excludes something.** A
   definition that excludes nothing is a synonym for "thing".
3. **Find the real boundaries.** Where one word covers two concepts, name both.
   Where two words cover one, pick one and say which loses.
4. **Check the model against behaviour**: what can each thing do, what must be
   true of it always, what changes it, and what it cannot be.
5. **Name things after what they are to the domain**, never after their technical
   shape. `OrderRepository` describes storage; `Orders` describes the domain.
6. **Write the vocabulary down** — into the effort's `spec.md` while it is being
   settled, and into `[[contexts]]` once it is stable and outlives the effort.

## Constraints

- **Use the domain's word, not a better one you invented.** A model the humans do
  not recognise is a translation layer everyone pays for forever.
- Distinguish what the domain requires from what today's implementation happens
  to do. The second is not a constraint on the model.
- **A term stays in the spec until it is stable.** Promoting a still-moving word
  into `contexts/` makes the whole repository chase it.
- Do not build a taxonomy. Model what the change needs and stop.

## Done when

Every term in the spec means exactly one thing, each is defined by what it
excludes, and the humans recognise the words as theirs.
