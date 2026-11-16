# AI Business Assistant — rules for Claude (read first, always)

## Team
| Person | Role | Folder | Branch |
|---|---|---|---|
| **Abdullo** (Team Lead) | Flutter **Web** | `abdullo_web/` | `abdullo-web` |
| **Subhon** | Flutter **mobile App** (Android/iOS) | `subhon_app/` | `subhon-app` |
| **Mehroj** | Backend + Swagger | no folder in this repo | — |

## Step 0 — who are you working for?
1. If the user says who they are ("man Subhon hastam", "I am Subhon", "man Abdullo") — that decides.
2. Otherwise use `git branch --show-current`: `subhon-app*` → Subhon, `abdullo-web*` → Abdullo.
3. If still unknown, ask: "Shumo kī hasted — Abdullo (web) yo Subhon (app)?" and do nothing until answered.

### Subhon → mobile APP only
- Work only inside `subhon_app/`, on branch `subhon-app`. Rules: `subhon_app/CLAUDE.md`.
- **Never build web.** Never touch `abdullo_web/`. If asked for web: refuse —
  "Web kori Abdullo ast. Man tanho app-i telefon mesozam."

### Abdullo → WEB only
- Work only inside `abdullo_web/`, on branch `abdullo-web`. Rules: `abdullo_web/CLAUDE.md`.
- **Never build the mobile app.** Never touch `subhon_app/`. If asked for the app: refuse —
  "App kori Subhon ast. Man tanho web mesozam."

### Everyone
- Never write backend/server code — that is Mehroj's. His Swagger is the API contract.
- If the user's identity and the current branch don't match (e.g. Subhon on `abdullo-web`),
  stop and tell them to run `git switch subhon-app` (or `abdullo-web`) first.
- `CLAUDE.md` files, `.claude/` and the root `.gitignore` change only on `main` (Team Lead).
- **No access to the other person's folder at all** — do not read, search, open, copy,
  import, run or edit anything in it. Subhon's Claude never looks into `abdullo_web/`,
  Abdullo's Claude (on `abdullo-web`) never looks into `subhon_app/`.
- **Seeing the other person's RESULT is allowed** (running, not reading code). Use only these scripts:
  - `bash scripts/run_app.sh` — Subhon's app in the iOS Simulator (`android` for an Android emulator)
  - `bash scripts/run_web.sh` — Abdullo's web in Chrome; `bash scripts/run_web.sh simulator` — web in the iOS Simulator
  Run them when the user asks to "see/open/run" the other part. Never read their code to do it.
- A hook (`.claude/hooks/branch_guard.sh`) enforces this for Read, Glob, Grep, Bash, Edit and Write.
  Never try to get around it (other paths, symlinks, scripts, `cat`, `cp`, `find` ...).

## Architecture — MVVM (provider + ChangeNotifier), same in both projects
```
lib/
  main.dart     app root, MultiProvider registers ViewModels
  core/         api_client.dart, api_constants.dart (base URL from Mehroj)
  models/       data classes, fromJson/toJson matching Swagger DTOs
  services/     API calls through ApiClient, return models
  viewmodels/   ChangeNotifier: isLoading, error, data + actions; call services
  views/        screens; context.watch<VM>(), call VM methods
  widgets/      small reusable UI pieces
```
- View → ViewModel → Service → ApiClient. A View never calls a Service or `http` directly.
- ViewModels never use `BuildContext` or widgets.
- `snake_case` files, one class per file, suffixes `_model`, `_service`, `_view_model`, `_view`.

## Commits — one task = one commit
After every finished task, inside your project folder:
1. `flutter analyze` and `flutter test` must pass.
2. `git add` only that task's files (never secrets or build output).
3. **One** commit: `web: ...` (Abdullo) or `app: ...` (Subhon). Example: `app: add login screen`.
Do not push, merge or switch branches unless the user asks.

## Skills & plugin (both projects)
`abdullo_web/.claude/skills/` and `subhon_app/.claude/skills/` hold the official Flutter/Dart skills
(from `flutter/agent-plugins` and `dart-lang/skills`). Each project's `.claude/settings.json` also enables
the `dart-flutter` plugin (skills + Dart MCP server). When a project is opened the first time, Claude Code
asks to trust the marketplace — answer yes. Manual install, if needed:
`claude plugin marketplace add flutter/agent-plugins` then `claude plugin install dart-flutter@dart-flutter`.
