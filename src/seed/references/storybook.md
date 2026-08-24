---
use-when: "working on a component that has stories, or checking one in isolation"
---

# Reference — Storybook

**This file is yours.** Installed because a `.storybook` directory was detected.
Correct the scripts from `package.json`.

## Commands

```sh
npm run storybook                # dev server; long-running, interactive
npx storybook build              # static build, into storybook-static/
npx test-storybook               # the interaction-test runner, where configured
```

| Purpose | Command |
| --- | --- |
| dev | `npm run storybook` |
| build | `npx storybook build` |

## What it is good for here

A component's stories are the cheapest place to see a UI change without running
the whole application, and they are where a state that is hard to reach in the
app — loading, empty, error — is already set up.

**A story is not a test.** Rendering without throwing proves very little; unless
this repository runs the test-runner, a green Storybook says nothing about
behaviour (`[[policies/engineering]]`).

## Failure handling

- The dev server never exits. In an automated run, build instead.
- A story that renders in the app's dev server but not in Storybook is usually a
  missing decorator — provider, router, or theme — not a broken component.
- Adding a story for a component you changed is usually right. Adding stories
  nobody asked for across the repository is scope (`[[policies/execution]]`).
