# TODO — fishing-arcade-game 問題清單與解決方案

**建立日期**：2026-04-29  
**依據**：ALIGN_REPORT.md 深度分析 + 各文件交叉比對  
**維護原則**：完成一項立即標記 `[x]`，不要批次更新

---

## 優先級說明

| 標記 | 意義 |
|------|------|
| 🔴 P0 | 阻擋其他所有工作，今天就要解決 |
| 🟠 P1 | 實作啟動前必須完成 |
| 🟡 P2 | Sprint 1 內完成，財務/品質風險 |
| 🟢 P3 | 重要但可排入 Backlog |

---

## A. 設計衝突（實作前必解）

### A-1：`age_status` 型別定義衝突 🔴 P0

**問題**  
EDD §5.5 定義 `age_status ENUM('UNVERIFIED','DEMO_ONLY','VERIFIED')`，但 SCHEMA §3.1 原始定義為 `age_verified TINYINT(1)`（二值，無法表達 `DEMO_ONLY` 中間態）。ALIGN_REPORT 標記為 FIXED（選 Option A），但以下兩處尚未確認落地：
- SCHEMA.md 文字是否已更新為 ENUM 定義
- README.md Known Issue #4 仍顯示為 open HIGH

**影響鏈**  
`users.age_status` → 年齡驗證狀態機 → BDD Scenarios → API 回應格式 → RBAC 授權判斷

**解決方案**
- [ ] 確認 `docs/SCHEMA.md §3.1` 中 `users` 表已將 `age_verified TINYINT(1)` 改為 `age_status ENUM('UNVERIFIED','DEMO_ONLY','VERIFIED') NOT NULL DEFAULT 'UNVERIFIED'`
- [ ] 確認 `docs/API.md` 所有回應中 `age_verified: boolean` 的說明已備註「API 回應層以 `age_verified=true` 映射 VERIFIED 狀態，DB 欄位為 ENUM」
- [ ] 更新 `README.md Known Issues #4`：在該行加上 `~~` 刪除線並標記 `[FIXED]`
- [ ] 實作 Prisma migration 時使用原生 SQL（Prisma 不支援 ENUM 直接宣告在某些 MySQL 版本）：
  ```sql
  ALTER TABLE users
    DROP COLUMN age_verified,
    ADD COLUMN age_status ENUM('UNVERIFIED','DEMO_ONLY','VERIFIED')
      NOT NULL DEFAULT 'UNVERIFIED';
  ```
- [ ] 在 Prisma schema 中以 `@db.Enum` 對應，並加 `@default(UNVERIFIED)`

---

### A-2：VIP 付費渠道合規決策 🔴 P0

**問題**  
PRD US-VIP-001/AC-1 原定為 Apple/Google IAP（USD 9.99/月），但 API.md 與 EDD 實作為鑽石扣款（30 鑽/月）。ALIGN_REPORT 將 PRD 改為鑽石扣款並將 IAP 降為 P2，但此決策有合規風險：
- Apple App Store Review Guidelines §3.1.1：App 內訂閱類功能通常必須走 In-App Purchase
- Google Play Billing Policy：類似限制，繞過 Store 的訂閱可能導致下架
- 鑽石扣款模式讓平台少付 Apple/Google 的 30% 抽成，但一旦被要求補交或下架，損失更大

**解決方案**
- [ ] **法務審查（最優先）**：在任何實作之前，確認以下問題：鑽石訂閱是否屬於「虛擬商品一次性購買」（允許繞過 IAP）或「訂閱服務」（必須走 Store Billing）
- [ ] 若法務確認鑽石扣款合規：更新 `README.md Known Issues #5` 為 `[FIXED]`，並在 `docs/BRD.md` 補充 ADR（架構決策記錄）說明選擇依據
- [ ] 若法務確認必須走 IAP：將 EDD/API/SCHEMA 回滾：
  - `SCHEMA vip_subscriptions` 補加 `iap_receipt_hash VARCHAR(255)`
  - `API.md POST /v1/vip/subscriptions` 改為接受 `receipt` 欄位
  - `EDD` 補充 IAP Circuit Breaker 降級策略（與 IAP 充值共用邏輯）
- [ ] 無論哪種結果，建立 `docs/ADR-001-vip-payment-channel.md` 記錄決策

