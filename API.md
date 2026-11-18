# Business Management System — API for the Flutter apps

> Generated from the live Swagger (`/openapi.json`) of Mehroj's backend. The web (Abdullo) is already connected to every endpoint below.
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
- One service per tag below: `AuthService`, `ProfileService`, `StoreService`, `SalesService`, `EmployeeService`, `PayrollService`, `ReportsService`.
- Models with `fromJson` that parse money strings with `double.parse` and dates as local dates.
- ViewModels call services; views never call `http` directly.

### Which endpoint for which screen

| Screen | Endpoints |
|---|---|
| Login / Register | `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/me` |
| Dashboard | `GET /api/reports/dashboard`, `GET /api/sales/daily`, `GET /api/sales/weekly`, `GET /api/reports/monthly-sales`, `GET /api/reports/store-comparison` |
| Stores | `GET/POST /api/stores`, `PUT/DELETE /api/stores/{id}`, `GET /api/sales/store/{storeId}`, `GET /api/employees/store/{storeId}` |
| Sales | `GET/POST /api/sales`, `PUT/DELETE /api/sales/{id}` |
| Employees | `GET/POST /api/employees`, `PUT/DELETE /api/employees/{id}`, `GET /api/reports/employees` |
| Salaries | `GET /api/payroll/monthly?month=&year=`, `POST /api/payroll`, `GET /api/payroll`, `GET /api/payroll/employee/{employeeId}`, `DELETE /api/payroll/{id}` |
| Reports | `GET /api/reports/store-comparison`, `GET /api/reports/payroll?year=`, `GET /api/reports/employees` |
| Profile | `GET/PUT /api/profile`, `PATCH /api/profile/password`, `PATCH /api/profile/avatar` (multipart, field `file`) |

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
| 🔒 | `GET` | `/api/reports/dashboard` | Business dashboard |
| 🔒 | `GET` | `/api/reports/weekly-sales` | Weekly sales of all stores |
| 🔒 | `GET` | `/api/reports/monthly-sales` | Monthly sales of all stores |
| 🔒 | `GET` | `/api/reports/store-comparison` | Compare stores |
| 🔒 | `GET` | `/api/reports/employees` | Employees report |
| 🔒 | `GET` | `/api/reports/payroll` | Payroll report for a year |
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
| `search` | query | string \| null |  | Part of the name or address. maxLength=`100` |
| `includeDeleted` | query | boolean |  |  default=`False` |
| `sort` | query | string \| null |  | `name` (default), `createdAt`, `status`; `-` = descending.  |
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

`saleDate` defaults to today. The store must exist and not be deleted.

Body (`application/json`): **SaleCreate**

Responses:
- `201` Successful Response → **SaleOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `SALE_DATE_IN_FUTURE`, `VALIDATION_ERROR` → **ErrorResponse**

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

Sales of every store on one day, compared with the day before.

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

Same report as `GET /api/reports/weekly-sales`. Defaults to the current Monday–Sunday week. With only `startDate` (or only `endDate`) the range is 7 days.

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

Send only the fields you want to change.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | string (uuid) | yes | The sale ID.  |

Body (`application/json`): **SaleUpdate**

Responses:
- `200` Successful Response → **SaleOut**
- `401` Not authenticated or the token is not valid: `AUTH_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_SESSION_REVOKED` → **ErrorResponse**
- `403` Authenticated but not allowed: `AUTH_ACCOUNT_DISABLED` → **ErrorResponse**
- `404` Not found (records of another business are also reported as not found): `SALE_NOT_FOUND`, `STORE_NOT_FOUND` → **ErrorResponse**
- `422` Validation or business-rule error: `SALE_DATE_IN_FUTURE`, `VALIDATION_ERROR` → **ErrorResponse**

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
| `includeDeleted` | query | boolean |  |  default=`False` |
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
| `includeDeleted` | query | boolean |  |  default=`False` |
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

The employee is hidden and set to `INACTIVE`; `terminatedAt` becomes today if it was empty, so no more salary is due. Payroll history is kept and still shows in reports and in `GET /api/payroll/employee/{employeeId}`.

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

Hire date, months worked, salary history, every month with due / paid / remaining / status, and all payments. Works for deleted employees too.

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

Example: `?startDate=2026-11-09&endDate=2026-11-15`. Returns the total of all stores and every store separately (name, total, number of sales), compared with the previous week. **All stores count, ACTIVE and INACTIVE**, and deleted stores that sold in the period, so no sales history is lost. Defaults to the current Monday–Sunday week.

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

### AuthResponse

| Field | Type | Required | Notes |
|---|---|---|---|
| `accessToken` | string | yes | Send as `Authorization: Bearer <accessToken>`.  |
| `refreshToken` | string | yes | Works once. Store the new one after each refresh.  |
| `tokenType` | string |  |  default=`Bearer` |
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

### HealthOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `status` | string | yes |   |
| `checks` | object |  |  default=`{}` |

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
| `avatar` | string \| null | yes | Public URL of the avatar image, or `null`.  |
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

