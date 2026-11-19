#!/usr/bin/env bash
# Show Subhon's mobile APP result (anyone may run this — it only runs, never edits).
#   bash scripts/run_app.sh            -> iOS Simulator
#   bash scripts/run_app.sh android    -> running Android emulator (start it first in Android Studio > Device Manager)
set -e
cd "$(dirname "$0")/../subhon_app"
flutter pub get >/dev/null
case "${1:-ios}" in
  ios)
    open -a Simulator 2>/dev/null || open -a DeviceHub  # Xcode 27+: Simulator is now DeviceHub
    until xcrun simctl list devices booted | grep -q Booted; do sleep 1; done
    udid=$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1)
    flutter run -d "$udid" ;;
  android)
    flutter run -d emulator ;;
  *) echo "usage: bash scripts/run_app.sh [ios|android]"; exit 1 ;;
esac
