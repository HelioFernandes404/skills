# ArgoCD CLI Reference

Complete command reference for the `argocd` CLI.

## Global Flags

| Flag | Description |
|------|-------------|
| `--server string` | ArgoCD server address |
| `--auth-token string` | Bearer token for authentication |
| `--client-crt string` | Client certificate file |
| `--client-crt-key string` | Client certificate key file |
| `--config string` | Path to ArgoCD config, default `~/.argocd/config` |
| `--core` | Use direct Kubernetes API, no argocd-server |
| `--grpc-web` | Use gRPC-web protocol for proxies or ingress |
| `--grpc-web-root-path string` | gRPC-web root path override |
| `--header strings` | Additional headers, repeatable |
| `--http-retry-max int` | Max HTTP retries |
| `--insecure` | Skip TLS verification |
| `--kube-context string` | Kubernetes context for `--core` mode |
| `--logformat string` | Log format, `text` or `json` |
| `--loglevel string` | Log level, `debug`, `info`, `warn`, or `error` |
| `--plaintext` | Disable TLS |
| `--port-forward` | Connect via port-forward |
| `--port-forward-namespace string` | Namespace for port-forward |
| `--server-crt string` | Server certificate file |

## Authentication Commands

### `argocd login`

```bash
argocd login SERVER [flags]

argocd login argocd.example.com
argocd login argocd.example.com --username admin --password secret
argocd login argocd.example.com --sso
argocd login argocd.example.com --insecure
```

Common flags: `--grpc-web`, `--insecure`, `--name`, `--password`, `--plaintext`, `--skip-test-tls`, `--sso`, `--sso-port`, `--username`.

### Other Auth Commands

```bash
argocd logout SERVER
argocd relogin --sso
argocd context
argocd context myserver
argocd context myserver --delete
```

## Application Commands

### `argocd app create`

```bash
argocd app create myapp \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

argocd app create myapp \
  --repo https://charts.example.com \
  --helm-chart mychart \
  --revision 1.0.0 \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --helm-set image.tag=v1.0.0

argocd app create myapp \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal \
  --sync-option CreateNamespace=true
```

Common flags: `--allow-empty`, `--annotations`, `--auto-prune`, `--dest-name`, `--dest-namespace`, `--dest-server`, `--directory-recurse`, `--file`, `--helm-chart`, `--helm-set`, `--helm-set-file`, `--helm-set-string`, `--helm-version`, `--ignore-missing-value-files`, `--jsonnet-ext-var`, `--kustomize-image`, `--label`, `--path`, `--project`, `--repo`, `--revision`, `--self-heal`, `--set-finalizer`, `--sync-option`, `--sync-policy`, `--upsert`, `--validate`, `--values`.

### Read Applications

```bash
argocd app get myapp
argocd app get myapp -o json
argocd app get myapp -o wide
argocd app get myapp --show-operation
argocd app get myapp --show-params

argocd app list
argocd app list -p myproject
argocd app list -l app=myapp
argocd app list --cluster production
argocd app list -o json
```

### Sync And Wait

```bash
argocd app sync myapp
argocd app sync myapp --prune
argocd app sync myapp --force
argocd app sync myapp --dry-run
argocd app sync myapp --revision v1.0.0
argocd app sync myapp --resource apps:Deployment:nginx
argocd app sync myapp --async
argocd app sync myapp --retry-limit 5 --retry-backoff-duration 5s
argocd app sync myapp --preview-changes

argocd app wait myapp
argocd app wait myapp --health
argocd app wait myapp --sync
argocd app wait myapp --operation
argocd app wait myapp --health --timeout 300
```

Common sync flags: `--apply-out-of-sync-only`, `--async`, `--assumeYes`, `--dry-run`, `--force`, `--info`, `--label`, `--local`, `--preview-changes`, `--prune`, `--replace`, `--resource`, `--retry-limit`, `--revision`, `--server-side`, `--strategy`, `--timeout`.

### Delete, History, Rollback, Diff

```bash
argocd app delete myapp
argocd app delete myapp -y
argocd app delete myapp --cascade=false

argocd app history myapp
argocd app history myapp -o json

argocd app rollback myapp 2
argocd app rollback myapp 2 --dry-run
argocd app rollback myapp 2 --prune

argocd app diff myapp
argocd app diff myapp --revision v1.0.0
argocd app diff myapp --local ./manifests
argocd app diff myapp --exit-code
```

### Logs, Resources, Manifests, Patch, Actions

