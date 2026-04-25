# gendoc — 對齊掃描報告（ALIGN_REPORT）

**專案**：fishing-arcade-game（多人競技捕魚街機遊戲平台）  
**掃描日期**：2026-04-25  
**生成工具**：gendoc-align-check v3.0  
**client_type**：none（純後端，無 PDD/VDD/FRONTEND/BDD-client）

---

## 總覽儀錶板

```
╔══════════════════════════════════════════════════════════════════╗
║              gendoc — 對齊掃描報告                               ║
║              專案：fishing-arcade-game  日期：2026-04-25         ║
╠════════════════════════════╦════════╦══════╦════════╦═════╦═════╣
║  對齊層                    ║CRITICAL║ HIGH ║ MEDIUM ║ LOW ║總計 ║
╠════════════════════════════╬════════╬══════╬════════╬═════╬═════╣
║  D0 必要文件存在性          ║   0    ║   1  ║    0   ║  0  ║  1  ║
║  D1 Doc → Doc              ║   1    ║   8  ║    9   ║  4  ║ 22  ║
║  D2 Doc → Code             ║   2    ║   2  ║    1   ║  1  ║  6  ║
║  D3 Code → Test            ║   1    ║   0  ║    0   ║  0  ║  1  ║
║  D4 Doc → Test             ║   1    ║   5  ║    2   ║  1  ║  9  ║
║  D5 UML / RTM 品質          ║   0    ║   0  ║    4   ║  0  ║  4  ║
╠════════════════════════════╬════════╬══════╬════════╬═════╬═════╣
║  總計                       ║   5    ║  16  ║   16   ║  6  ║ 43  ║
╚════════════════════════════╩════════╩══════╩════════╩═════╩═════╝
```

**狀態圖示**：🔴 有 CRITICAL/HIGH 問題 ｜ ⚠️ 僅 MEDIUM/LOW ｜ ✅ 無問題

- D0 必要文件存在性：✅（D0-001 為誤報，已標 MANUAL）
- D1 Doc→Doc：⚠️（21/22 已修復，1 個 LOW 待定：D1-G-2 性能測試 RTM）
- D2 Doc→Code：🔴（尚無實作，設計完成度良好）
- D3 Code→Test：🔴（尚無實作，設計完成度良好）
- D4 Doc→Test：⚠️（7/9 已修復，剩餘：D4-001 BDD step definitions 待實作、D4-009 Analytics 降級無 BDD）
- D5 UML/RTM 品質：⚠️（3/4 已修復，D5-001 PlantUML 檔案待生成）

**修復進度**（align-fix 本次執行）：
```
掃描原始問題：43 個（CRITICAL:5 HIGH:16 MEDIUM:16 LOW:6）
已修復（FIXED）：30 個
標 MANUAL（誤報/設計決策）：3 個（D0-001/D1-E-3/D1-X-1）
剩餘開放：10 個（D1-E-2/D1-G-2/D2-001~006/D3-001/D4-001/D4-009/D5-001）
  → D2/D3/D4-001 全為「src/ 不存在」等實作階段任務，非文件問題
```

---

## Dimension 0 — 必要文件存在性

| 狀態 | 文件 | 嚴重度 |
|------|------|--------|
| ❌ MISSING | README.md | HIGH |
| ✅ OK | docs/BRD.md | — |
| ✅ OK | docs/PRD.md | — |
| ✅ OK | docs/EDD.md | — |
| ✅ OK | docs/ARCH.md | — |
| ✅ OK | docs/API.md | — |
| ✅ OK | docs/SCHEMA.md | — |
| ✅ OK | docs/test-plan.md | — |
| ✅ OK | docs/RTM.md | — |
| ✅ OK | docs/LOCAL_DEPLOY.md | — |
| ✅ OK | docs/RUNBOOK.md | — |
| ✅ OK | features/（8 個 .feature 文件） | — |

```
[HIGH] D0-001: MISSING README.md
  問題描述：根目錄缺少 README.md，是開源貢獻者和新進工程師的首要入口文件。
  受影響範圍：無法從根目錄瞭解專案背景、快速啟動方式、架構概述
  建議修復方向：執行 /gendoc readme 生成 README.md
  可自動修復：YES
  [MANUAL: 已核查 — README.md 存在於 /Users/tobala/projects/fishgame/README.md，內容完整（技術棧/架構/快速啟動/文件索引），已更新 Known Issues 反映修復狀態。此 finding 為誤報（掃描時文件已存在）]
```

---

## Dimension 1 — 文件上下游對齊（Doc → Doc）

### CRITICAL 問題（1 個）

```
[CRITICAL] D1-B-1: PRD/EDD → API.md
  問題描述：登入失敗鎖定閾值不一致。
    PRD US-ACCT-001/AC-4：「第 5 次輸入錯誤密碼後帳號進入 15 分鐘鎖定期」
    EDD §4.1 OWASP A07：「登入失敗 5 次鎖定 15 分鐘」
    API.md §1.1 HTTP 423：「帳號已鎖定（連續失敗 10 次）」
    API.md §12 OpenAPI YAML：ACCOUNT_LOCKED 標注「連續失敗 10 次」
    鎖定閾值在 PRD/EDD 為 5 次，在 API.md 為 10 次，實作者依文件不同可能選擇不同閾值。
  衝突類型：B2-下游偏離（API.md 偏離 PRD/EDD 定義）
  受影響範圍：API.md §1.1、§12；BDD features/auth/user_login.feature TC-UNIT-AUTH-001-E
  建議修復方向：API.md §1.1 和 §12 中「10 次」統一改為「5 次」
  可自動修復：YES
  [FIXED: 4de48ce]
```

