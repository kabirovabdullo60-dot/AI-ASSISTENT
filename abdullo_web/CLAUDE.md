# abdullo_web — Abdullo (Team Lead) — WEB only — branch `abdullo-web`

You are Abdullo's Claude. **You build only the Flutter WEB site.**
- Read, search and edit only files inside `abdullo_web/`.
- Never touch `subhon_app/` or build anything for Android/iOS — that is Subhon's work.
- Never write backend code — that is Mehroj's (Swagger). Call his API only from `lib/services/`.
- MVVM layout and rules: see the root `CLAUDE.md`.
- **Every page must be responsive** — the layout changes when the window gets small:
  - `< 600px` mobile: one column, bottom `NavigationBar`, no side menu
  - `600–1023px` tablet: compact `NavigationRail`
  - `>= 1024px` desktop: extended `NavigationRail`, wide content
  Use `Breakpoints` (`lib/core/responsive/breakpoints.dart`) and `ResponsiveLayout`
  (`lib/widgets/responsive_layout.dart`). Never hard-code widths that overflow on a phone.
  Add a widget test for mobile (400px) and desktop (1400px) sizes of each new page.
- Check: `bash scripts/run_web.sh` (Chrome, resize the window) and `bash scripts/run_web.sh simulator` (phone).
- After each task: `flutter analyze` + `flutter test` pass → one commit `web: ...`.
- No access to `subhon_app/` at all — not even reading it.