---

### A-3：README.md Known Issues 狀態過時 🔴 P0

**問題**  
`README.md Known Issues` 第 3、4、5 條均已在 ALIGN_REPORT 中標記 FIXED，但 README 未同步更新。新工程師讀 README 看到三個「HIGH 問題待解」，調查後才發現已修復，造成 onboarding 浪費。

**解決方案**
- [ ] 更新 `README.md Known Issues #3`（BDD 錯誤碼）：加 `~~刪除線~~` + `[FIXED]` 標記，說明已對齊 EDD §5.3
- [ ] 更新 `README.md Known Issues #4`（age_status）：待 A-1 確認落地後標記 `[FIXED]`
- [ ] 更新 `README.md Known Issues #5`（VIP 付費渠道）：待 A-2 法務決策後更新狀態
- [ ] 建立規則：每次 ALIGN_REPORT 標記 FIXED 的項目，必須同步更新 README Known Issues（可加入 PR Checklist）

---

## B. 實作啟動工作

### B-1：建立 `src/` 架構骨架 🟠 P1

**問題**  
`src/` 目錄完全不存在。EDD §3.1 定義四層架構（Presentation / Application / Domain / Infrastructure），ARCH §2.2 定義四個 Bounded Context（Account / Game / Commerce / Admin）。

**解決方案**
- [ ] 初始化 `package.json`（Node.js 20 LTS + TypeScript 5.4）：
  ```bash
  npm init -y
  npm install express@4 colyseus@0.15 @prisma/client prisma jsonwebtoken bcrypt ioredis nats
  npm install -D typescript @types/node @types/express ts-node nodemon jest ts-jest
  ```
- [ ] 建立目錄骨架（依 EDD §3.1 × ARCH §2.2）：
  ```
  src/
  ├── account/
  │   ├── presentation/   # Express routes
  │   ├── application/    # Use cases
  │   ├── domain/         # Entities, Value Objects
  │   └── infrastructure/ # Prisma repos, Redis
  ├── game/               # 同結構，Colyseus Room
  ├── commerce/           # 同結構，IAP
  ├── admin/              # 同結構
  └── shared/
      ├── config/env.ts   # Fail-fast env 驗證
      ├── infrastructure/
      │   ├── database.ts # Prisma singleton + softDeleteMiddleware
      │   ├── redis.ts    # Redis client
      │   └── eventBus.ts # Redis Pub/Sub Domain Event Bus
      └── types/
  ```
- [ ] 建立 `.env.example`（含所有必要環境變數：`DATABASE_URL`、`REDIS_URL`、`JWT_SECRET`、`JWT_PRIVATE_KEY`、`APPLE_IAP_SECRET`、`GOOGLE_IAP_SERVICE_ACCOUNT`）
- [ ] 實作 `src/shared/config/env.ts` Fail-fast 啟動驗證（EDD §1.2 原則 3）

**實作優先順序**（由財務風險決定）：
1. Account Service（auth / JWT）
2. RTP Engine + Jackpot（財務核心）
3. Shop Service（IAP + 鑽石）
4. Game Service（Colyseus Room）
5. Admin endpoints

---

### B-2：建立 `prisma/schema.prisma` 🟠 P1

**問題**  
SCHEMA.md 定義 11 張資料表，但 `prisma/schema.prisma` 不存在。

**解決方案**
- [ ] 依 SCHEMA.md §3 逐一建立 11 個 Prisma model（`users`、`game_sessions`、`session_players`、`fish_kills`、`jackpot_events`、`orders`、`vip_subscriptions`、`game_configs`、`audit_logs`、`products`、`data_access_logs`）
- [ ] `users.age_status` 使用 ENUM（依 A-1 決策）
- [ ] `fish_kills` 月 RANGE 分區：Prisma 不支援此 DDL，需在 `prisma/migrations/manual/` 建立手動 SQL 檔案，於 `postmigrate` hook 執行：
  ```sql
  ALTER TABLE fish_kills
    PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
      PARTITION p202601 VALUES LESS THAN (202602),
      PARTITION p202602 VALUES LESS THAN (202603),
      ...
    );
  ```