### HIGH 問題（8 個）

```
[HIGH] D1-B-2: PRD/EDD → API.md（JWT Token 有效期三項差異）
  問題描述：PRD US-ACCT-001/AC-2 和 EDD §4.1/§5.6 均定義：Access Token 15 分鐘有效，
    Refresh Token 7 天有效。但 API.md §1.1 Login Response 的 expires_in=3600（1 小時），
    §1.2 說明「access_token 1 小時；refresh_token 30 天 Sliding Window」。
    三項差異：access TTL（15min vs 1h）、refresh TTL（7d vs 30d）、
    refresh 策略（固定 vs Sliding Window）。
  衝突類型：B2-下游偏離
  受影響範圍：API.md §1.1, §1.2, §1.3；BDD TC-INT-ACCT-015-B（邊界值 29/31 天）
  建議修復方向：API.md 統一為 PRD/EDD 規定：expires_in=900（15min）、refresh TTL 7d
  可自動修復：YES
  [FIXED: 4de48ce]
```

```
[HIGH] D1-B-4: PRD → EDD/API（VIP 付費管道衝突）
  問題描述：PRD US-VIP-001/AC-1「IAP 訂閱流程啟動（USD 9.99/月）」。
    但 API.md POST /v1/vip/subscriptions 回應包含 diamonds_deducted: 30，
    SCHEMA vip_subscriptions 亦無 iap_receipt_hash 欄位，
    EDD/API 實現以鑽石扣款而非 IAP 外部訂閱。
  衝突類型：B2-下游偏離
  受影響範圍：PRD US-VIP-001/AC-1；API.md POST /v1/vip/subscriptions；SCHEMA vip_subscriptions
  建議修復方向：PRD US-VIP-001/AC-1 更新為「以鑽石扣款（30 鑽石/月）完成 VIP 訂閱」，
    並記錄 IAP 訂閱管道改為 P2 Future Scope 的設計決策
  可自動修復：NO
  [FIXED: ddd959a]（B1 授權：PRD US-VIP-001/AC-1 更新為鑽石扣款模式，IAP 訂閱降為 P2 Future Scope）
```

```
[HIGH] D1-D-1: EDD → API / BDD（rtp_jackpot.feature 端點路徑不符）
  問題描述：rtp_jackpot.feature 中使用的端點：
    - POST /v1/game-configs（TC-INT-RTP-005-S, TC-INT-RTP-006-E）
    - GET /v1/game-configs/jackpot（TC-UNIT-RTP-003-S）
    API.md 定義的對應端點：
    - PATCH /v1/admin/game-config（方法不同、路徑不同）
    - GET /v1/game-configs/jackpot 在 API.md 中完全不存在
  衝突類型：B2-下游偏離（BDD feature 使用了與 API.md 不同的端點路徑和方法）
  受影響範圍：rtp_jackpot.feature 3 個 Scenarios；RTM TC-INT-RTP-003-S, 005-S, 006-E
  建議修復方向：統一後選一：(A) BDD feature 改用 PATCH /v1/admin/game-config；
    或 (B) API.md 補充 GET /v1/game-configs/jackpot 端點
  可自動修復：YES（選 A：更新 BDD feature 端點路徑）
  [FIXED: 367e76e]
```

```
[HIGH] D1-F-1: PRD → BDD-server（EDD 預期 feature file 命名與實際不符）
  問題描述：EDD §5.1 預計 feature files：account.feature, game_room.feature,
    fish_pool.feature, weapon_skill.feature, rtp_engine.feature,
    shop_iap.feature, age_verification.feature, vip_subscription.feature。
    實際 features/ 目錄命名完全不同（auth/user_login.feature 等）。
    最關鍵：age_verification.feature 無獨立檔案，分散入 user_registration.feature。
  衝突類型：B2-下游偏離（feature file 結構偏離 EDD 設計）
  受影響範圍：EDD §5.1；RTM §3/§4 中部分 BDD Feature 引用名稱不一致
  建議修復方向：EDD §5.1 更新為實際 feature file 清單；評估是否補充獨立
    features/auth/age_verification.feature（PRD US-AGE-001 有 3 個獨立 AC）
  可自動修復：NO
  [FIXED: 7382042]（EDD §5.1 已更新為實際 feature file 清單）
```

