---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: skill
use-when: "a test needs something replaced, and the question is whether it may be replaced and how"
---

# TDD — what may be replaced, and how

`[[skills/tdd/tests]]` says a test asserts through the caller's interface.
This is the exception that proves it: **some things genuinely cannot be called in
a test**, and the rule for those is narrow.

## Mock at system boundaries. Nothing else.

| Replace | Do not replace |
| --- | --- |
| third-party services you do not control | your own modules |
| time and randomness | internal collaborators |
| the network | anything you could just call |
| the filesystem, sometimes | the database, where a real test instance is available |

The two lines under "sometimes" and "where available" are the same judgement: a
**real** dependency running in the test is better than a stand-in, because a
stand-in can only ever agree with what you believed when you wrote it. Reach for
the real thing when it is cheap enough, and for the stand-in when it is not.

**Mocking your own module is the failure this note exists to prevent.** It
freezes today's internal structure into the suite, so the first refactor breaks
tests that assert no behaviour at all.

## Design so the boundary can be replaced

**Inject the dependency; do not construct it inside.**

```
process(order, payments)                 // the caller supplies it
process(order) { new PaymentClient(...) } // nothing can reach it
```

The second is not merely hard to test — it is hard to *configure*, hard to
retry, and hard to point at a second provider. Testability is the symptom here,
not the reason.

**Give each external operation its own function**, rather than one generic caller
with the operation encoded in its arguments:

```
{ getUser, getOrders, createOrder }      // each independently replaceable
{ request }                              // a replacement needs its own branching
```

The generic shape forces conditional logic *inside the replacement* — a second
implementation of the routing, in test code, which then has to be maintained and
which can disagree with the real one. The specific shape also makes it readable
at a glance which external calls a test actually exercises.

## Before adding a replacement, ask once

*Is this a boundary, or is it just awkward?* Awkward-to-construct internals are a
design finding, not a mocking problem — `[[skills/review]]` has somewhere to put
it. Replacing an internal to avoid dealing with it hides the finding and keeps
the cost.
