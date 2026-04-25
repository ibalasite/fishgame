# features/shop/iap_purchase.feature
# 來源：PRD US-SHOP-001/AC-1,AC-2,AC-3,AC-4,AC-5,AC-6
# Risk Level：Critical（IAP 充值直接涉及真實金錢，Scenario 數量加倍）

Feature: IAP 鑽石充值與金幣兌換
  作為 已年齡驗證的遊戲玩家
  我希望 透過 Apple/Google IAP 購買鑽石並兌換金幣
  以便 取得遊戲內資源進行消費

  Background:
    Given 資料庫已初始化（clean state）
    And 玩家 "shopper@example.com" 已登入，age_verified=true，JWT 有效
    And 玩家初始鑽石餘額 0，金幣餘額 0
    And Apple IAP 服務 mock 已就緒（verifyReceipt stub）

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-E2E-SHOP-001-S
  Scenario: Apple IAP 收據驗證成功後鑽石即時到帳
    Given Apple IAP mock 回應 {status:0, product_id:"diamonds_330", transaction_id:"TX-001"}
    And Idempotency-Key="idem-key-001" 尚未使用
    When 玩家發送 POST /v1/shop/purchases，platform="apple"，product_id="diamonds_330"，receipt="valid_receipt"，idempotency_key="idem-key-001"
    Then API 回應狀態碼 201
    And 回應包含 order_id，status="completed"，diamonds_credited=330
    And GET /v1/users/:id/balance 顯示 diamond_balance=330
    And 資料庫 orders 記錄狀態為 "completed"

  @p0 @smoke @regression @api @TC-INT-SHOP-002-S
  Scenario: 鑽石兌換金幣匯率 1:10
    Given 玩家 diamond_balance=50
    When 玩家執行鑽石兌換操作，兌換 50 鑽石
    Then 玩家 diamond_balance 減少 50（變為 0）
    And 玩家 coin_balance 增加 500（50 × 10）
    And 兌換操作在 1 秒內完成

  @p0 @regression @api @TC-INT-SHOP-003-S
  Scenario: Google Play IAP 收據驗證成功後鑽石到帳
    Given Google Play IAP mock 回應驗證成功，product_id="diamonds_50"
    When 玩家發送 POST /v1/shop/purchases，platform="google"，receipt="valid_google_receipt"
    Then API 回應狀態碼 201
    And 回應 diamonds_credited=50
    And 玩家 diamond_balance 更新為 50

  @p0 @regression @api @TC-INT-SHOP-004-S
  Scenario: 充值後金幣餘額即時更新，可立即使用
    Given 玩家透過 IAP 成功充值獲得 330 鑽石，並兌換為 3,300 金幣
    When 玩家立即使用 300 金幣購買武器
    Then 武器購買成功，coin_balance=3,000

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract @TC-INT-SHOP-003-B
  Scenario: 重複的 Idempotency-Key 返回 409 並回傳原始訂單
    Given Idempotency-Key="idem-key-001" 已被成功使用，對應 order_id="ORD-001"
    When 玩家以相同 Idempotency-Key="idem-key-001" 再次發送 POST /v1/shop/purchases
    Then API 回應狀態碼 409
    And 回應錯誤碼為 "DUPLICATE_ORDER"
    And 回應包含 original_order_id="ORD-001"
    And 鑽石未重複發放

  @p0 @regression @api @contract @TC-INT-SHOP-010-E
  Scenario: 偽造 IAP 收據返回收據無效錯誤
    Given Apple IAP mock 回應 {status:21002}（收據格式錯誤）
    When 玩家發送 POST /v1/shop/purchases，附上偽造 receipt
    Then API 回應狀態碼 422
    And 回應錯誤碼為 "IAP_RECEIPT_INVALID"
    And 訂單未建立，鑽石未發放

  @p0 @regression @api @contract @TC-INT-SHOP-007-E
  Scenario: 未攜帶 JWT Token 的充值請求被拒絕
    Given 請求未包含 Authorization header
    When 匿名使用者發送 POST /v1/shop/purchases
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "UNAUTHORIZED"

  @p0 @regression @api @contract @TC-INT-SHOP-005-E
  Scenario: IAP Circuit Breaker 觸發後返回服務不可用
    Given Apple IAP 服務連續失敗次數已超過 Circuit Breaker 閾值
    When 玩家發送 POST /v1/shop/purchases
    Then API 回應狀態碼 503
    And 回應錯誤碼為 "IAP_SERVICE_UNAVAILABLE"
    And 回應包含 retry_after=30（秒）

  @p0 @regression @api @contract @TC-INT-SHOP-006-E
  Scenario: 退款 webhook 將訂單標記為 REFUNDED
    Given 訂單 "ORD-002" 狀態為 "completed"，已發放 330 鑽石
    When Apple 發送退款 webhook，transaction_id 對應 "ORD-002"
    Then 資料庫 orders.status 更新為 "REFUNDED"
    And 玩家 diamond_balance 相應扣除 330（若仍有足夠餘額）

  @p0 @regression @api @TC-INT-AGE-004-E
  Scenario: 年齡驗證未通過的用戶無法進行充值
    Given 玩家 age_verified=false
    When 玩家嘗試發送 POST /v1/shop/purchases
    Then API 回應狀態碼 403
    And 回應錯誤碼為 "AGE_RESTRICTED"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-SHOP-008-B
  Scenario Outline: 不同充值方案的鑽石數量驗證
    Given Apple IAP mock 回應 product_id="<product_id>" 驗證成功
    When 玩家發送 POST /v1/shop/purchases，product_id="<product_id>"
    Then API 回應 diamonds_credited=<diamonds>

    Examples:
      | product_id      | diamonds |
      | diamonds_50     | 50       |
      | diamonds_330    | 330      |
      | diamonds_1680   | 1680     |
      | diamonds_5800   | 5800     |

  @p0 @regression @api @TC-INT-SHOP-009-E
  Scenario: Rate Limit — 同一用戶 1 分鐘內超過 5 次充值請求返回 429
    Given 玩家 1 分鐘內已發送 5 次 POST /v1/shop/purchases
    When 玩家發送第 6 次請求
    Then API 回應狀態碼 429
    And 回應包含 Retry-After header