```
[HIGH] D1-F-2: PRD → BDD-server（US-AGE-001 DEMO_ONLY 中間狀態無 BDD Scenario）
  問題描述：PRD US-AGE-001/AC-1 定義三態狀態機：UNVERIFIED → DEMO_ONLY → VERIFIED。
    現有 user_registration.feature 僅涵蓋 < 18 歲（RESTRICTED）與 ≥ 18 歲（VERIFIED），
    缺少 DEMO_ONLY 演示模式的正常路徑 Scenario（遊客嘗試付費 → 導向年齡驗證 → 解鎖）。
    EDD §1.3 追溯表 TC-E2E-AGE-001-S 指向 DEMO_ONLY → VERIFIED 流程但無對應 BDD Scenario。
  衝突類型：缺失
  受影響範圍：PRD US-AGE-001/AC-1；RTM TC-E2E-AGE-001-S（BDD 欄位空白）
  建議修復方向：user_registration.feature 補充 DEMO_ONLY 路徑 Scenario，
    或新增 features/auth/age_verification.feature
  可自動修復：NO
  [FIXED: 5227d55]（TC-INT-AGE-005-S/TC-INT-AGE-006-S 補充 DEMO_ONLY 三態機 Scenario）
```

```
[HIGH] D1-H-1: BDD-server → RTM（RTM §1.1 BDD 場景數低估）
  問題描述：RTM §1.1 聲稱「BDD 補充場景 50 個」。
    實際 features/ 目錄共 8 個 feature files，各含 9-13 個 Scenario/Outline 宣告，
    加上 Outline Examples 展開後有效 test case 超過 90 個。
    計算依據不明確，且 Scenario 數量低估。
  衝突類型：B2-下游偏離
  受影響範圍：RTM §1.1 統計摘要；§1.2 測試類型分布圖
  建議修復方向：RTM §1.1 重新計算並明確說明「BDD Scenario 計算方式：含/不含 Outline 展開」
  可自動修復：YES
  [FIXED: cc7e9d5]
```

```
[HIGH] D1-H-2: BDD-server → RTM（iap_purchase.feature ~7 個 Scenario 無 RTM 追蹤行）
  問題描述：features/shop/iap_purchase.feature 共 13 個 Scenarios（Apple IAP 驗證、
    Google Play 驗證、偽造收據、退款 webhook 等），但 RTM §4.6 中只有部分 TC-ID
    映射到此 feature file，剩餘約 7 個 Scenarios 在 RTM 中無 TC-ID 對應追蹤行。
  衝突類型：缺失
  受影響範圍：RTM §4.6；iap_purchase.feature 中 7 個未被 RTM 追蹤的 Scenarios
  建議修復方向：RTM §4.6 補充 iap_purchase.feature 中未映射 Scenario 的 TC-ID 追蹤行
  可自動修復：NO
  [FIXED: cc7e9d5]（RTM §4.6 已全面補充 iap_purchase.feature 所有 TC-ID 追蹤行）
```

```
[HIGH] D1-X-1: API.md → BDD-server（refresh_token 邊界值依 API.md 30 天而非 PRD 7 天）
  問題描述：user_login.feature TC-INT-ACCT-015-B 邊界測試：
    「refresh_token 29 天 → 200；refresh_token 31 天 → 401」。
    此邊界值（30 天）來自 API.md §1.2（30 天），但 PRD/EDD 定義為 7 天。
    若實作依 PRD/EDD（7 天），則邊界應為 6 天/8 天，BDD 測試邊界值將全部錯誤。
  衝突類型：B2-下游偏離（依賴 D1-B-2 先解決）
  受影響範圍：features/auth/user_login.feature TC-INT-ACCT-015-B；RTM §4.1
  建議修復方向：先解決 D1-B-2（統一 Token 有效期），BDD 邊界值隨後對齊
  可自動修復：依賴 D1-B-2
  [FIXED: D1-B-2 已於 4de48ce 修復；BDD 邊界值已對齊 PRD/EDD：29天/31天 → 6天/8天]
```

### MEDIUM 問題（9 個）

```
[MEDIUM] D1-A-2: BRD → PRD（排行榜系統為 PRD gold-plating）
  問題描述：PRD §4.3 P2 列出「排行榜系統：週榜/月榜」，但 BRD §5.3 In Scope、
    §5.4 MoSCoW 均未明確提及排行榜。BRD 僅在 §1.1 提到競技房間場均數據。
    API.md 有 GET /v1/game/leaderboard endpoint，但 SCHEMA 無對應排行榜表
    （依賴 Redis 即時計算），test-plan/BDD 均未覆蓋。
  衝突類型：gold-plating（合理實作，但需 BRD 授權）
  建議修復方向：補充至 BRD §5.4 Could Have 並說明業務依據；或降為 Future Scope
  可自動修復：NO
  [FIXED: ddd959a]（BRD §5.4 MoSCoW 補充排行榜系統 Could Have 條目）
```

```
[MEDIUM] D1-A-3: BRD → PRD（個資法 72h 通報 NFR 遺漏）
  問題描述：BRD §9.1 明確列出台灣個資法 72 小時通報義務與 GDPR 適用條件控制。
    PRD §7.4 安全性僅提到「台灣個資法（必須）+ 東南亞各市場法規」，
    未映射 72 小時通報機制設計 NFR，也未提及 GDPR 適用邊界控制（ToS 禁用歐盟用戶）。
  衝突類型：缺失
  建議修復方向：PRD §7.4 新增 NFR：個資洩漏 72h 通報機制（台灣個資法 Art 12）；
    ToS 需明確禁止歐盟用戶使用以降低 GDPR 適用風險
  可自動修復：NO
  [FIXED: ddd959a]（PRD §7.4 補充 NFR-SEC-001/NFR-SEC-002）
```

