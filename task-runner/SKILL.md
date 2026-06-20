---
name: task-runner
description: >
  Run, track, and hand off plan-driven implementation tasks. Use this skill whenever
  the user mentions progress tracking, task status, starting or completing tasks,
  resuming work, preparing handoffs, switching agents, expanding tasks for other models,
  or running implementation plans. Also trigger when you see ai/PROGRESS.md, ai/plans/,
  ai/CONSTRAINTS.md, or ai/PRD.md in the project, or when the user says things like
  "what task am I on", "start auth task 2.1", "run dashboard", "prepare for handoff",
  "status", "resume", "continue where we left off", "I'm switching to DeepSeek/GLM",
  "expand this task", "snapshot", or "mark task done". Trigger even on loose phrasing
  like "what's next", "keep going", or "do the next task".
---

# Task Runner

A skill for running plan-driven implementation, tracking progress, and generating
handoffs for less capable models.

You are working with an experienced developer. Keep communication concise.
Do not explain basic concepts unless asked.

---

## File Layout

```
ai/
├── CONSTRAINTS.md              # Technical constraints (user-maintained, required)
├── PRD.md                      # Product requirements (user-maintained, optional)
├── PROGRESS.md                 # Current state only (skill-maintained)
├── plans/
│   ├── auth/
│   │   ├── requirements.md     # Feature requirements (feature-planner output)
│   │   ├── 01-setup.md         # Plan files (feature-planner output, skill marks [DONE])
│   │   └── 02-endpoints.md
│   ├── dashboard/
│   │   ├── requirements.md
│   │   ├── 01-layout.md
│   │   └── 02-widgets.md
│   └── notifications/
│       ├── requirements.md
│       └── 01-implementation.md
└── handoff/                    # Handoff files (skill-generated)
    └── auth-task-2.1-otp-service.md
```

Each feature has its own directory under `ai/plans/`. Inside each directory:
- `requirements.md` — feature requirements (read first for context)
- Numbered plan files — implementation plans sorted by filename

## Git Workflow

This skill delegates all git mechanics to three bash scripts. Run them directly —
do not replicate their logic manually.

- `git-workflow-start <type> <branch-name>` — repo init, stashing, branch creation
- `git-workflow-commit '<prefix>: <description>'` — validate prefix, stage, commit
- `git-workflow-end` — diff summary, commit count, suggested next steps

If the scripts are not on `$PATH`, inform the user and stop.

---

## Required Reading

Before any implementation, read these files in order:

1. `ai/CONSTRAINTS.md` — technical constraints, stack, conventions. **Stop if missing.**
2. `ai/PRD.md` — product context, users, goals, scope. Useful but not blocking — skip if missing.
3. Feature files — `ai/plans/<feature>/requirements.md` first, then numbered plan files in order.
4. `ai/PROGRESS.md` — current state (if it exists).

---

## Feature Targeting

Most commands operate on a specific feature. Determine the target feature from:

1. **Explicit argument**: "start auth task 2.1", "run dashboard", "status notifications"
2. **PROGRESS.md**: the `Feature` field in the Current section
3. **Prompt**: if ambiguous, list available features and ask

When the feature is known, read only files in `ai/plans/<feature>/`.
For project-wide commands (e.g. "status" with no argument), scan all
subdirectories in `ai/plans/`.

---

## Plan Files

Inside each feature directory, read `requirements.md` first for context,
then numbered plan files sorted by filename (`01-setup.md`, `02-endpoints.md`).

Tasks in plan files carry a status marker in their heading:

```
## Task 2.1: OTP Service [DONE]
## Task 2.2: Auth Controller [DONE]
## Task 2.3: Token Management
```

A task without a marker is incomplete. When a task is completed, append ` [DONE]`
to its heading in the plan file. Commit this change together with the implementation.

---

## PROGRESS.md

This file stays small. It contains current state only — never historical records.
Overwrite the content on each update. Three sections:

```markdown
# Progress

## Current
- **Feature**: auth
- **Task**: 2.3 (Token Management)
- **Branch**: feature/auth-token-management
- **Started**: 2026-06-20
- **Status**: Implementing token refresh logic

### Notes
- Decided to use short-lived tokens (15 min) with refresh tokens (7 days)
- TokenService depends on OtpService (task 2.1) which is complete

## Up Next
- 2.4: Auth Middleware
- 2.5: Rate Limiting

## Blockers
- None
```

If PROGRESS.md does not exist when needed, create it.

