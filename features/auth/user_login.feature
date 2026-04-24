# features/auth/user_login.feature
# 來源：PRD US-ACCT-001/AC-3,AC-4,AC-5
# Risk Level：High（認證安全核心，Scenario 數量加倍）

Feature: 使用者帳號登入與 JWT 認證
  作為 已註冊的遊戲玩家
  我希望 使用 email 和密碼安全登入
  以便 取得 JWT Token 進行後續遊戲操作

  Background:
    Given 資料庫已初始化（clean state）
    And 系統中存在有效帳號 email "player-login@example.com"，密碼 "Valid1234!"，age_verified=true

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract
  Scenario: 有效憑證成功登入並取得雙 Token
    Given 帳號 "player-login@example.com" 存在且未被鎖定
    When 使用者提交 POST /v1/auth/login，email="player-login@example.com"，password="Valid1234!"
    Then API 回應狀態碼 200
    And 回應包含 access_token（JWT，到期時間 15 分鐘）
    And 回應包含 refresh_token（JWT，到期時間 30 天）
    And 資料庫 users.last_login_at 已更新為當前時間

  @p0 @smoke @regression @api @contract
  Scenario: 使用 Refresh Token 無縫更換 Access Token
    Given 使用者持有有效的 refresh_token（未過期）
    When 使用者提交 POST /v1/auth/refresh，帶上 refresh_token
    Then API 回應狀態碼 200
    And 回應包含新的 access_token（有效期重置為 15 分鐘）
    And 舊的 refresh_token 已作廢（replay attack prevention）

  @p0 @regression @api @contract
  Scenario: 成功登出後 Refresh Token 作廢
    Given 使用者已登入，持有有效的 access_token 和 refresh_token
    When 使用者提交 POST /v1/auth/logout，帶上 access_token
    Then API 回應狀態碼 200
    And 嘗試以已登出的 refresh_token 執行 POST /v1/auth/refresh 返回狀態碼 401

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract
  Scenario: 錯誤密碼登入返回認證失敗
    Given 帳號 "player-login@example.com" 存在
    When 使用者提交 POST /v1/auth/login，password="WrongPass!"
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "INVALID_CREDENTIALS"
    And 回應不洩漏帳號是否存在

  @p0 @regression @api @contract
  Scenario: 不存在的 email 登入返回認證失敗
    Given email "ghost@example.com" 在系統中不存在
    When 使用者提交 POST /v1/auth/login，email="ghost@example.com"
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "INVALID_CREDENTIALS"
    And 回應與密碼錯誤的訊息完全相同（防止帳號枚舉攻擊）

  @p0 @regression @api @contract @TC-INT-ACCT-004-E
  Scenario: 24 小時內同一 IP 超過 100 次登入嘗試觸發 Rate Limit
    Given 同一 IP 在過去 24 小時內已嘗試登入 100 次
    When 該 IP 再次提交 POST /v1/auth/login
    Then API 回應狀態碼 429
    And 回應包含 Retry-After header，時間 ≥ 3600 秒
    And 回應錯誤碼為 "RATE_LIMITED"

  @p0 @regression @api @contract
  Scenario: 以撤銷的 Refresh Token 刷新 Token 被拒絕
    Given 使用者的 refresh_token 已被撤銷（已登出或已使用一次）
    When 使用者以該 refresh_token 提交 POST /v1/auth/refresh
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "TOKEN_REVOKED"

  @p0 @regression @api
  Scenario: 無 Token 存取受保護端點被拒絕
    Given 使用者未攜帶任何 Authorization header
    When 使用者發送 GET /v1/users/some-user-id
    Then API 回應狀態碼 401
    And 回應錯誤碼為 "UNAUTHORIZED"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api
  Scenario Outline: JWT Token 有效期邊界條件
    Given 使用者取得了 <token_type>
    And Token 在 <elapsed_time> 後被使用
    When 使用者以該 Token 存取受保護端點
    Then API 回應狀態碼為 <expected_status>

    Examples:
      | token_type    | elapsed_time | expected_status |
      | access_token  | 14 分鐘      | 200             |
      | access_token  | 16 分鐘      | 401             |
      | refresh_token | 29 天        | 200             |
      | refresh_token | 31 天        | 401             |
