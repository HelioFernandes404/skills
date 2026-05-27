---
name: audit-skill
description: Audit an existing SKILL.md against agentskills.io best practices. Use when user wants to review, audit, or improve a skill's quality — checking scope, context efficiency, instruction calibration, and effective patterns. Designed to feed findings into skill-creator for iteration.
---

# Skill Auditor

Audit a `SKILL.md` against agentskills.io best practices and produce structured findings ready for skill-creator iteration.

## Process

1. Ask for the skill path if not provided
2. Read `SKILL.md` and any referenced files in the skill folder
3. Audit against each dimension below
4. Report findings, then ask: *"Want to iterate on this with skill-creator?"*

## Audit Dimensions

### 1. Grounded in real expertise
- Instructions are specific: names actual APIs, schemas, edge cases, conventions
- No generic filler ("handle errors appropriately", "follow best practices")

### 2. Context window efficiency
- Adds what the agent lacks; omits what it already knows
- No over-explanation of common concepts (HTTP, PDFs, migrations, etc.)
- `SKILL.md` under 500 lines / 5 000 tokens
- Large reference material moved to `references/` with conditional load triggers

### 3. Scope coherence
- Covers one coherent unit of work
- Not too narrow (would force multiple skills per task)
- Not too broad (hard to trigger precisely)

### 4. Instruction calibration
- Flexible where variation is acceptable — explains *why* rather than rigid steps
- Prescriptive only for fragile, sequential, or destructive operations
- One clear default per choice; alternatives mentioned briefly, not as equal menus

### 5. Procedures over declarations
- Teaches *how to approach* a class of problems, not *what to produce* for a specific instance
- Reusable method that generalizes across inputs

### 6. Effective patterns (check which are present and warranted)
- **Gotchas** — non-obvious environment-specific facts (wrong field names, soft deletes, misleading endpoints)
- **Output templates** — concrete template when format must be exact
- **Checklists** — step-by-step with checkboxes for workflows with dependencies or gates
- **Validation loops** — agent runs validator, fixes issues, repeats until passing
- **Plan-validate-execute** — for batch/destructive ops: structured plan → validation script → execution

### 7. Progressive disclosure
- Heavy content in separate files under `references/` or `assets/`
- Each external file linked with a conditional trigger, not a generic "see references/"

## Output Format

Report per dimension:

| Dimension | Status | Finding | Fix |
|---|---|---|---|
| Grounded | OK / ⚠ / ✗ | … | … |

End with **Top 3 priority changes** ordered by impact.

Then ask the user whether to hand off to skill-creator for iteration.

## Gotchas

- A skill that passes all dimensions may still not be valuable — if the agent already handles the task without it, the skill adds noise. Flag this if it seems likely.
- Don't penalize brevity. A 20-line skill can be excellent if it's specific and grounded.
- Progressive disclosure is only relevant for skills that legitimately need more content; don't suggest splitting a short skill.
