# Business Management System — API for the Flutter apps

> Generated from the live Swagger (`/openapi.json`) of Mehroj's backend (regenerated 2026-11-21 with `python3 scripts/gen_api_md.py` — run it again after every backend deploy). The web (Abdullo) is connected to every endpoint below.
> **Mobile app:** give this file to Claude and say: *"Connect the app to this API following API.md"*.

- **Base URL:** `https://api-production-86caefb2.up.railway.app`
- **Swagger UI (try it):** https://api-production-86caefb2.up.railway.app/docs
- **OpenAPI JSON:** https://api-production-86caefb2.up.railway.app/openapi.json

## How to connect (read first)

1. **Auth flow**
   - `POST /api/auth/register` or `POST /api/auth/login` → response: `accessToken`, `refreshToken`, `user`.
   - Save **both** tokens on the device (e.g. `flutter_secure_storage`).
   - Send `Authorization: Bearer <accessToken>` on every 🔒 endpoint.
   - `accessToken` lives **30 min**, `refreshToken` **30 days**.
   - On `401` with `error.code == "AUTH_TOKEN_EXPIRED"`: call `POST /api/auth/refresh {"refreshToken": "..."}` **once**, save **both** new tokens, retry the request.
     A refresh token works only once — reusing an old one ends the session (`AUTH_SESSION_REVOKED`). If several requests fail at the same time, let them share one refresh call.
   - Any other 401 (`AUTH_SESSION_REVOKED`, `AUTH_TOKEN_INVALID`, `AUTH_REQUIRED`) → clear tokens, show the login screen.
   - App start: if a refresh token is saved, call `GET /api/auth/me`; success = signed in.
   - Logout: `POST /api/auth/logout {"refreshToken": "..."}`, then clear tokens.
2. **JSON keys are camelCase.** Unknown keys are rejected (422).
3. **Money is a decimal STRING in TJS**: `"1250.50"`. Parse with `double.parse(...)`; send amounts as strings with 2 decimals: `amount.toStringAsFixed(2)`.
4. **Dates** are `YYYY-MM-DD` in the business calendar (Asia/Dushanbe) → parse as a local date, not UTC. **Timestamps** (`createdAt`) are ISO-8601 UTC.
5. **IDs** are UUID strings.
6. **Lists** return `{items, total, page, limit, pages}` (sales and payments also `totalAmount`). Query `?page=1&limit=20` (limit ≤ 100) and `?sort=-saleDate` (`-` = descending; allowed sort fields are listed per endpoint).
7. **PUT updates only the fields you send.** Send `null` to clear an optional field.
8. **DELETE is a soft delete** — history is never lost.
9. **Phone** must match `^\+?[0-9]{7,15}$` → strip spaces and dashes before sending (`+992901234567`).
10. **Errors** always look like this — switch on `error.code` and show your own translated text (en / ru / tg):
    ```json
    {"error": {"code": "STORE_NOT_FOUND", "message": "Store not found.", "details": [], "meta": {}, "requestId": "..."}}
    ```
    `422 VALIDATION_ERROR` lists each problem in `details` (`location`, `field`, `code`, `message`).
