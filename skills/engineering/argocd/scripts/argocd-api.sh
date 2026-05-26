#!/usr/bin/env bash
#
# ArgoCD API Helper Functions
# Usage: source this file or run directly with commands.
#
# Environment variables:
#   ARGOCD_SERVER      - ArgoCD server (required)
#   ARGOCD_AUTH_TOKEN  - Bearer token (required)
#   ARGOCD_INSECURE    - Set to "true" to skip TLS verification

set -euo pipefail

ARGOCD_SERVER="${ARGOCD_SERVER:-}"
ARGOCD_AUTH_TOKEN="${ARGOCD_AUTH_TOKEN:-}"
ARGOCD_INSECURE="${ARGOCD_INSECURE:-false}"

_check_env() {
    if [[ -z "$ARGOCD_SERVER" ]]; then
        echo "Error: ARGOCD_SERVER not set" >&2
        return 1
    fi
    if [[ -z "$ARGOCD_AUTH_TOKEN" ]]; then
        echo "Error: ARGOCD_AUTH_TOKEN not set" >&2
        return 1
    fi
}

_curl_opts() {
    local opts=(-s -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" -H "Content-Type: application/json")
    if [[ "$ARGOCD_INSECURE" == "true" ]]; then
        opts+=(-k)
    fi
    echo "${opts[@]}"
}

argocd_api() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    _check_env

    local url="https://$ARGOCD_SERVER/api/v1$endpoint"
    local opts
    read -ra opts <<< "$(_curl_opts)"

    if [[ -n "$data" ]]; then
        curl "${opts[@]}" -X "$method" "$url" -d "$data"
    else
        curl "${opts[@]}" -X "$method" "$url"
    fi
}

argocd_app_list() {
    local project="${1:-}"
    local endpoint="/applications"
    if [[ -n "$project" ]]; then
        endpoint="/applications?projects=$project"
    fi
    argocd_api GET "$endpoint" | jq -r '.items[]? | "\(.metadata.name)\t\(.status.health.status)\t\(.status.sync.status)"'
}

argocd_app_get() {
    local name="$1"
    argocd_api GET "/applications/$name"
}

argocd_app_status() {
    local name="$1"
    argocd_api GET "/applications/$name" | jq '{
        name: .metadata.name,
        health: .status.health.status,
        sync: .status.sync.status,
        revision: .status.sync.revision,
        operationState: .status.operationState.phase
    }'
}

argocd_app_create() {
    local name="$1"
    local repo="$2"
    local path="$3"
    local dest_server="$4"
    local dest_namespace="$5"
    local project="${6:-default}"

    local payload
    payload=$(cat <<EOF
{
    "metadata": {"name": "$name", "namespace": "argocd"},
    "spec": {
        "project": "$project",
        "source": {
            "repoURL": "$repo",
            "path": "$path",
            "targetRevision": "HEAD"
        },
        "destination": {
            "server": "$dest_server",
            "namespace": "$dest_namespace"
        }
    }
}
EOF
)
    argocd_api POST "/applications" "$payload"
}

argocd_app_create_autosync() {
    local name="$1"
    local repo="$2"
    local path="$3"
    local dest_server="$4"
    local dest_namespace="$5"
    local project="${6:-default}"

    local payload
    payload=$(cat <<EOF
{
    "metadata": {"name": "$name", "namespace": "argocd"},
    "spec": {
        "project": "$project",
        "source": {
            "repoURL": "$repo",
            "path": "$path",
            "targetRevision": "HEAD"
        },
        "destination": {
            "server": "$dest_server",
            "namespace": "$dest_namespace"
        },
        "syncPolicy": {
            "automated": {"prune": true, "selfHeal": true},
            "syncOptions": ["CreateNamespace=true"]
        }
    }
}
EOF
)
    argocd_api POST "/applications?upsert=true" "$payload"
}

argocd_app_sync() {
    local name="$1"
    local revision="${2:-HEAD}"
    local prune="${3:-true}"
    local dry_run="${4:-false}"

    local payload
    payload=$(cat <<EOF
{
    "revision": "$revision",
    "prune": $prune,
    "dryRun": $dry_run,
    "strategy": {"hook": {}}
}
EOF
)
    argocd_api POST "/applications/$name/sync" "$payload"
}

argocd_app_sync_wait() {
    local name="$1"
    local timeout="${2:-300}"
    local start_time end_time

    echo "Syncing application: $name"
    argocd_app_sync "$name" >/dev/null

    echo "Waiting for health (timeout: ${timeout}s)..."
    start_time=$(date +%s)
    end_time=$((start_time + timeout))

    while true; do
        local status health sync
        status=$(argocd_app_status "$name")
        health=$(echo "$status" | jq -r '.health')
        sync=$(echo "$status" | jq -r '.sync')

        echo "  Health: $health, Sync: $sync"

        if [[ "$health" == "Healthy" && "$sync" == "Synced" ]]; then
            echo "Application is healthy and synced!"
            return 0
        fi

        if [[ "$health" == "Degraded" ]]; then
            echo "Application is degraded!" >&2
            return 1
        fi

        if [[ $(date +%s) -gt $end_time ]]; then
            echo "Timeout waiting for application health" >&2
            return 1
        fi

        sleep 5
    done
}

argocd_app_rollback() {
    local name="$1"
    local history_id="$2"
    local payload='{"id": '"$history_id"', "prune": true}'
    argocd_api POST "/applications/$name/rollback" "$payload"
}

argocd_app_delete() {
    local name="$1"
    local cascade="${2:-true}"
    argocd_api DELETE "/applications/$name?cascade=$cascade"
}

