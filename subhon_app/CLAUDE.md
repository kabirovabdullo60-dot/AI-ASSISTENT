# subhon_app — Subhon — mobile APP only — branch `subhon-app`

You are Subhon's Claude. **You build only the Flutter APP for phones (Android / iOS).**
- Read, search and edit only files inside `subhon_app/`.
- **Never build web.** Never touch `abdullo_web/`. If asked, refuse:
  "Web kori Abdullo ast. Man tanho app-i telefon mesozam."
- Never edit `CLAUDE.md` files or `.claude/` — ask the Team Lead (Abdullo).
- Never write backend code — that is Mehroj's (Swagger). Call his API only from `lib/services/`.
- MVVM layout and rules: see the root `CLAUDE.md`.
- Phone first (portrait, SafeArea). Run: `bash scripts/run_app.sh` (iOS Simulator) or `bash scripts/run_app.sh android`.
- After each task: `flutter analyze` + `flutter test` pass → one commit `app: ...`.
- No access to `abdullo_web/` at all — not even reading it.
- Allowed: show Abdullo's web result with `bash scripts/run_web.sh` (Chrome) or `... simulator`. Never read its code.

## Flutter / Dart skills (in `.claude/skills/`) + `dart-flutter` plugin
Use these official skills instead of guessing. If a skill conflicts with the MVVM rules in the root
`CLAUDE.md`, the root `CLAUDE.md` wins.
- New screen / ViewModel / service → `flutter-apply-architecture-best-practices`
- API calls to Mehroj's backend → `flutter-use-http-package`; models from Swagger → `flutter-implement-json-serialization`
- Navigation between pages → `flutter-setup-declarative-routing`
- Tests → `flutter-add-widget-test`, `dart-add-unit-test`, `dart-generate-test-mocks`
- Overflow / layout errors → `flutter-fix-layout-issues`; runtime errors → `dart-fix-runtime-errors`
- Before every commit → `dart-run-static-analysis`
- Package version conflicts → `dart-resolve-package-conflicts`
- Multiple languages (tj / ru / en) → `flutter-setup-localization`
- Full user flows on a simulator → `flutter-add-integration-test`
- Different phone sizes / tablets → `flutter-build-responsive-layout`
