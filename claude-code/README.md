# Claude Code extras

Optional pieces for Claude Code only. `install.sh` does not install them,
because Codex and other tools don't support them.

- [/refresh](#refresh-save-and-clear-instead-of-compact): save state, then `/clear`
- [/sonnet-build](#sonnet-build-plan-with-your-model-build-with-sonnet): plan with
  your main model, build with a Sonnet subagent

## /refresh: save and clear instead of compact

### Why

Long sessions burn usage, because Claude Code sends the whole conversation on
every request. `/compact` doesn't help much: it reads the whole conversation to
summarize it, which is itself a large request. A cheaper habit:

1. At a stopping point, run `/refresh`. It writes `ai/PROGRESS.md`, including
   the options you ruled out, so the next session doesn't try them again.
2. Run `/clear`. It costs nothing.
3. A hook loads `ai/PROGRESS.md` into the fresh session automatically.

### Install

1. Copy the command:

   ```bash
   mkdir -p ~/.claude/skills
   cp -R claude-code/refresh ~/.claude/skills/
   ```

   If `~/.claude/skills` is a symlink to `~/.agents/skills`, this puts the
   skill there too. That is fine for Claude Code; if Codex complains about the
   `disable-model-invocation` field, keep the skill in a real
   `~/.claude/skills` folder instead.

2. Add this hook to `~/.claude/settings.json`, inside `"hooks"`. If you already
   have a `SessionStart` list, add the object to it:

   ```json
   "SessionStart": [
     {
       "matcher": "clear",
       "hooks": [
         {
           "type": "command",
           "command": "f=\"$CLAUDE_PROJECT_DIR/ai/PROGRESS.md\"; [ -f \"$f\" ] && { echo 'State saved by /refresh (ai/PROGRESS.md):'; cat \"$f\"; }; exit 0",
           "timeout": 5
         }
       ]
     }
   ]
   ```

3. Optional: add these lines to `~/.claude/CLAUDE.md`:

   ```markdown
   ## Sessions

   - When a task or phase is done, or context passes about 50%, say "Good
     stopping point" and suggest `/refresh`. Don't start the next phase in the
     same session.
   - Never suggest `/compact`. Use `/refresh`, then I run `/clear`.
   - After `/clear`, a hook loads `ai/PROGRESS.md`. Treat its "Ruled out" list
     as settled.
   ```

### Check it works

Restart Claude Code, run `/refresh` in a project, then `/clear`. The new
session should start with "State saved by /refresh (ai/PROGRESS.md):".

## /sonnet-build: plan with your model, build with Sonnet

For changes too big to do in one go but too small for feature-planner. Your
main model (for example Opus) plans and reviews; a Sonnet subagent does the
building. Sonnet costs less, so long builds use less of your plan's limit.

How it works:

1. Run `/sonnet-build <what to change>`. It reads the code, asks only the
   questions that change the plan, and shows the plan for your OK.
2. It starts a branch with `git-workflow-start`, saves the plan to
   `ai/sonnet-build/<date>-<slug>.md`, and commits it.
3. The `sonnet-builder` subagent builds from that file alone, commits as it
   goes, and stops to report if the plan turns out wrong.
4. The main model checks the diff against the plan, runs the tests, fills in
   the plan's Result section, and runs the Task Complete steps.

It needs Claude Code, the `git-workflow-*` scripts from this repo, and access
to Sonnet. For large features that span sessions, use feature-planner and
task-runner instead.

### Install

```bash
mkdir -p ~/.claude/skills ~/.claude/agents
cp -R claude-code/sonnet-build ~/.claude/skills/
cp claude-code/agents/sonnet-builder.md ~/.claude/agents/
```

Restart Claude Code. `/sonnet-build` only runs when you type it; Claude won't
start it on its own.
