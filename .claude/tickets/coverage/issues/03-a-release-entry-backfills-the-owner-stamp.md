---
owner: repository
title: "feat(configure): a release entry backfills the owner stamp"
status: resolved
blocked-by: [01]
part-of: coverage
---

## Problem

Repositories configured by earlier releases hold repository-owned files with no owner declaration, and nothing reaches them: generation passes over files that exist, and no dated repair covers the gap — the crystallize release's entry moved the framework-owned files and the two derived policies only.

## Outcome

The migration changelog carries a frozen entry under the release shipping this effort. An audit on an older repository recognises governed files lacking the declaration by content and stamps each as repository-owned, touching no prose — fields sit beside frozen accounts. Tickets and the per-clone set are exempt, and the entry says what it writes and what it never touches.

## Acceptance

- The changelog gains an entry filed under the new release, recognising its shape by content before acting, so a repository that never had the shape is a no-op.
- After one audit of a repository configured by an earlier release, no governed file lacks an owner declaration, and no frozen prose changed.
- The entry names its exemptions — tickets, the per-clone set — and states that framework-owned files are not its subject.
- The suite asserts the entry exists for the release and was confirmed to fail with the entry removed.
