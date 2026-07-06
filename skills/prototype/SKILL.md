---
name: prototype
description: >
  Builds a static interactive HTML prototype of a product before feature planning begins.
  Use this skill whenever the developer wants to prototype, visualise, or validate their
  product's UI and features after running project-kickoff. Also triggers when they say
  "build the prototype", "let's prototype", "show me what this looks like", "visual
  mockup", "interactive prototype", or "start prototyping". Covers the full workflow:
  brand interview → skeleton confirmation → navigation build → iterative screen filling
  → PRD sync → blueprint generation. Always use this skill rather than improvising when
  prototype work is involved — it ensures blueprint.md stays in sync with index.html,
  which downstream skills depend on.
---

# Prototype Skill

Builds a single-file static interactive HTML prototype of the entire product. Sits
between project-kickoff and feature-planner in the development workflow. Its job is to
let the developer visually validate and refine features before committing to detailed
plans. Covers roughly 80% of features with simulated interactions — no backend, no
persistent state.

## Inputs and Outputs

**Reads:**
- `ai/PRD.md` — product scope and feature list (required)
- `ai/CONSTRAINTS.md` — any UI-relevant constraints (optional)
- Developer-provided sketches if available (PNG/JPG/Excalidraw/Figma)

**Writes:**
- `ai/prototype/index.html` — the visual prototype
- `ai/prototype/blueprint.md` — machine-readable structure for feature-planner

**May update:**
- `ai/PRD.md` — when features change, split, or emerge during prototyping

## Tech Stack

Single HTML file. No build step. No backend. No persistent state.

- **Alpine.js** via CDN — navigation, modals, tabs, toggles, form states
- **Tailwind CSS** via CDN — all styling, responsive layout
- No other dependencies. No localStorage. No cookies.

---

## Phases

Work through these phases in order. Each phase ends with developer confirmation before
moving to the next. Exception: in autonomous mode (see AGENTS.md), proceed
through the phases without waiting — build all screens in sequence and note
the assumptions made in the delivery message and the blueprint.md header.

### Phase 1 — Read PRD

Read `ai/PRD.md`. If it doesn't exist, stop: "Run project-kickoff first to create PRD.md".

Also read `ai/CONSTRAINTS.md` if it exists. Note any UI-relevant constraints (design
system, accessibility, supported devices, etc.).

If the developer has provided sketches, examine them alongside the PRD for layout
direction.

If PRD has no features listed, warn the developer and proceed based on the interview
alone.

### Phase 2 — Brand and Style Interview

Ask all of these in a single message — keep it short, 4–6 questions max:

- What's the brand feel? (e.g., professional/corporate, modern/minimal, playful, technical)
- Any color preferences? Primary color, dark/light theme, existing brand colors?
- Any reference products or sites they like the look of?
- Preferred navigation pattern? (sidebar, top nav, or both)
- Any UI patterns they specifically want or want to avoid? (cards vs tables, etc.)

This is a prototype, not final design — don't over-engineer this interview.

### Phase 3 — Confirm Skeleton Layout

Based on the PRD features and the style interview, propose:

- Navigation pattern (sidebar / top nav / both)
- Complete screen list derived from PRD features
- Layout structure for the main content area

Present this as a brief outline. Wait for the developer to confirm or adjust before building
anything.

### Phase 4 — Build Navigation Skeleton

Build `ai/prototype/index.html` with:

- Full navigation structure (all screens in the confirmed screen list)
- Brand styling applied — colors, type feel from the style interview
- Alpine.js `x-data` on the root element with a `page` variable controlling screen visibility
- Each screen body is a placeholder: screen name as heading + one-line description
- Shared components in place: header, sidebar/nav, footer if applicable

Deliver the file. Let the developer review before filling in any screens.

After the developer accepts the skeleton, generate the initial
`ai/prototype/blueprint.md` (see Blueprint section below for timing rules).

### Phase 5 — Fill Screens (Iterative)

Fill screens one at a time. For each screen:

1. Re-read the relevant feature entry in `ai/PRD.md` for context
2. Build realistic UI with representative sample/mock data — make it look real, not lorem ipsum
3. Add Alpine.js interactions: modals, tabs, toggles, form states, inline validation states
4. Use Tailwind for responsive layout

Deliver each screen and wait for feedback before moving to the next. This is the phase
where features get refined — the developer may say "split this into two screens", "add a
filter bar", "remove this section", or "add a feature we didn't plan". That's expected and
welcome.

Regenerate `ai/prototype/blueprint.md` at the sync points defined in the
Blueprint section (session end, all requested screens accepted, on request,
or before feature-planner runs) — not after every screen tweak.

### Phase 6 — Update PRD (When Needed)

When prototyping reveals changes to features — features added, removed, split, or modified —
update `ai/PRD.md` to stay in sync with what was actually prototyped. The developer will
usually ask for this, but flag it proactively when you notice drift between the prototype
and the PRD.

---

## Blueprint — MANDATORY

**`ai/prototype/blueprint.md` must be regenerated before anything downstream
reads it — but NOT after every individual change.** Rewriting the blueprint on
each screen tweak wastes tokens on versions nobody reads.

Regenerate the blueprint when any of these happen:

- The working session ends or the developer pauses
- All screens requested in this session have been accepted
- The developer asks for it
- Work is about to hand off to feature-planner

During rapid iteration on a screen, skip regeneration and continue.

Safety net: feature-planner checks whether `index.html` is newer than
`blueprint.md` and regenerates it before planning, so a missed regeneration
is recoverable — but do not rely on that as the normal path.

To generate it:
1. Read the current `index.html`
2. Parse `x-data` to identify Alpine state variables and which values represent screens
3. Parse `x-show` / `x-if` directives to map state values to screen sections
4. Parse component structure within each screen
5. Parse `@click` / `x-on:click` directives to identify interactions
6. Write `blueprint.md` in the format below

### Blueprint Format

```markdown
# Prototype Blueprint
Generated: [date]

## Navigation Structure
- [Navigation pattern: sidebar / top nav / tabs / etc.]
- [List of main navigation items and what screen they lead to]

## Screens

### Screen: [Name]
**Route/State:** x-show="page === '[value]'"
**Components:**
- [Component name and description, with counts where relevant]
- [Another component]
**Interactions:**
- [Trigger] → [Result]
- [Trigger] → [Result]

[Repeat for each screen]

## Modals
- **[Modal name]:** [What it contains / when it appears]

## Shared Components
- **[Component name]:** [Description]
```

The blueprint captures: what screens exist, what's on each screen, how screens connect,
and what interactions are available. It does NOT include Tailwind classes, styling details,
or implementation specifics.

---

## Edge Cases

| Situation | Behaviour |
|---|---|
| No PRD.md | Stop: "Run project-kickoff first to create PRD.md" |
| PRD has no features | Warn and proceed — base prototype on style interview |
| Developer provides sketches | Examine alongside PRD to inform layout and screen design |
| Developer changes a screen after it's built | Modify the screen; regenerate blueprint.md at the next sync point (see Blueprint section) |
| Developer adds a feature not in PRD | Build it in the prototype, update PRD.md to include it |
| Developer removes a feature from PRD | Remove from prototype, update PRD.md |
| Prototype already exists (re-running) | Read existing index.html and blueprint.md, continue from current state |

---

## What This Skill Does NOT Do

- Does not produce production code
- Does not use backend or API calls
- Does not persist state (no localStorage, no cookies)
- Does not use build tools or package managers
- Does not produce multiple HTML files
- Does not handle authentication or real sessions
