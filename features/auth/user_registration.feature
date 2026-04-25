# features/auth/user_registration.feature
# 來源：PRD US-ACCT-001/AC-1,AC-2；US-AGE-001/AC-1,AC-2
# Risk Level：High（帳號認證為核心安全功能，Scenario 數量加倍）

Feature: 使用者帳號註冊
  作為 遊戲新玩家
  我希望 使用 email 和密碼完成帳號申請
  以便 進入平台進行遊戲和消費

  Background:
    Given 資料庫已初始化（clean state）
    And email "test-new@example.com" 在系統中不存在

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-E2E-ACCT-001-S
  Scenario: 有效帳號資料成功註冊
    Given 使用者備好 email "player-001@example.com"、密碼 "Secure1234!"、顯示名稱 "Player001"、出生日期 "2000-06-15"
    When 使用者提交 POST /v1/auth/register 並帶上 agree_terms=true
    Then API 回應狀態碼 201
    And 回應包含 user_id（非空 UUID 格式）
    And 回應的 email 已部分遮蔽（格式為 "p***@example.com"）
    And 回應包含 age_verified=true
    And 資料庫中存在對應 user 記錄，密碼以 bcrypt rounds=12 儲存

  @p0 @smoke @regression @api @contract @TC-INT-ACCT-002-S
  Scenario: 成功註冊後可以立即登入
    Given email "autotest-reg@example.com" 已透過有效資料完成註冊
    When 使用者以相同 email 和密碼執行 POST /v1/auth/login
    Then API 回應狀態碼 200
    And 回應包含有效的 access_token（JWT，15 分鐘到期）

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract @TC-INT-ACCT-003-E
  Scenario: 重複 email 註冊返回衝突錯誤
    Given email "existing@example.com" 已在系統中存在
    When 使用者嘗試以 email "existing@example.com" 再次提交 POST /v1/auth/register
    Then API 回應狀態碼 409
    And 回應錯誤碼為 "EMAIL_ALREADY_EXISTS"

  @p0 @regression @api @contract @TC-INT-ACCT-017-E
  Scenario: 未勾選同意條款的帳號申請被拒絕
    Given 使用者備好有效的帳號資料
    When 使用者提交 POST /v1/auth/register 但 agree_terms=false
    Then API 回應狀態碼 400
    And 回應包含 VALIDATION_ERROR，欄位指向 agree_terms

  @p0 @regression @api @TC-INT-ACCT-006-E
  Scenario: 已過期 JWT Token 存取受保護資源被拒絕
    Given 使用者持有一個已過期的 JWT access_token
    When 使用者以該 Token 發送 GET /v1/users/:id 請求
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "TOKEN_EXPIRED"

  @p0 @regression @api @TC-INT-ACCT-007-E
  Scenario: 使用者嘗試存取其他使用者的個人資料被禁止
    Given 使用者 A 已登入並持有有效 JWT
    And 系統中存在使用者 B（不同 user_id）
    When 使用者 A 以自己的 Token 存取 GET /v1/users/{userB_id}
    Then API 回應狀態碼 403
    And 回應錯誤碼為 "FORBIDDEN"

  @p0 @regression @api @TC-E2E-AGE-001-S
  Scenario: 18 歲以下使用者嘗試註冊被拒絕（年齡限制）
    Given 使用者出生日期為距今不足 18 年的日期 "2010-01-01"
    When 使用者提交 POST /v1/auth/register 含該出生日期
    Then API 回應狀態碼 422
    And 回應錯誤碼為 "AGE_RESTRICTION"
    And 資料庫中不存在該 email 的 user 記錄

  @p0 @regression @api @TC-INT-AGE-002-S
  Scenario: 18 歲以上使用者年齡驗證自動通過
    Given 使用者出生日期為距今超過 18 年的日期 "2000-01-01"
    When 使用者完成 POST /v1/auth/register
    Then API 回應狀態碼 201
    And 資料庫中 users.age_verified = true

  @p0 @regression @api @TC-INT-AGE-003-E
  Scenario: 未年齡驗證使用者無法進行付費操作
    Given 使用者 age_verified=false（年齡驗證未通過）
    When 使用者嘗試執行 POST /v1/shop/purchases
    Then API 回應狀態碼 403
    And 回應錯誤碼為 "AGE_RESTRICTED"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-UNIT-ACCT-005-B
  Scenario Outline: 帳號欄位格式驗證邊界條件
    Given 系統已就緒，準備接受帳號申請
    When 使用者提交 POST /v1/auth/register，其中 <field> 的值為 "<value>"
    Then API 回應狀態碼 400
    And 回應包含 VALIDATION_ERROR，欄位指向 <field>

    Examples:
      | field        | value               |
      | password     | short               |
      | password     | <超過128字元的密碼>  |
      | email        | not-an-email        |
      | display_name | x                   |
      | birthdate    | 2000-13-01          |

  @p0 @regression @api @TC-INT-ACCT-016-E
  Scenario: Rate Limit — 同一 IP 單分鐘超過 5 次註冊請求返回 429
    Given 同一 IP 在 1 分鐘內已發送 5 次 POST /v1/auth/register
    When 同一 IP 再次發送第 6 次 POST /v1/auth/register
    Then API 回應狀態碼 429
    And 回應包含 Retry-After header
