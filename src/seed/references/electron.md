---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, prototype]
use-when: "building or running this Electron application, or changing what its renderer may reach"
---

# Reference — Electron

**This file is yours.** Installed because Electron packaging configuration was
detected. Record which packager this repository uses — Forge, Builder, or a
hand-rolled script — since only one of the command sets below will be real.

## Commands

```sh
npm run start                    # or `electron .` — long-running
npx electron-forge start
npx electron-forge package       # unpacked app, no installer
npx electron-forge make          # installers — slow, may sign
npx electron-builder --dir       # unpacked
```

| Purpose | Command |
| --- | --- |
| dev | `npm run start` |
| package | `npm run package` |

## The process boundary is the security model

Main has the operating system; the renderer has untrusted content. The settings
that keep them apart are `contextIsolation`, `sandbox`, and `nodeIntegration`.

**Never turn `contextIsolation` off, or `nodeIntegration` on, to make something
work.** That hands full process access to whatever the renderer loads, and it is
the single change most likely to turn a rendering bug into a remote code
execution path. Expose exactly the calls the renderer needs through a preload
`contextBridge`, and treat every argument crossing it as untrusted.

## Failure handling

- A module that works in main and not in the renderer is the boundary doing its
  job, not a bundler problem.
- A native module failing to load is usually built against the wrong ABI —
  rebuild for Electron's Node version rather than the system one.
- `make` and `build` produce signed, distributable installers. Never run them
  unasked, and never publish.
