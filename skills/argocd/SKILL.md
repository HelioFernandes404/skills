---
name: argocd
description: "ArgoCD REST API skill for GitOps automation via HTTP/curl. Use when making direct API calls to ArgoCD for: (1) Managing Applications - create, sync, delete, get status via REST, (2) ApplicationSets - spec/generator YAML, (3) Bearer token auth setup, (4) Application Spec YAML reference, (5) Sync options, resource hooks. For argocd CLI commands, use the argocd-cli skill instead."
---

# ArgoCD REST API Skill

ArgoCD operations via REST API with bearer token authentication.

## Authentication Setup

```bash
# Generate token (requires argocd login first — see argocd-cli skill)
ARGOCD_TOKEN=$(argocd account generate-token)

# Or for a service account
ARGOCD_TOKEN=$(argocd account generate-token --account cibot --expires-in 7d)

export ARGOCD_SERVER="argocd.example.com"
export ARGOCD_AUTH_TOKEN="$ARGOCD_TOKEN"
```

Service account setup (in argocd-cm ConfigMap):

```yaml
data:
  accounts.cibot: apiKey,login
  accounts.cibot.enabled: "true"
```

## REST API Pattern

```bash
curl -s -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://$ARGOCD_SERVER/api/v1/{endpoint}"
```

Use `scripts/argocd-api.sh` for common operations.

## API Examples

### Create Application

```bash
curl -X POST -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://$ARGOCD_SERVER/api/v1/applications" \
  -d '{
    "metadata": {"name": "myapp", "namespace": "argocd"},
    "spec": {
      "project": "default",
      "source": {
        "repoURL": "https://github.com/org/repo.git",
        "path": "manifests",
        "targetRevision": "HEAD"
      },
      "destination": {
        "server": "https://kubernetes.default.svc",
        "namespace": "default"
      },
      "syncPolicy": {
        "automated": {"prune": true, "selfHeal": true},
        "syncOptions": ["CreateNamespace=true"]
      }
    }
  }'
```

### Sync Application

```bash
curl -X POST -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  "https://$ARGOCD_SERVER/api/v1/applications/myapp/sync" \
  -d '{"revision": "HEAD", "prune": true, "strategy": {"hook": {}}}'
```

### Poll Sync Status

`POST /sync` returns immediately — poll until complete:

```bash
until curl -s -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  "https://$ARGOCD_SERVER/api/v1/applications/myapp" | \
  jq -e '.status.operationState.phase == "Succeeded"' > /dev/null; do
  sleep 5
done
```

## Application Spec — Non-Obvious Parts

The agent knows standard ArgoCD spec fields. These parts are easy to get wrong:

```yaml
metadata:
  finalizers:
    # Exact string required for cascade delete to work
    - resources-finalizer.argocd.argoproj.io

spec:
  syncPolicy:
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m

  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers: [/spec/replicas]
```

## Resource Hooks and Waves

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"   # lower = runs earlier during sync
    argocd.argoproj.io/hook: PreSync|Sync|PostSync|SyncFail|PostDelete
    argocd.argoproj.io/hook-delete-policy: HookSucceeded|HookFailed|BeforeHookCreation
```

## Gotchas

- **`POST /sync` is fire-and-forget.** It returns before sync finishes. Poll `status.operationState.phase` for `Succeeded` or `Failed`.
- **Always set `namespace: argocd` in metadata.** Omitting it succeeds on create but causes 404 on subsequent GET/sync calls.
- **List endpoint paginates at 100 items.** Check `metadata.continue` in the response and loop until empty to get all apps.
- **`sync-wave` only affects sync order, not health check order.** Resources in wave -1 still wait for health checks from all resources, not just earlier waves.
- **Finalizer string must be exact.** A typo silently skips cascade delete — resources stay running after app deletion.

## Progressive Reference Loading

- Read `references/api-reference.md` when you need complete endpoint docs, query params, pagination details, or error codes.
- Read `references/api-reference.md` for ApplicationSet generator patterns or the full sync option list.
