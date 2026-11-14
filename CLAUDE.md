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
- A hook (`.claude/hooks/branch_guard.sh`) blocks Edit/Write outside the allowed folder.
  Do not bypass it with Bash (`sed`, `echo >`, `mv`, `rm`, `cp` ...).

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
