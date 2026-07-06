#!/usr/bin/env bash
set -euo pipefail

# Installs (or updates) the agents-skills files into their standard locations.
# Run it again after every `git pull` to sync.
#
# Sync semantics: each managed skill directory and script is DELETED at the
# destination and freshly copied, so files removed or renamed in the repo do
# not linger. Unrelated files in the destination directories are untouched.
#
# Destinations (override with env vars):
#   SKILLS_DIR   ~/.agents/skills   all skill directories
#   BIN_DIR      ~/.local/bin       git-workflow-* and ai-monitor
#   CODEX_HOME   ~/.codex           AGENTS.md (global Codex config)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS_DIR="${SKILLS_DIR:-$HOME/.agents/skills}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_SKILLS="$HOME/.claude/skills"

SCRIPTS=(git-workflow-start git-workflow-commit git-workflow-end ai-monitor)

# --- OS detection (paths are $HOME-based everywhere; this is for messaging) ---
case "$(uname -s)" in
  Darwin*) OS="macOS" ;;
  Linux*)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS="WSL"; else OS="Linux"; fi ;;
  MINGW*|MSYS*|CYGWIN*) OS="Windows (Git Bash)" ;;
  *) OS="unknown" ;;
esac
echo "[install] OS: $OS"
echo "[install] Repo: $REPO_DIR"
echo ""

# --- Skills: delete existing copy, then fresh copy (per skill directory) ---
mkdir -p "$SKILLS_DIR"
for src in "$REPO_DIR"/skills/*/; do
  name="$(basename "$src")"
  rm -rf "${SKILLS_DIR:?}/${name:?}"
  cp -R "$src" "$SKILLS_DIR/$name"
  echo "[skills]  $name -> $SKILLS_DIR/$name"
done

# --- Claude Code: symlink ~/.claude/skills -> $SKILLS_DIR if absent ---
if [[ ! -e "$CLAUDE_SKILLS" && ! -L "$CLAUDE_SKILLS" ]]; then
  mkdir -p "$HOME/.claude"
  if ln -s "$SKILLS_DIR" "$CLAUDE_SKILLS" 2>/dev/null; then
    echo "[claude]  Symlinked $CLAUDE_SKILLS -> $SKILLS_DIR"
  else
    echo "[claude]  Could not create symlink (common on Windows without developer mode)."
    echo "[claude]  Copy the skills manually: cp -R $SKILLS_DIR $CLAUDE_SKILLS"
  fi
else
  echo "[claude]  $CLAUDE_SKILLS already exists — left unchanged."
fi

# --- Scripts: delete, fresh copy, make executable ---
mkdir -p "$BIN_DIR"
for s in "${SCRIPTS[@]}"; do
  rm -f "${BIN_DIR:?}/$s"
  cp "$REPO_DIR/scripts/$s" "$BIN_DIR/$s"
  chmod +x "$BIN_DIR/$s"
  echo "[scripts] $s -> $BIN_DIR/$s"
done

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo ""
    echo "[warning] $BIN_DIR is not on your PATH. Add this to your shell profile:"
    echo "          export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

# --- AGENTS.md: global Codex config ---
mkdir -p "$CODEX_HOME"
rm -f "${CODEX_HOME:?}/AGENTS.md"
cp "$REPO_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"
echo "[agents]  AGENTS.md -> $CODEX_HOME/AGENTS.md"
echo "[agents]  For Claude Code, merge AGENTS.md into ~/.claude/CLAUDE.md manually if wanted"
echo "[agents]  (not done automatically — that file may hold unrelated config)."

# --- Summary ---
echo ""
echo "=== agents-skills installed ==="
echo "  Skills:  $SKILLS_DIR"
echo "  Scripts: $BIN_DIR"
echo "  AGENTS:  $CODEX_HOME/AGENTS.md"
echo "==============================="
