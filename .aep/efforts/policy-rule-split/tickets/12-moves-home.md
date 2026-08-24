---
status: resolved
---

# docs(scripts): payload.mjs says what it installs, and now also what it moves

## Outcome

`payload.mjs` describes its own contents accurately, or `MOVES` lives somewhere
that does.

## Acceptance Criteria

- [ ] Either the file header covers release metadata that is not installed, or
      `MOVES` moves to a home whose stated purpose includes it.
- [ ] Whatever is decided, `install.mjs` and `verify.mjs` still read the manifest
      from exactly one place.

## Relevant areas

`src/scripts/payload.mjs` — its header opens *"What a release installs, declared
once."*

## Notes

Raised by review. A move is not a thing a release installs; it is an instruction
about a tree that already exists. The current placement is defensible — both the
installer and the suite read it, and splitting it out would create a second file
they both import for one array — but the header no longer describes the file.

## Resolution — the header, not a move

`MOVES` stays in `payload.mjs`, and the header now says so explicitly: it names
the exception, says a move is an instruction about a tree that already exists
rather than a thing installed, and gives the reason it sits there anyway — two
callers, one release, and no separation worth a second import for one array.

The title changed with it, so the file no longer opens by describing only half of
what it holds.
