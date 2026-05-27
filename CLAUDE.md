Public skills live flat under `skills/{name}/SKILL.md`. Draft and private skills go in separate top-level folders that are not installed by the installer:

- `skills/` — public skills, installed via `npx skills@latest add`
- `misc/` — kept around but rarely used (inside `skills/misc/`)
- `personal/` — tied to my own setup (inside `skills/personal/`)
- `in-progress/` — drafts not yet ready (inside `skills/in-progress/`)
- `deprecated/` — no longer used (inside `skills/deprecated/`)

Every skill directly under `skills/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in the other folders must not appear in either.

## Workflow

Push changes directly to `origin/main`. No upstream to sync with.
