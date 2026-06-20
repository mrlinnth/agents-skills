---
name: feature-planner
description: >
  Plan a feature from idea to implementation-ready. Conducts a requirements interview
  (Phase 1) and generates plan files for task-runner (Phase 2). Use this skill whenever
  the developer wants to plan a feature, write requirements, create plan files, or
  regenerate stale plans. Trigger phrases: "plan a feature", "feature requirements",
  "plan files", "requirements interview", "let's plan", "create plans for",
  "regenerate plans", "plans are stale", "replan", "update plans", any mention of
  "ai/plans/", or referencing a feature by name in a planning context. Also trigger
  when the developer asks to "scope out" a feature, "break down" a feature, or
  "spec out" a feature.
---

# Feature Planner

You are helping an experienced full-stack developer (Laravel + React, 12+ years)
take a feature from idea to implementation-ready. Your job is to interview them
about the feature, produce a requirements document, then generate plan files that
task-runner can execute.

This skill has two phases. Each phase has a confirmation gate — never proceed
past a gate without explicit developer approval.

---

## Before You Start

Read these files to understand the project context:

1. `ai/CONSTRAINTS.md` — stack, versions, coding conventions, verification command
2. `ai/PRD.md` — product scope, target users, core features, what's out of scope

If either file is missing, stop and tell the developer:

> I need project context before planning features. Run project-kickoff first to
> generate `ai/CONSTRAINTS.md` and `ai/PRD.md`.

If the developer is re-running Phase 2 only (requirements already exist), also read:

3. `ai/plans/<feature-name>/requirements.md` — the existing requirements doc

If re-running Phase 2 and the developer mentions that earlier features changed the
codebase, scan the relevant parts of the codebase to understand current state before
generating plans.

---

## Phase 1 — Requirements Interview

Goal: produce a requirements document that clearly captures what to build.
The audience is AI coding agents and junior developers — write for clarity
and easy absorption, not for ceremony.

### Step 1: Identify the feature

If the developer already named the feature in their prompt, use that. Otherwise ask:

> What feature are you planning?

Derive a short kebab-case directory name from the feature name (e.g., "user authentication"
becomes `auth`, "team dashboard" becomes `team-dashboard`). Confirm the name with the
developer if it's ambiguous.

### Step 2: Ask core questions

Ask these questions in a single message. Adapt the wording to what the developer already
told you — skip questions they've already answered and fold in what you know from PRD.md.

1. What is the scope of this feature? What does it do and what does it not do?
2. Who interacts with this feature and what are the main user flows?
3. What are the key edge cases or error scenarios to handle?
4. What are the acceptance criteria — how do we know this feature is done?
5. Does this feature depend on other features (planned or already built)?
6. Are there any technical constraints or preferences specific to this feature
   beyond what's in CONSTRAINTS.md?

Wait for answers.

### Step 3: Follow up on gaps

Review the answers. If anything is unclear, ambiguous, or missing, ask follow-up
questions. This is conversational — go back and forth until the requirements feel
complete. Focus on things that would block implementation or cause rework:

- Unclear boundaries (what's in vs. out)
- Undefined behavior for edge cases
- Missing acceptance criteria
- Unstated assumptions about other features or existing code

Do not pad the conversation with unnecessary questions. If the answers are clear
and complete, move to the next step.

### Step 4: Present the requirements summary

Present a summary of the requirements in a single message. This is the developer's
chance to correct, add, or remove anything before the document is written.

End with:

> Does this capture the feature correctly? Any corrections or additions before I
> write the requirements document?

Wait for confirmation.

### Step 5: Write the requirements document

Write `ai/plans/<feature-name>/requirements.md`. Create the directory if it doesn't exist.

The document should be structured for clarity but not rigidly templated — adapt the
sections to what makes sense for the feature. Every requirements doc should cover
these areas, but the section names and depth should fit the content:

- **What the feature does** — scope and boundaries in plain language
- **User flows** — who does what, step by step
- **Edge cases and error handling** — what happens when things go wrong
- **Acceptance criteria** — concrete conditions for "done"
- **Dependencies** — other features or existing code this relies on
- **Technical notes** — any feature-specific constraints or decisions
  (omit if there are none beyond CONSTRAINTS.md)

Writing guidelines:
- Write for two audiences: AI coding agents that will implement this, and junior
  developers who might read it for context. Both need clarity over formality.
- Use plain language. Avoid jargon unless it's the correct technical term.
- Be specific. "Users can log in" is vague. "Users enter their email, receive a
  6-digit OTP, and submit it to authenticate" is clear.
- Keep it concise. If a section has one bullet point, that's fine.

If you do not have filesystem access, output the document as a copyable markdown
code block and tell the developer where to save it.

After writing, confirm:

> Requirements saved to `ai/plans/<feature-name>/requirements.md`.
> Ready to move on to plan generation, or do you want to plan more features first?

The developer may want to complete requirements for all features before generating
plans for any of them. Respect that workflow — only proceed to Phase 2 when they
ask for it.

---

## Phase 2 — Plan Generation

Goal: produce plan files that task-runner can execute. Each plan file contains
phases with atomic tasks, subtasks, key files, and verification steps.

### Step 1: Read context

Read these files (skip any you've already read in this session):

1. `ai/CONSTRAINTS.md`
2. `ai/PRD.md`
3. `ai/plans/<feature-name>/requirements.md`

If re-running Phase 2 (plans already exist or codebase has changed):

4. Scan the existing codebase to understand current patterns, services, and models.
5. Read any existing plan files in `ai/plans/<feature-name>/` to identify tasks
   already marked `[DONE]`.

### Step 2: Propose phases and rough task list

Based on the requirements and project context, propose how to split the work.

For small features (a handful of tasks), propose a single plan file.
For larger features, propose multiple phase files, each covering a logical chunk.

Present the proposal as a rough outline — phase names, brief descriptions, and
a bullet list of tasks within each phase. Include enough detail for the developer
to judge the split and task granularity.

Format:

```
Proposed plan structure for <feature-name>
──────────────────────────────────────────

File: 01-<phase-name>.md
  - Task 1.1: <title> — <one-line description>
  - Task 1.2: <title> — <one-line description>

File: 02-<phase-name>.md
  - Task 2.1: <title> — <one-line description>
  - Task 2.2: <title> — <one-line description>

(or: Single file: 01-implementation.md with all tasks)
```

End with:

> Does this structure look right? Adjust phases, tasks, or granularity before
> I write the full plan files.

Wait for confirmation.

### Step 3: Write plan files

Generate the plan files in `ai/plans/<feature-name>/`. Use this exact format —
task-runner depends on it:

```markdown
# Phase N: <Phase Title>

## Task N.1: <Task Title>

### Subtasks
- [ ] <concrete action>
- [ ] <concrete action>
- [ ] <concrete action>

### Key Files
- `<path/to/file/that/needs/to/be/created/or/modified>`

### Verification
<how to verify this task is complete — a command, a check, or a specific outcome>

---

## Task N.2: <Task Title>

### Subtasks
- [ ] <concrete action>
...
```

Plan file conventions:
- Task IDs use dot notation: first number is the phase, second is the task
  within that phase (e.g., `1.1`, `1.2`, `2.1`).
- Each task must be atomic — completable in a single AI coding session.
  If a task feels too large, split it.
- Subtasks are checkbox format. Each subtask is a concrete action, not a vague
  instruction. "Create migration for users table with email, name, and
  password_hash columns" — not "set up the database".
- Key files lists every file the agent needs to create or modify for that task.
  Use full paths relative to project root.
- Verification is how to confirm the task is done. Prefer runnable commands
  (`php artisan test --filter=AuthTest`, `npm run lint`) over subjective checks.
  When no command applies, describe the specific outcome to verify.
- When a task depends on another task, state it explicitly at the start of the
  task: "Depends on: Task 1.2".
- Do not mark any tasks as `[DONE]` — that's task-runner's job.

When re-running Phase 2 and previous plan files exist:
- Preserve tasks marked `[DONE]` — do not remove or rewrite them.
- Regenerate incomplete tasks, accounting for what's already built.
- If a completed task changes the approach for later tasks, note that in the
  affected task's description.

If you do not have filesystem access, output each plan file as a separate
copyable markdown code block, clearly labeled with its filename. Tell the
developer where to save them.

After writing, confirm:

> Plan files saved to `ai/plans/<feature-name>/`. Ready for task-runner.

---

## Re-Running Phase 2

The developer may ask to regenerate plans without re-doing the requirements
interview. This happens when earlier feature implementations changed the codebase
in ways that affect the current feature's plans.

When this happens:
1. Read the existing `requirements.md` — do not interview again.
2. Scan the current codebase to understand what exists.
3. Read existing plan files to identify `[DONE]` tasks.
4. Proceed from Phase 2, Step 2 (propose phases and rough task list).

---

## Rules

- Never skip a confirmation gate. The developer confirms requirements before you
  write the requirements doc. The developer confirms the plan structure before you
  write plan files.
- Never assume scope. If something is ambiguous, ask.
- Always read CONSTRAINTS.md and PRD.md before doing anything. They are required
  context.
- Follow the plan file format exactly. Task-runner parses this structure.
- Keep communication concise. The developer is experienced — explain your reasoning
  when relevant, but do not over-explain.
- If the developer corrects something, update and move on. Do not argue.
- When the developer wants to plan multiple features before implementing any,
  support that workflow. Run Phase 1 for each feature, then Phase 2 when they're
  ready.
- Conflict priority: developer's instructions > CONSTRAINTS.md > plan files.