- [ ] 建立 `prisma/seed.ts`：插入 `game_configs` 初始值（`base_rtp=0.95`、`jackpot_probability=0.001`、`jackpot_min_pool=10000`）
- [ ] 實作 `softDeleteMiddleware`：所有查詢自動注入 `WHERE deleted_at IS NULL`
- [ ] 執行 `prisma migrate dev --name init` 驗證 DDL 正確

---

### B-3：建立 `tests/` 框架 🟠 P1

**問題**  
`tests/` 目錄不存在，目標覆蓋率 Unit ≥ 85%、Integration ≥ 70%，現在 0%。

**解決方案**
- [ ] 建立 `jest.config.ts`（覆蓋率門檻 80%，unit/integration/e2e 三個 project）
- [ ] 安裝 Testcontainers：`npm install -D testcontainers`（MySQL + Redis in Docker for integration tests）
- [ ] 建立 `tests/unit/`、`tests/integration/`、`tests/e2e/`、`tests/features/step-definitions/`
- [ ] **最先實作（財務風險最高）**：
  - `tests/unit/rtp-engine.test.ts`（100 萬局 Monte Carlo，驗證 RTP 分布）
  - `tests/unit/jackpot.test.ts`（Redis Lua Script 原子觸發，100 並發模擬）
- [ ] 配置 `cucumber.js`：指向 `features/` + `tests/features/step-definitions/`

---

## C. 財務風險優先測試

### C-1：Jackpot Redis 原子性並發測試（TC-INT-FISH-006-B） 🟠 P1

**問題**  
`fishing_gameplay.feature` 原本在「遊戲未開始時發射被忽略」場景錯誤貼上 `@TC-INT-FISH-006-B` 標籤（定義為「6 玩家同時命中同一魚 → Redis SETNX 唯一計算」）。此錯誤已修復，但對應的 unit test 尚未實作。這是財務風險最高的場景：若 SETNX 原子鎖失效，多名玩家各得全額 Jackpot。

**解決方案**
- [ ] 實作 `tests/unit/fish-kill-lock.test.ts`：
  - 使用真實 Redis（Testcontainers），模擬 6 個並發請求同時命中同一條魚
  - 驗證只有 1 個請求成功（SETNX 返回 1），其他 5 個被拒絕（返回 0）
  - 驗證金幣只計算一次（無重複發放）
- [ ] 實作 `tests/unit/jackpot-atomic.test.ts`：
  - 模擬 100 個房間同時觸發 Jackpot（`GETSET` 原子操作）
  - 驗證只有 1 個房間取得獎池金額，其他 99 個返回 0
  - 驗證獎池在第一個成功後立即重置為 `jackpot_min_pool`
- [ ] 使用 Redis Lua Script（`EVALSHA`）封裝原子操作，不依賴 Redis 版本的 `GETSET` 行為差異

---

### C-2：RTP 引擎數值沙箱驗證 🟡 P2

**問題**  
`TC-UNIT-RTP-001-S` 只模擬 10,000 局（樣本量不足以偵測系統性偏差）。另外 Jackpot 觸發頻率（估算 8 次/天）與 Jackpot 積累速度（3% 投注）的財務可持續性沒有計算文件。

**解決方案**
- [ ] 升級 `TC-UNIT-RTP-001-S` 的模擬規模：100 萬局，驗證統計分布而非只看平均值：
  ```
  - 長期 RTP 均值：[93%, 97%]
  - 標準差 < 0.5%
  - 99th percentile 單局玩家 RTP < 500%（防止極端賠付）
  ```
- [ ] 建立 `docs/RTP-SANDBOX.md` 財務模型文件，計算：
  - 每日 Jackpot 觸發次數期望值（依 DAU × 每人局數 × 觸發概率）
  - Jackpot 池累積速度（3% 投注 × 每日金幣投注總量）
  - 日賠付上限 vs 日積累的損益平衡點
  - 建議 `jackpot_min_pool` 最小值（避免空池後仍觸發導致賠付 0）

---

### C-3：IAP 冪等訂單端到端測試 🟡 P2

**問題**  
IAP 充值的冪等性（UUID order_id）是防止重複發鑽石的核心保障，但目前只有 BDD Scenario（`TC-INT-SHOP-003-B`），沒有實際 integration test。

