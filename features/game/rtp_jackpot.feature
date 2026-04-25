# features/game/rtp_jackpot.feature
# 來源：PRD US-RTP-001/AC-1,AC-2,AC-3,AC-4,AC-5
# Risk Level：High（RTP 設計 + Jackpot 觸發 = 直接財務影響，Scenario 數量加倍）

Feature: RTP 引擎與 Jackpot 獎池系統
  作為 遊戲營運方
  我希望 RTP 系統嚴格維持 95%±2% 的長期回報率
  以便 確保遊戲公平性和財務健全性

  Background:
    Given 資料庫已初始化（clean state）
    And Jackpot 獎池初始金額為 10,000 金幣
    And RTP 參數設定：base_rtp=0.95，jackpot_probability=0.001

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-UNIT-RTP-001-S
  Scenario: RTP 引擎長期統計回報率維持在 95%±2%
    Given RTP 引擎設定 base_rtp=0.95
    When 模擬 10,000 局遊戲，計算總投注與總獎勵
    Then 長期 RTP = 總獎勵 / 總投注，範圍在 [93%, 97%]
    And 任何單一房間的 RTP 偏差不超過 ±5%（短期正常浮動）

  @p0 @regression @api @contract @TC-UNIT-RTP-002-S
  Scenario: Jackpot 觸發概率符合 ≤ 0.1% 設定
    Given jackpot_probability=0.001（每局觸發概率）
    When 執行 100,000 次 Jackpot 觸發檢查
    Then 觸發次數在 [50, 150] 之間（期望值 100，3σ 範圍）
    And 每次觸發均會清空獎池並廣播 jackpot_trigger 事件

  @p0 @regression @api @TC-INT-RTP-002-S
  Scenario: 連敗補償機制在連續 10 次未命中後提升命中率
    Given RTP 引擎啟用連敗補償（loss_streak_threshold=10）
    And 玩家已連續 10 次射擊未命中
    When 玩家發送第 11 次 fire 事件
    Then 服務端計算命中率時應用補償係數（boost_factor > 1.0）
    And 本次命中概率不低於 base_hit_rate × 1.5
    And 補償機制在玩家成功命中後重置 loss_streak 計數器

  @p0 @regression @api @TC-UNIT-RTP-003-S
  Scenario: Jackpot 獎池金額正確累積（3% 投注比例）
    Given Jackpot 獎池初始金額 10,000
    And 玩家 A 投注 1,000 金幣，玩家 B 投注 2,000 金幣
    When 兩局遊戲結束後查詢獎池金額
    Then 獎池金額 = 10,000 + (1,000 × 3%) + (2,000 × 3%) = 10,090
    And GET /v1/admin/game-config 返回 jackpot_min_pool 相關欄位，且獎池累積金額為 10090

  @p0 @regression @api @contract @TC-INT-RTP-004-S
  Scenario: Jackpot 觸發時玩家獲得全額獎池並獎池重置
    Given 獎池金額 50,000，本局觸發 Jackpot
    When 服務端廣播 jackpot_trigger 事件
    Then 觸發玩家獲得 50,000 金幣獎勵
    And 獎池重置為最低基礎值（如 10,000）
    And 所有房間玩家均收到 jackpot_trigger 廣播事件

  @p0 @regression @api @TC-INT-RTP-005-S
  Scenario: Admin 調整 RTP 參數後 15 分鐘內生效
    Given Admin 已登入並持有 admin 角色 JWT
    When Admin 發送 PATCH /v1/admin/game-config，調整 base_rtp=0.92
    Then API 回應狀態碼 200
    And 15 分鐘後新的遊戲局使用 base_rtp=0.92 計算
    And 資料庫 game_configs 記錄更新時間

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract @TC-INT-RTP-005-E
  Scenario: RTP Health Check 失敗後系統降級為 80% 保底 RTP
    Given RTP 引擎健康檢查端點連續 3 次回應超時或 500 錯誤
    When 新一局遊戲開始，FishSpawnService 嘗試取得 RTP 參數
    Then 系統降級為保底 base_rtp=0.80（最低安全 RTP）
    And 服務端發出告警事件（rtp_health_check_failed）
    And 告警通知 ops 人員，包含最近 3 次失敗時間戳

  @p0 @regression @api @contract @TC-INT-RTP-006-E
  Scenario: 非 Admin 角色嘗試修改 RTP 參數被拒絕
    Given 普通玩家（role=player）已登入並持有 JWT
    When 普通玩家嘗試發送 PATCH /v1/admin/game-config
    Then API 回應狀態碼 403
    And 回應錯誤碼為 "FORBIDDEN"
    And RTP 參數未被修改

  @p0 @regression @api @contract @TC-INT-RTP-007-E
  Scenario: RTP 參數超出有效範圍（< 80% 或 > 99%）被拒絕
    Given Admin 已登入
    When Admin 嘗試設定 base_rtp=0.79（低於最低限制 0.80）
    Then API 回應狀態碼 422
    And 回應錯誤碼為 "RTP_OUT_OF_RANGE"
    And 回應說明有效範圍 [0.80, 0.99]

  @p0 @regression @api @TC-INT-RTP-008-B
  Scenario: Jackpot 觸發時 Redis 原子操作確保僅一位玩家獲得獎池
    Given 獎池金額 100,000，同時 100 個房間各有觸發請求
    When Redis GETSET 原子操作執行
    Then 只有一個房間的玩家取得獎池獎勵
    And 其他 99 個觸發請求獲得 jackpot_amount=0

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-RTP-009-B
  Scenario Outline: RTP 參數邊界值驗證
    Given Admin 已登入
    When Admin 嘗試設定 base_rtp=<value>
    Then API 回應狀態碼 <expected_status>

    Examples:
      | value | expected_status |
      | 0.80  | 200             |
      | 0.95  | 200             |
      | 0.99  | 200             |
      | 0.79  | 422             |
      | 1.00  | 422             |
