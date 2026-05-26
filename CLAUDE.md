Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `in-progress/`, and `deprecated/` must not appear in either.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.

## Fork workflow

This repo is used as a personal fork for daily work.

- `origin` points to the personal fork and is used for local changes and pushes.
- `upstream` should point to the original project and is used to receive updates.

Set the upstream remote once:

```bash
git remote add upstream git@github.com:mattpocock/skills.git
```

Update from the original project:

```bash
git fetch upstream
git merge upstream/main
git push origin main
```

Prefer `merge` for daily updates because it is simpler and safer for a personal fork with local customizations. Use `rebase` only when a linear history is explicitly wanted and conflicts are expected to be handled manually.
