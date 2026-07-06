# AGENTS.md

These are behavioral defaults that apply to every task, regardless of which
skill is active. For procedural workflows, defer to the relevant skill:

- **project-kickoff** — product and technical context (ai/PRD.md, ai/CONSTRAINTS.md)
- **feature-planner** — requirements and plan files (ai/plans/<feature>/)
- **task-runner** — implementation, progress tracking, handoffs
- **git-workflow** — branching, commits, and end-of-task summaries via bash scripts

When a skill instruction conflicts with this file, the skill wins for its
specific workflow. This file governs everything else.

---

## Git

Git mechanics are handled by three bash scripts on `$PATH`:
`git-workflow-start`, `git-workflow-commit`, `git-workflow-end`.
Do not replicate their logic. See the git-workflow skill for usage.

If the script fails with a permission error, run the git commands from the script output individually to trigger sandbox approval.

Rules that remain the agent's judgment:

- Never push without explicit user permission. Exception: pushing `develop` after a user-approved local merge (see Task Complete)
- Use clear, descriptive commit messages
- Commit at logical checkpoints — not after every line, not only at the end

---

## Task Complete

At the end of every task:

1. Commit any uncommitted changes via `git-workflow-commit`
2. Run `git-workflow-end` and report its output
3. If the current branch is not `main`, `master`, or `develop`:
   - Ask the user: PR, local merge to develop, or leave as-is
4. If the user approves local merge to develop:
   - Merge to `develop`
   - Push `develop`
   - Delete the local merged branch

If working inside task-runner, also run `complete` or `snapshot` as appropriate
before the merge question.

---

## Autonomous Mode

Skills pause at confirmation gates by default. Autonomous mode skips those
gates so work can run without back-and-forth.

Autonomous mode is active when either:

- The developer explicitly asks in the prompt ("run autonomously",
  "no confirmations", "don't ask, just proceed"), or
- `ai/CONSTRAINTS.md` contains `Autonomous: yes`

When active:

- Skip confirmation gates and proceed with reasonable assumptions
- Record every assumption where the next reader will see it:
  - project-kickoff → the Assumptions block, written into the generated files
  - feature-planner → an "Assumptions" section in requirements.md
  - task-runner → the Notes section of ai/PROGRESS.md
  - prototype → the delivery message and blueprint.md header

Never skipped, even in autonomous mode:

- Destructive actions (see Destructive Actions and Recovery)
- Pushing to any remote
- Stops caused by verification failures or plan drift

---

## Scope

- Only modify what is necessary for the current task
- If you notice unrelated issues:
  - Mention them briefly
  - Do not fix unless explicitly asked
- If changes affect multiple unrelated areas:
  - Outline a plan and ask for approval before proceeding
- If changes are repetitive or mechanical across files:
  - Proceed without approval
- If a task is non-trivial and no plan file exists:
  - Outline a plan before making changes
  - Wait for approval

---

## Task Execution

Prefer existing project scripts (e.g. `npm run dev`, `php artisan test`)
over ad-hoc commands.

Break every task into the smallest logical units before starting.

A unit of work is:

- A single logical change within a file (function, class, or section)
- A change that can be verified independently

Execution rules:

- Complete one unit fully before moving to the next
- Multi-file tasks: finish one file before moving to another
- Large files: work top-to-bottom in sections
- Do not mix unrelated changes in a single step

---

## Destructive Actions and Recovery

Explain and wait for confirmation before:

- Deleting files or directories
- Database schema changes
- Overwriting critical files
- Force push, rebase, or history rewrite

When possible, use `--dry-run` or preview commands first.

If changes introduce major breakage:

- Prefer reverting the last change over stacking fixes
- Use safe git commands (`restore`, `reset` without data loss)
- Avoid destructive history edits unless approved

---

## Failure Handling

If the same fix fails 3 times:

1. Stop
2. Summarize what was attempted and why it likely failed
3. Suggest 1-2 alternative approaches
4. Ask for guidance

---

## After Changes

If tests or linters fail after your changes:

- Fix if clearly related to your changes
- Otherwise stop and report

---

## Communication

- Be concise and direct
- If ambiguous, ask the minimum number of clarifying questions needed
  before proceeding
