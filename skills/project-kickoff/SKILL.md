---
name: project-kickoff
description: >
  Run this skill at the start of any new project or new feature planning session.
  Conducts a structured interview to capture product scope and technical constraints.
  Researches current stable package versions. Produces two files: ai/PRD.md (product
  context) and ai/CONSTRAINTS.md (technical rules) that feature-planner and task-runner
  reference downstream.
  Trigger phrases: "new project", "start a project", "planning a feature",
  "kickoff", "starting fresh", "new feature planning", "PRD", "constraints".
---

# Project Kickoff

You are helping an experienced full-stack developer (Laravel + React, 12+ years)
capture the right context before any planning or implementation begins.

Your job is to interview them, research versions, get confirmation, and produce
two files: `ai/PRD.md` and `ai/CONSTRAINTS.md`. Do not skip steps or combine phases.

---

## Phase 1 — Interview

Ask ALL of the following questions in a SINGLE message. Do not ask them one at a time.
Keep the message concise. Number each question. Group them under two headings:
**Product** and **Technical**.

**Product**

1. What are you building? (one or two sentences — scope and purpose)
2. Who are the target users and what problem does this solve for them?
3. What are the core features at a high level? (feature names with one-line descriptions)
4. What is explicitly out of scope?
5. What does success look like? (key metric, user goal, or just "it works")
6. Any reference products, mockups, or existing docs? (optional)

**Technical**

7. What is the primary stack? (e.g. Laravel + React, Laravel only, React only, other)
8. Are there any packages you already know you will use beyond the standard stack?
9. Any packages or approaches you want to explicitly avoid?
10. Are there existing codebase patterns I should match? (e.g. existing services, repository layer, test setup, database engine, queue driver)
11. Any hard deadlines, performance constraints, or non-functional requirements?
12. Is this a new project from scratch, or are we adding to an existing one?
13. What command verifies the project is working? (e.g. `php artisan test`, `npm run test && npm run lint`, or "none yet")

Wait for the developer's answers before proceeding.

---

## Phase 2 — Version Research

Based on the answers, identify every major package or framework mentioned.

For each one, use web search to find the current stable major version.
Apply this rule: recommend the latest stable major version ONLY if its initial
stable release was at least 3 months ago. If the latest major version's initial
stable release is newer than 3 months, recommend the previous stable major
version instead.

Research each package separately. Do not rely on training data for version numbers
— always verify with a search.

Examples of what to look up:
- "Laravel latest stable version release date"
- "React latest stable version release date"
- "Filament PHP latest stable version"
- "TanStack Router latest stable version"

---

## Phase 3 — Propose and Confirm

Present your findings in a single message with two sections. The developer needs
to confirm both before you write the files.

```
Product Summary
───────────────
Product: [one-line description]
Users: [who uses it]
Problem: [what it solves]
Out of scope: [what it does not do]
Success: [how we know it works]
References: [any references, or "none"]

Core features:
  [Feature name]
    Scope: [2-3 sentences]
    Dependencies: [feature names, or "None"]
    Priority: [number or level]

  [Feature name]
    Scope: [2-3 sentences]
    Dependencies: [feature names, or "None"]
    Priority: [number or level]

Proposed Stack & Versions
─────────────────────────
[Framework/Package]    v[X]    (latest stable: v[X], released [Month Year])
[Framework/Package]    v[X]    (latest stable: v[X.Y] — skipping, initial release < 3 months)
...

Proposed Conventions
─────────────────────
Language: [TypeScript / PHP 8.x / etc.]
Typing: [strict / standard]
Style: [brief description based on developer's answers]
Patterns: [brief description — e.g. thin controllers, service classes where appropriate]
Abstractions: [minimal — only when there is clear reuse or complexity justification]
Verification: [command from interview, or "not yet defined"]

Assumptions I am making:
- [list any assumptions not confirmed by the developer's answers]

Please confirm, correct, or add anything before I write the files.
```

Wait for confirmation before proceeding.

---

## Phase 4 — Write Files

Generate both files using the templates below. Write `ai/PRD.md` first,
then `ai/CONSTRAINTS.md`.

**If you have filesystem access**, create both files directly.
Create the `ai/` and `ai/plans/` directories if they do not exist.

**If you do not have filesystem access** (e.g. claude.ai), output each file
as a separate copyable markdown code block, clearly labeled. Then tell the developer:

> Save these as `ai/PRD.md` and `ai/CONSTRAINTS.md` in your project root.
> Also create `ai/plans/` — that is where feature-planner writes plan files.

---

### PRD Template

```markdown
# Product Requirements Document
Generated: [date]
Confirmed by developer: yes

## Overview
[What this product is, in 2-3 sentences]

## Problem
[What problem it solves and for whom]

## Target Users
[Who uses this and in what context]

## Core Features

### [Feature name]
**Scope:** [2-3 sentences describing what this feature covers — enough for feature-planner to start an informed interview]
**Dependencies:** [feature names that must be built first, or "None"]
**Priority:** [1 / 2 / 3 ... or high / medium / low]

### [Feature name]
**Scope:** [2-3 sentences]
**Dependencies:** [feature names, or "None"]
**Priority:** [number or level]

## Out of Scope
[What this product explicitly does not do — bullet list]

## Success Criteria
[How we know it is working — metric, user goal, or qualitative measure]

## References
[Similar products, mockups, design docs, or "none"]
```

---

### CONSTRAINTS Template

```markdown
# Project Constraints
Generated: [date]
Confirmed by developer: yes

## Project
[One or two sentence description from interview]

## Stack & Versions

| Package / Framework | Version | Notes |
|---|---|---|
| [name] | [version] | [any relevant note] |

## Language Standards

- **TypeScript**: [strict mode yes/no, no `any` yes/no, explicit return types yes/no]
- **PHP**: [version, strict_types, nullable handling preference]
- **CSS**: [Tailwind / vanilla / other, any conventions]

## Coding Conventions

- Controllers: thin — validation and delegation only, no business logic
- Business logic: service classes when logic is reused or complex; inline otherwise
- Abstractions: only when there is clear justification — no speculative abstraction
- OOP: use traits and service classes when suitable; avoid over-engineering
- Naming: follow framework conventions ([Laravel / React] standard naming)
- File structure: follow framework defaults unless project has existing pattern

## Verification

Command: `[verification command from interview]`
Expected: [brief description of passing state, e.g. "all tests pass", "no lint errors"]

If a plan file specifies its own verification, use that instead for those tasks.

## Explicit Exclusions

[List anything the developer said to avoid]

## Plan File Format

Plan files live in `ai/plans/<feature-name>/`, sorted by filename
(e.g. `01-setup.md`, `02-auth.md`). Each feature gets its own subdirectory.

Tasks use this heading format (H2, bare ID — no brackets):
## Task N.N: Title

When a task is completed, append ` [DONE]` to the heading:
## Task N.N: Title [DONE]
```

---

After writing or outputting both files, confirm to the developer:

> PRD and CONSTRAINTS are ready. Next steps:
> 1. Use feature-planner to create requirements and plan files for your first feature
> 2. Use task-runner to execute them

---

## Rules for This Skill

- Never skip the interview. Even if the developer provides partial context upfront, ask the remaining questions.
- Never use training data for version numbers. Always search.
- Never write files until the developer has confirmed the proposal.
- Keep questions and proposals concise. The developer is experienced — no explanations needed unless asked.
- If the developer corrects anything, update silently and regenerate the proposal. Do not argue.
- Only include Language Standards subsections that are relevant to the project stack. Do not include TypeScript standards for a PHP-only project, or PHP standards for a React-only project.
