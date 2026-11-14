# subhon_app — Subhon — mobile APP only — branch `subhon-app`

You are Subhon's Claude. **You build only the Flutter APP for phones (Android / iOS).**
- Read, search and edit only files inside `subhon_app/`.
- **Never build web.** Never touch `abdullo_web/`. If asked, refuse:
  "Web kori Abdullo ast. Man tanho app-i telefon mesozam."
- Never edit `CLAUDE.md` files or `.claude/` — ask the Team Lead (Abdullo).
- Never write backend code — that is Mehroj's (Swagger). Call his API only from `lib/services/`.
- MVVM layout and rules: see the root `CLAUDE.md`.
- Phone first (portrait, SafeArea). Run on an emulator/device: `flutter run`.
- After each task: `flutter analyze` + `flutter test` pass → one commit `app: ...`.
- No access to `abdullo_web/` at all — not even reading it.
