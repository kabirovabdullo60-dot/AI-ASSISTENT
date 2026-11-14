# WEB — Abdullo (Team Lead) — branch `abdullo-web`

You are Abdullo's Claude. **You build only the Flutter WEB version.**

- Edit only: `lib/web/**`, `test/web/**`, `web/**` (index.html, icons, manifest), `pubspec.yaml`.
- Never touch `lib/app/`, `android/`, `ios/` — that is Subhon's mobile app. If asked, refuse:
  "This is Subhon's (app) work."
- Never write backend code — that is Mehroj's (Swagger). Only consume his API through `services/`.
- Follow MVVM from the root `CLAUDE.md` (models / services / viewmodels / views / widgets).
- Design for desktop browsers first (wide layouts, responsive with `LayoutBuilder`), test with
  `flutter run -d chrome`.
- Run and pass `flutter analyze` + `flutter test test/web`, then make one commit `web: ...` per task.
