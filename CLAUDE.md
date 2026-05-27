Public skills live flat under `skills/{name}/SKILL.md`. Draft and private skills go in separate top-level folders that are not installed by the installer:

- `skills/` — public skills only, installed via `npx skills@latest add`
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup
- `in-progress/` — drafts not yet ready
- `deprecated/` — no longer used

Every skill directly under `skills/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in the other folders must not appear in either.

## Workflow

Push changes directly to `origin/main`. No upstream to sync with.