For completed task history, check `[DONE]` markers in plan files or run
`git log --oneline` — do not maintain a separate log.

---

## Conflict Priority

When instructions conflict, apply in this order:

1. User's latest explicit prompt
2. `ai/CONSTRAINTS.md`
3. Plan files in `ai/plans/<feature>/`

---

## Commands

Determine which command the user needs from their intent:

| User Intent | Command |
|---|---|
| "what's the status", "where are we", "which task" | `status` |
| "start task X", "begin working on X" | `start` |
| "run auth", "do all tasks", "keep going" | `run` |
| "task X is done", "mark complete", "finished" | `complete` |
| "snapshot", "save state", "I'm stopping for now" | `snapshot` |
| "expand task X", "prepare for handoff", "switching to DeepSeek" | `handoff` |
| "resume", "continuing", "I'm back", "pick up where I left off" | `resume` |
| "initialize", "set up tracking" | `init` |

---

### init

Set up task tracking for a project.

1. Verify `ai/CONSTRAINTS.md` exists. If not, stop and ask.
2. Read `ai/PRD.md` if it exists.
3. Scan `ai/plans/` for feature directories.
4. If a feature is specified (e.g. "init auth"), verify `ai/plans/auth/` has plan files.
5. If no feature is specified, list available features and ask which to start.
6. Create `ai/PROGRESS.md` with the feature field. Set the first incomplete task as current.
7. Create `ai/handoff/` directory if it does not exist.
8. Report what was created and the first task to work on.

---

### status

Report current state without changing anything. Works at two levels:

**Feature level** ("status auth"):
1. Read plan files in `ai/plans/auth/` to count total tasks and `[DONE]` tasks.
2. Read `ai/PROGRESS.md` for current task in that feature.
3. Verify current branch matches PROGRESS.md.
4. Report: current task, branch, what's done, what's next, feature progress (X of Y tasks).
5. If branch doesn't match PROGRESS.md, flag it.

**Project level** ("status" with no argument):
1. Scan all feature directories in `ai/plans/`.
2. For each feature, count total tasks and `[DONE]` tasks.
3. Read `ai/PROGRESS.md` for which feature and task is currently active.
4. Report: per-feature progress summary, current feature/task, overall progress.

---

### start

Begin working on a specific task.

1. Parse the feature and task ID from user input (e.g. "start auth task 2.3", "start auth 2.3").
2. If feature is not specified, use the current feature from PROGRESS.md.
3. Find the task in that feature's plan files. If not found, stop and ask.
4. If the task is marked `[DONE]`, warn the user and confirm before proceeding.
5. Run `git-workflow-start <type> <branch-name>` with an appropriate type and name
   derived from the feature and task (e.g. `feature/auth-token-management`).
6. Update `ai/PROGRESS.md` — set feature, current task, branch, started date.
7. Read the task's details from the plan file and summarize what needs to be done.

---

### run

Execute tasks sequentially using a unit-of-work loop.

1. Parse the user's scope: a feature name, a specific task, a phase, or "all pending".
   If a feature is named (e.g. "run auth"), run all pending tasks in that feature.
   If no scope is given, continue from the current task in PROGRESS.md.
2. Read plan files for the target feature and identify selected tasks. Skip any marked `[DONE]`.
3. Read `ai/CONSTRAINTS.md` and `ai/PRD.md` (if it exists).
4. Read `ai/plans/<feature>/requirements.md` for feature context.

For each selected task:

5. Re-read the task section from the plan file.
6. Implement only that task. Do not implement future tasks early.
7. Run verification for that task (use the command from the plan, or infer from the project).
8. If verification succeeds:
   - Mark the task `[DONE]` in the plan file
   - Update `ai/PROGRESS.md` with the next task as current
   - Commit implementation, plan file update, and progress update together via `git-workflow-commit`
   - Continue to the next task
9. If verification fails:
   - Stop
   - Report: current branch, feature, task ID, what changed, verification command, failure summary
   - Ask the user before continuing

If the plan file explicitly says to confirm before continuing to the next task, stop and ask.
Otherwise, continue without asking after each successful task.

After all selected tasks pass:

10. Run `git-workflow-end` and report the summary.

---

### complete

Mark a task as done.

1. Determine which task — current task from PROGRESS.md if not specified.
2. Mark the task `[DONE]` in the plan file.
3. Update `ai/PROGRESS.md` — set the next incomplete task as current (within the same feature).
4. Commit the changes via `git-workflow-commit`.
5. Run `git-workflow-end`.
6. Report what was completed and what's next.
7. If this was the last task in the feature, note that the feature is complete.