**解決方案**
- [ ] 實作 `tests/integration/shop-idempotency.test.ts`（使用 Testcontainers MySQL + Apple IAP mock）：
  - 同一 `idempotency_key` 連續送 5 次請求
  - 驗證資料庫 `orders` 表只建立 1 筆記錄
  - 驗證 `diamond_balance` 只增加一次
  - 驗證第 2-5 次回傳 409 + `original_order_id`
- [ ] 實作退款 webhook 測試（`TC-INT-SHOP-006-E`）：
  - 驗證 `diamond_balance` 扣除不超過現有餘額（餘額不足時行為需定義）

---

## D. BDD 測試補全

### D-1：建立 BDD Step Definitions 🟡 P2

**問題**  
`features/` 下 8 個 feature 檔共 78 個 Scenario（Outline 展開後約 95 個 test case），全部沒有 step definitions，Cucumber 無法執行。

**解決方案**
- [ ] 安裝並配置 Cucumber.js：
  ```bash
  npm install -D @cucumber/cucumber @cucumber/pretty-formatter
  ```
- [ ] 建立以下 step definition 檔案（依模組優先順序）：
  ```
  tests/features/step-definitions/
  ├── auth.steps.ts       # user_login + user_registration
  ├── game-room.steps.ts  # room_matchmaking
  ├── fishing.steps.ts    # fishing_gameplay
  ├── rtp.steps.ts        # rtp_jackpot
  ├── weapon.steps.ts     # weapon_skill
  ├── shop.steps.ts       # iap_purchase
  ├── vip.steps.ts        # vip_subscription
  └── shared.steps.ts     # Background steps (DB init, JWT)
  ```
- [ ] `shared.steps.ts` 優先實作 `Background` steps（每個 feature 都用到）：
  - `Given 資料庫已初始化（clean state）` → Testcontainers + Prisma migrate reset
  - `And 玩家 "xxx@example.com" 已登入...` → 直接呼叫 auth service 建立真實 JWT

---

### D-2：補全效能測試（k6） 🟡 P2

**問題**  
BRD NFR 要求 WebSocket P99 ≤ 100ms、REST P99 ≤ 500ms、DAU 10,000 並發。目前 0 個效能測試腳本，SLO 完全未驗證。

**解決方案**
- [ ] 安裝 k6 並建立 `tests/performance/` 目錄
- [ ] 建立 5 個 k6 腳本（對應 RTM TC-PERF-001~005）：
  ```
  tests/performance/
  ├── auth-login-load.js     # TC-PERF-001：登入 QPS 100，P99 ≤ 500ms
  ├── shop-purchase-load.js  # TC-PERF-002：充值 QPS 50，P99 ≤ 500ms
  ├── ws-room-latency.js     # TC-PERF-003：WebSocket 房間狀態同步 P99 ≤ 100ms
  ├── concurrent-rooms.js    # TC-PERF-004：200 個同時房間（DAU 10,000 估算）
  └── jackpot-concurrent.js  # TC-PERF-005：Jackpot 100 並發觸發壓力測試
  ```
- [ ] 在 CI pipeline 加入效能門檻：P99 超標時 fail build

---

## E. 業務與策略風險

### E-1：核心假設用戶驗證（逾期） 🟠 P1

**問題**  
BRD §1.2 FAQ 記載「最大風險：核心假設風險——玩家對多人競爭搶魚的需求強度可能不及預期」，計畫在「BRD 後 4 週內完成用戶訪談（N ≥ 10）+ MVP A/B 測試驗證」。BRD 日期 2026-04-24，今日 2026-04-29，此任務已逾期開始。

**解決方案**
- [ ] **立即啟動用戶訪談（N ≥ 10）**，受訪者條件：台灣/東南亞 18-45 歲，過去 30 天有玩捕魚遊戲
- [ ] 訪談核心問題：
  1. 「若旁邊玩家搶走你正在打的魚，你的感受是？」（測試競爭接受度）
  2. 「你願意為技能冷卻等待嗎？或是你希望隨時能用？」（測試策略深度接受度）
  3. 「你上一次因為捕魚遊戲感到興奮是什麼時候？」（了解爽感來源）