11. Send `Accept-Language: en | ru | tg`.
12. **Multi-tenant:** one account = one business, it sees only its own data (another business's record answers 404).
13. CORS limits only the web build; the Android/iOS app is not affected.

### Suggested Flutter structure (MVVM, same as the web)

- `core/network/api_client.dart` — base URL, adds the token, refresh-once-and-retry on `AUTH_TOKEN_EXPIRED`, turns error bodies into `ApiException(statusCode, code, message, details)`.
- One service per tag below: `AuthService`, `ProfileService`, `StoreService`, `SalesService`, `EmployeeService`, `PayrollService`, `ExpenseService`, `TargetService`, `ReportsService`, `ActivityService`, `NotificationService`, `AssistantService`, `ExchangeRateService`.
- Models with `fromJson` that parse money strings with `double.parse` and dates as local dates.
- ViewModels call services; views never call `http` directly.

### Which endpoint for which screen

| Screen | Endpoints |
|---|---|
| Login / Register | `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/me` |
| Dashboard | `GET /api/reports/dashboard` (incl. `monthProfit`, `weekTarget`, `monthTarget`), `GET /api/sales/daily`, `GET /api/sales/weekly`, `GET /api/reports/monthly-sales`, `GET /api/reports/store-comparison`, `GET /api/activity`, `PUT /api/targets` |
| Stores | `GET/POST /api/stores`, `PUT/DELETE /api/stores/{id}`, `GET /api/sales/store/{storeId}`, `GET /api/employees/store/{storeId}` |
| Sales | `GET/POST /api/sales`, `PUT/DELETE /api/sales/{id}` |
| Employees | `GET/POST /api/employees`, `PUT/DELETE /api/employees/{id}`, `GET /api/reports/employees` |
| Salaries | `GET /api/payroll/monthly?month=&year=`, `POST /api/payroll`, `GET /api/payroll`, `GET /api/payroll/employee/{employeeId}`, `DELETE /api/payroll/{id}` |
| Expenses & profit | `GET/POST /api/expenses`, `PUT/DELETE /api/expenses/{id}`, `GET /api/reports/profit` |
| Reports | `GET /api/reports/store-comparison`, `GET /api/reports/payroll?year=`, `GET /api/reports/employees` |
| AI assistant — chat | `POST /api/assistant/chat` (`language` en / ru / tg, `conversationId`, last 20 messages; `429 RATE_LIMITED`, `503 ASSISTANT_UNAVAILABLE`) |
| AI assistant — history | `GET/POST /api/assistant/conversations`, `GET/PATCH/DELETE /api/assistant/conversations/{id}` |
| AI assistant — actions | `POST /api/assistant/actions/{id}/confirm`, `POST /api/assistant/actions/{id}/cancel`, `GET /api/assistant/actions/{id}` |
| Notifications (bell) | `GET /api/notifications`, `POST /api/notifications/read-all` |
| Currency (USD) | `GET /api/settings/exchange-rates` |
| Profile | `GET/PUT /api/profile`, `PATCH /api/profile/password`, `PATCH /api/profile/avatar` (multipart, field `file`) |

### AI assistant — rules for the apps

1. **Chat history lives on the server.** Send `conversationId` from the previous reply to continue a chat; without it a new conversation is saved. List with `GET /api/assistant/conversations?page=1&limit=20` (newest first), open one with `GET /api/assistant/conversations/{id}` (messages with their `actions` in their **current** status), rename with `PATCH`, delete with `DELETE` (then `404 CONVERSATION_NOT_FOUND`; if the open chat was deleted, send the next question without `conversationId`).
2. **The assistant proposes, the user confirms.** A reply may carry `actions` (`AssistantActionOut`). Under that message show one card per action: its `summary` as is, Cancel / Confirm; `danger: true` → red Confirm and one extra "Are you sure?". Disable both buttons while the request runs.
   - `POST /api/assistant/actions/{id}/confirm` (optional body `{"params": {…only the corrected fields}}`) → `DONE` (show ✓, reload the affected screens) or `FAILED` (show the translated `error.code`, allow Confirm again).
   - `/cancel` → `CANCELLED`. `CANCELLED` / `EXPIRED` cards are greyed out: "ask the assistant again".
   - `409 ACTION_ALREADY_HANDLED` → `GET /api/assistant/actions/{id}` and show the real status. `409 ACTION_EXPIRED` → greyed out. `404 ACTION_NOT_FOUND`.
3. **Answer in the language the user writes in**, not the app's language: detect it from the question and send it as `language` — Tajik letters (ӣ ӯ ҳ ҷ қ ғ) or Tajik words in Cyrillic → `tg`; other Cyrillic → `ru`; Latin letters with Tajik words (`yak`, `magazin`, `ilova`, `kun`, `imruz`, `furush`…) → `tg`; other Latin → `en`; too short to tell (`ok`, `100`) → the app's language.
4. **Slow answers:** 3–60 s. Show a typing indicator and use a client timeout of at least **70 s**. `429 RATE_LIMITED` → wait `error.meta.retryAfter` seconds (10 questions a minute, 200 a day). `503 ASSISTANT_UNAVAILABLE` → "try again later".

## Endpoints overview

| Auth | Method | Path | What |
|---|---|---|---|
|  | `POST` | `/api/auth/register` | Create an account (and your business) |
|  | `POST` | `/api/auth/login` | Log in |
|  | `POST` | `/api/auth/refresh` | Get new tokens |
|  | `POST` | `/api/auth/logout` | Log out |
| 🔒 | `GET` | `/api/auth/me` | The current user |
| 🔒 | `GET` | `/api/profile` | Get my profile |
| 🔒 | `PUT` | `/api/profile` | Update my profile |
| 🔒 | `PATCH` | `/api/profile/avatar` | Upload my avatar |
| 🔒 | `PATCH` | `/api/profile/password` | Change my password |
| 🔒 | `POST` | `/api/stores` | Add a store |
| 🔒 | `GET` | `/api/stores` | List stores |
| 🔒 | `GET` | `/api/stores/{id}` | Get a store |
| 🔒 | `PUT` | `/api/stores/{id}` | Update a store |
| 🔒 | `DELETE` | `/api/stores/{id}` | Delete a store (soft delete) |
| 🔒 | `POST` | `/api/sales` | Record a sale |
| 🔒 | `GET` | `/api/sales` | List sales |
| 🔒 | `GET` | `/api/sales/daily` | Daily sales report |
| 🔒 | `GET` | `/api/sales/weekly` | Weekly sales report (all stores) |
| 🔒 | `GET` | `/api/sales/monthly` | Monthly sales report (all stores) |
| 🔒 | `GET` | `/api/sales/store/{storeId}` | Sales of one store |
| 🔒 | `GET` | `/api/sales/{id}` | Get a sale |
| 🔒 | `PUT` | `/api/sales/{id}` | Update a sale |
| 🔒 | `DELETE` | `/api/sales/{id}` | Delete a sale (soft delete) |
| 🔒 | `POST` | `/api/employees` | Add an employee |
| 🔒 | `GET` | `/api/employees` | List employees |
| 🔒 | `GET` | `/api/employees/store/{storeId}` | Employees of one store |
| 🔒 | `GET` | `/api/employees/{id}` | Get an employee |
| 🔒 | `PUT` | `/api/employees/{id}` | Update an employee |
| 🔒 | `DELETE` | `/api/employees/{id}` | Delete an employee (soft delete) |
| 🔒 | `POST` | `/api/payroll` | Record a salary payment |
| 🔒 | `GET` | `/api/payroll` | List salary payments |
| 🔒 | `GET` | `/api/payroll/monthly` | Monthly payroll report |
| 🔒 | `GET` | `/api/payroll/summary` | Payroll summary of all employees |
| 🔒 | `GET` | `/api/payroll/employee/{employeeId}` | Salary history of one employee |
| 🔒 | `GET` | `/api/payroll/{id}` | Get a salary payment |
| 🔒 | `DELETE` | `/api/payroll/{id}` | Cancel a salary payment (soft delete) |
| 🔒 | `POST` | `/api/expenses` | Record an expense |
| 🔒 | `GET` | `/api/expenses` | List expenses |
| 🔒 | `GET` | `/api/expenses/{id}` | Get an expense |
| 🔒 | `PUT` | `/api/expenses/{id}` | Update an expense |
| 🔒 | `DELETE` | `/api/expenses/{id}` | Delete an expense (soft delete) |
| 🔒 | `PUT` | `/api/targets` | Set a sales target |
| 🔒 | `GET` | `/api/targets` | List sales targets |
| 🔒 | `GET` | `/api/reports/dashboard` | Business dashboard |
| 🔒 | `GET` | `/api/reports/weekly-sales` | Weekly sales of all stores |
| 🔒 | `GET` | `/api/reports/monthly-sales` | Monthly sales of all stores |
| 🔒 | `GET` | `/api/reports/store-comparison` | Compare stores |
| 🔒 | `GET` | `/api/reports/profit` | Profit for a period |
| 🔒 | `GET` | `/api/reports/employees` | Employees report |
| 🔒 | `GET` | `/api/reports/payroll` | Payroll report for a year |
| 🔒 | `GET` | `/api/activity` | Business activity log |
| 🔒 | `GET` | `/api/notifications` | My notifications |
| 🔒 | `POST` | `/api/notifications/read-all` | Mark all notifications as read |
| 🔒 | `POST` | `/api/assistant/chat` | Ask the AI business assistant |
| 🔒 | `GET` | `/api/assistant/conversations` | List saved conversations |
| 🔒 | `POST` | `/api/assistant/conversations` | Save a conversation (without asking the AI) |
| 🔒 | `GET` | `/api/assistant/conversations/{id}` | Get a saved conversation |
| 🔒 | `PATCH` | `/api/assistant/conversations/{id}` | Rename a conversation |
| 🔒 | `DELETE` | `/api/assistant/conversations/{id}` | Delete a conversation (soft delete) |
| 🔒 | `GET` | `/api/assistant/actions/{id}` | Get a proposed action |
| 🔒 | `POST` | `/api/assistant/actions/{id}/confirm` | Confirm a proposed action (run it) |
| 🔒 | `POST` | `/api/assistant/actions/{id}/cancel` | Cancel a proposed action |
| 🔒 | `GET` | `/api/settings/exchange-rates` | Exchange rates |
|  | `GET` | `/health/live` | The process is running |
|  | `GET` | `/health/ready` | The database is reachable |

## Auth

Register, log in, rotate tokens, log out. Ҳар як корбар аккаунти шахсӣ ва бизнеси худро дорад.

### `POST /api/auth/register`

**Create an account (and your business)**

Creates the user, a new business owned by them (role `OWNER`), and logs in. All data you add later belongs to this business only.

Body (`application/json`): **RegisterRequest**

Responses:
- `201` Successful Response → **AuthResponse**
- `409` Conflicts with the current state: `EMAIL_ALREADY_REGISTERED` → **ErrorResponse**
- `422` Validation or business-rule error: `PASSWORD_TOO_WEAK`, `VALIDATION_ERROR` → **ErrorResponse**

### `POST /api/auth/login`

**Log in**

Returns an access token and a refresh token. After 10 failed attempts in a row the account is locked for 15 minutes (`429 AUTH_ACCOUNT_LOCKED`, see `Retry-After`).

Body (`application/json`): **LoginRequest**

Responses:
- `200` Successful Response → **AuthResponse**
- `401` Not authenticated or the token is not valid: `AUTH_INVALID_CREDENTIALS` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**
- `429` Too many attempts: `AUTH_ACCOUNT_LOCKED` → **ErrorResponse**

### `POST /api/auth/refresh`

**Get new tokens**

Exchanges a refresh token for a new access token **and a new refresh token**. The old refresh token stops working. Using an old one again ends the whole session (`AUTH_SESSION_REVOKED`), so refresh only once at a time (single-flight).

Body (`application/json`): **RefreshRequest**

Responses:
- `200` Successful Response → **TokenPair**
- `401` Not authenticated or the token is not valid: `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `POST /api/auth/logout`

**Log out**

Ends the session of this refresh token; its access token stops working too. Works even when the access token has already expired. Idempotent.

Body (`application/json`): **RefreshRequest**

Responses:
- `204` Successful Response
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/auth/me` 🔒

**The current user**

Same data as `GET /api/profile`.

Responses:
- `200` Successful Response → **ProfileOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

## Profile

The current user's profile, avatar and password. Профили шахсӣ.

### `GET /api/profile` 🔒

**Get my profile**

Responses:
- `200` Successful Response → **ProfileOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

### `PUT /api/profile` 🔒

**Update my profile**

Send only the fields you want to change. `phone: null` removes the phone number. `businessName` renames your business.

Body (`application/json`): **ProfileUpdate**

Responses:
- `200` Successful Response → **ProfileOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `409` Conflicts with the current state: `EMAIL_ALREADY_REGISTERED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PATCH /api/profile/avatar` 🔒

**Upload my avatar**

`multipart/form-data` with one field `file`: a JPEG, PNG or WebP image of at most 5 MB. Replaces the previous avatar. The response contains the new public `avatar` URL.

Body (`multipart/form-data`): **Body_upload_avatar**

Responses:
- `200` Successful Response → **ProfileOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `413` Too large: `AVATAR_TOO_LARGE` → **ErrorResponse**
- `415` Unsupported file type: `AVATAR_INVALID_TYPE` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PATCH /api/profile/password` 🔒

**Change my password**

Every other device is logged out. The current session stays logged in.

Body (`application/json`): **PasswordChange**

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `CURRENT_PASSWORD_INCORRECT`, `PASSWORD_TOO_WEAK`, `VALIDATION_ERROR` → **ErrorResponse**

## Stores

Stores of the business (ACTIVE / INACTIVE). Мағозаҳо. Deleting a store keeps its sales history.

### `POST /api/stores` 🔒

**Add a store**

Store names are unique within your business (case-insensitive).

Body (`application/json`): **StoreCreate**

Responses:
- `201` Successful Response → **StoreOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `409` Conflicts with the current state: `STORE_NAME_TAKEN` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/stores` 🔒

**List stores**

Deleted stores are hidden unless `includeDeleted=true`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `status` | query | StoreStatus \| null |  | Only this status.  |
| `search` | query | string \| null |  | Part of the name, address, city, region, type, opening hours or status note. maxLength=`100` |
| `includeDeleted` | query | boolean |  |  default=`false` |
| `sort` | query | string \| null |  | `name` (default), `createdAt`, `status`; `-` = descending.  |
| `city` | query | string \| null |  | Only this city (case-insensitive). maxLength=`100` |
| `region` | query | string \| null |  | Only this region (case-insensitive). maxLength=`100` |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_StoreOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/stores/{id}` 🔒

**Get a store**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The store ID.  |

Responses:
- `200` Successful Response → **StoreOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PUT /api/stores/{id}` 🔒

**Update a store**

Send only the fields you want to change. Set `status` to `INACTIVE` for a closed store: its sales still count in every report.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The store ID.  |

Body (`application/json`): **StoreUpdate**

Responses:
- `200` Successful Response → **StoreOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `409` Conflicts with the current state: `STORE_NAME_TAKEN` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/stores/{id}` 🔒

**Delete a store (soft delete)**

The store is hidden and set to `INACTIVE`. Its sales are **not** deleted and keep appearing in reports. A store with ACTIVE employees can't be deleted (`STORE_HAS_ACTIVE_EMPLOYEES`): move them to another store or deactivate them first.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The store ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `409` Conflicts with the current state: `STORE_HAS_ACTIVE_EMPLOYEES` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Sales

Sales records of each store, plus daily, weekly and monthly reports (all stores, ACTIVE and INACTIVE). Фурӯши мағозаҳо.

### `POST /api/sales` 🔒

**Record a sale**

`saleDate` defaults to today. The store must exist and not be deleted. Optional: `paymentMethod`, `receiptNumber`, and a split into `cashAmount` + `cardAmount` that must add up to `amount` (`422 SALE_SPLIT_MISMATCH`). `registeredById` / `registeredByName` are set from your login, don't send them.

Body (`application/json`): **SaleCreate**

Responses:
- `201` Successful Response → **SaleOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `SALE_DATE_IN_FUTURE`, `SALE_SPLIT_MISMATCH`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales` 🔒

**List sales**

Newest first. `totalAmount` is the sum of all matching sales (all pages).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | query | string (uuid) \| null |  |   |
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `sort` | query | string \| null |  | `saleDate`, `amount`, `createdAt`; `-` = descending. Default `-saleDate,-createdAt`.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **SalePage**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales/daily` 🔒

**Daily sales report**

Sales of every store on one day, compared with the day before. Also `byPaymentMethod` and `byHour` (24 entries, by the hour each sale was entered).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `date` | query | string (date) \| null |  | `YYYY-MM-DD`. Defaults to today.  |

Responses:
- `200` Successful Response → **SalesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales/weekly` 🔒

**Weekly sales report (all stores)**

Same report as `GET /api/reports/weekly-sales`. Defaults to the current Monday–Sunday week. With only `startDate` (or only `endDate`) the range is 7 days. **Range: 1 to 366 days**; longer or reversed ranges answer `422 INVALID_DATE_RANGE`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |

Responses:
- `200` Successful Response → **SalesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales/monthly` 🔒

**Monthly sales report (all stores)**

Same report as `GET /api/reports/monthly-sales`: one calendar month, compared with the previous month.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `month` | query | integer \| null |  | 1–12. Defaults to the current month. minimum=`1`, maximum=`12` |
| `year` | query | integer \| null |  | Defaults to the current year. minimum=`2000`, maximum=`2100` |

Responses:
- `200` Successful Response → **SalesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales/store/{storeId}` 🔒

**Sales of one store**

Works for deleted stores too, so their history stays available.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | path | string (uuid) | yes | The store ID.  |
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `sort` | query | string \| null |  | `saleDate`, `amount`, `createdAt`; `-` = descending. Default `-saleDate,-createdAt`.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **SalePage**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/sales/{id}` 🔒

**Get a sale**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The sale ID.  |

Responses:
- `200` Successful Response → **SaleOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `SALE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PUT /api/sales/{id}` 🔒

**Update a sale**

Send only the fields you want to change. Changing `amount` without `cashAmount` / `cardAmount` clears a split that no longer adds up.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The sale ID.  |

Body (`application/json`): **SaleUpdate**

Responses:
- `200` Successful Response → **SaleOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `SALE_NOT_FOUND`, `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `SALE_DATE_IN_FUTURE`, `SALE_SPLIT_MISMATCH`, `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/sales/{id}` 🔒

**Delete a sale (soft delete)**

The sale no longer counts in lists and reports, but stays in the database.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The sale ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `SALE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Employees

Employees, their store, salary and employment dates. Кормандон.

### `POST /api/employees` 🔒

**Add an employee**

The store must exist and not be deleted. The salary is remembered in the salary history from the month of `hiredAt`.

Body (`application/json`): **EmployeeCreate**

Responses:
- `201` Successful Response → **EmployeeOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_EMPLOYMENT_DATES`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/employees` 🔒

**List employees**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | query | string (uuid) \| null |  |   |
| `status` | query | EmployeeStatus \| null |  | Only this status.  |
| `search` | query | string \| null |  | Part of the name, position or phone. maxLength=`100` |
| `includeDeleted` | query | boolean |  |  default=`false` |
| `sort` | query | string \| null |  | `fullName` (default), `position`, `hiredAt`, `monthlySalary`, `createdAt`; `-` = descending.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_EmployeeOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/employees/store/{storeId}` 🔒

**Employees of one store**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | path | string (uuid) | yes | The store ID.  |
| `status` | query | EmployeeStatus \| null |  | Only this status.  |
| `search` | query | string \| null |  | Part of the name, position or phone. maxLength=`100` |
| `includeDeleted` | query | boolean |  |  default=`false` |
| `sort` | query | string \| null |  | `fullName` (default), `position`, `hiredAt`, `monthlySalary`, `createdAt`; `-` = descending.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_EmployeeOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/employees/{id}` 🔒

**Get an employee**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The employee ID.  |

Responses:
- `200` Successful Response → **EmployeeOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EMPLOYEE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PUT /api/employees/{id}` 🔒

**Update an employee**

Send only the fields you want to change. A new `monthlySalary` applies from the current month on; earlier months keep their salary (see `GET /api/payroll/employee/{employeeId}` → `salaryHistory`).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The employee ID.  |

Body (`application/json`): **EmployeeUpdate**

Responses:
- `200` Successful Response → **EmployeeOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EMPLOYEE_NOT_FOUND`, `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_EMPLOYMENT_DATES`, `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/employees/{id}` 🔒

**Delete an employee (soft delete)**

The employee is hidden and set to `INACTIVE`; `terminatedAt` becomes today if it was empty. **Nothing more is owed**: in every salary figure (payroll, the dashboard's `salaryDueThisMonth` and `monthProfit`, profit, notifications) a deleted employee's due equals what was already paid to them, so unpaid salary stops counting and they can't be paid any more. Payments already made stay in reports and in `GET /api/payroll/employee/{employeeId}`. For someone who left the job, set `status: INACTIVE` instead: they stay owed up to `terminatedAt`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The employee ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EMPLOYEE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Payroll

Salary payments with automatic calculation: months worked, salary due per month, paid and remaining amounts, partial payments, protection against paying twice. Маоши кормандон.

### `POST /api/payroll` 🔒

**Record a salary payment**

Records money paid to an employee for one month (`month` + `year`).

The backend checks everything and calculates the balance:
* the employee must not be deleted (`404 EMPLOYEE_NOT_FOUND`): a deleted employee is owed
  nothing more;
* the month can't be in the future, and the employee must have worked in it
  (from `hiredAt` to `terminatedAt`; the first and last month are prorated by days);
* **partial payments** are fine: pay 1500 now and 1500 later;
* the payments of a month can never exceed the salary due for it, so nothing is paid twice:
  `409 PAYROLL_ALREADY_PAID` when the month is fully paid, `422 PAYROLL_AMOUNT_EXCEEDS_REMAINING`
  when the amount is too big. Both errors carry `meta.dueAmount`, `meta.paidAmount` and
  `meta.remainingAmount`.

The response contains the month's balance after this payment (`period`) and its `status`.

Body (`application/json`): **PaymentCreate**

Responses:
- `201` Successful Response → **PaymentOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EMPLOYEE_NOT_FOUND` → **ErrorResponse**
- `409` Conflicts with the current state: `PAYROLL_ALREADY_PAID` → **ErrorResponse**
- `422` Validation or business-rule error: `PAYROLL_AMOUNT_EXCEEDS_REMAINING`, `PAYROLL_PERIOD_IN_FUTURE`, `EMPLOYEE_NOT_EMPLOYED_IN_PERIOD`, `PAYMENT_DATE_IN_FUTURE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/payroll` 🔒

**List salary payments**

Newest first. `totalAmount` is the sum of all matching payments.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `employeeId` | query | string (uuid) \| null |  |   |
| `storeId` | query | string (uuid) \| null |  | Only this store.  |
| `month` | query | integer \| null |  |  minimum=`1`, maximum=`12` |
| `year` | query | integer \| null |  |  minimum=`2000`, maximum=`2100` |
| `startDate` | query | string (date) \| null |  | Payment date from (included).  |
| `endDate` | query | string (date) \| null |  | Payment date to (included).  |
| `sort` | query | string \| null |  | `paymentDate`, `amount`, `createdAt`; `-` = descending.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **PaymentPage**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/payroll/monthly` 🔒

**Monthly payroll report**

For one month: every employee who worked in it, with the salary due, paid and remaining, and `PAID` / `PARTIAL` / `UNPAID`. Defaults to the current month.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `month` | query | integer \| null |  |  minimum=`1`, maximum=`12` |
| `year` | query | integer \| null |  |  minimum=`2000`, maximum=`2100` |
| `storeId` | query | string (uuid) \| null |  | Only this store.  |

Responses:
- `200` Successful Response → **MonthlyPayrollOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/payroll/summary` 🔒

**Payroll summary of all employees**

For every employee, over the whole employment up to the current month: hire date, months worked, current salary, total due, paid and remaining, and how many months are not fully paid. Plus totals and the current month's totals.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | query | string (uuid) \| null |  | Only this store.  |

Responses:
- `200` Successful Response → **PayrollSummaryOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/payroll/employee/{employeeId}` 🔒

**Salary history of one employee**

Hire date, months worked, salary history, every month with due / paid / remaining / status, and all payments. Works for deleted employees too: they list only the months with payments, and each month's due equals what was paid.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `employeeId` | path | string (uuid) | yes | The employee ID.  |

Responses:
- `200` Successful Response → **EmployeePayrollOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EMPLOYEE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/payroll/{id}` 🔒

**Get a salary payment**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The payment ID.  |

Responses:
- `200` Successful Response → **PaymentOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `PAYROLL_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/payroll/{id}` 🔒

**Cancel a salary payment (soft delete)**

For payments entered by mistake. The payment stays in the database but no longer counts, so the month's remaining amount goes back up.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The payment ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `PAYROLL_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Expenses

Business expenses (rent, utilities, delivery, …) of a store or the whole business, for profit and margin. Хароҷот.

### `POST /api/expenses` 🔒

**Record an expense**

For one store (`storeId`) or the whole business (`storeId: null`). `expenseDate` defaults to today and can't be in the future.

Body (`application/json`): **ExpenseCreate**

Responses:
- `201` Successful Response → **ExpenseOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `EXPENSE_DATE_IN_FUTURE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/expenses` 🔒

**List expenses**

Newest first. `totalAmount` is the sum of all matching expenses (all pages).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `storeId` | query | string (uuid) \| null |  | Only this store.  |
| `category` | query | ExpenseCategory \| null |  |   |
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `sort` | query | string \| null |  | `expenseDate`, `amount`, `createdAt`; `-` = descending. Default `-expenseDate,-createdAt`.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **ExpensePage**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/expenses/{id}` 🔒

**Get an expense**

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The expense ID.  |

Responses:
- `200` Successful Response → **ExpenseOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EXPENSE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PUT /api/expenses/{id}` 🔒

**Update an expense**

Send only the fields you want to change. `storeId: null` makes it an expense of the whole business.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The expense ID.  |

Body (`application/json`): **ExpenseUpdate**

Responses:
- `200` Successful Response → **ExpenseOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EXPENSE_NOT_FOUND`, `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `EXPENSE_DATE_IN_FUTURE`, `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/expenses/{id}` 🔒

**Delete an expense (soft delete)**

It no longer counts in lists and the profit report, but stays in the database.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The expense ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `EXPENSE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Targets

Weekly and monthly sales targets for a store or the whole business. Нақшаи фурӯш.

### `PUT /api/targets` 🔒

**Set a sales target**

Creates the target, or changes its amount when one already exists for the same `period` and `storeId` (`null` = the whole business). Always answers 200 with the target. The business-wide targets also appear on the dashboard (`weekTarget`, `monthTarget`).

Body (`application/json`): **TargetPut**

Responses:
- `200` Successful Response → **TargetOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/targets` 🔒

**List sales targets**

The whole business first, then stores by name; WEEK before MONTH.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_TargetOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Reports

Dashboard and management reports. Ҳисоботҳо.

### `GET /api/reports/dashboard` 🔒

**Business dashboard**

Total stores and employees, sales today / this week / this month, salary paid and remaining, and the best-selling store of the month.

Responses:
- `200` Successful Response → **DashboardOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

### `GET /api/reports/weekly-sales` 🔒

**Weekly sales of all stores**

Example: `?startDate=2026-11-09&endDate=2026-11-15`. Returns the total of all stores and every store separately (name, total, number of sales), compared with the previous period of the same length, plus `byDay` (one entry per day, for charts). **All stores count, ACTIVE and INACTIVE**, and deleted stores that sold in the period, so no sales history is lost. Defaults to the current Monday–Sunday week; with only `startDate` (or only `endDate`) the range is 7 days.

**Range: 1 to 366 days** (both dates included), so longer ranges such as the last 24 or 31 days work too. `startDate` after `endDate`, or a range longer than 366 days, answers `422 INVALID_DATE_RANGE`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |

Responses:
- `200` Successful Response → **SalesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/reports/monthly-sales` 🔒

**Monthly sales of all stores**

One calendar month, per store and in total, compared with the previous month, with a per-day series for charts. Defaults to the current month.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `month` | query | integer \| null |  |  minimum=`1`, maximum=`12` |
| `year` | query | integer \| null |  |  minimum=`2000`, maximum=`2100` |

Responses:
- `200` Successful Response → **SalesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/reports/store-comparison` 🔒

**Compare stores**

Stores ranked by sales in a period (default: the current month) with their share of the total, average sale, change vs the previous period of the same length, and number of active employees.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |

Responses:
- `200` Successful Response → **StoreComparisonOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/reports/profit` 🔒

**Profit for a period**

Sales minus expenses minus salary due, in total, per expense category and per
store. Defaults to the current month; `?startDate=&endDate=` for any range of up to
366 days (`422 INVALID_DATE_RANGE` otherwise).

* `salaryDue`: salary due for the period. A month only partly inside the range counts in
  proportion to its days (15 of 30 days = half); whole months count in full; months after
  the current one count as 0.
* `grossProfit = salesTotal - expensesTotal - salaryDue`; `marginPercent = grossProfit /
  salesTotal` in % (`null` without sales).
* `byStore`: every store (profit = its sales - its expenses - its employees' salary), then
  one row with `storeId: null` for expenses of the whole business. The rows add up to the
  totals. The current month's figures equal the dashboard's `monthProfit`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `startDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |
| `endDate` | query | string (date) \| null |  | `YYYY-MM-DD`, included.  |

Responses:
- `200` Successful Response → **ProfitOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/reports/employees` 🔒

**Employees report**

Headcount (active / inactive), new hires this month, monthly salary cost, and breakdowns by store and by position. Deleted employees are not counted.

Responses:
- `200` Successful Response → **EmployeesReportOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

### `GET /api/reports/payroll` 🔒

**Payroll report for a year**

Per month: salary due, paid and remaining for all employees. Defaults to the current year (January up to the current month).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `year` | query | integer \| null |  |  minimum=`2000`, maximum=`2100` |

Responses:
- `200` Successful Response → **PayrollYearOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Activity

The log of every change in the business (recent activity, a store's operations log). Таърихи амалиётҳо.

### `GET /api/activity` 🔒

**Business activity log**

Every change in your business, newest first: the dashboard's "Recent Business
Activity" and a store's "Operations Log" (`?storeId=…`).

Written automatically, in the same transaction as the change, when:
* a store is created, updated, deleted or its status changes (`STORE`);
* a sale is created, updated or deleted (`SALE`);
* an employee is created, updated, deleted or their status changes (`EMPLOYEE`);
* a salary payment is made or cancelled (`PAYROLL`: `PAID`, `CANCELLED`);
* the profile or the business name changes (`PROFILE`: `UPDATED`).

The response contains codes, not sentences: build the text in the app from `type` + `action`.
An update that changes the status and other fields gives two rows (`UPDATED` and
`STATUS_CHANGED`). `startDate` / `endDate` are business-calendar days (Asia/Dushanbe).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `type` | query | ActivityType \| null |  |   |
| `action` | query | ActivityAction \| null |  |   |
| `storeId` | query | string (uuid) \| null |  | Only this store (its operations log).  |
| `employeeId` | query | string (uuid) \| null |  | Only this employee (EMPLOYEE and PAYROLL rows).  |
| `startDate` | query | string (date) \| null |  | From this day (included).  |
| `endDate` | query | string (date) \| null |  | Until this day (included).  |
| `sort` | query | string \| null |  | `-createdAt` (default, newest first) or `createdAt`.  |
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_ActivityOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND`, `EMPLOYEE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `INVALID_DATE_RANGE`, `VALIDATION_ERROR` → **ErrorResponse**

## Notifications

Things that need attention: unpaid and overdue salaries, stores without sales today. Огоҳиномаҳо.

### `GET /api/notifications` 🔒

**My notifications**

Calculated on every request from your own data:

| kind | severity | count | amount | link |
|---|---|---|---|---|
| `SALARY_OVERDUE` | WARNING | unpaid employee-months before now | their unpaid salary | PAYROLL |
| `UNPAID_SALARIES` | INFO | employees still to be paid this month | the rest of it | PAYROLL |
| `STORE_NO_SALES_TODAY` | INFO | 1 (one per ACTIVE store without a sale today) | `null` | SALES |

A situation that is over disappears by itself (all paid, a sale recorded).
`unreadCount` counts the items that started after your last `POST /api/notifications/read-all`.

Responses:
- `200` Successful Response → **NotificationsOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

### `POST /api/notifications/read-all` 🔒

**Mark all notifications as read**

Everything shown now counts as read for you (`unreadCount` becomes 0). New situations (tomorrow's stores without sales, a month that becomes overdue) are unread again.

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

## Assistant

AI business assistant: answers questions about your own sales, stores, employees and payroll in English, Russian or Tajik, using the real figures of your business. It can read all your data and **propose changes** (add a store, record a sale, pay a salary…) that run only when the user confirms them. Chats are saved on the server per user (`conversationId`), so they show up on every device. Ёрдамчии зеҳни сунъӣ.

### `POST /api/assistant/chat` 🔒

**Ask the AI business assistant**

Answers questions about **your own business** ("How are my sales today?",
"Which store sells best?", "How much salary is still unpaid?") in the requested `language`.

The backend calculates the figures (the same ones as `/api/reports/dashboard`,
`/api/reports/store-comparison`, `/api/reports/employees` and `/api/payroll/monthly`) and
gives them to the language model, which is told to use only those numbers.
Data of other businesses is never used.

* Send the conversation oldest first, ending with the user's new message (`role: "user"`).
  At most 200 messages of 1–2000 characters each; only the
  last 20 are used. Answers are at most 2000 characters, so
  they can be sent back as they are.
* Per user: at most 10 questions a minute and 200 a day by default
  (`429 RATE_LIMITED` with `Retry-After` and `meta.retryAfter` in seconds).
* The model is Google Gemini (`GEMINI_MODEL`). When it is overloaded or out of quota the
  server retries once with a lighter model (`GEMINI_FALLBACK_MODEL`).
* `503 ASSISTANT_UNAVAILABLE` only when every model fails (the cause is logged on the server)
  or no key is configured: show a "try again later" message. An answer usually takes a few
  seconds, at most about 60.

**Chat history** (optional `conversationId`; clients that don't send it work as before):
* Without `conversationId` (or `null`), a new conversation is saved with **all** `messages`
  and the answer. Its title is the first user message (spaces collapsed, at most
  80 characters).
* With `conversationId`, only the **last** message (the new question) and the answer are added
  to that conversation. Still send the recent messages as before: they are what the model
  reads.
* The answer's `conversationId` is always set: send it with the next question.
* A conversation keeps its last 200 messages; older ones are dropped.
* Only a successful answer is saved: `422`, `429` and `503` save nothing. An unknown, deleted
  or another user's `conversationId` is `404 CONVERSATION_NOT_FOUND`, checked before the model
  is asked.

**Doing things** ("Add a store Central Plaza, 45 Rudaki Ave", in `en`, `ru` or `tg`):
* The assistant can **read** all data of your business with tools (one per `GET` endpoint,
  with the same parameters and the same answers), up to 6 rounds per question.
* It never changes data itself. A change comes back in `actions` as a **proposal**
  (`status: PROPOSED`) with a `summary` in the question's language, the exact `params` of the
  normal endpoint and `danger: true` for deletes. Show each with Confirm / Cancel and call
  `POST /api/assistant/actions/{id}/confirm` or `/cancel`. A proposal can be confirmed for
  30 minutes.
* When a required value is missing or a name matches several records, it asks a question
  instead. "Add 3 stores" gives 3 actions.
* Clients that ignore `actions` keep working: the answer text tells the user what was
  proposed. Auth (register, login, password) is never available to the assistant.

Body (`application/json`): **ChatRequest**

Responses:
- `200` Successful Response → **ChatReplyOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `CONVERSATION_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**
- `429` Too many attempts: `RATE_LIMITED` → **ErrorResponse**
- `503` Temporarily unavailable: `ASSISTANT_UNAVAILABLE` → **ErrorResponse**

### `GET /api/assistant/conversations` 🔒

**List saved conversations**

The signed-in user's saved assistant chats, **most recently updated first**
(`updatedAt` = when a message was last added). Each item has the title, `messageCount` and
`lastMessage` (the first 120 characters of the newest message), so a
chat list can be drawn without loading the messages. Deleted conversations are not listed.
Other users never see your conversations.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `page` | query | integer |  | Page number, starting at 1. minimum=`1`, default=`1` |
| `limit` | query | integer |  | Items per page (max 100). minimum=`1`, maximum=`100`, default=`20` |

Responses:
- `200` Successful Response → **Page_ConversationSummaryOut_**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `POST /api/assistant/conversations` 🔒

**Save a conversation (without asking the AI)**

Saves a chat the app already has, for example the chats kept in browser
storage before history was saved on the server. **The AI is not called** and no question is
counted against the limits.

* `messages`: 1–200 messages, oldest first, each 1–2000
  characters. Each `time` is kept (without a time zone it is read as business time); a message
  without `time` gets the server's time.
* `title` (optional, 1–80 characters). Default: the first user message, spaces
  collapsed and shortened to 80 characters.

Continue the chat with `POST /api/assistant/chat` and the returned `id` as `conversationId`.

Body (`application/json`): **ConversationCreate**

Responses:
- `201` Successful Response → **ConversationOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/assistant/conversations/{id}` 🔒

**Get a saved conversation**

The conversation with all its saved messages, **oldest first** (each with `role`, `text` and `time`). Another user's or a deleted conversation is `404 CONVERSATION_NOT_FOUND`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The conversation ID.  |

Responses:
- `200` Successful Response → **ConversationOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `CONVERSATION_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `PATCH /api/assistant/conversations/{id}` 🔒

**Rename a conversation**

Sets the `title` (1–80 characters). `updatedAt` doesn't change, so the conversation keeps its place in the list.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The conversation ID.  |

Body (`application/json`): **ConversationRename**

Responses:
- `200` Successful Response → **ConversationSummaryOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `CONVERSATION_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `DELETE /api/assistant/conversations/{id}` 🔒

**Delete a conversation (soft delete)**

The conversation disappears for the user: afterwards `GET`, `PATCH`, `DELETE` and `POST /api/assistant/chat` with this ID answer `404 CONVERSATION_NOT_FOUND`. It is kept in the database (`deletedAt`), like other deleted records.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The conversation ID.  |

Responses:
- `204` Successful Response
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `CONVERSATION_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `GET /api/assistant/actions/{id}` 🔒

**Get a proposed action**

A change the assistant proposed, with its current `status` (`PROPOSED`, `DONE`, `FAILED`, `CANCELLED`, `EXPIRED`). Another user's action is `404 ACTION_NOT_FOUND`.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The action ID.  |

Responses:
- `200` Successful Response → **AssistantActionOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `ACTION_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `POST /api/assistant/actions/{id}/confirm` 🔒

**Confirm a proposed action (run it)**

Runs the change **exactly like the normal endpoint** (the same validation,
activity log, notifications and soft-delete rules), in one transaction.

* Optional body `{"params": {…}}`: fields the user corrected. They replace the proposed ones;
  the others stay (`id` can't be changed). The params are validated again.
* `200` with `status: DONE` and `result` (what the endpoint returns, e.g. a `StoreOut`;
  `null` for deletes), or `200` with `status: FAILED` and `error` (`code` is the endpoint's own,
  e.g. `VALIDATION_ERROR`, `STORE_NAME_TAKEN`, `SALE_DATE_IN_FUTURE`). A `FAILED` action can be
  confirmed again with corrected `params`.
* Confirming a `DONE` action returns it again; the change never runs twice, even for two
  confirms at the same time.
* `409 ACTION_ALREADY_HANDLED` after Cancel; `409 ACTION_EXPIRED` more than
  30 minutes after the proposal (ask the assistant again).

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The action ID.  |

Body (`application/json`): **ActionConfirm \| null**

Responses:
- `200` Successful Response → **AssistantActionOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `ACTION_NOT_FOUND` → **ErrorResponse**
- `409` Conflicts with the current state: `ACTION_ALREADY_HANDLED`, `ACTION_EXPIRED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

### `POST /api/assistant/actions/{id}/cancel` 🔒

**Cancel a proposed action**

Nothing changes; the action becomes `CANCELLED` (cancelling it again returns it again). `409 ACTION_ALREADY_HANDLED` after Confirm, `409 ACTION_EXPIRED` when it expired.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The action ID.  |

Responses:
- `200` Successful Response → **AssistantActionOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `ACTION_NOT_FOUND` → **ErrorResponse**
- `409` Conflicts with the current state: `ACTION_ALREADY_HANDLED`, `ACTION_EXPIRED` → **ErrorResponse**
- `422` Validation or business-rule error: `VALIDATION_ERROR` → **ErrorResponse**

## Settings

Values the apps read from the server: exchange rates.

### `GET /api/settings/exchange-rates` 🔒

**Exchange rates**

How many TJS one unit of each currency is worth, for showing amounts in other currencies. Amounts in the API stay in TJS. The values are set on the server (`EXCHANGE_RATES`, `EXCHANGE_RATES_UPDATED_AT`).

Responses:
- `200` Successful Response → **ExchangeRatesOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**

## Health

Liveness and readiness probes (no auth).

### `GET /health/live`

**The process is running**

Responses:
- `200` Successful Response → **HealthOut**

### `GET /health/ready`

**The database is reachable**

Responses:
- `200` Successful Response
- `503` The database is down → **HealthOut**

## Schemas

### ActionConfirm

| Field | Type | Required | Notes |
|---|---|---|---|
| `params` | object \| null |  | Optional corrections made by the user: the fields sent replace the proposed ones, the others stay. `id` can't be changed.  |

### ActionErrorOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `code` | string | yes | The same code the normal endpoint returns, e.g. `VALIDATION_ERROR`, `STORE_NOT_FOUND`.  |
| `message` | string | yes | For developers. Show a translated text based on `code`.  |

### ActionStatus

Enum: `PROPOSED`, `DONE`, `FAILED`, `CANCELLED`, `EXPIRED`

### ActionType

The changes the assistant can propose. Each one is a normal endpoint.

Enum: `CREATE_STORE`, `UPDATE_STORE`, `DELETE_STORE`, `CREATE_SALE`, `UPDATE_SALE`, `DELETE_SALE`, `CREATE_EMPLOYEE`, `UPDATE_EMPLOYEE`, `DELETE_EMPLOYEE`, `CREATE_PAYROLL`, `DELETE_PAYROLL`, `CREATE_EXPENSE`, `UPDATE_EXPENSE`, `DELETE_EXPENSE`, `SET_TARGET`, `UPDATE_PROFILE`, `MARK_NOTIFICATIONS_READ`

### ActivityAction

Enum: `CREATED`, `UPDATED`, `DELETED`, `STATUS_CHANGED`, `PAID`, `CANCELLED`

### ActivityOut

One change. Build the sentence in the app from `type` + `action` (translated).

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `type` | ActivityType | yes |   |
| `action` | ActivityAction | yes | `CREATED`, `UPDATED`, `DELETED`, `STATUS_CHANGED` (stores, employees), `PAID` / `CANCELLED` (salary payments).  |
| `entityId` | string (uuid) | yes | The store, sale, employee, payment or user ID.  |
| `entityName` | string | yes | Name at the time of the change: the store name (STORE, SALE), the employee's name (EMPLOYEE, PAYROLL) or the user's name (PROFILE).  |
| `storeId` | string (uuid) \| null | yes |   |
| `storeName` | string \| null | yes |   |
| `employeeId` | string (uuid) \| null | yes | Set for EMPLOYEE and PAYROLL rows.  |
| `amount` | string \| null | yes | The record's amount, signed by money direction: sales are positive (`"1250.50"`), salary payments negative (`"-3000.00"`), also when deleted or cancelled. `null` for stores, employees and the profile. pattern=`^-?\d+\.\d{2}$` |
| `note` | string \| null | yes | The record's own note (sale description, payment note).  |
| `changedFields` | string[] \| null | yes | For `UPDATED`: the fields that changed (camelCase), e.g. `["name"]`.  |
| `status` | string \| null | yes | For `STATUS_CHANGED`: the new status (`ACTIVE` / `INACTIVE`).  |
| `period` | string \| null | yes | For PAYROLL: the salary month, `YYYY-MM`.  |
| `actorId` | string (uuid) | yes | The user who made the change.  |
| `actorName` | string | yes |   |
| `createdAt` | string (date-time) | yes |   |

### ActivityType

Enum: `STORE`, `SALE`, `EMPLOYEE`, `PAYROLL`, `PROFILE`

### AssistantActionOut

A change the assistant proposed. Nothing changes until the user confirms it.

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `type` | ActionType | yes | Which change, e.g. `CREATE_STORE`.  |
| `status` | ActionStatus | yes | `PROPOSED` (show Confirm / Cancel), `DONE`, `FAILED` (see `error`; can be confirmed again with corrected `params`), `CANCELLED`, `EXPIRED` (not confirmed within 30 minutes).  |
| `summary` | string | yes | One sentence in the language of the question, made by the backend from `params`.  |
| `danger` | boolean | yes | `true` for `DELETE_*`: show a red button.  |
| `params` | object | yes | Exactly the JSON body of the normal endpoint, plus `id` for updates and deletes.  |
| `result` | object \| null | yes | When `DONE`: what the normal endpoint returns (e.g. a `StoreOut`); `null` for deletes and otherwise.  |
| `error` | ActionErrorOut \| null | yes | When `FAILED`, otherwise `null`.  |
| `createdAt` | string (date-time) | yes | ISO 8601 UTC.  |
| `expiresAt` | string (date-time) | yes | `createdAt` + 30 minutes, ISO 8601 UTC.  |

### AuthResponse

| Field | Type | Required | Notes |
|---|---|---|---|
| `accessToken` | string | yes | Send as `Authorization: Bearer <accessToken>`.  |
| `refreshToken` | string | yes | Works once. Store the new one after each refresh.  |
| `tokenType` | string |  |  default=`Bearer`, const=`Bearer` |
| `expiresIn` | integer | yes | Seconds until the access token expires.  |
| `refreshExpiresIn` | integer | yes | Seconds until the refresh token expires.  |
| `user` | ProfileOut | yes |   |

### Body_upload_avatar

| Field | Type | Required | Notes |
|---|---|---|---|
| `file` | string | yes | JPEG, PNG or WebP image, at most 5 MB.  |

### BusinessOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `name` | string | yes |   |

### CategoryExpenseOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `category` | ExpenseCategory | yes |   |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |

### ChatMessage

| Field | Type | Required | Notes |
|---|---|---|---|
| `role` | string | yes | `user` (the person) or `assistant` (an earlier answer). one of `user`, `assistant` |
| `text` | string | yes | 1–2000 characters. minLength=`1`, maxLength=`2000` |
| `time` | string (date-time) \| null |  | When the message was written (ISO 8601). Optional and not used for answers. It is saved with the message in the chat history: without a time zone it is read as business time (Asia/Dushanbe); when absent, the server's time is used.  |

### ChatReplyOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `role` | string |  |  default=`assistant`, const=`assistant` |
| `text` | string | yes | The answer, plain text, at most 2000 characters, so it can be sent back in `messages` as it is.  |
| `time` | string (date-time) | yes | When the answer was made, ISO 8601 UTC.  |
| `conversationId` | string (uuid) | yes | The saved conversation this question and answer belong to. Send it as `conversationId` with the next question to continue the same chat.  |
| `actions` | AssistantActionOut[] |  | Changes the assistant proposed in this answer (empty when it only answered). Show each with Confirm / Cancel; nothing changes until `POST /api/assistant/actions/{id}/confirm`.  |

### ChatRequest

| Field | Type | Required | Notes |
|---|---|---|---|
| `language` | string | yes | Answer language: `en` English, `ru` Russian, `tg` Tajik (Cyrillic). one of `en`, `ru`, `tg` |
| `messages` | ChatMessage[] | yes | The conversation, oldest first, ending with the user's new question. Only the last 20 messages are used. minItems=`1`, maxItems=`200` |
| `conversationId` | string (uuid) \| null |  | The saved conversation to continue. Absent or `null`: a new conversation is saved with all `messages` and the answer. Given: only the last message (the new question) and the answer are added to it. Unknown, deleted or another user's ID: `404 CONVERSATION_NOT_FOUND`, before the model is asked.  |

### ConversationCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string \| null |  | Default: the first user message, shortened to 80 characters. minLength=`1`, maxLength=`80` |
| `messages` | ChatMessage[] | yes | The chat, oldest first: 1–200 messages. minItems=`1`, maxItems=`200` |

### ConversationMessageOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `role` | string | yes | `user` (the person) or `assistant` (an answer). one of `user`, `assistant` |
| `text` | string | yes |   |
| `time` | string (date-time) | yes | When the message was written, ISO 8601 UTC.  |
| `actions` | AssistantActionOut[] |  | The changes proposed in this answer, with their current status (empty for user messages).  |

### ConversationOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `title` | string | yes |   |
| `messageCount` | integer | yes | Saved messages (at most 200).  |
| `lastMessage` | string | yes | The first 120 characters of the newest message.  |
| `createdAt` | string (date-time) | yes | ISO 8601 UTC.  |
| `updatedAt` | string (date-time) | yes | When a message was last added, ISO 8601 UTC. Lists are sorted by it, newest first; renaming doesn't change it.  |
| `messages` | ConversationMessageOut[] | yes | Oldest first.  |

### ConversationRename

| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string | yes | 1–80 characters (spaces and line breaks collapse to one space). minLength=`1`, maxLength=`80` |

### ConversationSummaryOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `title` | string | yes |   |
| `messageCount` | integer | yes | Saved messages (at most 200).  |
| `lastMessage` | string | yes | The first 120 characters of the newest message.  |
| `createdAt` | string (date-time) | yes | ISO 8601 UTC.  |
| `updatedAt` | string (date-time) | yes | When a message was last added, ISO 8601 UTC. Lists are sorted by it, newest first; renaming doesn't change it.  |

### DashboardOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `today` | string (date) | yes |   |
| `weekStartDate` | string (date) | yes | Monday of the current week.  |
| `year` | integer | yes |   |
| `month` | integer | yes |   |
| `totalStores` | integer | yes | Stores that aren't deleted (ҳамагӣ мағозаҳо).  |
| `activeStores` | integer | yes |   |
| `inactiveStores` | integer | yes |   |
| `totalEmployees` | integer | yes | Employees that aren't deleted (ҳамагӣ кормандон).  |
| `activeEmployees` | integer | yes |   |
| `todaySales` | string | yes | Фурӯши имрӯз. pattern=`^-?\d+\.\d{2}$` |
| `todaySalesCount` | integer | yes |   |
| `weekSales` | string | yes | Фурӯши ҳафта: Monday until today. pattern=`^-?\d+\.\d{2}$` |
| `weekSalesCount` | integer | yes |   |
| `monthSales` | string | yes | Фурӯши моҳ: the 1st until today. pattern=`^-?\d+\.\d{2}$` |
| `monthSalesCount` | integer | yes |   |
| `salaryDueThisMonth` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `paidSalaryThisMonth` | string | yes | Маоши пардохтшуда (this month). pattern=`^-?\d+\.\d{2}$` |
| `remainingSalaryThisMonth` | string | yes | Маоши боқимонда (this month). pattern=`^-?\d+\.\d{2}$` |
| `remainingSalaryTotal` | string | yes | Unpaid salary of all months up to now, all employees. pattern=`^-?\d+\.\d{2}$` |
| `topStore` | TopStoreOut \| null | yes | Мағозаи аз ҳама серфурӯш: best store this month (`null` with no sales).  |
| `monthExpenses` | string |  | Expenses this month (`GET /api/expenses`). pattern=`^-?\d+\.\d{2}$`, default=`0.00` |
| `monthProfit` | string |  | This month's sales - expenses - salary due (= `GET /api/reports/profit`). pattern=`^-?\d+\.\d{2}$`, default=`0.00` |
| `monthMarginPercent` | number \| null |  | `monthProfit / monthSales` in %; `null` without sales.  |
| `weekTarget` | string \| null |  | Business-wide weekly sales target (`PUT /api/targets`). pattern=`^-?\d+\.\d{2}$` |
| `monthTarget` | string \| null |  | Business-wide monthly sales target. pattern=`^-?\d+\.\d{2}$` |

### DaySalesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `saleDate` | string (date) | yes |   |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |

### EmployeeBalanceRow

| Field | Type | Required | Notes |
|---|---|---|---|
| `employeeId` | string (uuid) | yes |   |
| `fullName` | string | yes |   |
| `position` | string | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `employeeStatus` | EmployeeStatus | yes |   |
| `isDeleted` | boolean | yes |   |
| `hiredAt` | string (date) | yes | Аз кадом сана ба кор омадааст.  |
| `terminatedAt` | string (date) \| null | yes |   |
| `monthsWorked` | integer | yes | Completed months of work (чанд моҳ кор кардааст).  |
| `monthlySalary` | string | yes | Current monthly salary. pattern=`^-?\d+\.\d{2}$` |
| `totalDue` | string | yes | Salary due for every month up to the current month. pattern=`^-?\d+\.\d{2}$` |
| `totalPaid` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalRemaining` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `unpaidMonths` | integer | yes | Months not fully paid yet (UNPAID or PARTIAL).  |

### EmployeeBriefOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `fullName` | string | yes |   |
| `position` | string | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `status` | EmployeeStatus | yes |   |
| `hiredAt` | string (date) | yes |   |
| `terminatedAt` | string (date) \| null | yes |   |
| `isDeleted` | boolean | yes |   |

### EmployeeCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string | yes |  minLength=`1`, maxLength=`150` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `position` | string | yes |  minLength=`1`, maxLength=`100` |
| `storeId` | string (uuid) | yes |   |
| `monthlySalary` | string | yes | Monthly salary in TJS. pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `hiredAt` | string (date) | yes | First working day, `YYYY-MM-DD`. Can't be in the future.  |
| `terminatedAt` | string (date) \| null |  | Last working day, or `null` while employed. Salary stops being due after this day. Setting `status` to `INACTIVE` without it uses today.  |
| `status` | EmployeeStatus |  |  default=`ACTIVE` |

### EmployeeOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `fullName` | string | yes |   |
| `phone` | string \| null | yes |   |
| `position` | string | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `monthlySalary` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `hiredAt` | string (date) | yes |   |
| `terminatedAt` | string (date) \| null | yes |   |
| `status` | EmployeeStatus | yes |   |
| `monthsWorked` | integer | yes | Completed months from `hiredAt` to today (or `terminatedAt`).  |
| `createdAt` | string (date-time) | yes |   |
| `updatedAt` | string (date-time) | yes |   |
| `deletedAt` | string (date-time) \| null | yes |   |

### EmployeePayrollOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `employee` | EmployeeBriefOut | yes |   |
| `monthlySalary` | string | yes | Current monthly salary. pattern=`^-?\d+\.\d{2}$` |
| `monthsWorked` | integer | yes |   |
| `totalDue` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalPaid` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalRemaining` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salaryHistory` | SalaryChangeOut[] | yes | Oldest first.  |
| `months` | PayrollMonthOut[] | yes | Every month worked, newest first.  |
| `payments` | PaymentOut[] | yes | Newest first.  |

### EmployeeStatus

Enum: `ACTIVE`, `INACTIVE`

### EmployeeUpdate

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string \| null |  |  minLength=`1`, maxLength=`150` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `position` | string \| null |  |  minLength=`1`, maxLength=`100` |
| `storeId` | string (uuid) \| null |  |   |
| `monthlySalary` | string \| null |  | A new salary applies from the current month on; past months keep the salary they had. pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `hiredAt` | string (date) \| null |  | First working day, `YYYY-MM-DD`. Can't be in the future.  |
| `terminatedAt` | string (date) \| null |  | Last working day, or `null` while employed. Salary stops being due after this day. Setting `status` to `INACTIVE` without it uses today.  |
| `status` | EmployeeStatus \| null |  | `INACTIVE` → `ACTIVE` clears `terminatedAt` (unless you send it).  |

### EmployeesByPositionOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `position` | string | yes |   |
| `employeesCount` | integer | yes |   |
| `activeEmployees` | integer | yes |   |
| `monthlySalaryTotal` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |

### EmployeesByStoreOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `storeStatus` | StoreStatus | yes |   |
| `storeIsDeleted` | boolean | yes |   |
| `employeesCount` | integer | yes |   |
| `activeEmployees` | integer | yes |   |
| `monthlySalaryTotal` | string | yes | Sum of current salaries of ACTIVE employees. pattern=`^-?\d+\.\d{2}$` |

### EmployeesReportOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `totalEmployees` | integer | yes | Employees that aren't deleted.  |
| `activeEmployees` | integer | yes |   |
| `inactiveEmployees` | integer | yes |   |
| `hiredThisMonth` | integer | yes |   |
| `monthlySalaryTotal` | string | yes | Monthly salary of all ACTIVE employees. pattern=`^-?\d+\.\d{2}$` |
| `averageMonthlySalary` | string | yes | Average salary of ACTIVE employees. pattern=`^-?\d+\.\d{2}$` |
| `byStore` | EmployeesByStoreOut[] | yes |   |
| `byPosition` | EmployeesByPositionOut[] | yes |   |

### ErrorBody

| Field | Type | Required | Notes |
|---|---|---|---|
| `code` | string | yes |   |
| `message` | string | yes | For developers. Show a translated text based on `code`.  |
| `details` | ErrorDetail[] | yes | Field-level problems (validation errors).  |
| `meta` | object | yes | Extra machine-readable data for some errors.  |
| `requestId` | string \| null | yes | Quote this when reporting a problem.  |

### ErrorDetail

| Field | Type | Required | Notes |
|---|---|---|---|
| `location` | string | yes |   |
| `field` | string | yes |   |
| `code` | string | yes |   |
| `message` | string | yes |   |

### ErrorResponse

Every error response uses this envelope. Switch on `error.code`.

| Field | Type | Required | Notes |
|---|---|---|---|
| `error` | ErrorBody | yes |   |

### ExchangeRatesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `base` | string |  |  default=`TJS` |
| `rates` | object | yes | 1 unit of each currency in TJS, as decimal strings.  |
| `updatedAt` | string (date-time) | yes | When the rates were last set (UTC).  |

### ExpenseCategory

Enum: `RENT`, `UTILITIES`, `DELIVERY`, `SUPPLIES`, `MARKETING`, `TAXES`, `OTHER`

### ExpenseCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) \| null |  | The store the expense belongs to, or `null` for the whole business.  |
| `category` | ExpenseCategory | yes |   |
| `amount` | string | yes | Amount in TJS, greater than 0. Send a string like `"1250.50"` (a JSON number is also accepted). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `expenseDate` | string (date) \| null |  | `YYYY-MM-DD`. Defaults to today. Can't be in the future.  |
| `description` | string \| null |  |  maxLength=`500` |

### ExpenseOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `storeId` | string (uuid) \| null | yes |   |
| `storeName` | string \| null | yes |   |
| `category` | ExpenseCategory | yes |   |
| `amount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `expenseDate` | string (date) | yes |   |
| `description` | string \| null | yes |   |
| `registeredById` | string (uuid) \| null | yes | The user who recorded it.  |
| `registeredByName` | string \| null | yes |   |
| `createdAt` | string (date-time) | yes |   |
| `updatedAt` | string (date-time) | yes |   |

### ExpensePage

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | ExpenseOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |
| `totalAmount` | string | yes | Sum of all expenses matching the filters. pattern=`^-?\d+\.\d{2}$` |

### ExpenseUpdate

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) \| null |  | The store the expense belongs to, or `null` for the whole business.  |
| `category` | ExpenseCategory \| null |  |   |
| `amount` | string \| null |  |  pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `expenseDate` | string (date) \| null |  | `YYYY-MM-DD`. Defaults to today. Can't be in the future.  |
| `description` | string \| null |  |  maxLength=`500` |

### HealthOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `status` | string | yes |   |
| `checks` | object |  |  default=`{}` |

### HourSalesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `hour` | integer | yes | Hour the sale was entered, Asia/Dushanbe. minimum=`0.0`, maximum=`23.0` |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |

### LoginRequest

| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string (email) | yes |  maxLength=`320` |
| `password` | string | yes |  minLength=`1`, maxLength=`128` |

### MonthTotalsOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `year` | integer | yes |   |
| `month` | integer | yes |   |
| `dueAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `paidAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `remainingAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |

### MonthlyPayrollOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `year` | integer | yes |   |
| `month` | integer | yes |   |
| `employeesCount` | integer | yes |   |
| `totalDue` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalPaid` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalRemaining` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `paidCount` | integer | yes |   |
| `partialCount` | integer | yes |   |
| `unpaidCount` | integer | yes |   |
| `items` | MonthlyPayrollRow[] | yes |   |

### MonthlyPayrollRow

| Field | Type | Required | Notes |
|---|---|---|---|
| `employeeId` | string (uuid) | yes |   |
| `fullName` | string | yes |   |
| `position` | string | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `employeeStatus` | EmployeeStatus | yes |   |
| `isDeleted` | boolean | yes |   |
| `monthlySalary` | string | yes | Salary that applies to this month. pattern=`^-?\d+\.\d{2}$` |
| `workedDays` | integer | yes | Days employed in this month.  |
| `dueAmount` | string | yes | Salary due for this month (prorated if partial). pattern=`^-?\d+\.\d{2}$` |
| `paidAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `remainingAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `status` | PayrollStatus | yes | Status of this employee's salary for that month: `PAID` (fully paid), `PARTIAL` (partly paid) or `UNPAID` (nothing paid yet).  |
| `paymentsCount` | integer | yes |   |

### NotificationKind

Enum: `UNPAID_SALARIES`, `STORE_NO_SALES_TODAY`, `SALARY_OVERDUE`

### NotificationLink

Enum: `STORES`, `SALES`, `PAYROLL`

### NotificationOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes | Stable while the situation lasts (same kind, store and start), so the app can remember it.  |
| `kind` | NotificationKind | yes | `UNPAID_SALARIES`: employees with salary still to pay this month. `SALARY_OVERDUE`: unpaid salary of earlier months. `STORE_NO_SALES_TODAY`: an ACTIVE store without a sale today (one per store).  |
| `severity` | Severity | yes |   |
| `count` | integer | yes | UNPAID_SALARIES: employees; SALARY_OVERDUE: unpaid employee-months (2 employees × 3 months = 6); STORE_NO_SALES_TODAY: 1.  |
| `amount` | string \| null | yes | Salary still to pay; `null` for stores. pattern=`^-?\d+\.\d{2}$` |
| `storeId` | string (uuid) \| null | yes |   |
| `storeName` | string \| null | yes |   |
| `link` | NotificationLink | yes | The app screen to open.  |
| `read` | boolean | yes | `false` until `POST /api/notifications/read-all`.  |
| `createdAt` | string (date-time) | yes | When the situation started: the start of this month (UNPAID_SALARIES), of the month after the newest overdue month (SALARY_OVERDUE) or of today (STORE_NO_SALES_TODAY), business calendar.  |

### NotificationsOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | NotificationOut[] | yes | WARNING first, then newest first.  |
| `unreadCount` | integer | yes | Items newer than the last read-all.  |
| `lastReadAt` | string (date-time) \| null | yes | The last read-all, or `null`.  |

### Page_ActivityOut_

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | ActivityOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |

### Page_ConversationSummaryOut_

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | ConversationSummaryOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |

### Page_EmployeeOut_

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | EmployeeOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |

### Page_StoreOut_

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | StoreOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |

### Page_TargetOut_

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | TargetOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |

### PasswordChange

| Field | Type | Required | Notes |
|---|---|---|---|
| `currentPassword` | string | yes |  minLength=`1`, maxLength=`128` |
| `newPassword` | string | yes | 8–128 characters, not a commonly used password. minLength=`1`, maxLength=`128` |

### PaymentCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `employeeId` | string (uuid) | yes |   |
| `amount` | string | yes | Paid amount in TJS. Several partial payments per month are allowed, but together they can't exceed the salary due for that month. pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `month` | integer | yes | The month the salary is for. minimum=`1.0`, maximum=`12.0` |
| `year` | integer | yes |  minimum=`2000.0`, maximum=`2100.0` |
| `paymentDate` | string (date) \| null |  | When the money was paid, `YYYY-MM-DD`. Defaults to today.  |
| `note` | string \| null |  |  maxLength=`500` |
| `method` | SalaryPaymentMethod \| null |  | How it was paid: `BANK_TRANSFER` or `CASH` (optional).  |

### PaymentMethod

Enum: `CASH`, `CARD`, `QR`, `MIXED`

### PaymentMethodSalesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `paymentMethod` | PaymentMethod \| null | yes | `null`: sales recorded without a payment method.  |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |
| `sharePercent` | number | yes | Share of the period's total, in %.  |

### PaymentOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `employeeId` | string (uuid) | yes |   |
| `employeeName` | string | yes |   |
| `amount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `month` | integer | yes |   |
| `year` | integer | yes |   |
| `paymentDate` | string (date) | yes |   |
| `status` | PayrollStatus | yes | Status of this employee's salary for that month: `PAID` (fully paid), `PARTIAL` (partly paid) or `UNPAID` (nothing paid yet).  |
| `note` | string \| null | yes |   |
| `method` | SalaryPaymentMethod \| null |  |   |
| `period` | PeriodBalanceOut | yes |   |
| `createdAt` | string (date-time) | yes |   |

### PaymentPage

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | PaymentOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |
| `totalAmount` | string | yes | Sum of all payments matching the filters. pattern=`^-?\d+\.\d{2}$` |

### PayrollMonthOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `year` | integer | yes |   |
| `month` | integer | yes |   |
| `monthlySalary` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `workedDays` | integer | yes |   |
| `dueAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `paidAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `remainingAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `status` | PayrollStatus | yes |   |
| `paymentsCount` | integer | yes |   |

### PayrollStatus

Enum: `PAID`, `PARTIAL`, `UNPAID`

### PayrollSummaryOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `asOf` | string (date) | yes | Today; months up to the current month are included.  |
| `employeesCount` | integer | yes |   |
| `totalDue` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalPaid` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalRemaining` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `currentMonth` | MonthTotalsOut | yes |   |
| `items` | EmployeeBalanceRow[] | yes |   |

### PayrollYearMonthOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `month` | integer | yes |   |
| `dueAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `paidAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `remainingAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `employeesCount` | integer | yes | Employees with salary due or paid that month.  |
| `paidCount` | integer | yes | Employees fully paid for that month.  |

### PayrollYearOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `year` | integer | yes |   |
| `totalDue` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalPaid` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `totalRemaining` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `months` | PayrollYearMonthOut[] | yes | January up to the current month (all 12 for past years).  |

### PeriodBalanceOut

The employee's salary for the payment's month, after all payments so far.

| Field | Type | Required | Notes |
|---|---|---|---|
| `dueAmount` | string | yes | Salary due for that month (prorated if partial). pattern=`^-?\d+\.\d{2}$` |
| `paidAmount` | string | yes | Sum of all payments for that month. pattern=`^-?\d+\.\d{2}$` |
| `remainingAmount` | string | yes | Still to be paid for that month. pattern=`^-?\d+\.\d{2}$` |

### PeriodOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `startDate` | string (date) | yes |   |
| `endDate` | string (date) | yes |   |
| `days` | integer | yes |   |

### ProfileOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `fullName` | string | yes |   |
| `email` | string | yes |   |
| `phone` | string \| null | yes |   |
| `avatar` | string \| null | yes | Absolute public URL of the avatar image (on the team server `https://…/media/avatars/…`), or `null`. Use it as it is.  |
| `role` | UserRole | yes |   |
| `business` | BusinessOut | yes |   |
| `createdAt` | string (date-time) | yes |   |

### ProfileUpdate

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string \| null |  |  minLength=`1`, maxLength=`150` |
| `email` | string (email) \| null |  |  maxLength=`320` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `businessName` | string \| null |  | Renames your business. minLength=`1`, maxLength=`150` |

### ProfitOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `period` | PeriodOut | yes |   |
| `salesTotal` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `expensesTotal` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salaryDue` | string | yes | Salary due for the period. A month only partly inside the period counts in proportion to its days; months after the current one count as 0. pattern=`^-?\d+\.\d{2}$` |
| `grossProfit` | string | yes | `salesTotal - expensesTotal - salaryDue`. pattern=`^-?\d+\.\d{2}$` |
| `marginPercent` | number \| null | yes | `grossProfit / salesTotal` in %; `null` when there are no sales.  |
| `byCategory` | CategoryExpenseOut[] | yes | Expenses per category, largest first.  |
| `byStore` | StoreProfitOut[] | yes | Every store, most profitable first, then one row with `storeId: null` for expenses of the whole business (when there are any). The rows add up to the totals.  |

### RefreshRequest

| Field | Type | Required | Notes |
|---|---|---|---|
| `refreshToken` | string | yes |  minLength=`1`, maxLength=`512` |

### RegionSalesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `region` | string \| null | yes | `null` groups the stores without a region.  |
| `storesCount` | integer | yes |   |
| `inactiveStores` | integer | yes | INACTIVE stores (deleted ones included).  |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `sharePercent` | number | yes | Share of the total of all stores, in %.  |

### RegisterRequest

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string | yes |  minLength=`1`, maxLength=`150` |
| `email` | string (email) | yes |  maxLength=`320` |
| `password` | string | yes | 8–128 characters, not a commonly used password. minLength=`1`, maxLength=`128` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `businessName` | string \| null |  | Name of your business. Defaults to your full name. minLength=`1`, maxLength=`150` |

### SalaryChangeOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `monthlySalary` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `effectiveFrom` | string (date) | yes | 1st day of the month this salary applies from.  |
| `createdAt` | string (date-time) | yes |   |

### SalaryPaymentMethod

Enum: `BANK_TRANSFER`, `CASH`

### SaleCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `amount` | string | yes | Amount in TJS, greater than 0. Send a string like `"1250.50"` (a JSON number is also accepted). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `saleDate` | string (date) \| null |  | `YYYY-MM-DD`. Defaults to today. Can't be in the future.  |
| `description` | string \| null |  |  maxLength=`500` |
| `paymentMethod` | PaymentMethod \| null |  | `CASH`, `CARD`, `QR` or `MIXED` (optional).  |
| `cashAmount` | string \| null |  | Optional split of a payment. When both `cashAmount` and `cardAmount` are given they must add up to `amount`, and neither may be larger than `amount` (`422 SALE_SPLIT_MISMATCH`). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `cardAmount` | string \| null |  | Optional split of a payment. When both `cashAmount` and `cardAmount` are given they must add up to `amount`, and neither may be larger than `amount` (`422 SALE_SPLIT_MISMATCH`). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `receiptNumber` | string \| null |  |  maxLength=`50` |

### SaleOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `amount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `saleDate` | string (date) | yes |   |
| `description` | string \| null | yes |   |
| `paymentMethod` | PaymentMethod \| null |  |   |
| `cashAmount` | string \| null |  |  pattern=`^-?\d+\.\d{2}$` |
| `cardAmount` | string \| null |  |  pattern=`^-?\d+\.\d{2}$` |
| `receiptNumber` | string \| null |  |   |
| `registeredById` | string (uuid) \| null |  | The user who recorded the sale (set by the server).  |
| `registeredByName` | string \| null |  |   |
| `createdAt` | string (date-time) | yes | When the sale was entered (UTC).  |
| `updatedAt` | string (date-time) | yes |   |

### SalePage

| Field | Type | Required | Notes |
|---|---|---|---|
| `items` | SaleOut[] | yes |   |
| `total` | integer | yes | Number of items matching the filters (all pages).  |
| `page` | integer | yes |   |
| `limit` | integer | yes |   |
| `pages` | integer | yes | Total number of pages.  |
| `totalAmount` | string | yes | Sum of all sales matching the filters (all pages). pattern=`^-?\d+\.\d{2}$` |

### SaleUpdate

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) \| null |  |   |
| `amount` | string \| null |  | Changing `amount` without sending `cashAmount` / `cardAmount` clears a split that no longer adds up. pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `saleDate` | string (date) \| null |  |   |
| `description` | string \| null |  |  maxLength=`500` |
| `paymentMethod` | PaymentMethod \| null |  | `CASH`, `CARD`, `QR` or `MIXED` (optional).  |
| `cashAmount` | string \| null |  | Optional split of a payment. When both `cashAmount` and `cardAmount` are given they must add up to `amount`, and neither may be larger than `amount` (`422 SALE_SPLIT_MISMATCH`). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `cardAmount` | string \| null |  | Optional split of a payment. When both `cashAmount` and `cardAmount` are given they must add up to `amount`, and neither may be larger than `amount` (`422 SALE_SPLIT_MISMATCH`). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `receiptNumber` | string \| null |  |  maxLength=`50` |