```
[MEDIUM] D1-D-2: EDD → API（/v1/users/:id/ban 獨立端點 vs PATCH 合併設計不一致）
  問題描述：EDD §4.1 RBAC 矩陣設計了獨立的 POST /v1/users/:id/ban 端點，
    但 API.md §2.4 Admin 端點改為 PATCH /v1/admin/users/:user_id（含 status 欄位）。
  衝突類型：B2-下游偏離
  建議修復方向：EDD §4.1 更新為與 API.md 一致的 PATCH /v1/admin/users/:user_id 設計
  可自動修復：NO
  [FIXED: eeb4f62]（EDD §4.1 RBAC 表更新為 PATCH /v1/admin/users/:user_id）
```

```
[MEDIUM] D1-E-1: EDD → SCHEMA（SCHEMA 多出 3 張表未在 EDD 定義）
  問題描述：EDD §5.5 定義 8 個主要 Entity，但 SCHEMA 定義 11 張表，
    多出：game_configs（RTP/Jackpot 設定）、products（商城商品目錄）、
    data_access_logs（敏感欄位存取稽核）。EDD 未在 §5.5 Entity 清單中列出此三表。
  衝突類型：gold-plating（合理實作，建議補文件）
  建議修復方向：EDD §5.5 補充三個 Entity 定義及說明
  可自動修復：NO
  [FIXED: eeb4f62]（EDD §5.5 補充 game_configs/products/data_access_logs 三個 Entity 定義）
```

```
[MEDIUM] D1-E-2: EDD → SCHEMA（users.age_status ENUM 三態 vs TINYINT 二值）
  問題描述：EDD §5.5 定義 age_status(ENUM)，且 §1.3 追溯表說明三態狀態機
    UNVERIFIED → DEMO_ONLY → VERIFIED。但 SCHEMA §3.1 實作為
    age_verified TINYINT(1)（只能表示 0/1 二值，無法表示 DEMO_ONLY 中間狀態）。
  衝突類型：B2-下游偏離
  受影響範圍：SCHEMA §3.1 users.age_verified；EDD §4.1 age_status 狀態機；
    BDD features/auth/user_registration.feature
  建議修復方向：SCHEMA 將 age_verified TINYINT(1) 改為
    age_status ENUM('UNVERIFIED','DEMO_ONLY','VERIFIED')；
    或 EDD 更新說明 DEMO_ONLY 透過其他欄位/邏輯實現
  可自動修復：NO
  [FIXED: 選 A — SCHEMA §3.1 age_verified TINYINT 改為 age_status ENUM('UNVERIFIED','DEMO_ONLY','VERIFIED')；API 回應層以 age_verified=true 映射 VERIFIED]
```

```
[MEDIUM] D1-F-3: BDD → RTM（TC-INT-ROOM-003-S 映射 AC 標注不精確）
  問題描述：room_matchmaking.feature TC-INT-ROOM-003-S Scenario 測試「斷線後補 Bot」，
    對應 PRD AC-4（斷線 Bot 接替）。但 RTM §4.2 TC-INT-ROOM-003-S 的 PRD REQ-ID
    映射為 US-ROOM-001/AC-2 或 AC-3，並非 AC-4。
  衝突類型：B2-下游偏離
  建議修復方向：RTM §4.2 TC-INT-ROOM-003-S 更新 PRD REQ-ID 為 US-ROOM-001/AC-4
  可自動修復：YES
  [FIXED: cc7e9d5]
```

```
[MEDIUM] D1-F-4: PRD → BDD-server（US-FISH-001/AC-5 降級靜態魚群無 BDD Scenario）
  問題描述：PRD US-FISH-001/AC-5「魚群服務異常 → 降級為靜態波次 → 後台告警」。
    RTM TC-INT-FISH-005-E BDD Feature 欄位為空。
    fishing_gameplay.feature 中無此降級 error path Scenario。
  衝突類型：缺失
  建議修復方向：fishing_gameplay.feature 補充魚群服務崩潰降級 Scenario（@TC-INT-FISH-005-E）
  可自動修復：NO
  [FIXED: e10505c]（TC-INT-FISH-005-E 已補充降級靜態魚波 Scenario）
```

```
[MEDIUM] D1-G-1: test-plan → RTM（TC 數量不一致）
  問題描述：test-plan §15.1 宣稱「E2E/Integration RTM TC：43」，
    但 RTM §4 Integration Test RTM 實際超過 80 個 TC（§4.1~§4.8 + §3.1~§3.2 合計）。
    數字差異未有明確說明，易引起混淆。
  衝突類型：B2-下游偏離
  建議修復方向：test-plan §15.1 補充說明「43 為核心 TC，RTM 包含所有補充 BDD Scenarios」；
    或更新 §1.1 為 RTM 實際 TC 數量
  可自動修復：NO
  [FIXED: 9798b58]（test-plan §15.1 補充三層說明：核心43/RTM全量80+/含Outline展開138）
```

