# LOCAL_DEPLOY — Local Development Deployment Guide (Rancher Desktop + Kubernetes)

---

## Document Control

| Field | Value |
|-------|-------|
| **DOC-ID** | LOCAL_DEPLOY-FISHING-ARCADE-GAME-20260424 |
| **Project** | fishing-arcade-game（捕魚街機遊戲平台）|
| **Version** | v1.0 |
| **Status** | DRAFT |
| **Date** | 2026-04-24 |
| **Upstream EDD** | [EDD.md](EDD.md) |
| **Last Verified** | 2026-04-24 |

> **⚠️ DRAFT** — 本地 K8s namespace 使用 `fishing-arcade-local`（EDD §7.3 Local 欄填寫為 `default`，但 `default` namespace 已預先存在於所有 k3s cluster，建議使用專屬 namespace 以避免污染；待 Engineering Lead 確認後更新 EDD §7.3）

---

## 1. Prerequisites

Install and verify every tool before proceeding. The setup will not work without exact version minimums.

| Tool | Min Version | Install | Verify |
|------|------------|---------|--------|
| macOS | 13.0+ | — | `sw_vers -productVersion` |
| **Rancher Desktop** | 1.13 | [rancherdesktop.io](https://rancherdesktop.io) | `rdctl version` |
| kubectl | 1.29 | Bundled with Rancher Desktop | `kubectl version --client` |
| helm | 3.14 | Bundled with Rancher Desktop | `helm version` |
| nerdctl | 1.7 | Bundled with Rancher Desktop | `nerdctl version` |
| Node.js | 20 LTS | `brew install node@20` | `node --version` |
| npm | 10+ | Bundled with Node.js | `npm --version` |
| k9s（選配）| 0.32 | `brew install k9s` | `k9s version` |
| skaffold（選配）| 2.11 | `brew install skaffold` | `skaffold version` |
| mysql client | 8.0 | `brew install mysql-client && brew link mysql-client` | `mysql --version` |
| mkcert | 1.4 | `brew install mkcert` | `mkcert --version` |
| Git | 2.40 | `brew install git` | `git --version` |
| Make | 4.3 | `brew install make` | `make --version` |
| wscat（選配，WS 測試）| 5.2 | `npm install -g wscat` | `wscat --version` |
| curl | 8.0 | Pre-installed | `curl --version` |

> **Rancher Desktop 設定：** 啟動後進入 **Preferences > Virtual Machine > Resources**，至少配置 **8 GB RAM / 4 CPU**（game-service Colyseus 記憶體較大）。Container engine 選 **containerd**（nerdctl）。
> **kubectl context：** Rancher Desktop 啟動後會自動注入 `rancher-desktop` context。執行 `kubectl config use-context rancher-desktop` 確認。

---

## 2. Architecture Overview

本地環境完全在 Kubernetes 內執行，與 staging / production 採用相同 K8s 資源模型（Deployment、Service、ConfigMap、Secret、Ingress）。

此專案為三服務架構（非單體 API）：
- **account-service** — 帳號/認證/VIP（REST, :3001）
- **game-service** — Colyseus 多人遊戲室/RTP/Jackpot（WebSocket, :2567）
- **shop-service** — 商城/IAP/訂單（REST, :3002）

**所有服務均在 namespace `fishing-arcade-local` 內。**

```
┌────────────────────────────────────────────────────────────────────────┐
│  Rancher Desktop (k3s)  —  namespace: fishing-arcade-local             │
│                                                                        │
│  Ingress (traefik)  ← http://fishing-arcade.local（需設定 /etc/hosts）  │
│         │                                                              │
│  ┌──────┴──────────┐  ┌──────────────────┐  ┌─────────────────────┐   │
│  │ account-service │  │  game-service    │  │    shop-service     │   │
│  │  REST :3001     │  │  Colyseus :2567  │  │    REST :3002       │   │
│  │  JWT / VIP      │  │  WS 對戰/RTP/    │  │    IAP / 訂單       │   │
│  └──────────────── ┘  │  Jackpot         │  └─────────────────────┘   │
│                       └──────────────────┘                            │
│         │                    │                       │                │
│  ┌──────┴──────────────────── ┴───────────────────── ┘               │
│  ▼                                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐   │
│  │  mysql      │  │  redis      │  │  iap-stub                   │   │
│  │ (StatefulSet│  │ (StatefulSet│  │  (Apple/Google IAP mock)    │   │
│  │ :3306       │  │  :6379      │  │  :8099                      │   │
│  └─────────────┘  └─────────────┘  └─────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

```mermaid
graph TB
    Dev["Developer\n(localhost)"]
    GameClient["Cocos Creator Client\n(外部連線)"]
    Ingress["Ingress (traefik)\nfishing-arcade.local"]

    subgraph K8s["K8s Namespace: fishing-arcade-local"]
        AccountSvc["account-service\nDeployment\n:3001 (REST)"]
        GameSvc["game-service\nDeployment\n:2567 (Colyseus WS)"]
        ShopSvc["shop-service\nDeployment\n:3002 (REST)"]
        DB[("mysql\nStatefulSet\n:3306")]
        Cache[("redis\nStatefulSet\n:6379")]
        IAPStub["iap-stub\nDeployment\n:8099"]
    end

    Dev -->|Ingress / port-forward| Ingress
    GameClient -->|WSS ws://fishing-arcade.local/game| GameSvc
    Ingress -->|/v1/account| AccountSvc
    Ingress -->|/v1/shop| ShopSvc
    Ingress -->|/game ws| GameSvc
    Dev -->|kubectl port-forward| DB
    Dev -->|kubectl port-forward| Cache
    AccountSvc -->|ClusterIP| DB
    AccountSvc -->|ClusterIP| Cache
    GameSvc -->|ClusterIP| DB
    GameSvc -->|ClusterIP| Cache
    ShopSvc -->|ClusterIP| DB
    ShopSvc -->|ClusterIP| IAPStub
```

**K8s 資源對照：**

| 服務 | Kind | Image | ConfigMap | Secret |
|------|------|-------|-----------|--------|
| account-service | Deployment | `fishing-arcade-game/account:local` | `fishing-arcade-account-config` | `fishing-arcade-account-secret` |
| game-service | Deployment | `fishing-arcade-game/game:local` | `fishing-arcade-game-config` | `fishing-arcade-game-secret` |
| shop-service | Deployment | `fishing-arcade-game/shop:local` | `fishing-arcade-shop-config` | `fishing-arcade-shop-secret` |
| mysql | StatefulSet | `mysql:8.0` | — | `fishing-arcade-db-secret` |
| redis | StatefulSet | `redis:7-alpine` | — | — |
| iap-stub | Deployment | `fishing-arcade-game/iap-stub:local` | `fishing-arcade-iap-stub-config` | — |

> **K8s manifest 位置：** `k8s/overlays/local/`（Kustomize）

---

## 3. Quick Start（5 分鐘上手）

適合熟悉 K8s 的工程師。初次設定請使用 Section 4。

```bash
# 1. Clone 並進入專案
git clone git@github.com:tbd-org/fishing-arcade-game.git
cd fishing-arcade-game

# 2. 確認 kubectl context 為 Rancher Desktop
kubectl config use-context rancher-desktop

# 3. 建立 namespace 與基礎 Secret
make k8s-init

# 4. Build 並載入所有 image
make image-build-all

# 5. 部署所有 K8s 資源
make k8s-apply

# 6. 等待所有 Pod 就緒
kubectl wait --for=condition=Ready pods --all -n fishing-arcade-local --timeout=180s

# 7. 初始化資料庫（migration + seed）
make db-migrate
make db-seed

# 8. 驗證所有服務健康
make health-check
```

預期輸出：

```
[OK] account-service  http://fishing-arcade.local/v1/account/health
[OK] shop-service     http://fishing-arcade.local/v1/shop/health
[OK] game-service     ws://fishing-arcade.local/game  (Colyseus WebSocket)
[OK] mysql            pod/mysql-0 — Running
[OK] redis            pod/redis-0 — Running
[OK] iap-stub         pod/iap-stub — Running
```

如有任何 `[FAIL]`，請進入 Section 10（Common Issues）。

---

## 4. Step-by-Step Setup

### 4.1 Clone & Configure

```bash
# Clone repository
git clone git@github.com:tbd-org/fishing-arcade-game.git  # TODO: 替換為實際 GitHub Org
cd fishing-arcade-game

# 確認 branch
git status
# Expected: On branch main / develop
```

### 4.2 Rancher Desktop 設定

```bash
# 1. 確認 k3s context 已注入
kubectl config get-contexts
# 應看到 rancher-desktop 並標示 *（current）

# 若未自動設定：
kubectl config use-context rancher-desktop

# 2. 確認 K8s API server 可連線
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://127.0.0.1:6443

# 3. 建立本地 namespace
kubectl create namespace fishing-arcade-local --dry-run=client -o yaml | kubectl apply -f -

# 4. 設定 /etc/hosts（一次性）— 讓 Ingress domain 可解析
echo "127.0.0.1   fishing-arcade.local api.fishing-arcade.local" | sudo tee -a /etc/hosts
```

### 4.3 建立 K8s Secret

Secret 不走 configmap，不提交到 git。首次設定需手動建立：

```bash
# 複製 secret 範本
cp k8s/overlays/local/secrets.example.env k8s/overlays/local/secrets.env
# 編輯 secrets.env，填入本地開發用的假憑證（不要用真實 IAP Key）

# 建立 K8s Secret（從 secrets.env 讀取）
make k8s-init
# 等同執行：
# kubectl create secret generic fishing-arcade-account-secret \
#   --from-env-file=k8s/overlays/local/secrets.env \
#   -n fishing-arcade-local \
#   --dry-run=client -o yaml | kubectl apply -f -
```

> `k8s/overlays/local/secrets.env` 已加入 `.gitignore`。`secrets.example.env` 是變數名稱的唯一來源，新增變數時需同步更新。

### 4.4 Build & 載入 Image

Rancher Desktop 使用 containerd runtime，需用 nerdctl 建置並直接載入到 k3s 內部 registry。

```bash
# 一次 build 全部 image（account + game + shop + iap-stub）
make image-build-all

# 等同：
nerdctl build -t fishing-arcade-game/account:local -f docker/account/Dockerfile .
nerdctl build -t fishing-arcade-game/game:local    -f docker/game/Dockerfile    .
nerdctl build -t fishing-arcade-game/shop:local    -f docker/shop/Dockerfile    .
nerdctl build -t fishing-arcade-game/iap-stub:local -f docker/iap-stub/Dockerfile .

# 確認 image 存在
nerdctl images | grep fishing-arcade-game
```

> **imagePullPolicy：** 本地環境所有 Deployment 設定 `imagePullPolicy: Never`，確保使用本機 build 的 image，不從 registry 拉取。

### 4.5 部署所有 K8s 資源

```bash
# 使用 Kustomize 部署 local overlay
make k8s-apply
# 等同：
# kubectl apply -k k8s/overlays/local/

# 觀察 Pod 啟動狀態（Ctrl+C 結束）
kubectl get pods -n fishing-arcade-local -w

# 等待全部 Ready
kubectl wait --for=condition=Ready pods --all -n fishing-arcade-local --timeout=180s
```

預期 Pod 狀態（全部 `Running`）：

```
NAME                                READY   STATUS    RESTARTS   AGE
account-service-<hash>              1/1     Running   0          60s
game-service-<hash>                 1/1     Running   0          60s
shop-service-<hash>                 1/1     Running   0          60s
mysql-0                             1/1     Running   0          60s
redis-0                             1/1     Running   0          60s
iap-stub-<hash>                     1/1     Running   0          60s
```

如有 Pod 停在 `Pending` 或 `CrashLoopBackOff`，請見 Section 10。

### 4.6 初始化資料庫

```bash
# 執行所有 pending migration（三個服務共用同一 MySQL，但各有獨立 schema/table 前綴）
make db-migrate
# 等同（以 account-service 執行 Prisma migrate）：
# kubectl exec -n fishing-arcade-local deploy/account-service -- npx prisma migrate deploy

# 載入 seed / fixture 資料
make db-seed
# 等同：
# kubectl exec -n fishing-arcade-local deploy/account-service -- npx prisma db seed
```

預期 migration 輸出：

```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": MySQL 8.0 at "mysql:3306"

1 migration found in prisma/migrations

The following migration(s) have been applied:
20260424000001_init/        — Applied
20260424000002_add_vip/     — Applied

All migrations have been successfully applied.
```

### 4.7 驗證所有服務健康

```bash
make health-check
```

個別驗證：

```bash
# Account Service（透過 Ingress）
curl -s http://fishing-arcade.local/v1/account/health | jq .
# Expected: {"status":"ok","service":"account-service","mysql":"ok","redis":"ok"}

# Shop Service（透過 Ingress）
curl -s http://fishing-arcade.local/v1/shop/health | jq .
# Expected: {"status":"ok","service":"shop-service","mysql":"ok"}

# Game Service（Colyseus WebSocket — 使用 wscat 或 curl websocket upgrade）
curl -s -o /dev/null -w "%{http_code}" \
  -H "Upgrade: websocket" -H "Connection: Upgrade" \
  http://fishing-arcade.local/game
# Expected: 101（Switching Protocols）
# 或使用 wscat：
wscat -c ws://fishing-arcade.local/game
# Expected: Connected（Colyseus handshake）

# MySQL（port-forward 後）
kubectl port-forward -n fishing-arcade-local statefulset/mysql 3306:3306 &
# ⚠️  WARNING: 密碼 'secret' 僅為本機開發預設值，staging / production 環境禁止使用。
mysql -h 127.0.0.1 -P 3306 -u app -psecret fishing_arcade_local -e "SELECT 1;"
# Expected: 1

# Redis
kubectl port-forward -n fishing-arcade-local statefulset/redis 6379:6379 &
redis-cli ping
# Expected: PONG
```

---

## 5. Service Reference

### Ingress 存取（需設定 /etc/hosts）

| 服務 | URL | 說明 |
|------|-----|------|
| account-service | `http://fishing-arcade.local/v1/account` | REST API（登入/註冊/VIP）|
| shop-service | `http://fishing-arcade.local/v1/shop` | REST API（商城/IAP）|
| game-service | `ws://fishing-arcade.local/game` | Colyseus WebSocket（多人遊戲）|
| game-service HTTP | `http://fishing-arcade.local/game/health` | Colyseus HTTP health |
| iap-stub UI | `http://fishing-arcade.local/iap-stub` | IAP 驗證 Mock Web UI |

### kubectl port-forward 存取（直連 Pod）

| 服務 | 指令 | 本地 URL |
|------|------|---------|
| account-service | `kubectl port-forward -n fishing-arcade-local deploy/account-service 3001:3001` | `http://localhost:3001` |
| game-service (WS) | `kubectl port-forward -n fishing-arcade-local deploy/game-service 2567:2567` | `ws://localhost:2567` |
| shop-service | `kubectl port-forward -n fishing-arcade-local deploy/shop-service 3002:3002` | `http://localhost:3002` |
| mysql | `kubectl port-forward -n fishing-arcade-local statefulset/mysql 3306:3306` | `localhost:3306` |
| redis | `kubectl port-forward -n fishing-arcade-local statefulset/redis 6379:6379` | `localhost:6379` |
| iap-stub | `kubectl port-forward -n fishing-arcade-local deploy/iap-stub 8099:8099` | `http://localhost:8099` |

> **Make shortcuts：** `make pf-account`、`make pf-game`、`make pf-shop`、`make pf-db`、`make pf-redis` 會在背景啟動 port-forward 並記錄 PID。`make pf-stop` 停止全部。

---

## 6. Development Commands

所有 `make` 指令從 repo root 執行。

### Image & Deployment

| 指令 | 等同底層命令 | 使用時機 |
|------|------------|---------|
| `make image-build-account` | `nerdctl build -t fishing-arcade-game/account:local -f docker/account/Dockerfile .` | 修改 account-service 後 |
| `make image-build-game` | `nerdctl build -t fishing-arcade-game/game:local -f docker/game/Dockerfile .` | 修改 game-service 後 |
| `make image-build-shop` | `nerdctl build -t fishing-arcade-game/shop:local -f docker/shop/Dockerfile .` | 修改 shop-service 後 |
| `make image-build-all` | 依序執行以上三條 nerdctl build 命令 | 初次設定或全面更新 |
| `make k8s-apply` | `kubectl apply -k k8s/overlays/local/` | 變更 K8s manifest 後 |
| `make k8s-restart-account` | `kubectl rollout restart deploy/account-service -n fishing-arcade-local` | Build 新 image 後套用 |
| `make k8s-restart-game` | `kubectl rollout restart deploy/game-service -n fishing-arcade-local` | Build 新 image 後套用 |
| `make k8s-restart-shop` | `kubectl rollout restart deploy/shop-service -n fishing-arcade-local` | Build 新 image 後套用 |
| `make k8s-restart-all` | `kubectl rollout restart deployment --all -n fishing-arcade-local` | 更新 ConfigMap / Secret 後 |
| `make k8s-delete` | `kubectl delete -k k8s/overlays/local/` | 重新部署時（保留 PVC）|
| `make k8s-clean` | `kubectl delete namespace fishing-arcade-local` | 完全重置（銷毀所有資料）|

### 觀察 & 偵錯

| 指令 | 說明 |
|------|------|
| `make pods` | `kubectl get pods -n fishing-arcade-local` |
| `make logs-account` | `kubectl logs -f deploy/account-service -n fishing-arcade-local` |
| `make logs-game` | `kubectl logs -f deploy/game-service -n fishing-arcade-local` |
| `make logs-shop` | `kubectl logs -f deploy/shop-service -n fishing-arcade-local` |
| `make shell-account` | `kubectl exec -it deploy/account-service -n fishing-arcade-local -- sh` |
| `make shell-game` | `kubectl exec -it deploy/game-service -n fishing-arcade-local -- sh` |
| `make shell-db` | `kubectl exec -it -n fishing-arcade-local statefulset/mysql -- mysql -u app -psecret fishing_arcade_local` |
| `make health-check` | 依序驗證 account/shop/game health endpoint（見 §4.7）|
| `make k9s` | `k9s -n fishing-arcade-local`（需已安裝 k9s）|

### 測試

| 指令 | 說明 |
|------|------|
| `make test-unit` | 在本機執行 unit test（不需 K8s）— 等同 `npm test`（Jest + ts-jest）|
| `make test-integration` | Integration test（Testcontainers: MySQL + Redis）— 等同 `npm run test:integration` |
| `make test-e2e` | E2E BDD test — 等同 `npx cucumber-js --profile local` |
| `make lint` | Lint 全部原始碼 — 等同 `npm run lint`（ESLint）|
| `make test-ws` | WebSocket 連線測試 — 等同 `wscat -c ws://fishing-arcade.local/game` |

---

## 7. Database Operations

### 進入 MySQL Shell

> ⚠️ **安全注意：** 下方連線字串中的密碼 `secret` 僅為本機開發預設值，禁止複製至 staging / production 環境。正式環境請從 AWS Secrets Manager 取得憑證。

```bash
# 方法 1：透過 kubectl exec（不需 port-forward）
kubectl exec -it -n fishing-arcade-local statefulset/mysql -- \
  mysql -u app -psecret fishing_arcade_local

# 方法 2：port-forward 後用本地 mysql client
kubectl port-forward -n fishing-arcade-local statefulset/mysql 3306:3306 &
# ⚠️  WARNING: 密碼 'secret' 僅為本機開發預設值，staging / production 環境禁止使用。
mysql -h 127.0.0.1 -P 3306 -u app -psecret fishing_arcade_local

# Make shortcut
make shell-db
```

### 執行 Migration（Prisma）

```bash
# 執行所有 pending migration
make db-migrate
# 等同（在 account-service pod 中執行）：
# kubectl exec -n fishing-arcade-local deploy/account-service -- npx prisma migrate deploy

# 查看 migration 狀態
make db-status
# 等同：
# kubectl exec -n fishing-arcade-local deploy/account-service -- npx prisma migrate status

# Rollback 操作（Prisma 不支援自動 down migration）
# 請參考 §9.2 DB Migration Rollback 說明
# 步驟：(1) 標記 migration 為 rolled back（僅更新元數據）
#        (2) 手動執行 down DDL SQL（從 git diff 取得）
```

### Seed 測試資料

```bash
# 載入所有 seed（idempotent，可重複執行）
make db-seed
# 等同：
# kubectl exec -n fishing-arcade-local deploy/account-service -- npx prisma db seed

# 重置為乾淨狀態（Drop + recreate + migrate + seed）
make db-reset
# Warning: 本機 MySQL PVC 資料全部清除
```

---

## 8. Test Data & Fixtures

`make db-seed` 後以下帳號與資料固定可用。

### Default User Accounts

| Role | Email | Password | 說明 |
|------|-------|----------|------|
| Admin | `admin@fishing-arcade.local` | `Password1!` | 全權限，可修改 RTP 參數 |
| VIP Player | `vip@fishing-arcade.local` | `Password1!` | vip_tier=1，月費已訂閱 |
| Regular Player | `player@fishing-arcade.local` | `Password1!` | 標準玩家角色 |
| Demo Player（未驗證年齡）| `demo@fishing-arcade.local` | `Password1!` | age_status=UNVERIFIED |

### Sample Data

| Entity | Count | 說明 |
|--------|-------|------|
| Players | 10 | 涵蓋所有角色，密碼同上 |
| Weapons | 4 | 散彈炮(10)、雷射炮(30)、導彈炮(50)、等離子炮(100) |
| Game Configs | 1 | base_rtp=0.95, jackpot_probability=0.001, jackpot_seed=10000 |
| VIP Plans | 1 | 30 鑽石/月 |
| Orders | 5 | 含 COMPLETED/PENDING/FAILED 狀態 |

### Redis 初始狀態（`make db-seed` 後）

```bash
# 驗證 Jackpot 獎池初始化
kubectl exec -n fishing-arcade-local deploy/game-service -- \
  redis-cli -h redis --scan --pattern "jackpot*"
# Expected: jackpot_pool（值為 10000）
```

---

## 9. ConfigMap & Secret Reference

### ConfigMap — `fishing-arcade-account-config`

| Key | Default | 說明 |
|-----|---------|------|
| `NODE_ENV` | `development` | Runtime 環境 |
| `PORT` | `3001` | Account Service 監聽 port |
| `DATABASE_URL` | `mysql://app:secret@mysql:3306/fishing_arcade_local` | MySQL 連線字串（K8s service DNS）|
| `REDIS_URL` | `redis://redis:6379/0` | Redis 連線字串（K8s service DNS）|
| `LOG_LEVEL` | `debug` | `debug` / `info` / `warn` / `error` |
| `CORS_ORIGINS` | `http://fishing-arcade.local` | 允許的 CORS origins |
| `JWT_ACCESS_EXPIRES` | `15m` | Access Token 有效期 |
| `JWT_REFRESH_EXPIRES` | `7d` | Refresh Token 有效期 |
| `LOGIN_LOCKOUT_ATTEMPTS` | `5` | 連續失敗鎖定次數 |
| `LOGIN_LOCKOUT_DURATION` | `900` | 鎖定時間（秒）|

### ConfigMap — `fishing-arcade-game-config`

| Key | Default | 說明 |
|-----|---------|------|
| `PORT` | `2567` | Colyseus 監聽 port |
| `DATABASE_URL` | `mysql://app:secret@mysql:3306/fishing_arcade_local` | MySQL 連線字串 |
| `REDIS_URL` | `redis://redis:6379/0` | Redis 連線字串 |
| `COLYSEUS_MONITOR_ENABLED` | `true` | 啟用 Colyseus 監控面板（:2567/colyseus）|
| `RTP_BASE` | `0.95` | RTP 基礎回報率 |
| `JACKPOT_PROBABILITY` | `0.001` | Jackpot 觸發概率 |
| `JACKPOT_SEED_AMOUNT` | `10000` | 獎池初始金額 |
| `FEATURE_JACKPOT_ENABLED` | `true` | Jackpot feature flag |
| `MAX_ROOMS` | `200` | 最大房間數（本地用 10 即可）|
| `FISH_SPAWN_INTERVAL_MS` | `3000` | 魚群刷新間隔 |

### ConfigMap — `fishing-arcade-shop-config`

| Key | Default | 說明 |
|-----|---------|------|
| `PORT` | `3002` | Shop Service 監聽 port |
| `DATABASE_URL` | `mysql://app:secret@mysql:3306/fishing_arcade_local` | MySQL 連線字串 |
| `REDIS_URL` | `redis://redis:6379/0` | Redis 連線字串 |
| `IAP_APPLE_URL` | `http://iap-stub:8099/apple/verifyReceipt` | Apple IAP 驗證 URL（本地使用 stub）|
| `IAP_GOOGLE_URL` | `http://iap-stub:8099/google/purchases` | Google IAP 驗證 URL（本地使用 stub）|
| `CIRCUIT_BREAKER_THRESHOLD` | `5` | Circuit Breaker 失敗閾值 |
| `CIRCUIT_BREAKER_TIMEOUT` | `60000` | Circuit Breaker 逾時（ms）|

### Secret — `fishing-arcade-account-secret`（從 `k8s/overlays/local/secrets.env` 建立）

| Key | 說明 | 設定方式 |
|-----|------|---------|
| `JWT_PRIVATE_KEY` | RS256 JWT 簽章私鑰（PEM）| `secrets.env`（使用 dev 測試 key，非 production key）|
| `JWT_PUBLIC_KEY` | RS256 JWT 驗證公鑰（PEM）| `secrets.env` |

### Secret — `fishing-arcade-db-secret`

| Key | 說明 |
|-----|------|
| `MYSQL_ROOT_PASSWORD` | MySQL root 密碼（僅本機 dev 用）|
| `MYSQL_PASSWORD` | 應用帳號 app 密碼（預設 `secret`，僅本機用）|

### 查看目前 ConfigMap / Secret

```bash
# 查看 game-service ConfigMap
kubectl get configmap fishing-arcade-game-config -n fishing-arcade-local -o yaml

# 查看 Secret key 清單（值會 base64 遮罩）
kubectl get secret fishing-arcade-account-secret -n fishing-arcade-local -o yaml

# 解碼特定 secret 值
kubectl get secret fishing-arcade-account-secret -n fishing-arcade-local \
  -o jsonpath='{.data.JWT_PRIVATE_KEY}' | base64 -d
```

---

## 10. Common Issues & Fixes

| Issue | Symptom | Root Cause | Fix |
|-------|---------|------------|-----|
| Pod stuck in `Pending` | `kubectl get pods` 顯示 Pending | 資源不足或 namespace 未建立 | `kubectl describe pod <name> -n fishing-arcade-local` 查看 Events；Rancher Desktop RAM 加至 8 GB |
| Pod in `CrashLoopBackOff` | Pod 反覆重啟 | 應用程式啟動失敗（設定錯誤、DB 未就緒）| `kubectl logs <pod> -n fishing-arcade-local --previous` 查看上次崩潰日誌 |
| `ImagePullBackOff` | Pod 無法找到 image | image 未 build 或 tag 錯誤 | `nerdctl images \| grep fishing-arcade-game`；重新執行 `make image-build-all` |
| Ingress 無法解析 | `curl: Could not resolve host` | /etc/hosts 未設定 | 確認 `/etc/hosts` 有 `127.0.0.1 fishing-arcade.local` |
| DB 連線拒絕 | account-service log: `ECONNREFUSED mysql` | MySQL pod 未就緒 | `kubectl wait --for=condition=Ready pod/mysql-0 -n fishing-arcade-local --timeout=60s` |
| Colyseus WS 拒絕連線 | `wscat: Connection refused` | game-service 未就緒或 JWT 無效 | 確認 game-service pod Running；WebSocket 連線需攜帶有效 JWT（`?token=<JWT>`）|
| Migration 失敗 | `Table already exists` | Migration 被部分執行過 | `kubectl exec ... -- npx prisma migrate status`；若有 Failed migration，參考 RUNBOOK.md §9.2 |
| Secret 找不到 | Pod 事件：`secret not found` | `make k8s-init` 未執行 | 重新執行 `make k8s-init`；確認 `secrets.env` 已填寫 |
| Prisma Migrate 失敗：`relation already exists` | — | 首次 migration 後重複執行 | Prisma migrate 是冪等的，此訊息為 WARNING 非 ERROR；確認最終輸出無 `Error` |
| Redis 連線失敗 | game-service log: `Redis connection refused` | Redis pod 未就緒 | `kubectl wait --for=condition=Ready pod/redis-0 -n fishing-arcade-local --timeout=60s` |
| IAP 驗證失敗 | shop-service log: `IAP stub connection refused` | iap-stub pod 未就緒 | `kubectl get pod -l app=iap-stub -n fishing-arcade-local`；重新執行 `make k8s-apply` |
| game-service Memory Limit | game-service Pod OOMKilled | Colyseus 本地房間數過多 | `make shell-game` 後確認活躍房間數；或在 ConfigMap 降低 `MAX_ROOMS` |

---

## 11. Logs & Debugging

### 查看 Pod 日誌

```bash
# 即時 tail 指定服務
kubectl logs -f deploy/account-service -n fishing-arcade-local
kubectl logs -f deploy/game-service -n fishing-arcade-local
kubectl logs -f deploy/shop-service -n fishing-arcade-local
kubectl logs -f statefulset/mysql -n fishing-arcade-local

# Make shortcuts
make logs-account
make logs-game
make logs-shop

# 查看上次 crash 日誌
kubectl logs deploy/game-service -n fishing-arcade-local --previous

# Colyseus 監控面板（port-forward 後存取）
kubectl port-forward -n fishing-arcade-local deploy/game-service 2567:2567 &
open http://localhost:2567/colyseus
# Colyseus Monitor：查看 active rooms、connected clients、room state
```

### 進入 Pod Shell

```bash
# game-service shell（查看 Colyseus 狀態、RTP 設定）
kubectl exec -it deploy/game-service -n fishing-arcade-local -- sh
make shell-game

# 查看環境變數（含 ConfigMap + Secret 注入的值）
kubectl exec deploy/game-service -n fishing-arcade-local -- env | sort

# 在 game-service pod 內 ping redis
kubectl exec deploy/game-service -n fishing-arcade-local -- \
  redis-cli -h redis ping
# Expected: PONG

# 在 game-service pod 內查詢 Jackpot 池狀態（使用 SCAN 非 KEYS）
kubectl exec deploy/game-service -n fishing-arcade-local -- \
  redis-cli -h redis --scan --pattern "jackpot*"
# Expected: jackpot_pool
```

### 常見 Log 模式

| Pattern | 含義 | 處理 |
|---------|------|------|
| `[ERROR] MySQL connection failed` | MySQL pod 未就緒 | 確認 mysql-0 Running；確認 K8s service 名稱為 `mysql` |
| `[WARN] Redis connection lost, retrying` | Redis 暫時不可用 | 通常自動恢復；`kubectl get pod redis-0 -n fishing-arcade-local` |
| `[Colyseus] Room fishingRoom created` | 房間正常創建 | 正常，無需處理 |
| `[ERROR] JWT verification failed` | WebSocket 連線帶無效 JWT | 確認 Cocos 客戶端傳入的 JWT 未過期 |
| `[ERROR] RTP calculation error` | RTP 引擎異常 | 確認 REDIS_URL 設定正確；`make logs-game` 查看完整 stacktrace |
| `[WARN] Circuit breaker OPEN: apple_iap` | IAP stub 連線問題 | `kubectl get pod -l app=iap-stub -n fishing-arcade-local` |

---

## 12. Port Reference

### Ingress（需 /etc/hosts 設定）

| Path | 服務 | 說明 |
|------|------|------|
| `http://fishing-arcade.local/v1/account` | account-service | 帳號/認證 REST API（含 `/v1/account/health`）|
| `http://fishing-arcade.local/v1/shop` | shop-service | 商城 REST API（含 `/v1/shop/health`）|
| `ws://fishing-arcade.local/game` | game-service | Colyseus WebSocket（多人對戰）|
| `http://fishing-arcade.local/game/health` | game-service | Colyseus HTTP health check |
| `http://fishing-arcade.local/iap-stub` | iap-stub | IAP 驗證 Mock UI |

### port-forward（直連 ClusterIP Service）

| 服務 | 指令 | 本地 Port |
|------|------|---------|
| account-service | `make pf-account` | `3001` |
| game-service (Colyseus WS) | `make pf-game` | `2567` |
| shop-service | `make pf-shop` | `3002` |
| mysql | `make pf-db` | `3306` |
| redis | `make pf-redis` | `6379` |
| iap-stub | `kubectl port-forward -n fishing-arcade-local deploy/iap-stub 8099:8099` | `8099` |

> 全部 port-forward：`make pf-all`。停止：`make pf-stop`。

---

## 13. Local HTTPS 設定

Colyseus WebSocket 連線（wss://）和某些 OAuth 流程需要 HTTPS。

```bash
# 1. 建立本地 CA（只需執行一次）
mkcert -install

# 2. 為本地 domain 生成憑證
mkcert "fishing-arcade.local" "*.fishing-arcade.local"
# 生成 fishing-arcade.local+1.pem 和 fishing-arcade.local+1-key.pem

# 3. 建立 K8s TLS Secret
kubectl create secret tls fishing-arcade-local-tls \
  --cert=fishing-arcade.local+1.pem \
  --key=fishing-arcade.local+1-key.pem \
  -n fishing-arcade-local \
  --dry-run=client -o yaml | kubectl apply -f -

# 4. 啟用 HTTPS Ingress
# 編輯 k8s/overlays/local/kustomization.yaml，啟用 tls-ingress patch：
# patches:
#   - path: patches/ingress-tls.yaml   # 取消此行註解

kubectl apply -k k8s/overlays/local/
```

> ⚠️ 憑證私鑰檔案（`*.pem`）已加入 `.gitignore`，禁止提交。

Cocos Creator 客戶端本地連線設定：

```
wss://fishing-arcade.local/game
```

---

## 14. Mock Services & External Integration Stubs

第三方服務在本地開發時使用 Mock，避免消耗真實 IAP 配額。所有 mock service 已包含在 K8s local overlay 內。

| 服務 | 本地替代方案 | K8s Service DNS | 說明 |
|------|-----------|----------------|------|
| Apple IAP 驗證 | iap-stub（Apple 端）| `iap-stub:8099/apple/verifyReceipt` | 回傳預設 VALID receipt 或可設定 INVALID 測試 error path |
| Google IAP 驗證 | iap-stub（Google 端）| `iap-stub:8099/google/purchases` | 回傳預設 VALID 或 INVALID |
| Mixpanel / Analytics | Log mock | — | 輸出 analytics events 至 game-service stdout（禁止真實埋點）|
| Apple Push Notification | Log mock | — | 輸出 push payload 至 account-service stdout |

### IAP Stub 操作

```bash
# 設定下一次 IAP 驗證回傳 VALID（預設）
curl -X POST http://fishing-arcade.local/iap-stub/config \
  -H "Content-Type: application/json" \
  -d '{"apple_response": "VALID", "google_response": "VALID"}'

# 設定下一次 IAP 驗證回傳 INVALID（測試 error path）
curl -X POST http://fishing-arcade.local/iap-stub/config \
  -H "Content-Type: application/json" \
  -d '{"apple_response": "INVALID", "google_response": "INVALID"}'

# 查看 IAP stub 收到的所有 receipt 請求
curl http://fishing-arcade.local/iap-stub/requests | jq .
```

---

## 15. Inner Loop — 快速迭代開發

每次修改程式碼後不需要重建整個環境。

### 後端服務（account-service / shop-service）

```bash
# 方法 1：重 build + rolling restart（約 30-60 秒）
make image-build-account && make k8s-restart-account
make image-build-shop && make k8s-restart-shop

# 方法 2：使用 skaffold（自動偵測檔案變更，約 10-20 秒）
skaffold dev --profile local
```

### Game Service（Colyseus）⚠️ 特別注意

```bash
# 重啟 game-service 會強制斷開所有 WebSocket 連線！
# 確認無活躍測試房間再執行

# 查詢活躍房間數
kubectl exec -n fishing-arcade-local deploy/game-service -- \
  wget -qO- http://localhost:2567/colyseus | grep -o '"rooms":[0-9]*' || echo "查看 Colyseus Monitor"

# 確認無活躍房間後再 restart
make image-build-game && make k8s-restart-game
```

### 前端/遊戲客戶端（Cocos Creator）

Cocos Creator 客戶端不在 K8s 內執行，直接在本機開發：

```bash
# 在 Cocos Creator 設定 server URL：
#   Account API:  http://fishing-arcade.local/v1/account
#   Shop API:     http://fishing-arcade.local/v1/shop
#   Game Server:  ws://fishing-arcade.local/game
# （或使用 port-forward：ws://localhost:2567）
```

> 純後端服務：**無前端 K8s inner loop**。遊戲客戶端（Cocos Creator）獨立開發，連線至本地 K8s 中的後端服務。

### 使用 skaffold（完整 inner loop）

`skaffold.yaml` 已設定在 repo root，`local` profile 對應 `k8s/overlays/local/`：

```bash
# 啟動 skaffold watch 模式（Ctrl+C 停止）
skaffold dev --profile local

# 一次性 build + deploy（不 watch）
skaffold run --profile local

# 清除 skaffold 部署的資源
skaffold delete --profile local
```

---

## 16. Cleanup

### 停止 port-forward

```bash
make pf-stop
```

### 刪除所有 K8s 資源（保留 PVC 資料）

```bash
make k8s-delete
# 等同：
kubectl delete -k k8s/overlays/local/
```

### 完全重置（刪除所有資源 + 資料）

```bash
make k8s-clean
# 等同：
kubectl delete namespace fishing-arcade-local
# Warning: 所有 PVC（MySQL 資料、Redis 資料）永久刪除
```

### 重建本地環境

```bash
make k8s-clean && make k8s-init && make image-build-all && make k8s-apply && \
  kubectl wait --for=condition=Ready pods --all -n fishing-arcade-local --timeout=180s && \
  make db-migrate && make db-seed
```

### 確認清除乾淨

```bash
kubectl get namespace fishing-arcade-local
# Expected: Error from server (NotFound)

nerdctl images | grep fishing-arcade-game
# 若需清除 local image：
nerdctl rmi \
  fishing-arcade-game/account:local \
  fishing-arcade-game/game:local \
  fishing-arcade-game/shop:local \
  fishing-arcade-game/iap-stub:local
```
