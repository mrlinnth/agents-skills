# Handoff: [FEATURE] — [TASK_ID] - [TASK_NAME]

**Generated**: [TIMESTAMP]
**Feature**: [FEATURE_NAME]
**Branch**: `[BRANCH_NAME]`
**For**: GLM/DeepSeek/other agent

---

## Context

[2-3 sentences explaining what this feature is about and where this task fits.
Summarize key points from the feature's requirements.md.]

---

## Current State

**Already completed in this feature:**
- [List tasks marked [DONE] in the feature's plan files]

**Files that exist:**
- `path/to/file.ext` - [brief description]

**Uncommitted changes:**
- [Any uncommitted work, or "None"]

---

## Remaining Subtasks

Work through these in order. Each subtask is atomic — complete it fully
before moving to the next.

### [SUBTASK_NUMBER]: [SUBTASK_TITLE]

- **File**: `[exact/path/to/file.ext]`
- **Action**: [Create new file | Add method | Modify existing | Add field]
- **Details**: [Method signature, field definition, or short code structure.
  Only inline code under 10 lines. For longer patterns, point to an existing
  file: "Follow the pattern in `app/Services/ExampleService.php`"]
- **Logic**:
  1. [Step-by-step implementation instructions]
  2. [Be specific about conditionals, return values, error handling]
  3. [Reference existing files for patterns rather than reproducing them]
- **Verify**: [Specific command or check to confirm this subtask works]

**Status**: [ ] Not started

---

[Repeat for each subtask]

---

## Reference Files

[Point to files in the codebase that the agent should read for context.
Do not reproduce file contents here — just list paths and what to look for.]

- `ai/plans/<feature>/requirements.md` — feature requirements and scope
- `path/to/model.php` — check fillable fields and casts
- `path/to/migration.php` — check table schema

---

## Testing

After completing all subtasks:

1. [Verification command]
2. [Expected outcome]

---

## When You're Done

1. Mark each subtask as complete: `[x]`
2. Commit with message: `feat([TASK_ID]): [description]`
3. If all subtasks are done, note that the task is ready for review

---

## Questions?

If any subtask is unclear:
1. Note the subtask number
2. Describe what's confusing
3. Do not proceed until clarified
