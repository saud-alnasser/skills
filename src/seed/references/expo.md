---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, prototype]
use-when: "running or building this Expo / React Native application"
---

# Reference — Expo

**This file is yours.** Installed because Expo configuration was detected.
Record whether this app runs in Expo Go or needs a development build — most
confusion here comes from that distinction.

## Commands

```sh
npx expo start                   # Metro bundler; long-running, interactive
npx expo start --clear           # clears the Metro cache
npx expo prebuild                # generates ios/ and android/ — overwrites them
npx expo run:ios                 # local native build; requires Xcode
npx expo run:android             # requires the Android SDK
npx expo-doctor                  # checks the environment and dependency versions
eas build --platform <p> --profile <profile>   # remote build; consumes quota
```

| Purpose | Command |
| --- | --- |
| dev | `npx expo start` |
| doctor | `npx expo-doctor` |

## Prebuild overwrites

`expo prebuild` regenerates the native directories from config. **If this
repository commits `ios/` or `android/`, prebuild will discard hand edits made
there.** Check before running it; config plugins are how native changes are
meant to survive.

## Failure handling

- A native module that is not in Expo Go needs a development build. The error
  says the module is missing, which reads like an install problem.
- Stale Metro cache produces errors that describe code you have already changed.
  `--clear` is the diagnosis.
- **`eas build` and `eas submit` run remotely, cost quota, and submit to app
  stores.** Never run either unasked, and never submit.
