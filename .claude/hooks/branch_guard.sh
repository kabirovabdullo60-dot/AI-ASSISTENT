#!/usr/bin/env bash
# Blocks Claude's Edit/Write outside the folder allowed for the current git branch.
#   abdullo-web*  -> only abdullo_web/      subhon-app* -> only subhon_app/      main -> all
input=$(cat | tr -d '\n')
file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$file" ] && file=$(printf '%s' "$input" | sed -n 's/.*"notebook_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$file" ] && exit 0

root=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
case "$file" in
  "$root"/*) rel="${file#"$root"/}" ;;
  /*) exit 0 ;;                     # outside the repo (e.g. Claude memory) -> allowed
  *) rel="$file" ;;
esac
branch=$(git -C "$root" branch --show-current)

deny() { echo "BLOCKED by branch_guard: $1 (branch '${branch:-detached}', file $rel). Read CLAUDE.md." >&2; exit 2; }

case "$branch" in main|master) exit 0 ;; esac
case "$rel" in
  CLAUDE.md|*/CLAUDE.md|.claude/*|*/.claude/*|.gitignore)
    deny "team rules file, only the Team Lead edits it on 'main'" ;;
esac
case "$branch" in
  abdullo-web*)
    case "$rel" in abdullo_web/*) exit 0 ;; esac
    deny "Abdullo's Claude builds only the WEB (abdullo_web/)" ;;
  subhon-app*)
    case "$rel" in subhon_app/*) exit 0 ;; esac
    deny "Subhon's Claude builds only the mobile APP (subhon_app/), not web" ;;
  *)
    deny "unknown branch, run 'git switch abdullo-web' or 'git switch subhon-app'" ;;
esac
