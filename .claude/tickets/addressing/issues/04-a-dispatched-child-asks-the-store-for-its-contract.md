---
owner: repository
title: "fix(agents): a dispatched child asks the store for its contract rather than opening a file"
status: open
blocked-by: [07]
part-of: addressing
---

## Problem

All five agent definitions open by instructing the child to read a path — *"the contract you
are bound by. Read it before anything else"*. That is the only reference kind in this effort
whose correction changes behaviour rather than wording: after conversion the file is not
there, and a child that cannot obtain its contract is a child bound by nothing while
believing itself bound.

A child inherits the boot tier and none of the conversation, so nothing else in its context
carries the contract, and the brief is not where it belongs — quoting it there would spend
the parent's window on something the child can fetch.

## Outcome

A dispatched child obtains its contract from the store and can tell whether it got it. The
definitions say how, and stop naming a file.

## Acceptance

- No agent definition addresses a store record by location.
- Each definition says how the child obtains its contract, and a child following the
  definition ends holding the contract or knowing that it does not.
- A child that cannot reach the store says so rather than proceeding — an unreachable store
  leaves it degraded rather than silently unbound.
- The posture each definition declares is unchanged, and still resolves.

## Blocked

Blocked because no field named what a record is about, so no filter could name the contract
and a filename is explicitly not an address. `07` adds `subject`, and the query a definition
states becomes `subject=sub-agents`.
