---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test]
use-when: "building or testing this .NET solution"
---

# Reference — .NET

**This file is yours.** Installed because .NET build configuration was detected.
Record the solution file and the target framework — `global.json` pins the SDK,
and a mismatch there is the first thing to check on a fresh machine.

## Commands

```sh
dotnet restore
dotnet build --no-restore
dotnet test                                      # builds, then runs every test project
dotnet test --filter "FullyQualifiedName~<name>" # one test or class
dotnet test <project> --logger "console;verbosity=detailed"
dotnet format --verify-no-changes                # reporting; `dotnet format` rewrites
dotnet --info                                    # installed SDKs, for diagnosing the pin
```

| Purpose | Command |
| --- | --- |
| build | `dotnet build` |
| test | `dotnet test` |
| single test | `dotnet test --filter "FullyQualifiedName~<name>"` |
| format check | `dotnet format --verify-no-changes` |

## Failure handling

- An SDK that does not match `global.json` fails before compiling anything, with
  a message about the version rather than about the code.
- `Directory.Build.props` and `Directory.Packages.props` apply to every project
  under them. A setting you cannot find in a `.csproj` usually lives there.
- A warning treated as an error is `TreatWarningsAsErrors`, which is a
  deliberate setting. Suppressing the warning to build is a change to what this
  repository enforces (`[[policies/engineering]]`).
- **Never `dotnet nuget push` or `dotnet publish` to a feed.**
