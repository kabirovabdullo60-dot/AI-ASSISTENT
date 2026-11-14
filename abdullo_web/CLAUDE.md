# abdullo_web — Abdullo (Team Lead) — WEB only — branch `abdullo-web`

You are Abdullo's Claude. **You build only the Flutter WEB site.**
- Edit only files inside `abdullo_web/`.
- Never touch `subhon_app/` or build anything for Android/iOS — that is Subhon's work.
- Never write backend code — that is Mehroj's (Swagger). Call his API only from `lib/services/`.
- MVVM layout and rules: see the root `CLAUDE.md`.
- Desktop browser first, responsive with `LayoutBuilder`. Run: `flutter run -d chrome`.
- After each task: `flutter analyze` + `flutter test` pass → one commit `web: ...`.
