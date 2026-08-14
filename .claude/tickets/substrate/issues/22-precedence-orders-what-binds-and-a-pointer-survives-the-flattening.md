---
owner: repository
title: "feat(knowledge): precedence orders what binds and a pointer survives the flattening"
status: resolved
blocked-by: [18]
part-of: substrate
---

## Problem

The truth order is six ranks over files. Flattening the corpus into one store removes the
thing those ranks were defined over, so precedence has to be computed from what a record
declares rather than from where its file sits.

Verification at use has the same problem from the other side. A Source Pointer today points
at a file, and a drift finding names a file it falsifies. Neither survives a store where the
addressable thing is a span.

## Outcome

Precedence is computed from a record's type, its store, and its firing condition, and it
orders **only what binds** — a record that describes rather than binds has no rank, because
ranking it would invite a caller to weigh a description against an instruction. Six ranks
collapse to three.

A cross-store conflict is a declared deviation rather than a rank, so it is loud by
construction instead of being silently resolved in someone's favour.

Verification at use survives with its asymmetry intact: a Source Pointer is declared on the
file and overridable per span, while a finding names an id. The asymmetry is deliberate — a
pointer targets the Codebase, which has no ids to name. The Marker's two facts do not move.

## Acceptance

- Two records that bind and could both apply are returned in a stable order, and that order
  is derivable from what each declares.
- A record that describes rather than binds carries no rank, and asking for its rank is
  refused rather than answered with a default.
- A conflict spanning two stores is reported as a declared deviation and appears in every
  audit until it is resolved.
- A finding naming an id that does not exist fails the build, naming the finding.
- A Source Pointer declared on a file applies to every span in it, and a span declaring its
  own overrides that one for that span only.
- A broken Source Pointer is reported as broken, and no run replaces it with a path that was
  not found by searching.
- The Marker's behaviour is unchanged by the flattening, demonstrated against the existing
  cache-validity cases.