### SalesReportOut

Sales of all stores (ACTIVE, INACTIVE and deleted ones that sold in the period).

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `period` | PeriodOut | yes |   |
| `previousPeriod` | PeriodOut | yes | The period it is compared with.  |
| `totalAmount` | string | yes | Sales of all stores together. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |
| `averageSaleAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `previousTotalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `previousSalesCount` | integer | yes |   |
| `changeAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `changePercent` | number \| null | yes |   |
| `storesCount` | integer | yes |   |
| `stores` | StoreSalesOut[] | yes | Every store, best first.  |
| `byDay` | DaySalesOut[] | yes | One entry per day of the period (for charts).  |
| `byPaymentMethod` | PaymentMethodSalesOut[] |  | Always CASH, CARD, QR, MIXED (in this order, zeros included), plus a `null` row when some sales have no payment method.  |
| `byHour` | HourSalesOut[] \| null |  | Daily reports only (`null` otherwise): 24 entries, hours 0–23, by the time the sale was entered (`createdAt`) in Asia/Dushanbe.  |

### Severity

Enum: `INFO`, `WARNING`

### StoreComparisonOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `currency` | string |  |  default=`TJS` |
| `period` | PeriodOut | yes |   |
| `previousPeriod` | PeriodOut | yes |   |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |
| `storesCount` | integer | yes |   |
| `bestStore` | StoreComparisonRow \| null | yes |   |
| `stores` | StoreComparisonRow[] | yes | Ranked, best first.  |
| `regions` | RegionSalesOut[] |  | The same stores grouped by region (case-insensitive), best first.  |

### StoreComparisonRow

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `status` | StoreStatus | yes |   |
| `isDeleted` | boolean | yes | The store was deleted; its sales still count.  |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes | Number of sales records in the period.  |
| `averageSaleAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `sharePercent` | number | yes | Share of the total of all stores, in %.  |
| `previousTotalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `previousSalesCount` | integer | yes |   |
| `changeAmount` | string | yes | `totalAmount - previousTotalAmount` (may be < 0). pattern=`^-?\d+\.\d{2}$` |
| `changePercent` | number \| null | yes | Change vs the previous period in %; `null` when the previous total is 0.  |
| `rank` | integer | yes | 1 = highest sales in the period.  |
| `activeEmployees` | integer | yes |   |
| `city` | string \| null |  |   |
| `region` | string \| null |  |   |

### StoreCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | yes |  minLength=`1`, maxLength=`150` |
| `address` | string \| null |  |  maxLength=`255` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `description` | string \| null |  |  maxLength=`1000` |
| `status` | StoreStatus |  |  default=`ACTIVE` |
| `city` | string \| null |  |  maxLength=`100` |
| `region` | string \| null |  | Region, e.g. `Dushanbe`, `Sughd`, `Khatlon`, `GBAO`, `RRS`. Groups the store comparison. maxLength=`100` |
| `type` | string \| null |  | Store format, e.g. `Flagship`, `Supermarket`, `Kiosk`. maxLength=`50` |
| `counters` | integer \| null |  | Number of checkout counters, 0–999. minimum=`0.0`, maximum=`999.0` |
| `openingHours` | string \| null |  |  maxLength=`100` |
| `statusNote` | string \| null |  | Why the store has its status, e.g. `Renovation`. maxLength=`255` |

### StoreOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `name` | string | yes |   |
| `address` | string \| null | yes |   |
| `phone` | string \| null | yes |   |
| `description` | string \| null | yes |   |
| `status` | StoreStatus | yes |   |
| `city` | string \| null |  |   |
| `region` | string \| null |  |   |
| `type` | string \| null |  |   |
| `counters` | integer \| null |  |   |
| `openingHours` | string \| null |  |   |
| `statusNote` | string \| null |  |   |
| `createdAt` | string (date-time) | yes |   |
| `updatedAt` | string (date-time) | yes |   |
| `deletedAt` | string (date-time) \| null | yes | Set when the store was deleted (soft delete).  |

### StoreProfitOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) \| null | yes | `null`: expenses of the whole business.  |
| `storeName` | string \| null | yes |   |
| `salesTotal` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `expensesTotal` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salaryDue` | string | yes | Salary due for the store's employees. pattern=`^-?\d+\.\d{2}$` |
| `profit` | string | yes | `salesTotal - expensesTotal - salaryDue` (may be < 0). pattern=`^-?\d+\.\d{2}$` |

### StoreSalesOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `status` | StoreStatus | yes |   |
| `isDeleted` | boolean | yes | The store was deleted; its sales still count.  |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes | Number of sales records in the period.  |
| `averageSaleAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `sharePercent` | number | yes | Share of the total of all stores, in %.  |
| `previousTotalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `previousSalesCount` | integer | yes |   |
| `changeAmount` | string | yes | `totalAmount - previousTotalAmount` (may be < 0). pattern=`^-?\d+\.\d{2}$` |
| `changePercent` | number \| null | yes | Change vs the previous period in %; `null` when the previous total is 0.  |

### StoreStatus

Enum: `ACTIVE`, `INACTIVE`

### StoreUpdate

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string \| null |  |  minLength=`1`, maxLength=`150` |
| `address` | string \| null |  |  maxLength=`255` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `description` | string \| null |  |  maxLength=`1000` |
| `status` | StoreStatus \| null |  |   |
| `city` | string \| null |  |  maxLength=`100` |
| `region` | string \| null |  | Region, e.g. `Dushanbe`, `Sughd`, `Khatlon`, `GBAO`, `RRS`. Groups the store comparison. maxLength=`100` |
| `type` | string \| null |  | Store format, e.g. `Flagship`, `Supermarket`, `Kiosk`. maxLength=`50` |
| `counters` | integer \| null |  | Number of checkout counters, 0–999. minimum=`0.0`, maximum=`999.0` |
| `openingHours` | string \| null |  |  maxLength=`100` |
| `statusNote` | string \| null |  | Why the store has its status, e.g. `Renovation`. maxLength=`255` |

### TargetOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `period` | TargetPeriod | yes |   |
| `storeId` | string (uuid) \| null | yes |   |
| `storeName` | string \| null | yes |   |
| `amount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `createdAt` | string (date-time) | yes |   |
| `updatedAt` | string (date-time) | yes |   |

### TargetPeriod

Enum: `WEEK`, `MONTH`

### TargetPut

| Field | Type | Required | Notes |
|---|---|---|---|
| `period` | TargetPeriod | yes | `WEEK` (Monday–Sunday) or `MONTH`.  |
| `storeId` | string (uuid) \| null |  | The store, or `null` for the whole business.  |
| `amount` | string | yes | The sales goal in TJS. pattern=`^\d{1,12}(\.\d{1,2})?$` |

### TokenPair

| Field | Type | Required | Notes |
|---|---|---|---|
| `accessToken` | string | yes | Send as `Authorization: Bearer <accessToken>`.  |
| `refreshToken` | string | yes | Works once. Store the new one after each refresh.  |
| `tokenType` | string |  |  default=`Bearer`, const=`Bearer` |
| `expiresIn` | integer | yes | Seconds until the access token expires.  |
| `refreshExpiresIn` | integer | yes | Seconds until the refresh token expires.  |

### TopStoreOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `totalAmount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `salesCount` | integer | yes |   |

