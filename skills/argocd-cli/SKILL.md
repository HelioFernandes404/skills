---
name: argocd-cli
description: "ArgoCD CLI skill for GitOps automation via the `argocd` command. Use when running argocd CLI commands for: (1) Login and authentication - connect to ArgoCD server, generate tokens, (2) Applications - create, sync, delete, rollback, wait, get status, (3) ApplicationSets - create/delete via YAML, (4) Projects - RBAC, source/destination restrictions, sync windows, (5) Repositories - add/remove Git repos, Helm charts, OCI registries, (6) Clusters - register, rotate credentials, manage multi-cluster, (7) Accounts - generate tokens, manage users, check permissions. For REST API/curl calls, use argocd skill instead."
---

# ArgoCD CLI Skill

ArgoCD operations via the `argocd` CLI.

## Authentication

```bash
argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PASSWORD
```

Login writes to `~/.argocd/config`. Subsequent commands in the session don't need `--server` or `--auth-token`.

Add `--grpc-web` when connecting through an HTTP proxy or ingress — gRPC is blocked otherwise.

## Applications

```bash
# Create (--upsert makes it idempotent)
argocd app create myapp \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune --self-heal \
  --upsert

# Sync then wait (sync alone is fire-and-forget)
argocd app sync myapp --prune --timeout 300
argocd app wait myapp --health --sync --timeout 300

# Sync specific resource — format is group:kind:name
argocd app sync myapp --resource apps:Deployment:nginx

# Dry run
argocd app sync myapp --dry-run

# Status
argocd app get myapp -o json | jq '{health: .status.health.status, sync: .status.sync.status}'

# Rollback (disables auto-sync — re-enable manually after)
argocd app history myapp
argocd app rollback myapp 2
argocd app set myapp --sync-policy automated

# Delete — --cascade removes k8s resources; without it they stay running
argocd app delete myapp --cascade -y

# Terminate a stuck sync
argocd app terminate-op myapp
```

## ApplicationSets

```bash
argocd appset create appset.yaml --upsert
argocd appset list
argocd appset delete myappset -y
```

## Projects

```bash
argocd proj create myproject \
  -d https://kubernetes.default.svc,default \
  -s https://github.com/org/*

# RBAC — role policy action: get|create|update|delete|sync|override|action
argocd proj role create myproject deployer
argocd proj role add-policy myproject deployer -a sync -p allow -o '*'
argocd proj role add-group myproject deployer my-sso-group
argocd proj role create-token myproject deployer --expires-in 24h

# Sync windows
argocd proj windows add myproject --kind allow --schedule "0 22 * * *" --duration 2h
```

## Repositories

Use HTTPS with a token for most cases:

```bash
argocd repo add https://github.com/org/repo --username git --password $GH_TOKEN --upsert
```

Alternatives:

```bash
# SSH
argocd repo add git@github.com:org/repo.git --ssh-private-key-path ~/.ssh/id_rsa

# Helm chart repo
argocd repo add https://charts.example.com --type helm --name myrepo

# Credential template (applies to all repos under the prefix)
argocd repocreds add https://github.com/myorg/ --username git --password $TOKEN
```

## Accounts

```bash
argocd account generate-token --account cibot --expires-in 7d --id deploy-token
argocd account can-i sync applications '*'
```

## Gotchas

- **`app sync` is fire-and-forget.** Always follow with `app wait` in pipelines — sync exits before k8s converges.
- **`--cascade` is not the default on delete.** Without it, the ArgoCD app record is removed but k8s resources keep running.
- **Rollback disables auto-sync.** After rollback, re-enable with `argocd app set myapp --sync-policy automated`, or ArgoCD won't deploy future commits.
- **`--resource` flag format is `group:kind:name`.** Use `apps:Deployment:nginx`, not `Deployment/nginx`.
- **`--grpc-web` is required through proxies/ingresses.** Plain gRPC is commonly blocked at the network layer in corporate environments.

## Error Handling

```bash
# Idempotent create-or-update
argocd app create myapp --upsert ...
argocd repo add https://repo --upsert ...

# Check before operating
if argocd app get myapp &>/dev/null; then
  argocd app sync myapp
else
  argocd app create myapp ...
fi

# Wait with failure handling
if ! argocd app wait myapp --health --timeout 300; then
  argocd app get myapp
  exit 1
fi
```

Read `references/cli-reference.md` for the full command reference, all flags, and advanced options.
