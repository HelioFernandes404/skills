#!/usr/bin/env bash
# Fetch today's GitHub commits for the authenticated user.
# Usage: ./get-commits.sh [YYYY-MM-DD]

set -euo pipefail

DATE=${1:-$(date +%Y-%m-%d)}
USER=$(gh api user --jq '.login' 2>/dev/null) || { echo "gh auth required" >&2; exit 1; }

gh api \
  "search/commits?q=author:${USER}+committer-date:${DATE}&per_page=100&sort=committer-date&order=desc" \
  --header "Accept: application/vnd.github.cloak-preview" \
  --jq '
    .items[]
    | {
        repo:    .repository.full_name,
        message: (.commit.message | split("\n")[0]),
        sha:     .sha[:7],
        date:    .commit.committer.date
      }
  '