### UserRole

Enum: `OWNER`

## Error codes

| HTTP | code | meaning |
|---|---|---|
| 401 | `AUTH_INVALID_CREDENTIALS` | Incorrect email or password. |
| 401 | `AUTH_REQUIRED` | Authentication is required. |
| 401 | `AUTH_SESSION_REVOKED` | This session has ended. Please log in again. |
| 401 | `AUTH_TOKEN_EXPIRED` | The access token has expired. Refresh it and retry. |
| 401 | `AUTH_TOKEN_INVALID` | The token is invalid. Please log in again. |
| 403 | `AUTH_ACCOUNT_DISABLED` | This account has been disabled. |
| 404 | `ACTION_NOT_FOUND` | Action not found. |
| 404 | `CONVERSATION_NOT_FOUND` | Conversation not found. |
| 404 | `EMPLOYEE_NOT_FOUND` | Employee not found. |
| 404 | `EXPENSE_NOT_FOUND` | Expense not found. |
| 404 | `PAYROLL_NOT_FOUND` | Payroll payment not found. |
| 404 | `SALE_NOT_FOUND` | Sale not found. |
| 404 | `STORE_NOT_FOUND` | Store not found. |
| 409 | `ACTION_ALREADY_HANDLED` | This action has already been confirmed or cancelled. |
| 409 | `ACTION_EXPIRED` | This action has expired. Ask the assistant again. |
| 409 | `EMAIL_ALREADY_REGISTERED` | An account with this email already exists. |
| 409 | `PAYROLL_ALREADY_PAID` | The salary for this month is already fully paid. |
| 409 | `STORE_HAS_ACTIVE_EMPLOYEES` | The store still has active employees. Move or deactivate them first. |
| 409 | `STORE_NAME_TAKEN` | A store with this name already exists. |
| 413 | `AVATAR_TOO_LARGE` | The avatar image is too large. |
| 415 | `AVATAR_INVALID_TYPE` | The avatar must be a JPEG, PNG or WebP image. |
| 422 | `CURRENT_PASSWORD_INCORRECT` | The current password is incorrect. |
| 422 | `EMPLOYEE_NOT_EMPLOYED_IN_PERIOD` | The employee did not work in this month, so no salary is due. |
| 422 | `EXPENSE_DATE_IN_FUTURE` | The expense date cannot be in the future. |
| 422 | `INVALID_DATE_RANGE` | The date range is invalid. |
| 422 | `INVALID_EMPLOYMENT_DATES` | The employment dates are invalid. |
| 422 | `PASSWORD_TOO_WEAK` | The password is too weak. |
| 422 | `PAYMENT_DATE_IN_FUTURE` | The payment date cannot be in the future. |
| 422 | `PAYROLL_AMOUNT_EXCEEDS_REMAINING` | The amount is larger than the salary that remains to be paid for this month. |
| 422 | `PAYROLL_PERIOD_IN_FUTURE` | Salary can't be paid for a future month. |
| 422 | `SALE_DATE_IN_FUTURE` | The sale date cannot be in the future. |
| 422 | `SALE_SPLIT_MISMATCH` | cashAmount + cardAmount must equal amount, and neither can be larger than it. |
| 422 | `VALIDATION_ERROR` | Request validation failed. |
| 429 | `AUTH_ACCOUNT_LOCKED` | Too many failed login attempts. Try again later. |
| 429 | `RATE_LIMITED` | Too many requests. Try again later. |
| 503 | `ASSISTANT_UNAVAILABLE` | The AI assistant is temporarily unavailable. Try again later. |

---
Questions about the API → Mehroj (backend). If something here differs from the live Swagger, the Swagger wins — regenerate this file with `python3 scripts/gen_api_md.py`.