---

### snapshot

Persist current state for the next session. Use this at the end of a session
or when pausing work.

1. Overwrite `ai/PROGRESS.md` with current state:
   - Current feature and task ID
   - Current branch
   - What's been done in this task so far
   - Decisions made and rationale
   - What to do next (specific, actionable)
   - Any blockers or open questions
2. Commit via `git-workflow-commit 'chore: snapshot progress'`.
3. Confirm to the user that state is saved.

The snapshot overwrites — it does not append. PROGRESS.md always reflects
the latest state only.

---

### handoff

Generate an expanded task file for a less capable model (GLM, DeepSeek, etc.).

1. Determine what to hand off — specified task or current task from PROGRESS.md.
2. Identify the feature from the task or PROGRESS.md.
3. Assess current state:
   - Read PROGRESS.md for notes
   - Run `git status` and `git log` on the branch for recent work
4. Read the task details from the plan file.
5. Read `ai/plans/<feature>/requirements.md` for feature context.
6. Generate the handoff file using the template in `references/HANDOFF.md`.
7. Break remaining work into atomic subtasks. Each subtask must:
   - Modify or create ONE file
   - Have a clear, verifiable outcome
   - Include exact file paths and method signatures
   - Include step-by-step logic (no architectural decisions required)
   - Include a verification step
   - Reference patterns from existing code when applicable
8. For reference information, point to files in the codebase rather than
   reproducing code inline. Only inline short snippets (under 10 lines) when
   the pattern is critical and the file is large.
9. Save to `ai/handoff/<feature>-task-{id}-{slug}.md`.
10. Update PROGRESS.md with a note that handoff was generated.
11. Output a summary the user can paste to the other agent:

```
Read these files in order:
1. ai/CONSTRAINTS.md (project rules)
2. ai/plans/<feature>/requirements.md (feature context)
3. ai/handoff/<feature>-task-{id}-{slug}.md (your task)

Start from the first unchecked subtask. After completing each subtask:
1. Mark it [x] in the handoff file
2. Commit your changes
3. Move to the next subtask

If anything is unclear, ask before proceeding.
```

---

### resume

Reconstruct context when returning to a project.

1. Gather state:

   From git:
   ```bash
   git branch --show-current
   git log --oneline -10
   git status --short
   ```

   From files:
   - Read `ai/PROGRESS.md` if it exists — get the current feature and task
   - Read `ai/plans/<feature>/requirements.md` for feature context
   - Read plan files for the current feature, check `[DONE]` markers
   - Read `ai/handoff/*.md` if any exist

2. Reconcile conflicts:
   - If branch doesn't match PROGRESS.md, trust git
   - If handoff file exists, check which subtasks are marked done
   - Cross-reference `[DONE]` markers in plan files with git commits

3. Update PROGRESS.md to reflect current reality.
4. Report: current feature, current task, branch, what's done, what's next, uncommitted changes.
5. If a handoff file exists with incomplete subtasks, ask the user whether to
   continue with atomic subtasks or switch to high-level work.

---

## Parsing Plan Files

The skill handles various task formats in plan files. Common patterns:

**Hierarchical headings:**
```
## Task 2.1: OTP Service
## Task 2.2: Auth Controller
```

**Numbered checkboxes:**
```
- [ ] 2.1 OTP Service
- [x] 2.2 Auth Controller
```

**Phase sections:**
```
# Phase 2: Authentication
## 2.1 OTP Service
```

When parsing, extract: task ID, task name, description, subtasks, key files,
and verification criteria. Use `[DONE]` markers as the canonical status
regardless of checkbox state.

---

## Verification

Use the verification command from the plan file when specified.

If the plan gives an expected outcome but no command, infer from the project:
- Laravel: `php artisan test`, `composer analyse`, `php -l`
- Node/React: `npm run build`, `npm run typecheck`, `npm test`
- General: look for test scripts in `composer.json` or `package.json`

If no verification command can be inferred, stop and ask the user before
starting implementation.

Treat as failures: build errors, test failures, type errors, lint failures,
runtime errors during verification.

Treat other warnings as non-blocking but mention them in PROGRESS.md notes.

---

## References

The `references/` directory contains templates used by this skill:

- `references/HANDOFF.md` — Template for handoff file generation

Read the template when executing the `handoff` command.