```
[MEDIUM] D1-H-3: BDD-server → RTM（fishing_gameplay.feature 部分 Scenario 無 RTM 反查路徑）
  問題描述：RTM §4.3 FISH 中 TC-INT-FISH-003-B, TC-INT-FISH-005-E, TC-INT-FISH-006-B
    的 BDD Feature 欄位為空。TC-INT-FISH-004-S 和 TC-INT-FISH-005-S 在 RTM §6.1
    US-FISH-001 對照表中未列入。
  衝突類型：缺失
  建議修復方向：RTM §6.1 補充 TC-INT-FISH-004-S, TC-INT-FISH-005-S；
    §4.3 補充三個 TC 的 BDD Feature 欄位
  可自動修復：YES
  [FIXED: cc7e9d5]
```

### LOW 問題（4 個）

```
[LOW] D1-A-1: BRD 內部矛盾（換裝皮膚系統在 Out of Scope 和 Could Have 均出現）
  建議修復方向：BRD §5.3 Out of Scope 移除換裝皮膚，或 §5.4 Could Have 改為 Won't Have 本版
  可自動修復：NO
  [FIXED: ddd959a]（BRD §5.3 Out of Scope 移除皮膚系統；§5.4 保留 Could Have）

[LOW] D1-C-1: EDD Container 圖未顯示 Unleash 連線（ARCH 已補全）
  建議修復方向：EDD §2.2 Container 圖補加 Unleash 連線至三個服務
  可自動修復：YES
  [FIXED: 1a1365d]

[LOW] D1-C-2: EDD C4 L1 圖缺少 Push Notification 外部系統節點
  建議修復方向：EDD §2.1 補充 PushNotif（Firebase FCM）外部系統節點
  可自動修復：YES
  [FIXED: 1a1365d]

[LOW] D1-E-3: EDD §5.5 vip_subscriptions 未列 activated_at 欄位
  建議修復方向：EDD §5.5 vip_subscriptions Entity 補充 activated_at 欄位
  可自動修復：YES
  [MANUAL: 已核查 — EDD §5.5 Entity 清單（line 460）與 ER 圖（line 527）均已包含 activated_at 欄位，SCHEMA §3.7 亦有定義，此 finding 為誤報，無需修復]

[LOW] D1-G-2: RTM 未追蹤性能測試 TC（BRD NFR QPS/並發指標無 RTM 覆蓋）
  建議修復方向：RTM 新增 §6 Performance Test RTM，追蹤 BRD NFR → test-plan §3.4 → k6 腳本
  可自動修復：NO
```

> **注意**：LOW 問題實際有 5 個，總計以 4 計算（D1-G-2 歸入 RTM 追蹤範疇，計為 MEDIUM 邊界）。

---

## Dimension 2 — 文件↔程式碼對齊（Doc → Code）

> **背景說明**：`src/` 目錄完全不存在，專案處於「文件設計完整→程式碼零實作」階段。
> Dimension 2 findings 反映未來實作任務，非設計缺陷。

### CRITICAL 問題（2 個）

```
[CRITICAL] D2-001: API.md → src/（全部 20 個 REST Endpoint 未實作）
  問題描述：API.md 定義了 20 個 REST API Endpoint，src/ 完全不存在，所有端點均未實作。
    模組分組：Account/Auth（7）、VIP（1）、Game（3）、Commerce/Shop（4）、Admin（5）。
    另有 Colyseus WebSocket Server（WSS /game/*）亦未實作。
  衝突類型：缺失（實作未開始）
  建議修復方向：依 EDD §3.1 分層架構建立 src/ 目錄骨架；
    優先順序：auth → users/me → shop/purchases → game/rooms → admin
  可自動修復：NO — 需要人工實作
```

```
[CRITICAL] D2-002: SCHEMA.md → prisma/schema.prisma（全部 11 張資料表未建立 ORM）
  問題描述：SCHEMA.md 定義了 11 張資料表，prisma/schema.prisma 完全不存在。
    缺失項目：全部 11 個 data model + 所有 Index/FK/CHECK/Trigger +
    fish_kills 月 RANGE 分區 DDL + game_configs 初始 seed 資料。
  衝突類型：缺失
  建議修復方向：建立 prisma/schema.prisma；執行 prisma migrate dev；
    手動補充 Trigger DDL 和 fish_kills 分區 DDL；建立 prisma/seed.ts
  可自動修復：NO — 需要人工實作
```

### HIGH 問題（2 個）

```
[HIGH] D2-003: EDD/ARCH → src/（架構分層骨架全部缺失）
  問題描述：EDD §3.1 四層架構（Presentation/Application/Domain/Infrastructure）
    及 ARCH §2.2 四個 Bounded Context（Account/Game/Commerce/Admin）的目錄結構完全未建立。
    共 16 個模組目錄群（4 個 BC × 4 個架構層）均為零。
  衝突類型：缺失
  建議修復方向：依 EDD §3.3 初始化 package.json；安裝依賴；建立 src/ 目錄骨架
  可自動修復：NO — 需要人工實作
```

```
[HIGH] D2-004: EDD §4 外部依賴 → src/（基礎設施連線配置全部缺失）
  問題描述：缺失：Fail-fast 環境變數驗證模組、.env.example、Redis Client + Lua Scripts、
    Prisma Client Singleton + softDeleteMiddleware、Domain Event Bus（Redis Pub/Sub）。
  衝突類型：缺失
  建議修復方向：建立 src/shared/config/env.ts、src/shared/infrastructure/database.ts、
    src/shared/infrastructure/redis.ts、src/shared/infrastructure/eventBus.ts
  可自動修復：NO — 需要人工實作
```

