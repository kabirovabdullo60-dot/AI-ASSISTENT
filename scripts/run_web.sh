#!/usr/bin/env bash
# Show Abdullo's WEB result (anyone may run this — it only runs, never edits).
#   bash scripts/run_web.sh            -> Chrome (resize the window / Cmd+Opt+I -> device toolbar to test phone size)
#   bash scripts/run_web.sh simulator  -> web opened in Safari inside the iOS Simulator (real phone size)
set -e
cd "$(dirname "$0")/../abdullo_web"
flutter pub get >/dev/null
PORT=8080
case "${1:-chrome}" in
  chrome)
    flutter run -d chrome --web-port "$PORT" ;;
  simulator)
    open -a Simulator
    until xcrun simctl list devices booted | grep -q Booted; do sleep 1; done
    ( until curl -s "http://localhost:$PORT" >/dev/null; do sleep 2; done
      xcrun simctl openurl booted "http://localhost:$PORT" ) &
    flutter run -d web-server --web-port "$PORT" ;;
  *) echo "usage: bash scripts/run_web.sh [chrome|simulator]"; exit 1 ;;
esac
