# Editor Templates

Focused reference for the editor-style HTML examples in `examples/09-editors/`.

Read this file only when the request maps to one of these patterns:
- Triage / prioritization editor
- Feature flag / config editor
- Prompt / template tuner

Use the matching HTML file as the final visual reference.

---

## Shared editor traits

- Warm editorial palette: ivory background, white panels, clay and olive accents.
- Typography split: serif headings, sans body copy, mono labels and controls.
- Sticky toolbar near the top.
- Large centered canvas (`max-width` around `1080px` to `1180px`).
- Rounded panels, thin borders, compact controls.
- Export or copy action is part of the main workflow, not an afterthought.

---

## 1. Triage board

**Optional example if available locally:** `18-editor-triage-board.html`

**Use when:**
- The user wants to sort, prioritize, or bucket work items.
- The page should support drag-and-drop between named columns.
- The output needs to be copied back as markdown.

**Layout:**
```text
header
sticky toolbar
4-column board
  each column:
    sticky column header
    count chip
    card stack
    footer with estimate summary
```

**Core content model:**
- Columns: `Now`, `Next`, `Later`, `Cut` or user-specific equivalents.
- Cards carry id, title, tag, estimate, owner.
- Per-column summary shows item count and points.
- Top summary shows counts across all columns.

**Important classes/elements:**
- `.board`, `.col`, `.col-head`, `.col-body`, `.col-foot`
- `.ticket`, `.ticket-top`, `.tid`, `.tag`, `.est`, `.ttitle`, `.owner`
- toolbar buttons for `Reset` and `Copy as markdown`

**Interaction model:**
- HTML5 drag-and-drop using `dragstart`, `dragover`, `drop`, `dragend`.
- Tag click toggles a filter and dims non-matching cards.
- Reset restores initial state.

**Export behavior:**
- Generate markdown grouped by column.
- Include section label, rationale, row count, point total, then bullet items.
- Copy to clipboard with textarea fallback.

**Visual notes:**
- Column meaning is reinforced with border-top color.
- Count pills and estimate chips use mono text and small rounded containers.
- Drag target uses dashed outline and light tinted background.

---

## 2. Feature flag / config editor

**Optional example if available locally:** `19-editor-feature-flags.html`

**Use when:**
- The user wants to toggle flags or settings.
- Dependencies or prerequisites between options matter.
- The page should export either a diff or the resulting full config.

**Layout:**
```text
header
two-column layout
  left: grouped flag sections
  right: sticky sidebar
    pending changes count
    diff preview
    copy diff / copy json / reset
banner above content for dependency warnings
```

**Core content model:**
- Groups contain named flags.
- Each flag has key, description, on/off value, optional rollout, optional prerequisite.
- Sidebar reflects current diff against initial state.

**Important classes/elements:**
- `.layout`, `.form-col`, `.group`, `.group-head`
- `.flag`, `.flag-info`, `.flag-key`, `.flag-desc`, `.req-chip`
- `.toggle`, `.track`
- `.sidebar`, `.side-count`, `.diff`, `.btn-stack`
- `.banner` for prerequisite warnings

**Interaction model:**
- Render form from structured data.
- Checkbox state is the live source of truth.
- Recompute on every `change` event.
- Rows gain `changed` and `warn` decoration based on state.
- Group header metadata updates with counts like `N flags, M on`.

**Export behavior:**
- `Copy diff`: only changed keys with before/after lines.
- `Copy full JSON`: ordered full config payload.
- `Reset`: restore initial checkbox values.
- Clipboard must support a fallback path for local `file://` usage.

**Validation logic:**
- If a flag is on while its prerequisite is off, show row warning and top banner.
- Disable `Copy diff` when nothing changed.

**Visual notes:**
- Warning rows use clay-tinted background and left border.
- Rollout and prerequisite chips are small mono pills.
- Toggle uses a pill track with a white knob and visible focus ring.

---

## 3. Prompt / template tuner

**Optional example if available locally:** `20-editor-prompt-tuner.html`

**Use when:**
- The user wants to edit a prompt or template directly.
- Variable placeholders need live highlighting.
- Multiple sample inputs should preview the rendered result.

**Layout:**
```text
header
sticky toolbar
two columns
  left: editable template panel
    toolbar
    contenteditable editor
    slot legend
  right: live preview panel
    multiple sample cards
footer note about slot behavior
```

**Core content model:**
- Default template text.
- Known slot list such as `{{customer_name}}`.
- Multiple sample records with label, plan badge, and data payload.

**Important classes/elements:**
- `.cols`, `.panel`, `.ed-toolbar`, `.editor`, `.legend`, `.chip`
- `.slot`, `.slot.warn`
- `.preview-panel`, `.sample`, `.sample-head`, `.rendered`
- `.filled`, `.missing`
- counter element for chars and estimated tokens

**Interaction model:**
- Use `contenteditable` as plain-text editor.
- Re-render syntax highlighting after each input while preserving caret position.
- Force plain-text paste.
- Intercept Enter to insert literal newline instead of nested block nodes.
- Render each sample by replacing known slots and marking unknown slots as missing.

**Export behavior:**
- Copy plain prompt text, not highlighted HTML.
- Reset restores the default template.
- Button shows a temporary copied state.

**Highlighting rules:**
- Known placeholders become `.slot`.
- Unknown placeholders become `.slot.warn`.
- Preview uses `.filled` for substituted values and `.missing` for unresolved placeholders.

**Visual notes:**
- Editor and preview are equal-status panels.
- Legend chips mirror placeholder styling.
- Sample cards use compact headers with plan badges and customer names.

---

## Choosing among the editor templates

- Need bucketed prioritization with drag-and-drop: use the triage board.
- Need toggles, dependencies, and config export: use the feature flag editor.
- Need editable text with variable slots and live examples: use the prompt tuner.

If a request mixes concerns, pick the dominant workflow and borrow only the needed interaction from the others.
