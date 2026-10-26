---
name: sonnet-build
description: Plan small-to-medium changes with the user, record the plan, then delegate the build to the sonnet-builder subagent and review the result. Manual only.
argument-hint: "[changes to make]"
disable-model-invocation: true
---

# sonnet-build

Requested changes:

$ARGUMENTS

You plan and review. The `sonnet-builder` subagent builds. For large features
that need progress tracking across sessions, suggest feature-planner and
task-runner instead, and stop.

## 1. Understand

Read the code the request touches before asking anything, so your questions
are specific to this codebase.

## 2. Interview

Ask only questions whose answer would change the plan: scope, behavior, edge
cases, data, UI. Group related questions into rounds. For minor details that a
reasonable, reversible assumption covers, don't ask: note the assumption.
Continue until nothing material is open.

In autonomous mode (see AGENTS.md), skip the interview and this step's
questions. Decide with stated assumptions instead.

## 3. Plan and approve

Show the plan in the conversation:

- Decisions settled in the interview
- Assumptions you made
- Ordered steps, each small enough to commit on its own, with the files it touches
- Done criteria: how to tell the work is complete and correct

Wait for explicit approval. Revise and show again if the user asks for
changes. In autonomous mode, skip the wait.

## 4. Record

After approval:

1. Start the branch with `git-workflow-start`, per the git-workflow skill.
2. Write the approved plan to `ai/sonnet-build/YYYY-MM-DD-<slug>.md`. Use
   today's date from `date +%F` and a short kebab-case slug for the change.
   If the file exists, add `-2`, `-3`, and so on. Use this structure:

```markdown
# <Short title>

## Request
<The user's request, as given>

## Decisions
<What the interview settled>

## Assumptions
<What you decided without asking>

## Plan
<Ordered steps, files per step>

## Done criteria
<How to tell the work is complete>

## Result
<Filled in after review>
```

The file must stand on its own. The builder can't see this conversation.

Commit the plan file with `git-workflow-commit` before delegating, so the
history shows the plan before the work.

## 5. Delegate

Start the `sonnet-builder` subagent with the Agent tool and set
`run_in_background: false`. Subagents run in the background by default, and
background subagents get a smaller tool set that can leave the builder without
Edit and Write. Wait for its report.

Give it the path to the plan file and nothing it can't find there. Don't
restate the plan in the delegation message.

If it stops with plan drift (the plan turns out wrong or incomplete), bring the
problem to the user, update the plan file, and delegate again.

## 6. Review

Compare the branch diff against the plan and done criteria. Check that each
decision was followed and nothing outside the plan changed. Run the project's
tests once if it has them.

Fill in the Result section: what was built, commits, any differences from the
plan, and anything left open. Commit the updated file with
`git-workflow-commit`.

Report the result to the user in a few sentences. Then run the Task Complete
steps from AGENTS.md.
