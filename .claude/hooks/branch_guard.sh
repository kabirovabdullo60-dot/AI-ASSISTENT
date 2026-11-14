#!/usr/bin/env bash
# Blocks Claude's Edit/Write outside the folders allowed for the current git branch.
input=$(cat | tr -d '\n')
file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$file" ] && file=$(printf '%s' "$input" | sed -n 's/.*"notebook_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$file" ] && exit 0

root=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
case "$file" in
  "$root"/*) rel="${file#"$root"/}" ;;
  /*) exit 0 ;;              # outside the repo (e.g. Claude memory) -> allowed
  *) rel="$file" ;;
esac
branch=$(git -C "$root" branch --show-current)

deny() { echo "BLOCKED by branch_guard: $1 (branch: '${branch:-detached}', file: $rel). See CLAUDE.md." >&2; exit 2; }

case "$branch" in
  main|master) exit 0 ;;
esac
case "$rel" in
  CLAUDE.md|*/CLAUDE.md|.claude/*|.gitignore|lib/main.dart|lib/core/*)
    deny "shared file, only the Team Lead edits it on 'main'" ;;
esac
case "$branch" in
  abdullo-web*)
    case "$rel" in lib/web/*|test/web/*|web/*|pubspec.yaml|pubspec.lock) exit 0 ;; esac
    deny "Abdullo's Claude builds only the WEB" ;;
  subhon-app*)
    case "$rel" in lib/app/*|test/app/*|android/*|ios/*|pubspec.yaml|pubspec.lock) exit 0 ;; esac
    deny "Subhon's Claude builds only the mobile APP" ;;
  *)
    deny "unknown branch, switch to abdullo-web or subhon-app" ;;
esac