argocd_app_terminate() {
    local name="$1"
    argocd_api DELETE "/applications/$name/operation"
}

argocd_app_resources() {
    local name="$1"
    argocd_api GET "/applications/$name/resource-tree" | jq '.nodes[]? | {kind: .kind, name: .name, namespace: .namespace, health: .health.status}'
}

argocd_repo_list() {
    argocd_api GET "/repositories" | jq -r '.items[]? | "\(.repo)\t\(.type)\t\(.connectionState.status)"'
}

argocd_repo_add() {
    local url="$1"
    local username="$2"
    local password="$3"
    local type="${4:-git}"

    local payload
    payload=$(cat <<EOF
{
    "repo": "$url",
    "type": "$type",
    "username": "$username",
    "password": "$password"
}
EOF
)
    argocd_api POST "/repositories?upsert=true" "$payload"
}

argocd_repo_delete() {
    local url="$1"
    local encoded
    encoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$url")
    argocd_api DELETE "/repositories/$encoded"
}

argocd_cluster_list() {
    argocd_api GET "/clusters" | jq -r '.items[]? | "\(.name)\t\(.server)\t\(.connectionState.status)"'
}

argocd_cluster_get() {
    local id="$1"
    local encoded
    encoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$id")
    argocd_api GET "/clusters/$encoded"
}

argocd_proj_list() {
    argocd_api GET "/projects" | jq -r '.items[]? | .metadata.name'
}

argocd_proj_get() {
    local name="$1"
    argocd_api GET "/projects/$name"
}

argocd_whoami() {
    argocd_api GET "/session/userinfo"
}

argocd_can_i() {
    local action="$1"
    local resource="$2"
    local subresource="${3:-*}"
    argocd_api GET "/account/can-i/$resource/$action/$subresource"
}

argocd_version() {
    _check_env
    local opts
    read -ra opts <<< "$(_curl_opts)"
    curl "${opts[@]}" "https://$ARGOCD_SERVER/api/version"
}

argocd_health() {
    _check_env
    local opts
    read -ra opts <<< "$(_curl_opts)"
    if curl "${opts[@]}" -o /dev/null -w "%{http_code}" "https://$ARGOCD_SERVER/api/version" 2>/dev/null | grep -q "200"; then
        echo "ArgoCD API is healthy"
        return 0
    fi

    echo "ArgoCD API is not responding" >&2
    return 1
}

argocd_login() {
    local username="$1"
    local password="$2"

    if [[ -z "$ARGOCD_SERVER" ]]; then
        echo "Error: ARGOCD_SERVER not set" >&2
        return 1
    fi

    local opts=(-s -H "Content-Type: application/json")
    if [[ "$ARGOCD_INSECURE" == "true" ]]; then
        opts+=(-k)
    fi

    local payload='{"username": "'"$username"'", "password": "'"$password"'"}'
    local response token
    response=$(curl "${opts[@]}" -X POST "https://$ARGOCD_SERVER/api/v1/session" -d "$payload")
    token=$(echo "$response" | jq -r '.token // empty')

    if [[ -n "$token" ]]; then
        echo "$token"
    else
        echo "Login failed: $(echo "$response" | jq -r '.message // .error // "Unknown error"')" >&2
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        cat <<EOF
ArgoCD API Helper Script

Usage: $0 <command> [args...]

Environment:
  ARGOCD_SERVER       ArgoCD server address (required)
  ARGOCD_AUTH_TOKEN   Bearer token (required for most commands)
  ARGOCD_INSECURE     Set to "true" to skip TLS verification

Commands:
  app-list [project]
  app-get <name>
  app-status <name>
  app-create <name> <repo> <path> <server> <ns> [project]
  app-create-autosync <name> <repo> <path> <server> <ns> [project]
  app-sync <name> [revision] [prune] [dry_run]
  app-sync-wait <name> [timeout]
  app-rollback <name> <history_id>
  app-delete <name> [cascade]
  app-terminate <name>
  app-resources <name>
  repo-list
  repo-add <url> <username> <password> [type]
  repo-delete <url>
  cluster-list
  cluster-get <name_or_server>
  proj-list
  proj-get <name>
  whoami
  can-i <action> <resource> [subresource]
  version
  health
  login <username> <password>
EOF
        exit 0
    fi

    command="$1"
    shift

    case "$command" in
        app-list) argocd_app_list "$@" ;;
        app-get) argocd_app_get "$@" ;;
        app-status) argocd_app_status "$@" ;;
        app-create) argocd_app_create "$@" ;;
        app-create-autosync) argocd_app_create_autosync "$@" ;;
        app-sync) argocd_app_sync "$@" ;;
        app-sync-wait) argocd_app_sync_wait "$@" ;;
        app-rollback) argocd_app_rollback "$@" ;;
        app-delete) argocd_app_delete "$@" ;;
        app-terminate) argocd_app_terminate "$@" ;;
        app-resources) argocd_app_resources "$@" ;;
        repo-list) argocd_repo_list ;;
        repo-add) argocd_repo_add "$@" ;;
        repo-delete) argocd_repo_delete "$@" ;;
        cluster-list) argocd_cluster_list ;;
        cluster-get) argocd_cluster_get "$@" ;;
        proj-list) argocd_proj_list ;;
        proj-get) argocd_proj_get "$@" ;;
        whoami) argocd_whoami ;;
        can-i) argocd_can_i "$@" ;;
        version) argocd_version ;;
        health) argocd_health ;;
        login) argocd_login "$@" ;;
        *)
            echo "Unknown command: $command" >&2
            exit 1
            ;;
    esac
fi
