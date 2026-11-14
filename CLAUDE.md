# AI Business Assistant — rules for Claude (read first, always)

## Team
| Person | Role | Branch | Folder Claude may edit |
|---|---|---|---|
| **Abdullo** (Team Lead) | Flutter **Web** | `abdullo-web` | `lib/web/`, `test/web/`, `web/` |
| **Subhon** | Flutter **App** (Android/iOS) | `subhon-app` | `lib/app/`, `test/app/`, `android/`, `ios/` |
| **Mehroj** | Backend + Swagger | — (not in this repo) | nothing here |

## Step 0 — find out who you work for
Before ANY change run `git branch --show-current` and follow the matching rule:
- `abdullo-web*` → you are **Abdullo's Claude**. You build **only the WEB**. See `lib/web/CLAUDE.md`.
- `subhon-app*` → you are **Subhon's Claude**. You build **only the mobile APP**. See `lib/app/CLAUDE.md`.
- `main` → Team Lead (Abdullo) only: shared files (`lib/main.dart`, `lib/core/`, `CLAUDE.md`, `.claude/`, `.gitignore`), merges.
- anything else → do not edit; ask the user to switch to their branch.

If the user asks for work that belongs to another person (e.g. app screens on `abdullo-web`,
web pages on `subhon-app`, or backend code anywhere) **refuse** and say whose job it is.
Never write backend/server code — that is Mehroj's. Use his Swagger as the API contract.
`pubspec.yaml` / `pubspec.lock` may be changed on both branches (only to add packages).
A hook in `.claude/hooks/branch_guard.sh` also blocks edits outside the allowed folders.
Do not bypass it with Bash (`sed`, `echo >`, `mv`, `rm` ...) on files outside your folder.

## Architecture — MVVM (provider + ChangeNotifier)
Each side (`lib/web/`, `lib/app/`) has the same layout:
```
models/      plain data classes, fromJson/toJson (match Swagger DTOs)
services/    API calls via core/network/api_client.dart, return models
viewmodels/  ChangeNotifier: state (isLoading, error, data) + actions; calls services
views/       screens; read state with context.watch<VM>(), call VM methods
widgets/     small reusable UI pieces for this side only
```
Rules:
- View → ViewModel → Service → ApiClient. A View never calls a Service or `http` directly.
- ViewModels never import `material.dart` widgets or use `BuildContext`.
- Register ViewModels in `web_app.dart` / `mobile_app.dart` (`MultiProvider`).
- File names `snake_case`, one class per file; suffixes `_model`, `_service`, `_view_model`, `_view`.
- Web code never imports from `lib/app/`, app code never imports from `lib/web/`. Both may import `lib/core/`.
- Need something new in `lib/core/`? Tell the user to ask the Team Lead (done on `main`).

## Commits — one task = one commit
After every finished task:
1. `flutter analyze` and `flutter test` must pass.
2. `git add` only the files of that task (never secrets, never build output).
3. Make **one** commit with a prefix: `web: ...` (Abdullo) or `app: ...` (Subhon) or `core: ...` (main).
   Example: `web: add login page with LoginViewModel`.
Do not push, merge or switch branches unless the user asks.
