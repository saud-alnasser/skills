---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "building or testing this project through Gradle"
---

# Reference — Gradle

**This file is yours.** Installed because a Gradle build was detected. Fill the
table from the real task names — `./gradlew tasks` lists them.

## Commands

```sh
./gradlew tasks                          # what this build actually defines
./gradlew build                          # compile + test + checks
./gradlew test
./gradlew :<module>:test                 # one module
./gradlew test --tests "<pattern>"       # one test class or method
./gradlew build --scan                   # detailed report; may upload — check first
./gradlew --stacktrace <task>
```

| Purpose | Command |
| --- | --- |
| build | `./gradlew build` |
| test | `./gradlew test` |
| single test | `./gradlew test --tests "<pattern>"` |

**Use `./gradlew`, not a system `gradle`.** The wrapper pins the version the
build expects; a different one fails in ways that read as build-script errors.

## Up-to-date and cached

Gradle reports tasks as `UP-TO-DATE` or `FROM-CACHE` and skips them. **A green
`./gradlew test` may have run no tests at all.** When the run is the evidence,
check the output or force it (`[[rules/evidence]]`).

## Failure handling

- The first run downloads a toolchain and takes minutes. That is not a hang.
- A daemon holding stale state produces failures that survive a clean build;
  `--no-daemon` diagnoses it.
- `--scan` can publish a report externally. Never run it unasked.
- Never run `publish`, `uploadArchives`, or a release task.