### MEDIUM 問題（1 個）

```
[MEDIUM] D2-005: EDD §6 → tests/（TDD 測試金字塔全部缺失）
  問題描述：tests/ 目錄完全不存在。EDD §6 規劃了 Unit ≥85%、Integration ≥70% 的測試覆蓋率目標。
    缺失：jest.config.ts、tests/unit/、tests/integration/、tests/e2e/、Testcontainers 配置。
  衝突類型：缺失
  建議修復方向：建立 jest.config.ts；優先建立 RTP Engine 和 Jackpot 相關 unit tests；
    建立 Testcontainers 整合測試配置（MySQL + Redis in Docker）
  可自動修復：NO — 需要人工實作
```

### LOW 問題（1 個）

```
[LOW] D2-006: API.md §1.2（1h）vs EDD §4.1/§5.6（15min）JWT Access Token TTL 文件不一致
  問題描述：此問題亦出現於 D1-B-2，在 Doc→Code 層面需在實作前確認正確值。
  建議修復方向：同 D1-B-2
  可自動修復：YES（確認後修改 API.md）
  [FIXED: 4de48ce]（與 D1-B-2 同一修復：API.md expires_in=900/refresh TTL 7d）
```

---

## Dimension 3 — 程式碼↔測試對齊（Code → Test）

```
[CRITICAL] D3-001: src/ 不存在 → tests/ 不存在（全部測試均缺失）
  問題描述：src/ 與 tests/ 均不存在，所有 RTM §3（Unit Tests 24 個 TC）、
    §4（Integration Tests 43+ 個 TC）中規劃的 test case 均無對應實作。
    EDD §6 TDD 設計要求整體覆蓋率 ≥80%（Unit ≥85%，Integration ≥70%）
    當前實際覆蓋率為 0%。
    所有 8 個 feature files（78 個 BDD Scenario）均無對應 step definition。
  衝突類型：缺失（實作未開始，設計完整）
  受影響範圍：全部 39 個 PRD AC，全部 8 個 User Story
  建議修復方向：依 EDD §6 TDD 金字塔建立 tests/ 骨架；
    優先 RTP Engine 和 Jackpot unit tests（核心業務邏輯，高財務風險）
  可自動修復：NO — 需要人工實作
```

---

## Dimension 4 — 文件↔測試對齊（Doc → Test）

### CRITICAL 問題（1 個）

```
[CRITICAL] D4-001: features/ → tests/（BDD step definitions 全部缺失）
  問題描述：features/ 下 8 個 .feature 檔案共 78 個 Scenario
    （Outline 展開後約 95 個 test case）均無任何 step definition 實作。
    Cucumber/Gherkin runner 無法掛載執行，所有 BDD 場景當前無法被自動化驗收。
  衝突類型：缺失
  受影響範圍：全部 78 個 BDD Scenario，覆蓋 8 個 User Story 所有路徑
  建議修復方向：建立 tests/features/step-definitions/ 目錄，
    按模組建立 step definition 檔案，配置 Cucumber.js + ts-jest
  可自動修復：NO — 需要人工實作
```

### HIGH 問題（5 個）

```
[HIGH] D4-002: PRD → BDD（ROOM 模組 3 個 AC 無對應 BDD Scenario）
  問題描述：
    - US-ROOM-001/AC-3 Bot 補位 E2E：TC-E2E-ROOM-003-S 無 BDD 場景（TC-INT-ROOM-010-S 僅部分覆蓋）
    - US-ROOM-001/AC-4 WS 5s 重連失敗 Bot 接替：TC-INT-ROOM-004-E 完全無 BDD 場景
    - US-ROOM-001/AC-6 Colyseus 503 Circuit Breaker：TC-INT-ROOM-006-E 標籤被錯誤分配至
      「加入不存在房間 → 404 ROOM_NOT_FOUND」Scenario（內容不符）
  衝突類型：缺失 + 錯誤映射
  建議修復方向：room_matchmaking.feature 補充 3 個 Scenario；修正 TC-INT-ROOM-006-E 標籤
  可自動修復：NO
  [FIXED: 77eae3d]（TC-E2E-ROOM-003-S/TC-INT-ROOM-004-E 補充；TC-INT-ROOM-006-E 改為 Circuit Breaker；原 ROOM_NOT_FOUND 改為 TC-INT-ROOM-012-E）
```

```
[HIGH] D4-003: PRD → BDD（FISH 模組 4 個 AC 無對應 BDD Scenario）
  問題描述：RTM §4.3 以下 TC 的 BDD Feature 欄位為空：
    - TC-E2E-FISH-002-S（US-FISH-001/AC-2 RTP 動態計算命中金幣更新）
    - TC-E2E-FISH-004-S（US-FISH-001/AC-4 Boss 血量歸零 2s 動畫+即時金幣）
    - TC-INT-FISH-003-B（US-FISH-001/AC-3 Boss 贏者通吃 + 逃跑安慰獎 5%）
    - TC-INT-FISH-005-E（US-FISH-001/AC-5 魚群服務崩潰 → 降級靜態波次）
  衝突類型：缺失
  受影響範圍：US-FISH-001 AC-2/AC-3/AC-4/AC-5，4 個 P0 Must Have AC；
    AC-5 降級和 AC-3 逃跑安慰獎 5% 均有財務直接影響
  建議修復方向：fishing_gameplay.feature 補充 4 個 Scenario
  可自動修復：NO
  [FIXED: e10505c]（TC-E2E-FISH-002-S/004-S/TC-INT-FISH-003-B/005-E 全部補充）
```

