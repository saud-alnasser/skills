---
owner: repository
status: accepted
load-when: something needs to name one record, or a script is about to recover meaning from a filename in the store
sources: [skills/configure/policies/records.template.md, scripts/query-knowledge-store.js, build/verify.js]
supersedes: []
superseded-by: []
---

# A record declares its subject, so a filename never has to be one

The store's declared fields say what a record is, who owns it, and when it fires — never what
it is about. So anything needing one particular record could only filter on `file`, while the
record format says a filename is not an address: an id names a norm rather than a file, which
is what lets files keep readable names and makes a rename free. Every record now declares
`subject`, and the query filters on it like any other field.

The concept was already in use and reconstructed everywhere it was used: a skill declares its
dependencies as bare subjects, the router's column names them, and the build recovered them
by stripping a stage suffix off a filename in more than one place. Three surfaces parsed what
one field can state, and a dispatched child — which does not know what file to look in —
could not parse anything at all.

## Considered Options

- **Citing the record's ids in a dispatched child's brief.** Rejected: it adds no field and
  uses the cross-store citation the query was built for, but a definition read on its own
  still could not say how a child obtains its contract, and that sentence is the thing that
  has to be written down.
- **Filtering on `file`.** Rejected by the format rather than on preference — treating the
  name as the handle is what makes a rename cost something, and the format spends the id to
  buy exactly that freedom.

## Consequences

The two filename conventions in the flat store stop being a hazard and become documentation:
a repository's record keeps whatever readable name it would have had, and a framework stage
norm encodes the stages it serves because the split that produced those files needs the name
checkable against the field. Both were already true; the field is what makes the difference
harmless, because nothing has to read either name to find a record.
