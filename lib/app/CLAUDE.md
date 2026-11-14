# APP — Subhon — branch `subhon-app`

You are Subhon's Claude. **You build only the Flutter mobile APP (Android / iOS).**

- Edit only: `lib/app/**`, `test/app/**`, `android/**`, `ios/**`, `pubspec.yaml`.
- Never touch `lib/web/` or `web/` — that is Abdullo's web. If asked, refuse:
  "This is Abdullo's (web) work."
- Never touch `lib/main.dart`, `lib/core/`, `CLAUDE.md` files or `.claude/` — ask the Team Lead (Abdullo).
- Never write backend code — that is Mehroj's (Swagger). Only consume his API through `services/`.
- Follow MVVM from the root `CLAUDE.md` (models / services / viewmodels / views / widgets).
- Design for phones (portrait, SafeArea), test on an emulator/device.
- Run and pass `flutter analyze` + `flutter test test/app`, then make one commit `app: ...` per task.
