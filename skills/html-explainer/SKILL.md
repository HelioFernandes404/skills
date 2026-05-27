---
name: html-explainer
description: Produce a self-contained, rich HTML file instead of markdown to communicate information with high density, visual clarity, ease of sharing, and two-way interactivity. Use this skill whenever a request benefits from visual layout (comparisons, timelines, charts, slides), code review diffs with annotations, interactive mockups/prototypes with sliders, custom editing tools (triage boards, configs, prompt tuners with copy-to-clipboard buttons), or when synthesizing data from git history, filesystems, and MCP tools. Trigger even if the user does not explicitly request HTML, as a browser-ready HTML artifact outperforms walls of text.
---

# html-explainer

When producing output that has meaningful structure, comparisons, timelines, code explanations, reports, or plans, a self-contained HTML file is almost always better than markdown. Markdown gets skimmed; HTML gets read.

## Why Use HTML?

- **Information Density:** Represent tabular data (tables), design systems (CSS), illustrations (SVG), code snippets, live interactions (JS/CSS), workflows, and spatial data.
- **Visual Clarity:** Organize content visually to be ideal to navigate using tabs, sidebars, sticky layout, illustrations, links, and mobile responsiveness.
- **Ease of Sharing:** Browsers render HTML natively, making outputs easily shareable and readable outside the terminal.
- **Two-way Interactions:** Add sliders, input fields, and knobs to adjust designs/algorithms, paired with "copy as prompt" / "copy as JSON" buttons to close the interaction loop.
- **Context Ingestion:** Leverage filesystem exploration, git history, and MCP tools (Slack, Linear, etc.) to compile rich context directly into reports.

Your job is to:

1. Identify which structural pattern fits the request.
2. Build a complete self-contained HTML using the skill references as the primary guide.
3. Use a matching example HTML file only when it is available in the current environment.
4. Write the file to disk and tell the user where it is.

---

## Choosing the right pattern

Match the request to a structural pattern. Read `references/pattern-catalog.md` before writing the page. That file is the primary routing and structure reference for all patterns.

For editor-style patterns, also read `references/editor-templates.md`. It contains the compact interaction and export rules for those templates.

If the current environment includes an `examples/` directory for this skill, open the closest matching example HTML file after reading the relevant reference files. Treat examples as optional visual companions, not as the only source of instructions.

| Request type | Pattern |
|---|---|
| Compare approaches, options, or designs | **Side-by-side** |
| PR, diff, or code change explanation | **Annotated document** |
| Codebase walkthrough, module relationships | **Module map / diagram** |
| How a feature or concept works | **Feature explainer** (sticky nav, collapsible steps, TL;DR) |
| Implementation or project plan | **Phased plan** (milestones, phases, risk table) |
| Weekly/sprint status | **Status report** (chart, shipped/slipped/next) |
| Incident or post-mortem | **Incident timeline** |
| Slide presentation | **Slide deck** (scroll-snap, arrow-key nav) |
| Design tokens, component states | **Design system / component sheet** |
| Interactive prototype, animation tuning | **Prototype / sandbox** |
| SVG illustrations, iconography, visual figure sheets | **SVG figure sheet** |
| Process flow, deploy pipeline | **Flowchart** (SVG, clickable nodes) |
| Drag/organize/prioritize items | **Triage editor** (with export button) |
| Toggle flags or config | **Flag/config editor** |
| Prompt or template tuning | **Prompt tuner** |

When the request doesn't match cleanly, default to the **Feature explainer** pattern -- it handles most documentation well.

**Optional example file locations** (only if an `examples/` directory is available in the current environment):

| Category | Path |
|---|---|
| Exploration / planning | `examples/01-exploration/` |
| Code review | `examples/02-code-review/` |
| Design | `examples/03-design/` |
| Prototyping | `examples/04-prototyping/` |
| Diagrams | `examples/05-diagrams/` |
| Decks | `examples/06-decks/` |
| Research | `examples/07-research/` |
| Reports | `examples/08-reports/` |
| Editors | `examples/09-editors/` |

---

## HTML construction rules

### Always self-contained

- No external CSS or JS CDN links. Everything inline in `<style>` and `<script>`.
- Fonts: use system stacks. Don't load Google Fonts.
- SVG icons: inline. No icon library imports.

### Structure

Every page needs:

- `<!doctype html>` + `<html lang="en">`
- `<meta charset="utf-8">` and viewport meta
- A descriptive `<title>` derived from the actual content
- Inline CSS based on the selected example
- A clean reset appropriate to that example

### Visual style

