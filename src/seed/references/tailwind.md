---
use-when: "styling with Tailwind here, or explaining why a class produced no style"
---

# Reference — Tailwind CSS

**This file is yours.** Installed because a Tailwind configuration was detected.
Record the version and the design tokens this repository actually defines.

## What to read first

The config's `theme` — colours, spacing, fonts — is this repository's design
system. **Use the tokens it defines rather than arbitrary values.** A
`bg-[#3b82f6]` where `bg-primary` exists is a change that leaves the system, and
it is the kind of drift nobody notices until the palette moves.

## The failure that looks like a bug

A class that produces no style is almost always **not present in the scanned
content**. Tailwind only emits what it finds as a literal string, so:

```jsx
className={`text-${color}-500`}     // emits nothing — the class never appears whole
className={color === 'red' ? 'text-red-500' : 'text-blue-500'}   // works
```

Check `content` (v3) or the `@source` directives (v4) before concluding the
class is wrong.

## Verification

Tailwind v3 and v4 configure differently — v4 moves theme configuration into
CSS. **Check the installed major** before editing config; guidance from the
wrong one applies cleanly and does nothing.

## Failure handling

- A style that works in dev and not in the build is usually a purge/content
  path that misses a file the dev server happened to serve.
- `!important` overrides and arbitrary values both work and both hide a
  specificity or ordering problem worth reporting instead.