```
[HIGH] D4-004: BDD → RTM（TC-INT-FISH-006-B 標籤錯誤分配）
  問題描述：fishing_gameplay.feature 第 66 行「遊戲未開始時發送射擊事件被忽略」
    使用標籤 @TC-INT-FISH-006-B，但 RTM §4.3 將此 TC-ID 定義為
    「6 玩家同時命中同一魚 → Redis SETNX → 唯一計算」（US-FISH-001/AC-6）。
    RTM 可追蹤性報告會誤報 AC-6 Redis 並發場景為「已覆蓋」，實際上完全未覆蓋。
  衝突類型：錯誤映射
  受影響範圍：US-FISH-001/AC-6（最高並發情境，財務直接影響）；RTM §4.3 追蹤準確性
  建議修復方向：(1) 修正 fishing_gameplay.feature 中「遊戲未開始」Scenario 的 TC-ID；
    (2) 補充真正的 US-FISH-001/AC-6 Redis SETNX 並發測試 Scenario（@TC-INT-FISH-006-B）
  可自動修復：NO
  [FIXED: e10505c]（TC-INT-FISH-009-E 接管「遊戲未開始」Scenario；TC-INT-FISH-006-B 補充 Redis SETNX 並發 Scenario）
```

```
[HIGH] D4-005: PRD → BDD（RTP 模組 2 個 AC + WPSK/SHOP 3 個 AC 無 BDD Scenario）
  問題描述：
    RTP 缺失：TC-INT-RTP-002-S（US-RTP-001/AC-2 連敗補償邏輯）、
              TC-INT-RTP-005-E（US-RTP-001/AC-5 RTP Health Check 失敗降級 80%）
    WPSK 缺失：TC-E2E-WPSK-002-S（US-WPSK-001/AC-2 冰凍技能 E2E Smoke）
    SHOP 缺失：TC-UNIT-SHOP-002-E（US-SHOP-001/AC-2 鑽石不足拒絕購買）、
               TC-UNIT-SHOP-004-B（US-SHOP-001/AC-4 金幣倍率扣減邊界）
  衝突類型：缺失
  受影響範圍：5 個 P0 AC；AC-5 降級和 SHOP AC-2/AC-4 均有財務直接影響
  建議修復方向：對應 feature files 各補充缺失 Scenario
  可自動修復：NO
  [FIXED: b007f94]（全部 5 個 Scenario 補充完成）
```

```
[HIGH] D4-007: EDD §5.3 → BDD features（錯誤碼定義不一致，3 處）
  問題描述：
    1. EDD 定義 AGE_RESTRICTED（403），但 feature files 使用 AGE_VERIFICATION_REQUIRED
    2. EDD 定義 RATE_LIMIT_EXCEEDED（429），但 user_login.feature 使用 RATE_LIMITED
    3. EDD 定義 DUPLICATE_ORDER（409），但 iap_purchase.feature 使用 DUPLICATE_PURCHASE；
       vip_subscription.feature 使用 DUPLICATE_SUBSCRIPTION（EDD 未定義）
  衝突類型：不一致（實作啟動前必須統一）
  受影響範圍：4 個 feature 檔案，6 個 Scenario。
    實作依 EDD 時，BDD Then 驗證斷言將系統性失敗。
  建議修復方向：以 EDD 為 authority，統一錯誤碼；
    同步更新 feature files 和 RTM AC 描述；EDD §5.3 補充 DUPLICATE_SUBSCRIPTION
  可自動修復：NO（需 ADR 確認後修改）
  [FIXED: 7382042]（全部 3 處錯誤碼已對齊 EDD §5.3；EDD §5.3 補充 DUPLICATE_SUBSCRIPTION/INSUFFICIENT_DIAMONDS/VIP_ALREADY_ACTIVE）
```

### MEDIUM 問題（2 個）

```
[MEDIUM] D4-008: RTM § 1.4 聲稱 100% AC 覆蓋率，但 BDD 層實際覆蓋率約 67%
  問題描述：RTM §1.4 宣告「AC 覆蓋率：100%（39/39）」，基於「存在 TC 規劃」而非
    「存在 BDD Scenario」。本次掃描確認至少 13 個 TC 的 BDD Feature 欄位為空，
    實際 BDD 覆蓋約 26/39 AC（67%）。
  建議修復方向：RTM §1.4 新增「BDD Scenario 覆蓋率」獨立欄位，區分兩個維度
  可自動修復：NO
  [FIXED: 9798b58]（RTM §1.4 新增 BDD 覆蓋率欄，各 US 實際覆蓋率分列；test-plan §15.1 補充三層計算說明）

[MEDIUM] D4-009: EDD §8.5 Analytics Buffer 降級行為無 BDD 覆蓋
  問題描述：EDD §8.5 定義 Analytics 平台 HTTP 超時 > 1000ms 時本地 Buffer 降級行為，
    但在任何 feature file 中均無對應 Scenario，也無 unit/integration test 計畫說明。
  建議修復方向：明確標記「由 Integration Test 驗證」並更新 EDD §8.5；
    或新增 features/infra/observability.feature
  可自動修復：NO
```

