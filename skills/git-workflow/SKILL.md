---
name: git-workflow
description: >
  Git branch and commit workflow for all coding tasks. Use this skill at the start of every task that involves code changes, file creation, or file modification. Auto-invoke this whenever the conversation involves writing code, fixing bugs, adding features, refactoring, or any file modifications. Do not skip this even for small changes.
---

# Git Workflow

This workflow uses three scripts on `$PATH`. Run them directly — do not replicate their logic manually.

## Before the task

Run `git-workflow-start <type> <branch-name>` where:
- `type` is one of: `feature`, `fix`, `refactor`, `chore`, `docs`
- `branch-name` is a short lowercase hyphen-separated description of the task

Example: `git-workflow-start fix cart-total`

The script handles repo init, stashing, branch creation, and collision avoidance. Branch names use flat format (`type-name`, e.g. `fix-cart-total`) to avoid git ref conflicts. Report its output to the user before proceeding.

Behavior depends on the current branch:

- On a protected branch (`main`, `master`, `develop`): uncommitted tracked changes are stashed, then the task branch is created. If a stash was made, the summary prints a restore hint — surface it to the user so the stash is not forgotten.
- Already on a non-protected branch: the script stays on that branch, leaves uncommitted changes in place, and does NOT create the requested branch. If the user wanted a fresh branch, switch to a protected branch first and re-run.

## During the task

Commit at logical checkpoints using:

`git-workflow-commit '<prefix>: <description>'`

Valid prefixes: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
An optional scope is allowed: `feat(2.3): ...`

Example: `git-workflow-commit 'feat: add user authentication middleware'`

The script validates the prefix, stages all changes, and commits. Never push without explicit user permission.

## After the task

Run `git-workflow-end` with no arguments.

The script shows a diff summary, commit count, uncommitted change warnings, and suggested next steps. Report its output to the user.
