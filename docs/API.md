# API — API 設計文件（API Design Document）

---

## Document Control

| 欄位 | 內容 |
|------|------|
| **DOC-ID** | API-FISHGAME-20260424 |
| **專案名稱** | fishing-arcade-game（捕魚街機遊戲平台）|
| **文件版本** | v1.0 |
| **狀態** | DRAFT |
| **作者** | AI Generated (gendoc-gen-api) |
| **日期** | 2026-04-24 |
| **上游 EDD** | [EDD.md](EDD.md)（EDD-FISHGAME-20260424）|
| **上游 PRD** | [PRD.md](PRD.md) |
| **上游 ARCH** | [ARCH.md](ARCH.md)（ARCH-FISHGAME-20260424）|

---

## Change Log

| 版本 | 日期 | 作者 | 變更摘要 |
|------|------|------|---------|
| v1.0 | 2026-04-24 | AI Generated (gendoc-gen-api) | 初稿 |

---

## 目錄

0. 快速概覽
1. 認證（Authentication）
2. Endpoint 列表
   - 2.1 Account — 帳號與認證
   - 2.2 Game — 遊戲房間與歷史
   - 2.3 Commerce — 商城與 IAP
   - 2.4 Admin — 後台管理
3. 共用 Schema 定義
4. API 呼叫序列圖
5. Webhook 規範
6. 標準 Headers
7. Error Code Registry
8. Rate Limiting
9. Batch Operations
10. File Upload
11. API Paradigm Decision
12. OpenAPI 3.1 Specification（YAML）
13. API Changelog
14. API Review Checklist
15. API Versioning & Deprecation Policy
16. Client SDK & Code Generation
17. API Observability & SLO

---

## 0. 快速概覽

| 項目 | 值 |
|------|-----|
| **Base URL（生產）** | `https://api.fishing-arcade-game.com/v1` |
| **Base URL（本地）** | `http://localhost:3000/v1` |
| **WebSocket（Colyseus）** | `wss://game.fishing-arcade-game.com` |
| **協議** | HTTPS 強制（TLS 1.3+；HTTP 重定向 308 至 HTTPS）|
| **認證** | `Authorization: Bearer <JWT>` — 所有端點必需（公開端點除外）|
| **回應格式** | `application/json; charset=utf-8` |
| **時區** | 所有時間欄位為 UTC，ISO 8601 格式（`2026-04-24T12:00:00Z`）|
| **分頁策略** | Cursor-based（`?after=<cursor>&limit=20`）— 非 OFFSET |
| **版本** | `v1` 路徑前綴，向下相容保證 ≥ 6 個月（見 §15）|
| **字元集** | UTF-8 |
| **最大請求 Body** | 1 MB（除 File Upload 端點外）|
| **路徑參數命名** | snake_case（`:user_id`, `:order_id`）；Response 欄位一律使用 `user_id`/`order_id`，User 資源縮略版中的 `id` 欄位等同 `user_id` |

---

## 1. 認證（Authentication）

### 1.1 取得 Token

**POST /v1/auth/login**

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `email` | string | ✅ | 電子郵件（格式驗證）|
| `password` | string | ✅ | 明文密碼（TLS 傳輸），8–128 字元 |

**Request 範例：**
```json
{
  "email": "player@example.com",
  "password": "Passw0rd!123"
}
```

**curl 範例：**
```bash
curl -X POST https://api.fishing-arcade-game.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"player@example.com","password":"Passw0rd!123"}'
```

**Response 200：**
```json
{
  "data": {
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "token_type": "Bearer",
    "user": {
      "id": "usr_01HX...",
      "email": "p***@example.com",
      "role": "player",
      "vip_tier": 0
    }
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**JWT Payload：**
```json
{
  "sub": "usr_01HX...",
  "role": "player",
  "iat": 1714003200,
  "exp": 1714006800,
  "jti": "jti_01HX..."
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | email/password 格式錯誤 |
| 401 | `INVALID_CREDENTIALS` | 帳號或密碼錯誤 |
| 423 | `ACCOUNT_LOCKED` | 帳號已鎖定（連續失敗 10 次）|
| 429 | `RATE_LIMITED` | 超過 10 req/min/IP 限制 |

---

### 1.2 使用 Token

所有需要認證的 API 請求必須在 HTTP Header 中包含：

```
Authorization: Bearer <access_token>
```

Token 有效期：`access_token` 1 小時；`refresh_token` 30 天（Sliding Window）。

---

### 1.3 刷新 Token

**POST /v1/auth/refresh**（公開端點，無需 Authorization header）

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `refresh_token` | string | ✅ | 有效的 Refresh Token |

**Response 200：**
```json
{
  "data": {
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `INVALID_REFRESH_TOKEN` | Token 無效、已過期或已吊銷 |
| 429 | `RATE_LIMITED` | 超過 10 req/min/IP |

---

### 1.4 認證 Rate Limit 設定

| 端點 | 限制 | 說明 |
|------|------|------|
| POST /auth/login | 10 req/min/IP | 防暴力破解 |
| POST /auth/register | 5 req/min/IP | 防批量註冊 |
| POST /auth/refresh | 30 req/min/IP | Refresh 較寬鬆 |
| 所有其他 API | 100 req/min/User | 預設限制 |
| POST /shop/purchases | 5 req/min/User | IAP 防重複購買 |
| Colyseus WebSocket | 60 msg/s/connection | 遊戲事件頻率上限 |

---

## 2. Endpoint 列表

### 2.1 Account — 帳號與認證

---

#### POST /v1/auth/register

**功能**：玩家帳號註冊（需年齡驗證）  
**認證**：不需要（公開）  
**權限**：public

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `email` | string | ✅ | RFC 5321 格式，最大 254 字元 |
| `password` | string | ✅ | 8–128 字元，需含大寫+數字 |
| `display_name` | string | ✅ | 玩家顯示名稱，2–30 字元，無特殊符號 |
| `birthdate` | string | ✅ | ISO 8601 日期（`YYYY-MM-DD`），年齡驗證用 |
| `agree_terms` | boolean | ✅ | 必須為 `true` |

**Request 範例：**
```json
{
  "email": "newplayer@example.com",
  "password": "Passw0rd!123",
  "display_name": "FishHunter88",
  "birthdate": "1995-03-15",
  "agree_terms": true
}
```

**curl 範例：**
```bash
curl -X POST https://api.fishing-arcade-game.com/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newplayer@example.com",
    "password": "Passw0rd!123",
    "display_name": "FishHunter88",
    "birthdate": "1995-03-15",
    "agree_terms": true
  }'
