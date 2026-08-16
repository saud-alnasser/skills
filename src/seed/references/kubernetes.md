---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, plan, review]
use-when: "reading or changing this repository's Kubernetes manifests, charts, or overlays"
---

# Reference — Kubernetes

**This file is yours.** Installed because Kubernetes manifests were detected.
Record which clusters and namespaces exist and which are real environments.

## Check the context before anything

```sh
kubectl config current-context   # which cluster the next command hits
kubectl config get-contexts
```

**Every command below acts on whichever context happens to be current**, and the
output gives no hint which cluster that was. Print the context before acting and
quote it in what you report (`[[rules/evidence]]`).

## Reading and rendering

```sh
kubectl get <kind> -n <namespace>
kubectl describe <kind>/<name> -n <namespace>
kubectl logs <pod> -n <namespace> --tail=100
kubectl diff -f <manifest>               # what applying would change
kubectl apply -f <manifest> --dry-run=server
kubectl kustomize <overlay>              # render, apply nothing
helm template <release> <chart> -f <values>   # render, install nothing
helm diff upgrade <release> <chart>           # where the plugin is installed
```

| Purpose | Command |
| --- | --- |
| render an overlay | `kubectl kustomize <overlay>` |
| render a chart | `helm template <release> <chart>` |
| what would change | `kubectl diff -f <manifest>` |

## Never run

`kubectl apply` without `--dry-run`, `kubectl delete`, `kubectl scale`,
`kubectl rollout restart`, `helm install`, `helm upgrade`, and `helm rollback`
change a running cluster. Rendering and diffing are the deliverable; applying is
the human's (`[[rules/version-control]]`).

## Failure handling

- `CrashLoopBackOff` needs `logs --previous`; the current container has usually
  not started yet.
- `ImagePullBackOff` is registry access or a tag that does not exist, not a
  manifest error.
- A chart that renders and fails to install is usually an admission policy or a
  CRD that is not installed — the rendered output is still correct.