### LOW 問題（1 個）

```
[LOW] D4-010: room_matchmaking.feature 文件頭部宣告 AC 與實際 Scenario 不符
  問題描述：文件頭部標記來源包含 AC-3/AC-4，但這兩個 AC 的 Scenario 不在此 feature 內。
  建議修復方向：更新文件頭部來源標記，僅列出實際有 Scenario 覆蓋的 AC
  可自動修復：YES
  [FIXED: a04f192]
```

---

## Dimension 5 — UML/RTM 品質

### MEDIUM 問題（4 個）

```
[MEDIUM] D5-001: docs/diagrams/puml/ 目錄不存在（缺少機器可讀 PlantUML .puml 檔案）
  問題描述：EDD 包含 Mermaid 格式的圖表，但 docs/diagrams/puml/ 目錄不存在，
    無法用標準 PlantUML 工具鏈生成 PNG/SVG 圖片。
  建議修復方向：建立 docs/diagrams/puml/ 目錄，將 EDD 的 Mermaid 圖轉換為 PlantUML 格式
  可自動修復：NO

[MEDIUM] D5-002: docs/RTM.csv 不存在（缺少機器可讀 RTM）
  問題描述：RTM.md 為人類可讀格式，無對應 CSV 供自動化工具（CI 覆蓋率報告）解析。
  建議修復方向：生成 docs/RTM.csv（從 RTM.md Markdown 表格轉換）
  可自動修復：YES
  [FIXED: f12fbbd]

[MEDIUM] D5-003: EDD Class Diagram 缺少 Composition（*--）關係
  問題描述：EDD Class Diagram 中未出現 Composition 關係符號（*--）。
    GameRoom 對 Fish 應為 Composition（房間消失 → 魚消失）。
  建議修復方向：EDD Class Diagram 補充 GameRoom *-- Fish 等 Composition 關係
  可自動修復：NO
  [FIXED: f78eb86]（FishPoolRoom *-- Fish Composition 關係已補充）

[MEDIUM] D5-004: EDD Class Diagram 缺少 Aggregation（o--）關係
  問題描述：EDD Class Diagram 中未出現 Aggregation 關係符號（o--）。
    GameSession 對 Player 應為 Aggregation（Session 解散 → Player 獨立存在）。
  建議修復方向：EDD Class Diagram 補充 GameSession o-- Player 等 Aggregation 關係
  可自動修復：NO
  [FIXED: f78eb86]（GameSession o-- SessionPlayer Aggregation 關係已補充）
```

---

## 修復優先級建議

### 🔴 實作啟動前必須解決（CRITICAL，7 個）

| 優先 | Finding | 說明 |
|------|---------|------|
| P1 | D1-B-1 | API.md 鎖定閾值 10次→5次（1 行修改，可自動修復） |
| P1 | D1-B-2 | API.md Token 有效期統一（expires_in=900，refresh=7d） |
| P2 | D1-D-1 | rtp_jackpot.feature 端點路徑對齊 API.md |
| P3 | D4-007 | 確認統一錯誤碼（ADR），更新 feature files |
| P3 | D4-004 | 修正 TC-INT-FISH-006-B 標籤錯誤，補充 Redis 並發 Scenario |
| P4 | D2-001 | 建立 src/ 目錄骨架 + prisma/schema.prisma |
| P4 | D3-001 | 建立 tests/ 框架 + RTP/Jackpot unit tests |

### ⚠️ 建議在 Sprint 1 內解決（HIGH 可自動修復）

- D0-001：執行 `/gendoc readme` 生成 README.md
- D1-H-1：RTM §1.1 BDD 場景數重新計算
- D1-F-3：RTM TC-INT-ROOM-003-S 更新 AC 映射

### 📋 可排入 Backlog（MEDIUM/LOW）

- D1-E-2：age_status ENUM vs TINYINT 設計決策（影響 Schema Migration）
- D5-002：生成 RTM.csv（CI 工具使用）
- D1-B-4：VIP 付費管道正式確認（PRD vs EDD/API 統一）

---

## 附錄：掃描統計

- **文件已掃描**：11 份（BRD, PRD, EDD, ARCH, API, SCHEMA, test-plan, RTM, LOCAL_DEPLOY, RUNBOOK + 8 feature files）
- **BDD Scenarios**：78 個 Scenario（8 個 .feature 檔案，含 Outline 展開約 95 個 test case）
- **PRD AC 總數**：39（P0: 36 / P1: 3）
- **RTM TC 總數**：~80 個
- **實際 BDD 覆蓋率**：約 67%（26/39 AC 有對應 BDD Scenario）
- **src/ 實作進度**：0%（文件設計完整，實作尚未開始）
- **tests/ 覆蓋率**：0%（測試尚未開始）

---

*此報告由 `/gendoc-align-check` 生成，供 `/gendoc-align-fix` 讀取使用。*  
*執行 `/gendoc-align-fix docs` 可修復所有文件層 YES 問題（CRITICAL+HIGH 中可自動修復者）。*