- [ ] 訪談結果若否定核心假設，立即召開 Pivot 會議，考慮：
  - 降低競爭強度（資源爭搶改為選擇性 PvP 模式）
  - 保留 RTP + Jackpot 作為核心，競爭功能降為 P2
- [ ] 將訪談摘要更新至 `docs/BRD.md §2.3 機會假設` 驗證狀態欄

---

### E-2：`fish_kills` 分區與 Prisma 共存策略 🟡 P2

**問題**  
`fish_kills` 月 RANGE 分區每日 200 萬行，但 Prisma migration 可能覆寫分區 DDL。沒有正式的 migration 策略文件。

**解決方案**
- [ ] 建立 `prisma/migrations/manual/001_fish_kills_partition.sql`，從 Prisma 的自動 migration 流程中排除
- [ ] 在 `package.json` 加入 `postmigrate` 腳本，在每次 `prisma migrate deploy` 後重新執行分區 DDL（使用 `IF NOT EXISTS` 冪等語法）
- [ ] 建立每月自動分區建立機制（定時任務或 Kubernetes CronJob）：
  ```sql
  -- 每月 1 日執行，建立下個月的分區
  ALTER TABLE fish_kills ADD PARTITION (
    PARTITION p<YYYYMM> VALUES LESS THAN (<YYYYMM+1>)
  );
  ```
- [ ] 測試：在 `tests/integration/` 加入分區切換測試，確認跨月查詢不中斷

---

### E-3：Analytics Buffer 降級行為驗證 🟢 P3

**問題**  
EDD §8.5 定義 Analytics 平台 HTTP 超時 > 1000ms 時系統降級為本地 Buffer，事件延後發送。此行為有 BDD Scenario（`TC-INT-INFRA-001-E`）但無 unit test 驗證 Buffer 機制的正確性。

**解決方案**
- [ ] 實作 `tests/unit/analytics-buffer.test.ts`：
  - Mock Analytics 服務返回超時
  - 驗證事件被推入 local Buffer，不丟失
  - 驗證 Analytics 恢復後 Buffer 事件自動重傳
  - 驗證 Buffer 在主流程（玩家射魚、金幣結算）失敗時不阻塞主流程

---

## F. 文件維護

### F-1：建立文件同步規則 🟢 P3

**問題**  
ALIGN_REPORT 修復了 30 個問題，但 README Known Issues 沒有同步更新，造成文件版本漂移。

**解決方案**
- [ ] 在 `docs/` 根目錄建立 `CONTRIBUTING.md`，加入以下規則：
  - **文件修改 PR Checklist**：若修復 ALIGN_REPORT 中的 finding，必須同步更新 README Known Issues
  - **新增/修改 API endpoint**：必須同步更新 API.md + EDD + BDD feature + RTM
  - **修改 SCHEMA**：必須同步更新 SCHEMA.md + EDD §5.5 + 相關 BDD Background steps
- [ ] 考慮在 CI 加入 ALIGN_REPORT 自動掃描，PR 有新 CRITICAL/HIGH 問題時阻擋合併

---

### F-2：PlantUML 圖表評估 🟢 P3

**問題**  
D5-001：EDD 圖表以 Mermaid 格式撰寫，無 PlantUML `.puml` 檔案。ALIGN_REPORT 標記為 MANUAL（格式偏好，非對齊問題）。

**解決方案**
- [ ] 評估現有工具鏈：若 GitHub Actions CI 已有 Mermaid 渲染，無需轉換
- [ ] 若需要 PlantUML 產出 PNG（如嵌入 Confluence/Word）：安裝 `@mermaid-js/mermaid-cli`，加入 `npm run diagrams` 指令自動產出
- [ ] 結論記錄在 `docs/ADR-002-diagram-format.md`

---

## 完成狀態總覽

```
類別                        項目數   完成   待辦
─────────────────────────────────────────────────
A. 設計衝突                    3      0      3
B. 實作啟動                    3      0      3
C. 財務風險測試                3      0      3
D. BDD / 效能測試              2      0      2
E. 業務與策略風險               3      0      3
F. 文件維護                    2      0      2
─────────────────────────────────────────────────
合計                          16      0     16
```

---

*此文件由深度 ALIGN_REPORT 分析生成，反映 2026-04-29 當日狀態。*
