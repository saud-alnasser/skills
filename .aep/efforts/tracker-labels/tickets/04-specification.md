---
status: resolved
---

# docs(specs): the specification requires an external task to be findable

## Outcome

§15.4 states the requirement normatively, so the implementation conforms to it
rather than the other way round, and the assertions in ticket 06 have something
to be named after.

## Acceptance Criteria

- [x] §15.4 gains the requirement: where tasks live in an external system, the
      effort membership MUST be carried where that system can answer it as a
      query.
- [x] It states **native mechanism before label**, and that an implementation
      MUST NOT create a label for a fact the tracker models itself.
- [x] It restates that this is not mirroring, and why — the existing prohibition
      on duplicating an external ticket system stays exactly as it is.
- [x] The conformance checklist at the end of the document gains the
      corresponding numbered line.
- [x] Nothing in §15.4 makes an external tracker mandatory, and the local-ticket
      paragraph is untouched.

## Relevant areas

`specs.md` §15.4 — the ticketing section, which already says AEP MUST NOT require
a local ticket system and MUST NOT duplicate an external one. The conformance
list near the end of the file — the existing entry 24 covers ticketing.

## Constraints

- `specs.md` is normative and is **not shipped**, so it may cite section numbers
  freely. The payload may not cite it.
- Keep the MUST/MUST NOT idiom of the surrounding text.

## Notes

Independent of tickets 01–03 — this is the normative side and can be written
against the spec's Requirements without waiting for the prose.
