---
name: standup
description: Write a short daily summary of what you did based on today's GitHub commits. Use when user asks what they did today, wants a standup note, daily log, or end-of-day summary.
---

# Standup

Write a concise daily summary from GitHub commits. Keep it short — 3–7 bullets max, no filler.

## Get today's commits

**If `search_commits` MCP tool is available in context**, call it with:
- `q`: `author:USERNAME committer-date:YYYY-MM-DD`
- Use today's date and the authenticated user's login

**Otherwise**, run the bundled script:
```bash
bash scripts/get-commits.sh          # today
bash scripts/get-commits.sh 2025-01-15  # specific date
```

Output: one JSON object per line — `repo`, `message`, `sha`, `date`.

## Write the summary

Group commits by repo. Distill each group into one bullet:

```
**YYYY-MM-DD**

- **repo-name**: what was done
- **repo-name**: what was done
```

Rules:
- Past tense, imperative voice (`added`, `fixed`, `refactored`)
- No intro, no "here is your summary", no trailing commentary

## Gotchas

- `gh api search/commits` requires `Accept: application/vnd.github.cloak-preview` header or returns 422 — the script already includes it, but if calling the API directly, always add this header.
- The search index lags ~30s; very recent commits may not appear immediately.
