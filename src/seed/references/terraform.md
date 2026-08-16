---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, plan, review]
use-when: "reading or changing this repository's infrastructure definitions"
---

# Reference — Terraform

**This file is yours.** Installed because Terraform configuration was detected.
Record where state lives, which workspaces exist, and which of them are real
environments — everything below depends on those answers.

## Commands

```sh
terraform init                   # downloads providers; required after any provider change
terraform validate               # syntax and types; touches no remote state
terraform fmt -check -recursive  # reporting; `terraform fmt` rewrites
terraform plan -out=tfplan       # reads state, changes nothing
terraform show tfplan            # the plan in readable form
terraform workspace list
```

| Purpose | Command |
| --- | --- |
| validate | `terraform validate` |
| plan | `terraform plan` |
| format check | `terraform fmt -check -recursive` |

## Plan, never apply

**`terraform apply` and `terraform destroy` change real infrastructure**, and
`destroy` removes it. Neither is ever run by an agent, on any workspace, for any
reason (`[[rules/version-control]]`).

`plan` is the deliverable: run it, read it, and report what it says. Pay
attention to anything marked **replace** — that is a destroy-and-recreate, and
for a database or a volume it is data loss described in the calm language of a
diff.

State is also mutable: `terraform state rm`, `state mv`, and `import` change
what Terraform believes exists, without touching infrastructure. Those are
recovery operations and belong to the human.

## Failure handling

- A lock left by an interrupted run blocks the next one. Forcing it unlocks a
  run that may still be in flight — never do it unasked.
- A plan showing changes nobody made usually means drift, a provider upgrade, or
  a different workspace than expected. Say which before proposing anything.
- Credentials come from the environment. A plan that "works locally" may be
  reading a different account than CI.
