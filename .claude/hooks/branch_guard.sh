#!/usr/bin/env bash
# Each person's Claude may READ, SEARCH, EDIT and run commands only in their own folder.
#   abdullo-web*  -> only abdullo_web/      subhon-app* -> only subhon_app/      main -> all (Team Lead)
input=$(cat | tr -d '\n')
field() { printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"; }
tool=$(field tool_name)

root=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$root" branch --show-current)
case "$branch" in main|master) exit 0 ;; esac

case "$branch" in
  abdullo-web*) mine=abdullo_web; other=subhon_app; who="Abdullo's Claude works only in abdullo_web/ (WEB)" ;;
  subhon-app*)  mine=subhon_app;  other=abdullo_web; who="Subhon's Claude works only in subhon_app/ (mobile APP)" ;;
  *) echo "BLOCKED: unknown branch '${branch:-detached}'. Run 'git switch abdullo-web' or 'git switch subhon-app'." >&2; exit 2 ;;
esac
deny() { echo "BLOCKED by branch_guard: $who. $1 Read CLAUDE.md." >&2; exit 2; }

# Bash: no command may mention the other person's folder
if [ "$tool" = "Bash" ]; then
  cmd="${input#*\"tool_input\"}"
  case "$cmd" in *"$other"*) deny "Command touches $other/." ;; esac
  exit 0
fi

file=$(field file_path); [ -z "$file" ] && file=$(field notebook_path); [ -z "$file" ] && file=$(field path)
if [ -z "$file" ]; then
  case "$tool" in Glob|Grep) file="${CLAUDE_PROJECT_DIR:-$PWD}" ;; *) exit 0 ;; esac
fi
case "$file" in
  "$root") rel="" ;;
  "$root"/*) rel="${file#"$root"/}" ;;
  /*) exit 0 ;;                       # outside the repo (e.g. Claude memory) -> allowed
  *) rel="$file" ;;
esac

case "$rel" in "$other"|"$other"/*) deny "No access to $other/." ;; esac

case "$tool" in
  Read) exit 0 ;;                                        # root CLAUDE.md etc. may be read
  Glob|Grep) case "$rel" in "$mine"|"$mine"/*) exit 0 ;; esac
             deny "Search only inside $mine/." ;;
esac

# Edit / Write / NotebookEdit
case "$rel" in
  CLAUDE.md|*/CLAUDE.md|.claude/*|*/.claude/*|.gitignore) deny "Team rules files change only on 'main' (Team Lead)." ;;
  "$mine"/*) exit 0 ;;
esac
deny "Edit only inside $mine/."