```bash
argocd app logs myapp
argocd app logs myapp -f
argocd app logs myapp --container nginx
argocd app logs myapp --name nginx-xxx
argocd app logs myapp --tail 100
argocd app logs myapp --since 1h

argocd app resources myapp
argocd app resources myapp -o tree

argocd app manifests myapp
argocd app manifests myapp --source live
argocd app manifests myapp --revision v1.0.0

argocd app patch myapp --patch '{"spec":{"source":{"targetRevision":"v1.0.0"}}}'
argocd app patch myapp --patch-file patch.json

argocd app terminate-op myapp
argocd app actions list myapp --kind Deployment
argocd app actions run myapp restart --kind Deployment --resource-name nginx --namespace default
```

## ApplicationSet Commands

```bash
argocd appset create appset.yaml
argocd appset create appset.yaml --upsert
argocd appset get myappset
argocd appset get myappset -o yaml
argocd appset list
argocd appset list -p myproject
argocd appset delete myappset
argocd appset delete myappset -y
```

## Project Commands

```bash
argocd proj create myproject \
  -d https://kubernetes.default.svc,default \
  -s https://github.com/org/*

argocd proj list
argocd proj list -o json
argocd proj get myproject
argocd proj edit myproject
argocd proj delete myproject

argocd proj add-destination myproject https://kubernetes.default.svc 'team-*'
argocd proj add-destination myproject production default --name
argocd proj remove-destination myproject https://kubernetes.default.svc default
argocd proj add-source myproject 'https://github.com/org/*'
argocd proj remove-source myproject 'https://github.com/org/*'

argocd proj role create myproject developer
argocd proj role delete myproject developer
argocd proj role add-policy myproject developer -a sync -p allow -o '*'
argocd proj role add-group myproject developer team-developers
argocd proj role create-token myproject developer --expires-in 24h
argocd proj role delete-token myproject developer IAT

argocd proj windows add myproject \
  --kind allow \
  --schedule "0 22 * * *" \
  --duration 2h \
  --applications '*'
argocd proj windows list myproject
argocd proj windows delete myproject ID
argocd proj windows update myproject ID
```

## Repository Commands

```bash
argocd repo add https://github.com/org/repo --username git --password $TOKEN
argocd repo add git@github.com:org/repo.git --ssh-private-key-path ~/.ssh/id_rsa
argocd repo add https://github.com/org/repo \
  --github-app-id 12345 \
  --github-app-installation-id 67890 \
  --github-app-private-key-path key.pem
argocd repo add https://charts.example.com --type helm --name stable
argocd repo add registry.example.com --type helm --enable-oci
argocd repo list
argocd repo get REPOURL
argocd repo rm REPOURL

argocd repocreds add https://github.com/myorg/ --username git --password $TOKEN
argocd repocreds add git@github.com:myorg/ --ssh-private-key-path ~/.ssh/id_rsa
argocd repocreds list
argocd repocreds rm URLPREFIX
```

## Cluster Commands

```bash
argocd cluster add my-context
argocd cluster add my-context --name production
argocd cluster add my-context --project myproject
argocd cluster add my-context --namespace default --namespace app
argocd cluster add my-context --label environment=production
argocd cluster list
argocd cluster get https://production.example.com
argocd cluster rm https://production.example.com -y
argocd cluster rotate-auth https://production.example.com
```

## Account Commands

```bash
argocd account list
argocd account get
argocd account get admin
argocd account generate-token
argocd account generate-token --account cibot
argocd account generate-token --account cibot --expires-in 7d
argocd account generate-token --account cibot --id deploy-token
argocd account update-password
argocd account update-password --account admin
argocd account can-i sync applications '*'
argocd account can-i get applications 'myproject/myapp'
argocd account can-i update clusters '*'
argocd account get-user-info
argocd account bcrypt --password PASSWORD
```

## Certificate And GPG Commands

```bash
ssh-keyscan github.com | argocd cert add-ssh --batch
argocd cert add-ssh --from /path/to/known_hosts
argocd cert add-tls cd.example.com --from /path/to/cert.pem
argocd cert list
argocd cert rm HOSTNAME

argocd gpg add --from /path/to/key.asc
argocd gpg list
argocd gpg get KEYID
argocd gpg rm KEYID
```

## Admin And Version Commands

```bash
argocd admin initial-password -n argocd
argocd admin settings rbac validate --policy-file policy.csv
argocd admin settings rbac can role:developer get applications '*/*'
argocd admin cluster generate-spec CONTEXT
argocd admin export > backup.yaml
argocd admin import < backup.yaml
argocd admin notifications template get app-deployed
argocd admin notifications trigger list

argocd version
argocd version --client
argocd version -o json
```
