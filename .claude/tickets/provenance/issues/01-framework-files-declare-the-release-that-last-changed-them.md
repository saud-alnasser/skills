---
owner: repository
title: 'feat(configure): framework-owned files declare the release that last changed them'
status: resolved
blocked-by: []
part-of: provenance
---

## Problem

A reader of an installed framework-owned file cannot tell when its content last
moved without archaeology in the repository that builds the workflow. The
installation-level version field answers which release configured the
repository, never which release last touched the file being read.

## Outcome

Every framework-owned template declares `version` in frontmatter — the release
in which that file's content last changed — and the stamp flows into installed
copies through the existing byte-lock. Initial values are recovered from
history rather than stamped uniformly, so no file claims to have just changed
when it did not. The router's section on its release field distinguishes the
two version facts that meet there, and the audit's documented procedure states
that the stamp routes attention while the content comparison runs regardless.

## Acceptance

- Opening any installed framework-owned file shows which release last changed
  it, in frontmatter, beside its owner declaration.
- Each stamp's value matches what history shows for that file, following
  renames; none simply restates the current release unless the file genuinely
  changed since the last one.
- The suite fails when a framework-owned template lacks the field.
- The byte-lock between each template and its installed copy still holds.
- The router distinguishes the configured-at release from the file's own stamp
  where both appear.
- The audit's documented procedure says the stamp never settles what the
  content comparison checks.
- The full suite passes.

## Comments

**Recovery yielded one value everywhere, and that is what history shows.** The
norm-form conversion that landed after the 1.16.0 release rewrote every
framework-owned template — all twenty appear in that commit's stat — so each
file's content genuinely last changed in unreleased 1.18.0, and the uniform
stamp is the recovered fact rather than the shortcut the acceptance forbids.
The distinction starts doing visible work at the first release that ships
without touching every template.
