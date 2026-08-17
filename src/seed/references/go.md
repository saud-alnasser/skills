---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "building, testing, or vetting this Go module"
---

# Reference — Go

**This file is yours.** Installed because a `go.mod` was detected. Read it for
the module path and the language version.

## Commands

```sh
go build ./...
go test ./...
go test ./<pkg> -run '^TestName$'    # one test; the regex anchors matter
go test ./... -race                  # what CI should run
go test ./... -count=1               # defeats the test cache
go vet ./...
gofmt -l .                           # lists unformatted files; empty is clean
go mod tidy                          # rewrites go.mod and go.sum
```

| Purpose | Command |
| --- | --- |
| build | `go build ./...` |
| test | `go test ./... -race` |
| single test | `go test ./<pkg> -run '^TestName$'` |
| vet | `go vet ./...` |

## The test cache

**A `go test` run can report `(cached)` and execute nothing.** That is correct
behaviour and useless as evidence. Use `-count=1` when the run is the proof
(`[[policies/engineering]]`).

`-race` catches what plain runs do not, and it is where concurrency bugs
actually surface. A suite that passes without it and fails with it has a real
defect, not a flaky test.

## Failure handling

- `go mod tidy` can remove a dependency something still needs at build time
  under a build tag. Check the diff to `go.mod`.
- An unused variable or import is a compile error by design. Deleting the code
  that uses it to make the error go away inverts the diagnosis.
- A test using `t.Parallel()` shares the enclosing state. That is the usual
  source of an order-dependent failure.
- Never publish a module version or push a tag.