- Preserve the native look of the selected example: palette, typography, border weight, radius, spacing, and layout density.
- Adapt class names and content as needed, but do not convert the page to another global design system.
- Keep responsive behavior from the example when it applies.
- Use new styles only when the content requires them.

---

## Patterns with interactive JS

For patterns that need interactivity (slide decks, editors, triage boards):

**Slide deck** -- keyboard nav:

```js
document.addEventListener('keydown', e => {
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown') nextSlide();
  if (e.key === 'ArrowLeft'  || e.key === 'ArrowUp')   prevSlide();
});
```

Use `scroll-snap-type: y mandatory` on `body`, `scroll-snap-align: start` on each `.slide`.

**Editors with export** -- always end with a button that serializes the current state to text the user can paste or commit. The export closes the loop between the HTML artifact and the next step in the user's workflow. Read `references/editor-templates.md` when the chosen pattern is a triage board, feature flag editor, or prompt tuner.

**Collapsible sections** — for explainers with many steps:

```html
<details>
  <summary>Step 3 -- Request hits rate-limit middleware</summary>
  <div class="detail-body">…</div>
</details>
```

Style `summary` with `cursor: pointer`, `padding: 0.5rem 0`, and a marker indicating expand/collapse state.

---

## Use Cases & Real-World Example Prompts

Borrow or adapt these prompts directly when invoking this skill or when drafting HTML responses for the user:

### 1. Specs, Planning & Exploration

- *Onboarding Grid:* "I'm not sure what direction to take the onboarding screen. Generate 6 distinctly different approaches—vary layout, tone, and density—and lay them out as a single HTML file in a grid so I can compare them side by side. Label each with the tradeoff it's making."
- *Plan with Mockups:* "Create a thorough implementation plan in a HTML file, be sure to make some mockups, show data flow and add important code snippets I might want to review. Make it easy to read and digest."

### 2. Code Review & Understanding

- *Interactive PR Review:* "Help me review this PR by creating an HTML artifact that describes it. I'm not very familiar with the streaming/backpressure logic, so focus on that. Render the actual diff with inline margin annotations, color-code findings by severity and whatever else might be needed to convey the concept well."

### 3. Design & Prototypes

- *Animation Tuning:* "I want to prototype a new checkout button, when clicked it does a play animation and then turns purple quickly. Create a HTML file with several sliders and options for me to try different options on this animation, give me a copy button to copy the parameters that worked well."

### 4. Reports, Research & Learning

- *Technical Explainer:* "I don't understand how our rate limiter actually works. Read the relevant code and produce a single HTML explainer page: a diagram of the token-bucket flow, the 3–4 key code snippets annotated, and a "gotchas" section at the bottom. Optimize it for someone reading it once."

### 5. Custom Editing Interfaces

- *Draggable Triage Board:* "I need to reprioritize these 30 Linear tickets. Make me an HTML file with each ticket as a draggable card across Now / Next / Later / Cut columns. Pre-sort them by your best guess. Add a "copy as Markdown" button that exports the final ordering with a one-line rationale per bucket."
- *Form-Based Configuration Editor:* "Here's our feature flag config. Build a form-based editor for it, group flags by area, show dependencies between them, warn me if I enable a flag whose prerequisite is off. Add a "copy diff" button that gives me just the changed keys."
- *Prompt Tuner Sandbox:* "I'm tuning this system prompt. Make a side-by-side editor: editable prompt on the left with the variable slots highlighted, three sample inputs on the right that re-render the filled template live. Add a character/token counter and a copy button."

---

## What to do when the skill triggers

1. Read the user's request carefully — identify the content type and the information they want communicated.
2. Choose the pattern from the table above.
3. Read `references/pattern-catalog.md` for the selected pattern.
4. If the pattern is an editor, read `references/editor-templates.md` too.
5. If an `examples/` directory is available, open the closest matching example HTML file and borrow its visual treatment.
6. Write the complete HTML to a file named descriptively (e.g., `feature-auth-explainer.html`, `week-23-status.html`, `refactor-plan.html`). Save it in the project root or wherever makes sense for the context.
7. Open it in the browser if possible: `xdg-open <filename>.html`
8. Tell the user the filename and what pattern you used.

---

## Quality check before delivering

- [ ] Opens in a browser with no external requests
- [ ] Visual style follows the selected example instead of a separate global theme
- [ ] Title is specific to the actual content, not generic
- [ ] Content is real — populated from the user's actual request, not placeholder Lorem Ipsum
- [ ] Interactive elements (if any) have visible focus styles
- [ ] The page would be useful to someone who has never seen the source markdown
