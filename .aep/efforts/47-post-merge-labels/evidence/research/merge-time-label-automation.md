---

---

# Question

Can a forge-native automation, firing when a human merges, move the `status:`
label on both the merged change request and its linked issue — on GitHub and on
GitLab — and what does each one need from the repository to do it?

# Sources

| Source | What it is | Read |
| --- | --- | --- |
| GitHub, *Events that trigger workflows* | primary, the platform's own reference | 2026-08-24 |
| GitHub, *Workflow syntax — `permissions`* | primary | 2026-08-24 |
| `actions/labeler` README, `main` | primary, the action's own documentation | 2026-08-24 |
| GitLab, *Merge request pipelines* | primary | 2026-08-24 |
| GitLab, *CI/CD job token* | primary | 2026-08-24 |
| Ten repositories under `~/Documents/workspace` carrying `.github/workflows/labeler.yml` | primary, the artifacts themselves | 2026-08-24 |
| This repository's issue #45 and pull request #46 | primary, observed via `gh` | 2026-08-24 |

# Findings

## GitHub can do it, with no secret to provision

**source.** "To run a workflow when a pull request merges, use the
`pull_request` `closed` event type along with a conditional that checks the
`merged` value of the event" — `if: github.event.pull_request.merged == true`.

**source.** `pull-requests: write` "permits an action to add a label to a pull
request"; `issues: write` is the corresponding scope for issue operations.

**conclusion.** The trigger exists and the two scopes needed are both grantable
to the built-in `GITHUB_TOKEN`. Nothing has to be created, stored, or rotated by
a human for the GitHub half to run.

## The linked issue is reachable, and this was observed rather than read

**observation.** Against this repository's own merged pull request:

```
gh api graphql -f query='… pullRequest(number: 46) { closingIssuesReferences … }'
→ {"number":45,"title":"feat(protocol): AEP 3 …"}
```

**conclusion.** A merge-time job can resolve the effort's issue from the pull
request without parsing the body, so both objects are reachable from the one
event.

## GitLab cannot do it without a token a human provisions

**source.** Merge request pipelines run when you "create a new merge request from
a source branch that has one or more commits", "push a new commit to the source
branch", or run one manually from the Pipelines tab. Merging is not among them.

**source.** `CI_JOB_TOKEN` "can access the `GET /projects/:id/merge_requests`
and `GET /projects/:id/merge_requests/:merge_request_iid` endpoints" — read
only. The documentation notes "an open proposal exists to make permissions more
granular".

**interpretation.** The two halves compound. No pipeline fires at merge, so the
job would have to run on the post-merge push to the default branch and find the
merge request by API; and the token that pipeline is given cannot write to it
anyway.

**conclusion.** A GitLab equivalent needs both a lookup the GitHub version does
not, and a project access token with `api` scope that a human creates and
stores. It is not the same shape of offer, and it is not self-contained.

## There is an established labeler convention on this machine, and AEP does not clash with it

**observation.** Ten repositories under `~/Documents/workspace` carry
`.github/workflows/labeler.yml`: `discord-trengo-integration`, `etg`,
`monkey-lang`, `mudaraj`, `nexuscord`, `nova-lang`, `pl-0`, `rentable`,
`screeps`, `support-app`. Four distinct checksums across the ten, so the shape is
shared and the label sets vary per repository.

**observation.** Every one of them has the same trigger and the same two jobs:

```yaml
on:
  pull_request_target:
    branches: ['*']
```

`actions/labeler@v7` with `sync-labels: true` for file-based labels, and
`mauroalderete/action-assign-labels@v1` reading the conventional-commit type out
of the pull request title.

**observation.** The vocabulary those workflows assign is the vocabulary this
repository's tracker already uses, emoji prefix included: `✨ type: enhancement`,
`💥 flag: breaking changes`, `📦 flag: dependencies`, `📚 type: documentation`.

**interpretation.** Two of the families `[[policies/execution]]` calls derived —
`type:` and part of `flag:` — are already computed by CI in these repositories,
from the same inputs the policy names, and the agent is deriving them a second
time.

**source.** `pull_request_target`'s default activity types are `opened`,
`synchronize`, and `reopened`. `closed` is not among them.

**conclusion.** No existing labeler touches `status:`, and none of them fires at
merge. The gap is unclaimed rather than contested.

## Adding a `status:` label beside `actions/labeler` is safe

**source.** `sync-labels` controls "whether to remove configured labels when they
no longer match. Labels not present in the labeler configuration are never
removed." And: "Other labels, including labels added by users or other
automation, are not rewritten or removed."

**conclusion.** A `status:` label written by AEP or by a merge-time job survives
every subsequent run of the existing file-based labeler. The two can coexist in
one repository, and in one workflow file.

# Conclusion

GitHub can carry the merge-time half with nothing provisioned: one `closed`
trigger, one `merged == true` guard, two token scopes, and the linked issue
resolvable from the pull request. GitLab cannot — no pipeline fires at merge and
the job token is read-only against merge requests — so it needs a human-created
`api`-scoped token, which makes it a materially different offer rather than the
same one twice.

Where a repository already runs a labeler, the merge-time job belongs in that
file rather than beside it, and adding it breaks nothing: `sync-labels` provably
leaves labels outside its own config alone.

# Not checked

- Whether `pull_request_target` grants a **write** token on a pull request from a
  fork. The documentation summary obtained was ambiguous, and it does not bite
  here because an AEP effort branch lives in the repository rather than a fork.
- Bitbucket, Gitea, Forgejo, and Jira. This repository seeds forge references for
  GitHub and GitLab only.
- Whether `mauroalderete/action-assign-labels@v1` is still maintained. The
  question was compatibility, not durability, and no existing workflow is being
  replaced.
- What GitLab's webhook `merge_request` event with `action: merge` could do. It
  needs an endpoint to receive it, which is outside anything a repository file
  can carry.