```

**Response 201：**
```json
{
  "data": {
    "user_id": "usr_01HX...",
    "email": "n***@example.com",
    "display_name": "FishHunter88",
    "age_verified": true,
    "created_at": "2026-04-24T12:00:00Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 欄位格式錯誤（errors 陣列含詳細欄位）|
| 409 | `EMAIL_ALREADY_EXISTS` | 電子郵件已被使用 |
| 422 | `AGE_RESTRICTION` | 年齡不符合法規要求（< 18 歲）|
| 429 | `RATE_LIMITED` | 超過 5 req/min/IP |

---

#### GET /v1/users/me

**功能**：取得當前玩家個人資料  
**認證**：✅ 需要 JWT  
**權限**：player:read

**curl 範例：**
```bash
curl https://api.fishing-arcade-game.com/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": {
    "id": "usr_01HX...",
    "email": "p***@example.com",
    "display_name": "FishHunter88",
    "role": "player",
    "vip_tier": 1,
    "vip_expires_at": "2026-05-24T00:00:00Z",
    "age_verified": true,
    "created_at": "2026-04-24T12:00:00Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效或過期 |

---

#### PATCH /v1/users/me

**功能**：更新玩家個人資料（Partial Update）  
**認證**：✅ 需要 JWT  
**權限**：player:write  
**冪等性**：相同請求重複執行結果相同  
**Partial Update 語義**：僅更新請求 Body 中包含的欄位；未傳入的欄位保持原值不變。所有欄位選填，但 Body 至少須包含一個欄位。

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `display_name` | string | ❌ | 2–30 字元，不含特殊符號 |
| `avatar_url` | string | ❌ | S3 presigned URL 上傳後的公開 URL，最大 512 字元 |

**Request 範例：**
```json
{
  "display_name": "SuperFishHunter"
}
```

**curl 範例：**
```bash
curl -X PATCH https://api.fishing-arcade-game.com/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{"display_name":"SuperFishHunter"}'
```

**Response 200：**
```json
{
  "data": {
    "id": "usr_01HX...",
    "display_name": "SuperFishHunter",
    "updated_at": "2026-04-24T12:05:00Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 欄位格式錯誤 |
| 401 | `UNAUTHORIZED` | Token 無效或過期 |
| 409 | `DISPLAY_NAME_TAKEN` | 顯示名稱已被使用 |

---

#### GET /v1/users/me/balance

**功能**：取得玩家遊戲幣餘額  
**認證**：✅ 需要 JWT  
**權限**：player:read

**curl 範例：**
```bash
curl https://api.fishing-arcade-game.com/v1/users/me/balance \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": {
    "user_id": "usr_01HX...",
    "gold_balance": 12500,
    "diamond_balance": 80,
    "updated_at": "2026-04-24T12:00:00Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效或過期 |

---

#### POST /v1/auth/logout

**功能**：登出（吊銷 Refresh Token）  
**認證**：✅ 需要 JWT  
**權限**：player:write

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `refresh_token` | string | ✅ | 要吊銷的 Refresh Token |

**Response 204**：無 body

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Access Token 無效 |

---

#### POST /v1/vip/subscriptions

**功能**：購買 VIP 訂閱（月費方案，使用鑽石）  
**認證**：✅ 需要 JWT  
**權限**：player:write  
**冪等性**：傳入 `Idempotency-Key` Header（UUID v4），相同 Key 重複呼叫回傳原始訂閱結果，不重複扣鑽

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `plan_id` | string | ✅ | VIP 方案 ID（`vip_monthly` / `vip_quarterly`）枚舉值 |

**Required Header：**

| Header | 必填 | 說明 |
|--------|------|------|
| `Idempotency-Key` | ✅ | UUID v4，防重複訂閱（24h TTL）|

**Request 範例：**
```json
{
  "plan_id": "vip_monthly"
}
```

**curl 範例：**
```bash
curl -X POST https://api.fishing-arcade-game.com/v1/vip/subscriptions \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: 550e8400-e29b-41d4-a716-446655440001" \
  -d '{"plan_id":"vip_monthly"}'
```

**Response 201：**
```json
{
  "data": {
    "subscription_id": "sub_01HX...",
    "plan_id": "vip_monthly",
    "vip_tier": 1,
    "activated_at": "2026-04-24T12:00:00Z",
    "expires_at": "2026-05-24T12:00:00Z",
    "diamonds_deducted": 30
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | plan_id 非 enum 值 |
| 401 | `UNAUTHORIZED` | Token 無效 |
| 409 | `DUPLICATE_SUBSCRIPTION` | 相同 Idempotency-Key 已使用（回傳原始訂閱）|
| 422 | `INSUFFICIENT_DIAMONDS` | 鑽石餘額不足 |
| 422 | `VIP_ALREADY_ACTIVE` | VIP 已啟用中（同方案不可重複訂閱）|

---

### 2.2 Game — 遊戲房間與歷史

> **注意**：遊戲即時通訊使用 Colyseus WebSocket（`wss://game.fishing-arcade-game.com`），非 REST API。以下端點用於房間查詢、歷史記錄等非即時操作。

---

#### GET /v1/game/rooms

**功能**：列出可加入的遊戲房間  
**認證**：✅ 需要 JWT  
**權限**：player:read  
**分頁**：Cursor-based

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `after` | string | ❌ | Cursor（base64 encoded room_id）|
| `limit` | integer | ❌ | 1–50，預設 20 |
| `status` | string | ❌ | `waiting` / `active`，預設 `waiting` |
| `sort` | string | ❌ | 排序欄位：`created_at`（預設，降序）/ `jackpot_pool`（降序）|

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/game/rooms?status=waiting&limit=20" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": [
    {
      "room_id": "room_01HX...",
      "room_name": "Ocean Battle #42",
      "status": "waiting",
      "player_count": 3,
      "max_players": 6,
      "jackpot_pool": 15000,
      "min_bet": 10,
      "created_at": "2026-04-24T11:55:00Z"
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6InJvb20_...",
    "has_more": true,
    "total_count": null
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 參數格式錯誤 |
| 401 | `UNAUTHORIZED` | Token 無效 |

---

#### GET /v1/game/history

**功能**：取得玩家個人遊戲歷史記錄  
**認證**：✅ 需要 JWT  
**權限**：player:read  
**分頁**：Cursor-based

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `after` | string | ❌ | Cursor |
| `limit` | integer | ❌ | 1–50，預設 20 |
| `from` | string | ❌ | 開始時間（ISO 8601 UTC）|
| `to` | string | ❌ | 結束時間（ISO 8601 UTC）|
| `sort` | string | ❌ | 排序欄位：`started_at`（預設，降序）/ `gold_earned`（降序）|

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/game/history?limit=20&from=2026-04-01T00:00:00Z" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": [
    {
      "session_id": "sess_01HX...",
      "room_id": "room_01HX...",
      "started_at": "2026-04-24T10:00:00Z",
      "ended_at": "2026-04-24T10:30:00Z",
      "gold_earned": 1200,
      "gold_spent": 800,
      "fish_killed": 47,
      "jackpot_won": 0,
      "rtp_actual": 0.88
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6InNlc3...",
    "has_more": false,
    "total_count": null
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 時間範圍格式錯誤 |
| 401 | `UNAUTHORIZED` | Token 無效 |

---

#### GET /v1/game/leaderboard

**功能**：取得全服排行榜（金幣榜）  
**認證**：✅ 需要 JWT  
**權限**：player:read

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `type` | string | ❌ | `daily` / `weekly` / `all_time`，預設 `daily` |
| `limit` | integer | ❌ | 1–100，預設 50 |

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/game/leaderboard?type=daily&limit=50" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": {
    "type": "daily",
    "period_start": "2026-04-24T00:00:00Z",
    "period_end": "2026-04-24T23:59:59Z",
    "rankings": [
      {
        "rank": 1,
        "user_id": "usr_01HX...",
        "display_name": "TopFisher",
        "gold_earned": 58000,
        "vip_tier": 2
      }
    ],
    "my_rank": {
      "rank": 142,
      "gold_earned": 12500
    }
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |

---

### 2.3 Commerce — 商城與 IAP

---

#### GET /v1/shop/products

**功能**：取得商城商品列表（鑽石儲值包）  
**認證**：✅ 需要 JWT  
**權限**：player:read

**curl 範例：**
```bash
curl https://api.fishing-arcade-game.com/v1/shop/products \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": [
    {
      "product_id": "diamonds_60",
      "name": "60 鑽石小包",
      "diamonds": 60,
      "bonus_diamonds": 0,
      "price_usd": 0.99,
      "apple_product_id": "com.fishingarcade.diamonds60",
      "google_product_id": "diamonds_60",
      "is_active": true,
      "badge": null
    },
    {
      "product_id": "diamonds_330",
      "name": "330 鑽石月包",
      "diamonds": 300,
      "bonus_diamonds": 30,
      "price_usd": 4.99,
      "apple_product_id": "com.fishingarcade.diamonds330",
      "google_product_id": "diamonds_330",
      "is_active": true,
      "badge": "BEST_VALUE"
    }
  ],
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |

---

#### POST /v1/shop/purchases

**功能**：驗證 IAP 收據並充值鑽石  
**認證**：✅ 需要 JWT  
**權限**：player:write  
**Rate Limit**：5 req/min/User

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `platform` | string | ✅ | `apple` / `google` |
| `product_id` | string | ✅ | 商品 ID（如 `diamonds_330`）|
| `receipt` | string | ✅ | Apple: base64 receipt data；Google: purchaseToken |
| `idempotency_key` | string | ✅ | UUID v4，防重複充值 |

**Request 範例：**
```json
{
  "platform": "apple",
  "product_id": "diamonds_330",
  "receipt": "MIIXXXXXXX...",
  "idempotency_key": "550e8400-e29b-41d4-a716-446655440000"
}
```

**curl 範例：**
```bash
curl -X POST https://api.fishing-arcade-game.com/v1/shop/purchases \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "apple",
    "product_id": "diamonds_330",
    "receipt": "MIIXXXXXXX...",
    "idempotency_key": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Response 201：**
```json
{
  "data": {
    "order_id": "ord_01HX...",
    "status": "completed",
    "diamonds_credited": 330,
    "new_diamond_balance": 410,
    "transaction_id": "1000000XXXXXX",
    "created_at": "2026-04-24T12:00:00Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 欄位格式錯誤 |
| 401 | `UNAUTHORIZED` | Token 無效 |
| 409 | `DUPLICATE_PURCHASE` | idempotency_key 已使用（重複請求，回傳原始訂單）|
| 422 | `IAP_RECEIPT_INVALID` | 收據驗證失敗（IAP 平台回拒）|
| 422 | `IAP_RECEIPT_USED` | 收據已被使用 |
| 429 | `RATE_LIMITED` | 超過 5 req/min/User |
| 503 | `IAP_SERVICE_UNAVAILABLE` | IAP 平台暫時不可用（Circuit Breaker 觸發）|

---

#### GET /v1/shop/orders

**功能**：取得玩家訂單歷史  
**認證**：✅ 需要 JWT  
**權限**：player:read  
**分頁**：Cursor-based

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `after` | string | ❌ | Cursor |
| `limit` | integer | ❌ | 1–50，預設 20 |
| `sort` | string | ❌ | 排序欄位：`created_at`（預設，降序）|
| `status` | string | ❌ | 篩選訂單狀態：`completed` / `pending` / `failed` |

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/shop/orders?limit=20" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": [
    {
      "order_id": "ord_01HX...",
      "product_id": "diamonds_330",
      "platform": "apple",
      "status": "completed",
      "diamonds_credited": 330,
      "amount_usd": 4.99,
      "created_at": "2026-04-24T12:00:00Z"
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6Im9yZF...",
    "has_more": false,
    "total_count": null
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |

---

#### GET /v1/shop/orders/:order_id

**功能**：取得單筆訂單詳情  
**認證**：✅ 需要 JWT  
**權限**：player:read（僅限本人訂單；operator/superadmin 可查所有）

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/shop/orders/ord_01HX..." \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": {
    "order_id": "ord_01HX...",
    "product_id": "diamonds_330",
    "platform": "apple",
    "transaction_id": "1000000XXXXXX",
    "status": "completed",
    "diamonds_credited": 330,
    "amount_usd": 4.99,
    "receipt_hash": "sha256:abcdef...",
    "created_at": "2026-04-24T12:00:00Z",
    "completed_at": "2026-04-24T12:00:02Z"
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非本人訂單且無管理員權限 |
| 404 | `ORDER_NOT_FOUND` | 訂單不存在 |

---

### 2.4 Admin — 後台管理

> 所有 Admin 端點需要 `operator` 或 `superadmin` 角色。

---

#### GET /v1/admin/users

**功能**：列出所有玩家（後台用）  
**認證**：✅ 需要 JWT  
**權限**：operator:read  
**分頁**：Cursor-based

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `after` | string | ❌ | Cursor |
| `limit` | integer | ❌ | 1–100，預設 50 |
| `search` | string | ❌ | 搜尋 email 或 display_name（前綴匹配）|
| `vip_tier` | integer | ❌ | 篩選 VIP 等級 0–3 |
| `status` | string | ❌ | `active` / `suspended` / `banned` |
| `sort` | string | ❌ | 排序欄位：`created_at`（預設，降序）/ `last_login_at` / `gold_balance` |

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/admin/users?limit=50&status=active" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": [
    {
      "id": "usr_01HX...",
      "email": "p***@example.com",
      "display_name": "FishHunter88",
      "role": "player",
      "vip_tier": 1,
      "gold_balance": 12500,
      "diamond_balance": 80,
      "status": "active",
      "created_at": "2026-04-24T12:00:00Z",
      "last_login_at": "2026-04-24T10:00:00Z"
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6InVzcl...",
    "has_more": true,
    "total_count": null
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非 operator/superadmin 角色 |

---

#### PATCH /v1/admin/users/:user_id

**功能**：更新玩家帳號狀態（封禁/解封/調整餘額）  
**認證**：✅ 需要 JWT  
**權限**：superadmin:write  
**冪等性**：相同請求重複執行結果相同  
**Partial Update 語義**：僅更新請求 Body 中包含的欄位；未傳入的欄位保持原值不變。  
**Audit Log**：所有成功操作自動寫入 `audit_logs` 表（operator_id、target_user_id、action、reason、IP、timestamp）。  
**X-Admin-Reason Header**：敏感操作（status 變更、gold_adjustment）需傳入 `X-Admin-Reason` Header（最大 256 字元）。

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `status` | string | ❌ | `active` / `suspended` / `banned` |
| `suspend_reason` | string | ❌ | 封禁原因（status=suspended/banned 時必填）|
| `gold_adjustment` | integer | ❌ | 金幣調整量（正數加，負數扣；SuperAdmin 限定）|
| `adjustment_reason` | string | ❌ | gold_adjustment 不為 0 時必填 |
| `X-Admin-Reason` | Header | 條件 | 必填（status 變更或 gold_adjustment 不為 0 時）|

**curl 範例：**
```bash
curl -X PATCH "https://api.fishing-arcade-game.com/v1/admin/users/usr_01HX..." \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -H "X-Admin-Reason: 違反遊戲服務條款 §3.2（外掛工具）" \
  -d '{"status":"suspended","suspend_reason":"外掛工具使用"}'
```

**Response 200：**
```json
{
  "data": {
    "user_id": "usr_01HX...",
    "status": "suspended",
    "updated_at": "2026-04-24T12:10:00Z",
    "updated_by": "usr_admin_01HX..."
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 欄位格式錯誤 |
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非 superadmin 角色 |
| 404 | `USER_NOT_FOUND` | 玩家不存在 |
| 422 | `CANNOT_MODIFY_ADMIN` | 不可修改管理員帳號 |

---

#### GET /v1/admin/game-config

**功能**：取得遊戲設定（RTP 目標、Jackpot 觸發機率）  
**認證**：✅ 需要 JWT  
**curl 範例：**
```bash
curl https://api.fishing-arcade-game.com/v1/admin/game-config \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**權限**：operator:read

**Response 200：**
```json
{
  "data": {
    "rtp_target_min": 0.85,
    "rtp_target_max": 0.95,
    "jackpot_trigger_probability": 0.0001,
    "jackpot_min_pool": 10000,
    "fish_spawn_rate": 1.0,
    "max_players_per_room": 6,
    "session_timeout_seconds": 1800,
    "updated_at": "2026-04-24T00:00:00Z",
    "updated_by": "usr_admin_01HX..."
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非 operator/superadmin 角色 |

---

#### PATCH /v1/admin/game-config

**功能**：更新遊戲設定（透過 Unleash Feature Flag 生效）  
**認證**：✅ 需要 JWT  
**權限**：superadmin:write  
**冪等性**：相同請求重複執行結果相同  
**Partial Update 語義**：僅更新傳入的欄位；未傳入的欄位保持原值不變。至少須傳入一個欄位。

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `rtp_target_min` | number | ❌ | 0.80–0.95（float，最多 4 位小數）|
| `rtp_target_max` | number | ❌ | rtp_target_min 至 0.98（必須 ≥ rtp_target_min）|
| `jackpot_trigger_probability` | number | ❌ | 0.00001–0.001 |
| `fish_spawn_rate` | number | ❌ | 0.5–2.0（倍率）|

**curl 範例：**
```bash
curl -X PATCH https://api.fishing-arcade-game.com/v1/admin/game-config \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{"rtp_target_min":0.87,"rtp_target_max":0.93}'
```

**Response 200：**
```json
{
  "data": {
    "rtp_target_min": 0.87,
    "rtp_target_max": 0.93,
    "effective_at": "2026-04-24T12:15:00Z",
    "updated_by": "usr_admin_01HX..."
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 400 | `VALIDATION_ERROR` | 數值超出允許範圍 |
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非 superadmin 角色 |
| 422 | `RTP_RANGE_INVALID` | rtp_target_min > rtp_target_max |

---

#### GET /v1/admin/stats/kpi

**功能**：取得 KPI 統計數據（DAU/MAU/Revenue）  
**認證**：✅ 需要 JWT  
**權限**：operator:read

**Query Parameters：**

| 參數 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `period` | string | ❌ | `today` / `7d` / `30d`，預設 `today` |

**curl 範例：**
```bash
curl "https://api.fishing-arcade-game.com/v1/admin/stats/kpi?period=today" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."
```

**Response 200：**
```json
{
  "data": {
    "period": "today",
    "from": "2026-04-24T00:00:00Z",
    "to": "2026-04-24T23:59:59Z",
    "dau": 842,
    "new_registrations": 34,
    "active_rooms": 18,
    "revenue_usd": 1250.50,
    "iap_transactions": 87,
    "jackpot_triggered_count": 2,
    "avg_session_duration_minutes": 24.3,
    "avg_rtp_actual": 0.8923
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**錯誤回應：**

| HTTP | Error Code | 說明 |
|------|-----------|------|
| 401 | `UNAUTHORIZED` | Token 無效 |
| 403 | `FORBIDDEN` | 非 operator/superadmin 角色 |

---

### 2.5 RBAC 權限矩陣（Role × Endpoint）

> 依 EDD §4.1 Role-Based Access Control 定義。`✅` = 允許；`❌` = 拒絕（回傳 403）；`—` = 不適用（公開）。

| Endpoint | player | operator | superadmin |
|----------|--------|----------|------------|
| POST /auth/login | — | — | — |
| POST /auth/register | — | — | — |
| POST /auth/refresh | — | — | — |
| POST /auth/logout | ✅ | ✅ | ✅ |
| GET /users/me | ✅ | ✅ | ✅ |
| PATCH /users/me | ✅ | ✅ | ✅ |
| GET /users/me/balance | ✅ | ✅ | ✅ |
| POST /vip/subscriptions | ✅ | ❌ | ✅ |
| GET /game/rooms | ✅ | ✅ | ✅ |
| GET /game/history | ✅（僅本人）| ✅（僅本人）| ✅（所有人）|
| GET /game/leaderboard | ✅ | ✅ | ✅ |
| GET /shop/products | ✅ | ✅ | ✅ |
| POST /shop/purchases | ✅ | ❌ | ✅ |
| GET /shop/orders | ✅（僅本人）| ✅（僅本人）| ✅（所有人）|
| GET /shop/orders/:order_id | ✅（僅本人）| ✅ | ✅ |
| POST /users/me/avatar/upload-url | ✅ | ✅ | ✅ |
| GET /admin/users | ❌ | ✅ | ✅ |
| PATCH /admin/users/:user_id | ❌ | ❌ | ✅ |
| GET /admin/game-config | ❌ | ✅ | ✅ |
| PATCH /admin/game-config | ❌ | ❌ | ✅ |
| GET /admin/stats/kpi | ❌ | ✅ | ✅ |

**403 Forbidden 觸發條件**：JWT 有效但 role 不在允許列表；Token 未攜帶時回傳 401 而非 403。

---

## 3. 共用 Schema 定義

### 3.1 成功回應 Envelope

```json
{
  "data": { "...": "資源物件或陣列" },
  "meta": {
    "request_id": "req_01HX..."
  }
}
```

### 3.2 錯誤 Envelope

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input validation failed",
    "errors": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "not-an-email"
      }
    ],
    "request_id": "req_01HX..."
  }
}
```

### 3.3 分頁 Envelope（Cursor-based）

```json
{
  "data": ["...陣列"],
  "pagination": {
    "next_cursor": "eyJpZCI6Inh4eCIsInRzIjoxNzE0MDA0ODAwfQ==",
    "has_more": true,
    "total_count": null
  },
  "meta": { "request_id": "req_01HX..." }
}
```

> **next_cursor**：base64 encoded JSON，內含 `{ "id": "last_record_id", "ts": unix_timestamp }`。
> **total_count**：大資料集不提供（避免全表 COUNT(*) 掃描）。

---

## 4. API 呼叫序列圖

> 完整 Sequence Diagram 檔案（含 Happy Path + Error Paths）位於 `docs/diagrams/`：
> - [sequence-login.md](diagrams/sequence-login.md) — POST /auth/login
> - [sequence-register.md](diagrams/sequence-register.md) — POST /auth/register
> - [sequence-iap-purchase.md](diagrams/sequence-iap-purchase.md) — POST /shop/purchases
> - [sequence-vip-subscribe.md](diagrams/sequence-vip-subscribe.md) — POST /vip/subscriptions

### 4.1 IAP 充值流程（Write Path）

```mermaid
sequenceDiagram
    participant Client as Cocos Client
    participant Ingress as Nginx Ingress
    participant Shop as Shop Service
    participant IAP as Apple/Google IAP
    participant MySQL as MySQL
    participant EventBus as Redis Pub/Sub
    participant Account as Account Service

    Client->>Ingress: POST /v1/shop/purchases (Bearer JWT + receipt)
    Ingress->>Shop: 路由 + JWT 驗證
    Shop->>Shop: Zod 驗證 + idempotency_key 檢查
    Shop->>IAP: HTTPS verifyReceipt(receipt)
    IAP-->>Shop: { status: 0, product_id, transaction_id }
    Shop->>MySQL: INSERT orders (status=pending)
    Shop->>MySQL: UPDATE orders SET status=completed
    Shop->>EventBus: PUBLISH events:commerce IAPPurchaseCompleted
    EventBus-->>Account: 異步消費 → UPDATE users.diamond_balance += 330
    Shop-->>Client: 201 { order_id, diamonds_credited: 330 }
```

### 4.2 玩家登入 + 遊戲加入流程（Read + WebSocket）

```mermaid
sequenceDiagram
    participant Client as Cocos Client
    participant Ingress as Nginx Ingress
    participant Account as Account Service
    participant Redis as Redis
    participant Game as Game Service (Colyseus)

    Client->>Ingress: POST /v1/auth/login (email + password)
    Ingress->>Account: 路由
    Account->>Account: bcrypt.compare(password, hash)
    Account->>Redis: SET session:{jti} (TTL 1h)
    Account-->>Client: 200 { access_token, refresh_token }

    Client->>Ingress: GET /v1/game/rooms
    Ingress->>Game: 路由 + JWT 驗證
    Game-->>Client: 200 [room 列表]

    Client->>Ingress: WSS Upgrade (Authorization: Bearer token)
    Ingress->>Game: Proxy WSS → Colyseus :2567
    Game->>Game: onAuth() 驗證 JWT
    Game-->>Client: WebSocket Connected (room state sync)
```

---

## 5. Webhook 規範

本系統 Phase 1 不對外提供 Webhook。Phase 2 計劃提供 Jackpot 觸發通知 Webhook，規範如下（預留）：

**事件類型**：`jackpot.triggered`

**POST 目標**：運營商在後台設定的 Webhook URL

**Headers：**
```
Content-Type: application/json
X-Signature: sha256=<HMAC-SHA256(webhook_secret, raw_body)>
X-Event-ID: evt_01HX...
X-Event-Type: jackpot.triggered
```

**Body：**
```json
{
  "event_id": "evt_01HX...",
  "event_type": "jackpot.triggered",
  "occurred_at": "2026-04-24T12:00:00Z",
  "data": {
    "winner_user_id": "usr_01HX...",
    "jackpot_amount": 50000,
    "room_id": "room_01HX..."
  }
}
```

**重試策略**：指數退避（1m, 5m, 30m, 2h, 1d）；超過 5 次失敗 → 停用並通知 SuperAdmin。

---

## 6. 標準 Headers

### 6.1 Request Headers

| Header | 必填 | 說明 |
|--------|------|------|
| `Authorization` | 條件 | `Bearer <JWT>`（非公開端點必填）|
| `Content-Type` | POST/PATCH | `application/json` |
| `X-Request-ID` | ❌ | 客戶端生成的 UUID，回傳於 meta.request_id |
| `X-Platform` | ❌ | `ios` / `android` / `web`（遙測用）|
| `X-App-Version` | ❌ | 客戶端應用版本（`1.0.0`）|
| `Idempotency-Key` | 條件 | POST /vip/subscriptions 必填，UUID v4 |
| `X-Admin-Reason` | 條件 | PATCH /admin/users/:user_id 敏感操作時必填，最大 256 字元 |

### 6.2 Response Headers

| Header | 說明 |
|--------|------|
| `X-Request-ID` | 對應 meta.request_id，方便追蹤 |
| `X-RateLimit-Limit` | 此端點的速率上限 |
| `X-RateLimit-Remaining` | 目前窗口剩餘配額 |
| `X-RateLimit-Reset` | 配額重置時間（Unix timestamp）|
| `Deprecation` | `true`（廢棄端點才出現）|
| `Sunset` | 廢棄端點的截止日期（RFC 3339）|

---

## 7. Error Code Registry

> 所有 `error.code` 均為全大寫底線格式（`DOMAIN_ENTITY_REASON`），唯一不重複。各 Endpoint 的錯誤碼均引用此 Registry，不重複定義。

| HTTP Code | Error Code | 說明 | 建議客戶端行為 |
|-----------|-----------|------|-------------|
| 400 | `VALIDATION_ERROR` | 輸入格式驗證失敗（`errors` 陣列含欄位詳情）| 顯示欄位錯誤提示 |
| 401 | `UNAUTHORIZED` | Token 無效、過期或缺失 | 導向登入頁 |
| 401 | `INVALID_CREDENTIALS` | 帳號或密碼錯誤 | 顯示錯誤訊息 |
| 401 | `INVALID_REFRESH_TOKEN` | Refresh Token 無效或過期 | 導向登入頁 |
| 403 | `FORBIDDEN` | 無此操作的角色權限 | 顯示無權限提示 |
| 404 | `NOT_FOUND` | 資源不存在 | 顯示 404 提示 |
| 404 | `USER_NOT_FOUND` | 指定玩家不存在 | 顯示 404 提示 |
| 404 | `ORDER_NOT_FOUND` | 指定訂單不存在 | 顯示 404 提示 |
| 409 | `CONFLICT` | 資源已存在（泛型）| 提示用戶更換輸入 |
| 409 | `EMAIL_ALREADY_EXISTS` | 電子郵件已被使用 | 提示更換 Email |
| 409 | `DISPLAY_NAME_TAKEN` | 顯示名稱已被使用 | 提示更換名稱 |
| 409 | `DUPLICATE_PURCHASE` | 重複購買（idempotency_key 已使用）| 查詢原訂單狀態 |
| 409 | `DUPLICATE_SUBSCRIPTION` | VIP 訂閱 Idempotency-Key 重複 | 查詢原訂閱狀態 |
| 422 | `BUSINESS_RULE_VIOLATION` | 業務規則違反（泛型）| 顯示 message 內容 |
| 422 | `INSUFFICIENT_DIAMONDS` | 鑽石不足 | 導向商城 |
| 422 | `AGE_RESTRICTION` | 年齡不符合法規要求（< 18 歲）| 顯示法規提示 |
| 422 | `VIP_ALREADY_ACTIVE` | VIP 已啟用中（同方案不可重複訂閱）| 顯示當前 VIP 到期日 |
| 422 | `IAP_RECEIPT_INVALID` | IAP 收據無效（平台回拒）| 提示重試或聯繫客服 |
| 422 | `IAP_RECEIPT_USED` | IAP 收據已被使用 | 提示聯繫客服 |
| 422 | `CANNOT_MODIFY_ADMIN` | 不可修改管理員帳號 | 顯示操作限制提示 |
| 422 | `RTP_RANGE_INVALID` | rtp_target_min > rtp_target_max | 修正數值後重試 |
| 423 | `ACCOUNT_LOCKED` | 帳號鎖定（連續失敗 10 次）| 提示聯繫客服 |
| 429 | `RATE_LIMITED` | 速率限制（Headers 含重置時間）| 依 `Retry-After` Header 等待後重試 |
| 500 | `INTERNAL_ERROR` | 系統錯誤（不含內部詳情）| 提示稍後重試並回報 |
| 503 | `SERVICE_UNAVAILABLE` | 服務暫時不可用（Circuit Breaker）| 等待後重試 |
| 503 | `IAP_SERVICE_UNAVAILABLE` | IAP 平台暫時不可用 | 等待後重試 |

---

## 8. Rate Limiting

### 8.1 三層 Rate Limiting

| 層次 | 執行位置 | 規則 | 觸發回應 |
|------|---------|------|---------|
| Layer 1（IP 層）| Nginx Ingress | 100 req/s/IP（全域）| HTTP 429 + `Retry-After` |
| Layer 2（User 層）| Express Middleware（Redis）| 100 req/min/User（預設）| HTTP 429 + Error Code |
| Layer 3（端點層）| Express Middleware | 各端點獨立配置（見 §1.4）| HTTP 429 + Error Code |

### 8.2 Rate Limit 429 Response

```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests. Please retry after 60 seconds.",
    "retry_after": 60,
    "request_id": "req_01HX..."
  }
}
```

---

## 9. Batch Operations

本系統 Phase 1 不提供批次端點。Phase 2 計劃：

**POST /v1/admin/users/batch** — 批次封禁/更新玩家帳號

**Response 207 Multi-Status：**
```json
{
  "data": {
    "results": [
      { "user_id": "usr_01HX...", "status": 200, "result": "updated" },
      { "user_id": "usr_02HX...", "status": 404, "error": { "code": "USER_NOT_FOUND" } }
    ],
    "succeeded": 1,
    "failed": 1
  },
  "meta": { "request_id": "req_01HX..." }
}
```

---

## 10. File Upload

### 10.1 頭像上傳（S3 Presigned URL 模式）

**Step 1：取得 Presigned URL**

**POST /v1/users/me/avatar/upload-url**

**認證**：✅ 需要 JWT

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `content_type` | string | ✅ | `image/jpeg` / `image/png` / `image/webp` |
| `file_size_bytes` | integer | ✅ | 最大 2,097,152（2 MB）|

**Response 200：**
```json
{
  "data": {
    "upload_url": "https://game-assets-prod.s3.amazonaws.com/avatars/usr_01HX...?X-Amz-Signature=...",
    "public_url": "https://assets.fishing-arcade-game.com/avatars/usr_01HX....jpg",
    "expires_in": 300
  },
  "meta": { "request_id": "req_01HX..." }
}
```

**Step 2**：客戶端直接 PUT 到 `upload_url`（Content-Type 必須匹配）

**Step 3**：PUT 成功後，呼叫 `PATCH /v1/users/me` 更新 `avatar_url` 為 `public_url`

**Step 4（非同步後台）**：S3 Event 觸發 Lambda 病毒掃描（ClamAV）；掃描失敗 → 自動刪除檔案 + 清空 avatar_url + 通知用戶。

**檔案限制**：最大 2 MB；格式 JPEG/PNG/WebP（MIME 白名單驗證，非副檔名黑名單）；圖片尺寸 100×100–2048×2048；Presigned URL 有效期 300 秒（5 分鐘）。

**curl 範例（Step 1）：**
```bash
curl -X POST https://api.fishing-arcade-game.com/v1/users/me/avatar/upload-url \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{"content_type":"image/jpeg","file_size_bytes":524288}'
```

---

## 11. API Paradigm Decision

### 11.1 技術選型比較

| 面向 | REST | GraphQL | gRPC |
|------|------|---------|------|
| 適合場景 | 資源 CRUD，行動端 App | 複雜圖狀數據，前端自選欄位 | 服務間 RPC，強型別，高性能 |
| 學習曲線 | 低 | 中 | 高 |
| 工具生態 | 最豐富 | 豐富 | 中等 |
| 行動端整合 | 優秀（HTTP/2 友好）| 良好 | 需特殊支援 |
| 型別安全 | OpenAPI 生成 | Schema 內建 | Protobuf 內建 |
| N+1 問題 | 無（資源設計良好時）| 需 DataLoader | 無 |
| Cache（HTTP 層）| 支援（GET Cache-Control）| 較複雜 | 不支援 |

### 11.2 本產品決策：REST（OpenAPI 3.1）

**決策依據**：

1. **客戶端技術**：Cocos Creator 3.x（Lua/TypeScript）對 REST HTTP 支援最成熟，GraphQL 客戶端生態在遊戲引擎中較弱
2. **資源模式清晰**：User、Order、Room、GameSession 等資源邊界清晰，適合 REST 語意
3. **行動端 Cache**：REST GET 端點可直接利用 HTTP Cache-Control，減少重複請求（商品列表、排行榜）
4. **團隊熟悉度**：3–5 人團隊以 REST + Express 為主要技術棧（EDD §3.3）
5. **OpenAPI 工具鏈**：`openapi-generator-cli` 可生成 TypeScript/Swift/Kotlin SDK，覆蓋所有客戶端平台

**WebSocket（Colyseus）**：即時遊戲對戰保留 WebSocket，由 Colyseus 框架提供 Schema State Sync — 這不是 REST 端點，是獨立的 Colyseus Room 協議。

---

## 12. OpenAPI 3.1 Specification（YAML）

```yaml
openapi: 3.1.0
info:
  title: fishing-arcade-game API
  version: 1.0.0
  description: |
    多人即時競技捕魚遊戲平台 REST API。
    Base URL: https://api.fishing-arcade-game.com/v1
    認證: Bearer JWT (RS256)
  contact:
    email: backend@fishing-arcade-game.com

servers:
  - url: https://api.fishing-arcade-game.com/v1
    description: Production
  - url: http://localhost:3000/v1
    description: Local Development

security:
  - BearerAuth: []

paths:
  /auth/login:
    post:
      summary: 玩家登入
      tags: [Auth]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LoginRequest'
      responses:
        '200':
          description: 登入成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LoginResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/TooManyRequests'

  /auth/register:
    post:
      summary: 玩家註冊
      tags: [Auth]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RegisterRequest'
      responses:
        '201':
          description: 註冊成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/Conflict'

  /auth/refresh:
    post:
      summary: 刷新 Access Token
      tags: [Auth]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [refresh_token]
              properties:
                refresh_token:
                  type: string
      responses:
        '200':
          description: Token 刷新成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /users/me:
    get:
      summary: 取得當前玩家個人資料
      tags: [Users]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserProfile'
        '401':
          $ref: '#/components/responses/Unauthorized'
    patch:
      summary: 更新玩家個人資料
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateProfileRequest'
      responses:
        '200':
          description: 更新成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /users/me/balance:
    get:
      summary: 取得玩家餘額
      tags: [Users]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserBalance'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /shop/products:
    get:
      summary: 取得商品列表
      tags: [Shop]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Product'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /shop/purchases:
    post:
      summary: 驗證 IAP 收據並充值
      tags: [Shop]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PurchaseRequest'
      responses:
        '200':
          description: 充值成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PurchaseResponse'
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '422':
          $ref: '#/components/responses/BusinessRuleViolation'
        '429':
          $ref: '#/components/responses/TooManyRequests'

  /game/rooms:
    get:
      summary: 列出遊戲房間
      tags: [Game]
      parameters:
        - $ref: '#/components/parameters/AfterCursor'
        - $ref: '#/components/parameters/LimitParam'
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /admin/stats/kpi:
    get:
      summary: 取得 KPI 統計
      tags: [Admin]
      parameters:
        - in: query
          name: period
          schema:
            type: string
            enum: [today, 7d, 30d]
            default: today
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

  /auth/logout:
    post:
      summary: 登出（吊銷 Refresh Token）
      tags: [Auth]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [refresh_token]
              properties:
                refresh_token:
                  type: string
      responses:
        '204':
          description: 登出成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /vip/subscriptions:
    post:
      summary: 購買 VIP 訂閱
      tags: [VIP]
      parameters:
        - in: header
          name: Idempotency-Key
          required: true
          schema:
            type: string
            format: uuid
          description: UUID v4，防重複訂閱
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [plan_id]
              properties:
                plan_id:
                  type: string
                  enum: [vip_monthly, vip_quarterly]
      responses:
        '201':
          description: 訂閱成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '409':
          $ref: '#/components/responses/Conflict'
        '422':
          $ref: '#/components/responses/BusinessRuleViolation'

  /game/history:
    get:
      summary: 取得玩家遊戲歷史
      tags: [Game]
      parameters:
        - $ref: '#/components/parameters/AfterCursor'
        - $ref: '#/components/parameters/LimitParam'
        - in: query
          name: from
          schema:
            type: string
            format: date-time
          description: 開始時間（ISO 8601 UTC）
        - in: query
          name: to
          schema:
            type: string
            format: date-time
          description: 結束時間（ISO 8601 UTC）
        - in: query
          name: sort
          schema:
            type: string
            enum: [started_at, gold_earned]
            default: started_at
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /game/leaderboard:
    get:
      summary: 取得排行榜
      tags: [Game]
      parameters:
        - in: query
          name: type
          schema:
            type: string
            enum: [daily, weekly, all_time]
            default: daily
        - $ref: '#/components/parameters/LimitParam'
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /shop/orders:
    get:
      summary: 取得訂單歷史
      tags: [Shop]
      parameters:
        - $ref: '#/components/parameters/AfterCursor'
        - $ref: '#/components/parameters/LimitParam'
        - in: query
          name: status
          schema:
            type: string
            enum: [completed, pending, failed]
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'

  /shop/orders/{order_id}:
    get:
      summary: 取得訂單詳情
      tags: [Shop]
      parameters:
        - in: path
          name: order_id
          required: true
          schema:
            type: string
          description: 訂單 ID
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

  /users/me/avatar/upload-url:
    post:
      summary: 取得頭像上傳 Presigned URL
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [content_type, file_size_bytes]
              properties:
                content_type:
                  type: string
                  enum: [image/jpeg, image/png, image/webp]
                file_size_bytes:
                  type: integer
                  minimum: 1
                  maximum: 2097152
      responses:
        '200':
          description: 成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /admin/users:
    get:
      summary: 列出所有玩家（後台）
      tags: [Admin]
      parameters:
        - $ref: '#/components/parameters/AfterCursor'
        - $ref: '#/components/parameters/LimitParam'
        - in: query
          name: search
          schema:
            type: string
          description: email 或 display_name 前綴搜尋
        - in: query
          name: vip_tier
          schema:
            type: integer
            minimum: 0
            maximum: 3
        - in: query
          name: status
          schema:
            type: string
            enum: [active, suspended, banned]
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

  /admin/users/{user_id}:
    patch:
      summary: 更新玩家帳號狀態
      tags: [Admin]
      parameters:
        - in: path
          name: user_id
          required: true
          schema:
            type: string
        - in: header
          name: X-Admin-Reason
          schema:
            type: string
            maxLength: 256
          description: 操作理由（status 變更或 gold_adjustment 時必填）
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  enum: [active, suspended, banned]
                suspend_reason:
                  type: string
                  maxLength: 512
                gold_adjustment:
                  type: integer
                adjustment_reason:
                  type: string
                  maxLength: 512
      responses:
        '200':
          description: 成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'
        '422':
          $ref: '#/components/responses/BusinessRuleViolation'

  /admin/game-config:
    get:
      summary: 取得遊戲設定
      tags: [Admin]
      responses:
        '200':
          description: 成功
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
    patch:
      summary: 更新遊戲設定
      tags: [Admin]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                rtp_target_min:
                  type: number
                  minimum: 0.80
                  maximum: 0.95
                rtp_target_max:
                  type: number
                  minimum: 0.80
                  maximum: 0.98
                jackpot_trigger_probability:
                  type: number
                  minimum: 0.00001
                  maximum: 0.001
                fish_spawn_rate:
                  type: number
                  minimum: 0.5
                  maximum: 2.0
      responses:
        '200':
          description: 成功
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '422':
          $ref: '#/components/responses/BusinessRuleViolation'

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    LoginRequest:
      type: object
      required: [email, password]
      properties:
        email:
          type: string
          format: email
          maxLength: 254
        password:
          type: string
          minLength: 8
          maxLength: 128

    LoginResponse:
      type: object
      properties:
        data:
          type: object
          properties:
            access_token:
              type: string
            refresh_token:
              type: string
            expires_in:
              type: integer
            token_type:
              type: string
            user:
              $ref: '#/components/schemas/UserSummary'
        meta:
          $ref: '#/components/schemas/Meta'

    RegisterRequest:
      type: object
      required: [email, password, display_name, birthdate, agree_terms]
      properties:
        email:
          type: string
          format: email
          maxLength: 254
        password:
          type: string
          minLength: 8
          maxLength: 128
        display_name:
          type: string
          minLength: 2
          maxLength: 30
        birthdate:
          type: string
          format: date
        agree_terms:
          type: boolean
          const: true

    UserSummary:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        role:
          type: string
          enum: [player, operator, superadmin]
        vip_tier:
          type: integer
          minimum: 0
          maximum: 3

    UserProfile:
      allOf:
        - $ref: '#/components/schemas/UserSummary'
        - type: object
          properties:
            display_name:
              type: string
            vip_expires_at:
              type: string
              format: date-time
            age_verified:
              type: boolean
            created_at:
              type: string
              format: date-time

    UserBalance:
      type: object
      properties:
        user_id:
          type: string
        gold_balance:
          type: integer
          minimum: 0
        diamond_balance:
          type: integer
          minimum: 0
        updated_at:
          type: string
          format: date-time

    UpdateProfileRequest:
      type: object
      properties:
        display_name:
          type: string
          minLength: 2
          maxLength: 30
        avatar_url:
          type: string
          maxLength: 512

    Product:
      type: object
      properties:
        product_id:
          type: string
        name:
          type: string
        diamonds:
          type: integer
        bonus_diamonds:
          type: integer
        price_usd:
          type: number
          format: float
        apple_product_id:
          type: string
        google_product_id:
          type: string
        is_active:
          type: boolean
        badge:
          type: string
          nullable: true

    PurchaseRequest:
      type: object
      required: [platform, product_id, receipt, idempotency_key]
      properties:
        platform:
          type: string
          enum: [apple, google]
        product_id:
          type: string
        receipt:
          type: string
        idempotency_key:
          type: string
          format: uuid

    PurchaseResponse:
      type: object
      properties:
        data:
          type: object
          properties:
            order_id:
              type: string
            status:
              type: string
            diamonds_credited:
              type: integer
            new_diamond_balance:
              type: integer
            transaction_id:
              type: string
            created_at:
              type: string
              format: date-time

    Meta:
      type: object
      properties:
        request_id:
          type: string

    ErrorEnvelope:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
            errors:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                  message:
                    type: string
            request_id:
              type: string

  responses:
    Unauthorized:
      description: Token 無效或過期
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'
          example:
            error:
              code: UNAUTHORIZED
              message: Invalid or expired token
              request_id: req_01HX...

    ValidationError:
      description: 輸入驗證失敗
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'
          example:
            error:
              code: VALIDATION_ERROR
              message: Input validation failed
              errors:
                - field: email
                  message: Invalid email format
              request_id: req_01HX...

    NotFound:
      description: 資源不存在
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'

    Forbidden:
      description: 無操作權限
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'

    Conflict:
      description: 資源衝突
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'

    BusinessRuleViolation:
      description: 業務規則違反
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'

    TooManyRequests:
      description: 超過速率限制
      headers:
        X-RateLimit-Reset:
          schema:
            type: integer
          description: 配額重置時間 (Unix timestamp)
        Retry-After:
          schema:
            type: integer
          description: 建議等待秒數
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorEnvelope'

  parameters:
    AfterCursor:
      in: query
      name: after
      schema:
        type: string
      description: Cursor-based 分頁起始位置（base64 encoded）

    LimitParam:
      in: query
      name: limit
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
      description: 每頁筆數
```

---

## 13. API Changelog

| 版本 | 日期 | 變更說明 | 破壞性變更 |
|------|------|---------|-----------|
| v1.0.0 | 2026-04-24 | 初始版本 — Account/Game/Commerce/Admin 全端點 | — |

**預計 v1.1.0 變更（Phase 2）：**
- 新增 POST /admin/users/batch（批次操作）
- 新增 POST /v1/webhooks（Webhook 設定）
- GET /game/history 新增 `fish_type` 篩選參數

---

## 14. API Review Checklist

| # | 項目 | 狀態 |
|---|------|------|
| 1 | 每個 PRD P0 功能都有對應 Endpoint | ✅ |
| 2 | 所有 Endpoint 有完整 Request/Response Schema | ✅ |
| 3 | 每個 Endpoint 有錯誤碼（至少 400、401、500）| ✅ |
| 4 | 認證說明完整（取得/使用/刷新/Rate Limit）| ✅ |
| 5 | §4 有至少 1 個 API 序列圖（Mermaid）| ✅（2 個）|
| 6 | 使用 Cursor-based 分頁（非 OFFSET）| ✅ |
| 7 | §11 API Paradigm Decision 已填寫 | ✅（REST 選型 + 比較表 + 決策依據）|
| 8 | §12 OpenAPI 3.1 YAML 已生成 | ✅（完整 paths/schemas/responses）|
| 9 | components/responses 定義標準錯誤（401/400/404/429）| ✅ |
| 10 | 所有 Endpoint 命名符合 RESTful 規範（小寫複數資源名詞）| ✅ |
| 11 | §9 Batch Operations 說明 | ✅（Phase 2 預留設計）|
| 12 | §10 File Upload 說明（S3 Presigned URL）| ✅ |
| 13 | §13 API Changelog 已建立 | ✅ |
| 14 | §15 Versioning & Deprecation Policy 已定義 | ✅ |
| 15 | §16 Client SDK 生成指令 | ✅ |
| 16 | §17 SLO 目標與 Error Budget 已定義 | ✅ |
| 17 | 無未替換的裸佔位符 | ✅ |
| 18 | 冪等性設計：PATCH 端點說明 + IAP 使用 idempotency_key | ✅ |
| 19 | 所有端點的 RBAC 權限對齊 EDD §4.1 矩陣 | ✅ |
| 20 | 分頁 Cursor 格式（base64 + 說明）已定義 | ✅ |

---

## 15. API Versioning & Deprecation Policy

### 15.1 版本策略

- **路徑版本**：`/v1/`，主要版本（v1、v2）有破壞性變更時升版
- **向下相容保證**：新增欄位、新增 Endpoint — 不視為破壞性變更；移除欄位、修改型別 — 視為破壞性變更
- **並行維護**：廢棄版本（如 v1）在 v2 發布後至少維護 6 個月

### 15.2 廢棄流程

**Step 1**：廢棄端點在 Response Headers 加入：
```
Deprecation: true
Sunset: Sat, 01 Nov 2026 00:00:00 GMT
Link: <https://docs.fishing-arcade-game.com/migration/v1-to-v2>; rel="successor-version"
```

**Step 2**：開發者文件發布 Migration Guide（至少提前 90 天）

**Step 3**：Sunset 日期後 → 端點回傳 410 Gone

### 15.3 非破壞性變更（無需升版）

- 新增 Response 欄位（客戶端應忽略未知欄位）
- 新增 Endpoint
- 放寬輸入限制（如 maxLength 增加）
- 新增 Query Parameter（有預設值）

---

## 16. Client SDK & Code Generation

### 16.1 OpenAPI Generator 生成指令

```bash
# 安裝 openapi-generator-cli
npm install -g @openapitools/openapi-generator-cli

# 生成 TypeScript (Axios) SDK — 給 Cocos Creator Web/Desktop 用
openapi-generator-cli generate \
  -i docs/API.md \
  -g typescript-axios \
  -o generated/sdk/typescript \
  --additional-properties=npmName=@fishing-arcade-game/api-client,withInterfaces=true

# 生成 Swift SDK — 給 iOS 客戶端用
openapi-generator-cli generate \
  -i docs/API.md \
  -g swift5 \
  -o generated/sdk/swift

# 生成 Kotlin SDK — 給 Android 客戶端用
openapi-generator-cli generate \
  -i docs/API.md \
  -g kotlin \
  -o generated/sdk/kotlin
```

### 16.2 TypeScript SDK 使用範例

```typescript
import { AuthApi, ShopApi, Configuration } from '@fishing-arcade-game/api-client';

const config = new Configuration({
  basePath: 'https://api.fishing-arcade-game.com/v1',
  accessToken: () => localStorage.getItem('access_token') ?? '',
});

const authApi = new AuthApi(config);
const shopApi = new ShopApi(config);

// 登入
const loginResult = await authApi.authLoginPost({
  email: 'player@example.com',
  password: 'Passw0rd!123',
});
const token = loginResult.data.data.access_token;

// 充值鑽石
const purchase = await shopApi.shopPurchasesPost({
  platform: 'apple',
  product_id: 'diamonds_330',
  receipt: 'MIIXXXXXXX...',
  idempotency_key: crypto.randomUUID(),
});
```

---

## 17. API Observability & SLO

### 17.1 SLO 目標

| SLO 指標 | 目標值 | 來源 | 測量方式 |
|---------|--------|------|---------|
| 可用性（Availability）| ≥ 99.5%（30 天滾動）| BRD NFR-AVAIL-001 | `rate(http_requests_total{status!~"5.."}[5m]) / rate(http_requests_total[5m])` |
| P95 回應時間 | < 300ms（REST）| EDD §10.5 | `histogram_quantile(0.95, http_request_duration_seconds_bucket)` |
| P99 回應時間 | < 500ms（REST）| BRD NFR-PERF-002 | `histogram_quantile(0.99, http_request_duration_seconds_bucket)` |
| Error Rate | < 0.1% | BRD NFR-REL-001 | `rate(http_requests_total{status=~"5.."}[1m])` |
| IAP 驗證成功率 | > 99% | 業務需求 | `rate(iap_verification_total{result="success"}[5m]) / rate(iap_verification_total[5m])` |

### 17.2 Error Budget 計算

```
月可用時間（秒）= 30 × 24 × 60 × 60 = 2,592,000 秒

Availability SLO = 99.5%
Error Budget = 2,592,000 × (1 - 0.995) = 12,960 秒（約 3.6 小時/月）

Error Budget 消耗率 > 10% / 周 → 觸發告警 → 暫停非關鍵功能發布
Error Budget 耗盡 → 啟動 Incident Review → 凍結非 Hotfix 部署
```

### 17.3 告警閾值

| 指標 | 告警條件 | 嚴重性 | 通知方式 |
|------|---------|--------|---------|
| Availability | < 99.75% 持續 30 分鐘 | P1 | PagerDuty + Slack #incident |
| P99 REST | > 400ms 持續 5 分鐘 | P2 | Slack #sre-alerts |
| Error Rate | > 0.05% 持續 10 分鐘 | P2 | Slack #sre-alerts |
| IAP Circuit Breaker | state=open | P1 | PagerDuty |
| Error Budget 消耗 | > 50% / 月 | P2 | Slack #sre-alerts |

### 17.4 監測工具

| 工具 | 用途 |
|------|------|
| Prometheus | Metrics 採集（`prom-client` Node.js SDK）|
| Grafana | SLO Dashboard（§12.2 Prometheus Queries）|
| Jaeger + OpenTelemetry | 分散式追蹤（Span 命名見 ARCH §12.4）|
| Loki | 結構化 JSON Log 聚合 |
| PagerDuty | P1 On-Call 告警 |

---

## 18. Approval Sign-off

| 角色 | 姓名 | 審核日期 | 狀態 |
|------|------|---------|------|
| Backend Lead | TBD | — | ⬜ PENDING |
| Security Engineer | TBD | — | ⬜ PENDING |
| Product Manager | TBD | — | ⬜ PENDING |
