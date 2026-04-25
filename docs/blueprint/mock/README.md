# FishGame Mock API 伺服器

供前端開發與整合測試使用的假資料 FastAPI 伺服器。

## 環境需求

- Python 3.10+

## 安裝

```bash
cd docs/blueprint/mock
pip install -r requirements.txt
```

## 啟動

```bash
uvicorn main:app --reload --port 8000
```

伺服器啟動後：

- API 文件（Swagger UI）：<http://localhost:8000/docs>
- ReDoc 文件：<http://localhost:8000/redoc>
- 健康狀態：<http://localhost:8000/health>

## 查詢參數

所有端點支援以下共用查詢參數：

| 參數 | 型別 | 預設值 | 說明 |
|------|------|--------|------|
| `delay` | int (毫秒) | 0 | 回應前等待指定毫秒，模擬網路延遲 |
| `error` | 0 或 1 | 0 | 設為 1 時回傳 HTTP 422，測試錯誤處理 |

### 範例

```bash
# 模擬 500ms 延遲
curl "http://localhost:8000/v1/game/rooms?delay=500" \
  -H "Authorization: Bearer mock_token"

# 模擬 422 錯誤
curl "http://localhost:8000/v1/game/rooms?error=1" \
  -H "Authorization: Bearer mock_token"
```

## 認證

除 `/v1/auth/register` 與 `/v1/auth/login` 外，所有端點需要：

```
Authorization: Bearer <任意字串>
```

Mock 伺服器只檢查 Header 是否存在，**不驗證 token 內容**。

取得 token 的方式：

```bash
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

回應範例：

```json
{
  "access_token": "mock_access_...",
  "refresh_token": "mock_refresh_...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

## API 端點總覽

### Auth

| 方法 | 路徑 | 說明 |
|------|------|------|
| POST | `/v1/auth/register` | 註冊新帳號 |
| POST | `/v1/auth/login` | 登入，取得 token |
| POST | `/v1/auth/refresh` | 刷新 access token |
| DELETE | `/v1/auth/logout` | 登出 |

### Game

| 方法 | 路徑 | 說明 |
|------|------|------|
| GET | `/v1/game/rooms` | 取得房間列表（支援 `?status=` 過濾） |
| POST | `/v1/game/rooms` | 建立新房間 |
| GET | `/v1/game/rooms/{room_id}` | 取得單一房間詳情 |
| GET | `/v1/game/leaderboard` | 取得排行榜（支援 `?limit=`） |
| GET | `/v1/game/history` | 取得遊戲歷史（支援 `?limit=&offset=`） |

### Shop

| 方法 | 路徑 | 說明 |
|------|------|------|
| GET | `/v1/shop/products` | 取得商品列表 |
| POST | `/v1/shop/purchase` | 建立購買訂單 |
| GET | `/v1/shop/orders` | 取得訂單記錄 |

### Admin

| 方法 | 路徑 | 說明 |
|------|------|------|
| GET | `/v1/admin/stats` | 取得 KPI 統計 |
| PATCH | `/v1/admin/game-config` | 更新遊戲參數配置（session 內生效） |
| GET | `/v1/admin/users` | 取得用戶列表（支援 `?status=&role=` 過濾） |

### WebSocket

| 路徑 | 說明 |
|------|------|
| `/ws/game/{room_id}` | 連線後每 2 秒接收假魚群事件；傳送任何訊息會被 echo 回來 |

WebSocket 測試範例（使用 `wscat`）：

```bash
wscat -c ws://localhost:8000/ws/game/room_01HX7ROOM1
```

收到的事件格式：

```json
{
  "type": "spawn",
  "room_id": "room_01HX7ROOM1",
  "fish": "鯊魚",
  "x": 1024.5,
  "y": 768.3,
  "reward": 350,
  "timestamp": "2026-04-25T10:00:00+00:00"
}
```

## 假資料來源

所有假資料儲存於 `data/` 目錄下的 JSON 檔案，伺服器每次請求都從磁碟讀取（PATCH game-config 除外，session 內 in-memory 緩存）：

| 檔案 | 對應端點 |
|------|---------|
| `game_rooms.json` | GET /v1/game/rooms |
| `leaderboard.json` | GET /v1/game/leaderboard |
| `game_history.json` | GET /v1/game/history |
| `shop_products.json` | GET /v1/shop/products |
| `orders.json` | GET /v1/shop/orders |
| `kpi_stats.json` | GET /v1/admin/stats |
| `game_config.json` | GET/PATCH /v1/admin/game-config |
| `users.json` | GET /v1/admin/users |
