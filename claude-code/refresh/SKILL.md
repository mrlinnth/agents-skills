---
name: refresh
description: Save session state to ai/PROGRESS.md so you can run /clear. Run with /refresh.
disable-model-invocation: true
---

# Refresh

Save what the next session needs, then hand over to `/clear`.

1. If `ai/plans/` exists, run the task-runner `snapshot` command.
2. Otherwise, overwrite `ai/PROGRESS.md` with the same fields as `snapshot`:
   what's done, decisions, Ruled out (copy forward old entries), active plan
   file, what to do next, and blockers. Don't commit it.
3. Keep it under 60 lines. Point to files instead of copying their content.
4. Reply with one line: "Saved to ai/PROGRESS.md. Type /clear; the next
   session loads it."

Don't start any other work after this.
