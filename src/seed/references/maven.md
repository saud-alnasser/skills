---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "building or testing this project through Maven"
---

# Reference — Maven

**This file is yours.** Installed because a `pom.xml` was detected. Read it for
the modules and the active profiles — both change what a command covers.

## Commands

```sh
./mvnw verify                            # compile, test, and run the checks
./mvnw test
./mvnw -Dtest=<Class>#<method> test      # one test
./mvnw -pl <module> -am test             # one module and what it depends on
./mvnw -o verify                         # offline, once dependencies are cached
./mvnw dependency:tree                   # where a version actually comes from
```

| Purpose | Command |
| --- | --- |
| build | `./mvnw verify` |
| test | `./mvnw test` |
| single test | `./mvnw -Dtest=<Class> test` |

**Use `./mvnw` where the wrapper exists.** It pins the Maven version the build
was written against.

## Phases

Maven runs every phase up to the one named. `verify` includes `test`; `install`
also writes to the local repository, and `deploy` reaches a remote one.

**Never run `deploy` or `release:*`.** `install` is usually unnecessary and can
mask a dependency problem by resolving from a locally installed artifact.

## Failure handling

- A dependency resolving to an unexpected version is a transitive conflict;
  `dependency:tree` shows the path, and that is what to report.
- A test passing in the IDE and failing under Maven is usually resource
  filtering or a profile that only one of them activates.
- `-DskipTests` produces a build that proves nothing. Never use it to reach a
  green result.
