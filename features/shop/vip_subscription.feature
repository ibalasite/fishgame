# features/shop/vip_subscription.feature
# 來源：PRD US-VIP-001/AC-1,AC-2,AC-3（P1 Should-have）
# Risk Level：Medium（VIP 訂閱涉及鑽石消費和 tier 特權）

Feature: VIP 月費訂閱系統
  作為 有鑽石餘額的遊戲玩家
  我希望 以月費 30 鑽石訂閱 VIP 方案
  以便 享受武器升級和每日補貼等 VIP 特權

  Background:
    Given 資料庫已初始化（clean state）
    And 玩家 "vip-player@example.com" 已登入，age_verified=true，JWT 有效
    And 玩家初始鑽石餘額 100，vip_tier=0（非 VIP）

  # ─── 正常路徑 ───────────────────────────────────────────

  @p1 @smoke @regression @api @contract @TC-E2E-VIP-001-S
  Scenario: 鑽石足夠時成功訂閱 VIP 月費方案
    Given Idempotency-Key="vip-idem-001" 尚未使用
    When 玩家發送 POST /v1/vip/subscriptions，plan_id="vip_monthly"，Idempotency-Key="vip-idem-001"
    Then API 回應狀態碼 201
    And 回應包含 subscription_id，vip_tier=1，expires_at（當前時間 +30 天），diamonds_deducted=30
    And 玩家 diamond_balance 更新為 70
    And 資料庫 users.vip_tier=1，vip_expires_at 正確設定

  @p1 @regression @api @TC-INT-VIP-002-S
  Scenario: VIP 訂閱後可解鎖 VIP 專屬武器升級（US-WPSK-001/AC-4）
    Given 玩家已成功訂閱 VIP，vip_tier=1
    When 玩家在遊戲房間發送 weapon_select，weapon_id="laser_cannon_vip"
    Then 服務端廣播武器升級成功
    And 玩家後續射擊倍率為 VIP 強化值（5x）

  @p1 @regression @api
  Scenario: VIP 訂閱後次日補貼 5 鑽石
    Given 玩家已訂閱 VIP，vip_tier=1，當前鑽石餘額 70
    When 24 小時後系統執行每日補貼 Job
    Then 玩家 diamond_balance 增加 5，餘額更新為 75
    And 資料庫記錄補貼發放記錄

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p1 @regression @api @contract @TC-INT-VIP-003-E
  Scenario: 鑽石不足 30 顆時訂閱 VIP 被拒絕
    Given 玩家 diamond_balance=20（不足 30）
    When 玩家嘗試發送 POST /v1/vip/subscriptions，plan_id="vip_monthly"
    Then API 回應狀態碼 422
    And 回應錯誤碼為 "INSUFFICIENT_DIAMONDS"
    And 鑽石餘額未扣除，vip_tier 未變更

  @p1 @regression @api @contract
  Scenario: 已是活躍 VIP 時重複訂閱返回衝突錯誤
    Given 玩家已訂閱 VIP，vip_expires_at 在未來（訂閱有效）
    When 玩家再次嘗試發送 POST /v1/vip/subscriptions
    Then API 回應狀態碼 422
    And 回應錯誤碼為 "VIP_ALREADY_ACTIVE"
    And 鑽石未扣除

  @p1 @regression @api @contract
  Scenario: 重複的 Idempotency-Key 訂閱返回 409 並回傳原始訂閱
    Given Idempotency-Key="vip-idem-001" 已被成功用於建立訂閱 sub_id="SUB-001"
    When 玩家以相同 Idempotency-Key="vip-idem-001" 再次發送訂閱請求
    Then API 回應狀態碼 409
    And 回應錯誤碼為 "DUPLICATE_SUBSCRIPTION"
    And 回應包含 original_subscription_id="SUB-001"
    And 鑽石未重複扣除

  @p1 @regression @api
  Scenario: 未帶 JWT Token 的訂閱請求被拒絕
    Given 請求未包含 Authorization header
    When 匿名使用者發送 POST /v1/vip/subscriptions
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "UNAUTHORIZED"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p1 @regression @api
  Scenario: VIP 到期後 vip_tier 自動重置為 0
    Given 玩家 vip_tier=1，vip_expires_at 為昨日（已到期）
    When 系統執行每日 VIP 到期檢查 Job
    Then 玩家 vip_tier 更新為 0
    And 玩家下次使用 VIP 專屬功能時被拒絕（"VIP_REQUIRED"）

  @p1 @regression @api
  Scenario Outline: VIP 訂閱前後鑽石餘額邊界驗證
    Given 玩家 diamond_balance=<initial_diamonds>
    When 玩家嘗試訂閱 VIP 月費方案（費用 30 鑽石）
    Then 訂閱結果為 <result>，最終餘額為 <final_balance>

    Examples:
      | initial_diamonds | result  | final_balance |
      | 30               | SUCCESS | 0             |
      | 31               | SUCCESS | 1             |
      | 29               | FAILED  | 29            |
      | 0                | FAILED  | 0             |
