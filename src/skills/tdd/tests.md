---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "writing a test and deciding what it should assert, or judging whether an existing test is worth keeping"
---

# TDD — what a good test asserts

`[[skills/tdd]]` has the loop. This is the judgement inside the RED step: *what
should this test actually assert?*

One sentence carries the whole distinction. **A good test fails when the
behaviour breaks and survives every refactor that keeps it; a bad test does the
reverse** — it survives broken behaviour and fails on refactors that changed
nothing.

## Assert through the interface a caller uses

```
create the state a caller would create
call the operation a caller would call
assert on what a caller can observe
```

Nothing in those three lines names an internal collaborator, a private function,
or a storage layer. That is the property to preserve.

Concretely: a checkout test builds a cart, checks out, and asserts the order came
back confirmed. It does **not** assert that the payment client was called with
the cart total — that is the same code written twice, once in the implementation
and once in the test, and it will need editing every time the implementation is
tidied.

## The four failures

**Asserting the implementation.** Mocking an internal collaborator, calling a
private function, or asserting on call counts and ordering. The tell: *the test
breaks under a refactor that changed no behaviour.*

**Verifying out of band.** Calling the operation, then reaching past its interface
— querying the database directly, reading the file it wrote — to check the
result. Read it back **through the interface**: `createUser` then `getUser`. The
out-of-band version passes even when reading back is broken, which is half of
what the feature is.

**The tautology.** The expected value is computed the way the code computes it, so
the test passes by construction and would keep passing if the formula were wrong:

```
expected = items.reduce((sum, i) => sum + i.price, 0)   // the implementation, again
expect(total(items)).toBe(expected)

expect(total([{price: 10}, {price: 5}])).toBe(15)       // an independent literal
```

**A name that describes HOW.** *"checkout calls paymentService.process"* names the
mechanism; *"checkout with a valid cart confirms the order"* names the behaviour.
The name is a good early warning: if it cannot be written without naming an
internal, the assertion is probably about one.

## What to keep per test

One behaviour, one reason to fail. Several assertions about the same behaviour
are fine; several behaviours in one test mean a failure names the test rather
than the fault.

## When a bad test is found

Do not weaken it and do not quietly delete it. Say what it asserts, why that is
an implementation detail, and what replaces it — then replace it in the same
change. **A deleted test with no replacement is a coverage decision, and that is
the human's.**
