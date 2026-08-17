---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test]
use-when: "installing dependencies or running this PHP project's scripts"
---

# Reference — Composer

**This file is yours.** Installed because a `composer.json` was detected. Fill
the table from its `scripts` block and CI.

## Commands

```sh
composer install                          # honours composer.lock
composer install --no-dev                 # production shape; omits test tooling
composer validate --strict                # manifest and lock agree
composer run-script <name>                # see composer.json for what exists
composer dump-autoload -o                 # after moving or adding classes
vendor/bin/phpunit
```

| Purpose | Command |
| --- | --- |
| install | `composer install` |
| test | `vendor/bin/phpunit` |
| lint | `vendor/bin/php-cs-fixer fix --dry-run` |
| static analysis | `vendor/bin/phpstan analyse` |

## Failure handling

- `composer validate` failing means the lock is stale. Running `update` to clear
  it moves every dependency — that is a change, not a fix.
- A class that is not found after being added is usually a stale autoloader or a
  PSR-4 path that does not match the namespace.
- The installed PHP version constrains resolution. A dependency that "cannot be
  installed" is often a platform requirement, and `--ignore-platform-reqs` hides
  a real incompatibility rather than resolving it.
- Adding a dependency is an architectural decision (`[[policies/engineering]]`).
