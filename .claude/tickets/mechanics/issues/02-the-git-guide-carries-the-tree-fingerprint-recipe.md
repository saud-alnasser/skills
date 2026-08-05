---
title: feat(skills): the git guide carries the tree-fingerprint recipe
status: resolved
blocked-by: [01]
part-of: mechanics
---

## Problem

Nothing documents how to build a fingerprint of a working tree. The git guide covers the drift reads, the review reads, the claim, and the pointer recovery, and stops there — so the marker rule ticket 01 states is unimplementable without someone inventing an invocation, which is the guessed CLI the engineering rules exist to prevent. This was found during the design that produced this effort and recorded as a configuration gap rather than worked around.

The obvious one-command answers are wrong in ways that are not visible from the command line. One of them cannot see untracked files at all, and its usage line is the only place that says so.

## Outcome

The git guide gains an entry for building a working-tree fingerprint: what it is for, the invocation, and the two things about it that are not obvious — that the index it builds into is a throwaway seeded from the repository's own, so the stat cache carries over and the real index is never touched; and that the path to the repository's index is asked for rather than assumed, because a worktree's index is not where a naive path would look.

The entry says what the fingerprint covers — file contents, including untracked files, excluding ignored ones — and states the two rejected alternatives with the reason each fails, so the cheaper-looking invocation is not substituted later by someone who did not know why it was passed over.

Both shell forms are given, because this guide ships to repositories driven from either.

## Acceptance

- The git guide has an entry for the working-tree fingerprint, reachable from the marker rule.
- The entry gives the invocation in both shell forms, and the invocations run as written on this repository.
- The entry states that the index used is a throwaway seeded from the repository's own, and why the seeding matters.
- The entry states that the repository's index path is asked for rather than assumed, and gives the invocation that asks.
- The entry states that the fingerprint covers untracked files and excludes ignored ones.
- The entry states why hashing the status output is unsound and why the stash-based form cannot see untracked files, each with the reason rather than the verdict alone.
- Running the recipe twice against an unchanged tree yields the same value, and against a tree changed by one byte yields a different one.
- Running the recipe leaves the repository's own index byte-identical.
- The suite asserts the entry exists and covers the two unobvious points, and each guard is confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

The sensitivity criterion is asserted with an untracked probe file rather than by editing a
tracked one, so the suite never mutates the working tree it runs in. A literal one-byte append
to a tracked file was checked by hand during the build and moved the fingerprint as expected;
the probe additionally exercises the untracked case, which is the one `git stash create` cannot
see and therefore the one worth having in the suite permanently.
