---
owner: repository
title: "feat(configure): repository-owned formats declare their owner"
status: resolved
blocked-by: []
part-of: coverage
---

## Problem

The formats the framework ships for repository-owned files — the domain context, the decision record, the evidence file, the spec, and the guidance for repository-discovered standards — declare no owner field, while the framework's own repository stamps every such file. The installed decision format says five fields and no others while the flagship's own decision records carry six, so the reference deviates from the law it ships, and a configured repository cannot be told apart from one that predates the owner split.

## Outcome

Every shipped format for a repository-owned file names an explicit repository-owner declaration, the field tables and field counts agree with their own formats, and the installed copies in this repository are byte-identical to their changed templates, each template carrying the new release's stamp.

## Acceptance

- The shipped domain-context, decision, evidence, and spec formats each show the owner declaration in their format blocks, and the decision format's field count matches its no-others claim.
- The guidance for standards discovered in a repository's own tree says each declares repository ownership.
- Every framework-owned template this ticket changes carries the new release's stamp, and the installed copies here match their templates byte-for-byte.
- The suite asserts the formats name the declaration, and each guard was confirmed to fail against a deliberate reintroduction of a format without it.
