---
owner: repository
title: "feat(configure): the audit sweeps the whole protocol directory"
status: resolved
blocked-by: [01]
part-of: coverage
---

## Problem

The audit checks a named list of categories, so a committed file outside that list — a repository-discovered rule, a stray loose file, a knowledge file missing its declared fields — sits unexamined indefinitely. The owner-contract re-check reaches only the rules, the modes, the policies, and the protocol file.

## Outcome

An audit run enumerates every committed file under the protocol directory, classifies each by owner and category, verifies it against that category's contract with the computed output quoted, reports any file fitting no category as a finding, and exempts exactly the per-clone set the ignore file defines. Tickets are verified against the tracker policy's contract and keep its fields. This repository passes its own sweep.

## Acceptance

- An audit run on this repository reports coverage of every committed file under the protocol directory, quoting computed output rather than judgement.
- A file fitting no category, and a governed file declaring no owner, are each reported as findings.
- The owner-contract re-check is no longer limited to four categories.
- The per-clone exemptions are named in the sweep, and nothing per-clone is reported as a finding.
- The suite asserts the sweep's presence and shape, and the guard was confirmed to fail against its deliberate removal.

## Comments

Two deviations from this ticket's wording, found at review and corrected in the same effort. The ticket said tickets are verified "against the tracker policy's contract"; the tracker policy declares no ticket fields — the fields are the ticket format policy's, with the tracker policy selecting the form — and the shipped sweep now says so. And the sweep's exemption is narrowed to ticket issue files: a spec or generated index filed beside tickets keeps its own format's contract, which the ticket's wording would have let the directory swallow.

A residual, out of this effort's scope: this repository's own tickets carry `owner: repository` under its whole-tree suite guard, while the shipped ticket format names no such field. Nothing fails — the format makes no no-others claim — but naming `owner` as an optional ticket field, or dropping it here, is a follow-up candidate.