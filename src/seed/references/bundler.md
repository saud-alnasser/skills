---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "installing gems or running this Ruby project's commands"
---

# Reference — Bundler (Ruby)

**This file is yours.** Installed because a `Gemfile` was detected. Fill the
table from the Rakefile, the `bin/` scripts, and CI.

## Commands

```sh
bundle install                   # honours Gemfile.lock
bundle install --deployment      # CI: refuses to change the lock
bundle exec <command>            # runs against the locked gem versions
bundle exec rspec
bundle exec rake -T              # the tasks this repository actually defines
bundle outdated                  # reporting only
```

| Purpose | Command |
| --- | --- |
| install | `bundle install` |
| test | `bundle exec rspec` |
| lint | `bundle exec rubocop` |

**Always `bundle exec`.** Without it a command runs against whatever gem version
happens to be installed globally, which produces failures that do not reproduce
anywhere else.

## Failure handling

- A deployment install failing means `Gemfile` and `Gemfile.lock` disagree. That
  is a finding, not a flag to drop.
- A native extension failing to build is a missing system library, not a Ruby
  problem — the error names the header it wanted.
- `bundle update` moves every gem it can. Updating one gem is
  `bundle update <gem>`, and either is a decision, not a mechanical step.
- **Never `gem push` or `rake release`.**