### RefreshRequest

| Field | Type | Required | Notes |
|---|---|---|---|
| `refreshToken` | string | yes |  minLength=`1`, maxLength=`512` |

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

### SaleCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `storeId` | string (uuid) | yes |   |
| `amount` | string | yes | Amount in TJS, greater than 0. Send a string like `"1250.50"` (a JSON number is also accepted). pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `saleDate` | string (date) \| null |  | `YYYY-MM-DD`. Defaults to today. Can't be in the future.  |
| `description` | string \| null |  |  maxLength=`500` |

### SaleOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `storeId` | string (uuid) | yes |   |
| `storeName` | string | yes |   |
| `amount` | string | yes | Amount in TJS as a decimal string with 2 decimals. pattern=`^-?\d+\.\d{2}$` |
| `saleDate` | string (date) | yes |   |
| `description` | string \| null | yes |   |
| `createdAt` | string (date-time) | yes |   |
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
| `amount` | string \| null |  |  pattern=`^\d{1,12}(\.\d{1,2})?$` |
| `saleDate` | string (date) \| null |  |   |
| `description` | string \| null |  |  maxLength=`500` |

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

### StoreCreate

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | yes |  minLength=`1`, maxLength=`150` |
| `address` | string \| null |  |  maxLength=`255` |
| `phone` | string \| null |  |  pattern=`^\+?[0-9]{7,15}$` |
| `description` | string \| null |  |  maxLength=`1000` |
| `status` | StoreStatus |  |  default=`ACTIVE` |

### StoreOut

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes |   |
| `name` | string | yes |   |
| `address` | string \| null | yes |   |
| `phone` | string \| null | yes |   |
| `description` | string \| null | yes |   |
| `status` | StoreStatus | yes |   |
| `createdAt` | string (date-time) | yes |   |
| `updatedAt` | string (date-time) | yes |   |
| `deletedAt` | string (date-time) \| null | yes | Set when the store was deleted (soft delete).  |

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

### TokenPair

| Field | Type | Required | Notes |
|---|---|---|---|
| `accessToken` | string | yes | Send as `Authorization: Bearer <accessToken>`.  |
| `refreshToken` | string | yes | Works once. Store the new one after each refresh.  |
| `tokenType` | string |  |  default=`Bearer` |
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
| 403 | `PERMISSION_DENIED` | You do not have permission to perform this action. |
| 404 | `EMPLOYEE_NOT_FOUND` | Employee not found. |
| 404 | `NOT_FOUND` | Resource not found. |
| 404 | `PAYROLL_NOT_FOUND` | Payroll payment not found. |
| 404 | `SALE_NOT_FOUND` | Sale not found. |
| 404 | `STORE_NOT_FOUND` | Store not found. |
| 409 | `CONFLICT` | The request conflicts with the current state of the resource. |
| 409 | `EMAIL_ALREADY_REGISTERED` | An account with this email already exists. |
| 409 | `PAYROLL_ALREADY_PAID` | The salary for this month is already fully paid. |
| 409 | `STORE_HAS_ACTIVE_EMPLOYEES` | The store still has active employees. Move or deactivate them first. |
| 409 | `STORE_NAME_TAKEN` | A store with this name already exists. |
| 413 | `AVATAR_TOO_LARGE` | The avatar image is too large. |
| 413 | `PAYLOAD_TOO_LARGE` | The request body is too large. |
| 415 | `AVATAR_INVALID_TYPE` | The avatar must be a JPEG, PNG or WebP image. |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | This file type is not supported. |
| 422 | `CURRENT_PASSWORD_INCORRECT` | The current password is incorrect. |
| 422 | `EMPLOYEE_NOT_EMPLOYED_IN_PERIOD` | The employee did not work in this month, so no salary is due. |
| 422 | `INVALID_DATE_RANGE` | The date range is invalid. |
| 422 | `INVALID_EMPLOYMENT_DATES` | The employment dates are invalid. |
| 422 | `PASSWORD_TOO_WEAK` | The password is too weak. |
| 422 | `PAYMENT_DATE_IN_FUTURE` | The payment date cannot be in the future. |
| 422 | `PAYROLL_AMOUNT_EXCEEDS_REMAINING` | The amount is larger than the salary that remains to be paid for this month. |
| 422 | `PAYROLL_PERIOD_IN_FUTURE` | Salary can't be paid for a future month. |
| 422 | `SALE_DATE_IN_FUTURE` | The sale date cannot be in the future. |
| 422 | `VALIDATION_ERROR` | Request validation failed. |
| 429 | `AUTH_ACCOUNT_LOCKED` | Too many failed login attempts. Try again later. |
| 429 | `RATE_LIMITED` | Too many requests. Try again later. |
| 500 | `INTERNAL_ERROR` | An unexpected error occurred. |

---
Questions about the API → Mehroj (backend). If something here differs from the live Swagger, the Swagger wins — regenerate this file.
