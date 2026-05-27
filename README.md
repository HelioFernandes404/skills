# Skills

Agent skills for daily engineering work with Claude Code and other coding agents.

## Install

```bash
npx skills@latest add HelioFernandes404/skills
```

## Skills

### Engineering

Skills for daily code work.

- **[argocd](./skills/argocd/SKILL.md)** — ArgoCD REST API skill for GitOps automation via HTTP/curl: create/sync apps, ApplicationSet specs, bearer token auth, sync options, resource hooks.
- **[argocd-cli](./skills/argocd-cli/SKILL.md)** — ArgoCD CLI skill for GitOps automation via the `argocd` command: login, apps, appsets, projects, repos, clusters, accounts.
- **[diagnose](./skills/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](./skills/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[html-explainer](./skills/html-explainer/SKILL.md)** — Produce a self-contained HTML file instead of markdown for high-density visual output: comparisons, timelines, charts, slides, interactive prototypes, custom editing tools.
- **[improve-codebase-architecture](./skills/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[prototype](./skills/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design — either a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route.
- **[setup-matt-pocock-skills](./skills/setup-matt-pocock-skills/SKILL.md)** — Scaffold the per-repo config (issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume.
- **[tdd](./skills/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[triage](./skills/triage/SKILL.md)** — Triage issues through a state machine of triage roles.
- **[to-issues](./skills/to-issues/SKILL.md)** — Break any plan, spec, or PRD into independently-grabbable GitHub issues using vertical slices.
- **[to-prd](./skills/to-prd/SKILL.md)** — Turn the current conversation context into a PRD and submit it as a GitHub issue.
- **[zoom-out](./skills/zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.

### Productivity

General workflow tools, not code-specific.

- **[caveman](./skills/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[write-a-skill](./skills/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.
