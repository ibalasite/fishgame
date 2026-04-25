# features/client/login_ui.feature
# 來源：PRD US-ACCT-001；PDD §5.1 LoginScene；VDD §5.3 按鈕規格 / §5.4 輸入欄位規格
# FRONTEND.md §6 scenes/LoginScene.scene；HttpClient.ts
# Client 層面：登入表單驗證、Loading 狀態、成功跳轉、失敗訊息、社交登入、欄位焦點樣式

Feature: 登入 / 註冊 UI
  作為遊戲新玩家或回訪玩家
  我希望在登入畫面快速完成身份驗證並進入遊戲
  以便不因繁瑣的帳號流程影響遊戲體驗

  # LoginScene 四態：空態（初始未填）/ 加載中（API 等待）/ 錯誤（驗證失敗）/ 成功（跳轉大廳）

  Background:
    Given 玩家進入 LoginScene（應用程式啟動或登出後）
    And LoginScene 已完整渲染（Background、LogoArea、FormPanel 均可見）

  # ─── 初始空態 ─────────────────────────────────────────────────

  @client @p0 @visual
  Scenario: LoginScene 初始載入時顯示完整表單結構（空態）
    When LoginScene 首次渲染
    Then 遊戲 LOGO 動態粒子效果可見（LogoArea/LogoImage，240×80 px）
    And 副標題「多人競技捕魚街機」以 text-h2（24px）顯示
    And Email 輸入框（FormPanel/EmailInput）顯示 Placeholder「請輸入 Email」
    And 密碼輸入框（FormPanel/PasswordInput）顯示 Placeholder「請輸入密碼」，預設遮罩（●●●）
    And 「登入」Primary Button 處於 Default 狀態（可點擊）
    And 「訪客模式」Secondary Button 可見
    And 底部「還沒有帳號？立即註冊」連結可見

  # ─── 表單欄位焦點樣式 ─────────────────────────────────────────

  @client @p0 @visual
  Scenario: Email 輸入框獲得焦點後邊框變為金色（Focus State）
    # VDD §5.4 輸入欄位 Focus 狀態：2px solid color-border-focus (#F5C842)
    Given LoginScene 已顯示
    When 玩家點擊（Tap）Email 輸入框
    Then Email EditBox 顯示 Focus 狀態：
      - 邊框加粗為 2px solid color-border-focus（#F5C842，金色）
      - 背景微亮 rgba(255,255,255,0.08)
    And 輸入框軟體鍵盤自動彈出（Cocos EditBox onEditingDidBegin）
    And 動畫切換至 Focus 狀態（150ms Tween border-color）

  @client @p0 @visual
  Scenario: Email 輸入框失焦且格式不合法時顯示 Error 狀態
    # VDD §5.4 Error 狀態：2px solid color-border-error (#FF4444)
    Given 玩家在 Email 輸入框輸入「not-an-email」
    When 玩家點擊其他區域（離開 Email 輸入框，onEditingDidEnd）
    Then Email 輸入框邊框切換為 2px solid color-border-error（#FF4444，150ms）
    And 輸入框下方顯示 Inline 錯誤文字「請輸入有效的 Email 格式」（text-body-sm，color-feedback-error）
    And ErrorLabel（FormPanel/ErrorLabel）Fade In（200ms）

  @client @p0 @visual
  Scenario: 密碼輸入框顯示/隱藏密碼切換按鈕
    Given 密碼輸入框顯示遮罩（●●●）
    When 玩家點擊密碼輸入框右側眼睛圖示按鈕
    Then 密碼文字切換為明文顯示（EditBox inputFlag 改變）
    And 眼睛圖示切換為「眼睛劃線」圖示（表示隱藏已關閉）
    When 玩家再次點擊眼睛按鈕
    Then 密碼恢復遮罩顯示（●●●）

  # ─── 登入按鈕 Loading 狀態 ────────────────────────────────────

  @client @p0 @interaction
  Scenario: 點擊登入按鈕後進入 Loading 狀態（防止重複提交）
    Given Email 輸入「user@example.com"，密碼輸入 "Password123"
    When 玩家點擊「登入」Primary Button
    Then 按鈕播放 Press 動畫（scale 0.95，100ms）
    And 按鈕文字替換為 Loading Spinner（旋轉圓環圖示）
    And 按鈕進入 Disabled 狀態（VDD Disabled：opacity 0.5，cursor not-allowed）
    And Email / 密碼輸入框也進入 Disabled 狀態（防止修改）
    And API 請求呼叫（HttpClient POST /v1/auth/login）

  # ─── 登入成功跳轉 ──────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 登入成功後以 Fade Out/In 過渡跳轉至大廳
    Given 玩家已填入有效 Email 和密碼並點擊登入
    When API 回傳 JWT Token（HTTP 200）
    Then 登入按鈕 Loading 狀態解除
    And 整體 LoginScene 以 Fade Out 動畫（300ms）消失
    And LobbyScene 以 Fade In 動畫（300ms）出現
    And LobbyScene 顯示正確的金幣和鑽石餘額（從 API 回應中載入）

  @client @p0 @interaction
  Scenario: 記住登入態後重新開啟 App 自動跳過 LoginScene
    Given 玩家前次成功登入且 Refresh Token 仍有效（7 天內）
    When 玩家重新啟動 App 進入 LoginScene
    Then GameBootstrap 偵測到有效 Refresh Token（StorageUtils.getToken）
    And 自動執行 Silent Login（HttpClient 使用 Refresh Token 刷新 Access Token）
    And LoginScene 不顯示（直接 Fade In LobbyScene，300ms）

  # ─── 登入失敗 / 錯誤狀態 ─────────────────────────────────────

  @client @p0 @interaction
  Scenario: 登入失敗時按鈕恢復可點擊並顯示 Inline 錯誤
    Given 玩家輸入錯誤密碼（API 回傳 HTTP 401）
    When API 回應到達客戶端
    Then 「登入」按鈕恢復 Default 狀態（Spinner 消失，文字恢復「登入」）
    And Email / 密碼輸入框恢復 Enabled 狀態
    And FormPanel/ErrorLabel 顯示「Email 或密碼不正確，請重試」（Fade In 200ms）
    And ErrorLabel 文字顏色 color-feedback-error（#FF4444）
    And 密碼輸入框自動清空（保留 Email 輸入）

  @client @p0 @interaction
  Scenario: 帳號被鎖定後顯示鎖定時間提示
    # PRD AC-4：5 次失敗後鎖定 15 分鐘
    Given 玩家連續登入失敗 5 次（API 回傳 HTTP 423 Locked）
    When 第 5 次 API 回應到達
    Then ErrorLabel 顯示「登入嘗試次數過多，帳號已暫時鎖定，請 15 分鐘後重試」
    And 「登入」按鈕進入 Disabled 狀態並顯示倒數計時（15:00 倒數，font-family-mono）
    And 倒數計時每秒更新（精度：分鐘:秒）
    And 倒數歸零後按鈕自動恢復 Default 狀態

  @client @p0 @interaction
  Scenario: 表單驗證：Email 為空時點擊登入顯示必填提示
    Given Email 輸入框為空，密碼已填
    When 玩家點擊「登入」按鈕
    Then 不發送任何 API 請求
    And Email 輸入框切換為 Error 狀態（2px solid #FF4444）
    And 顯示 Inline 錯誤「Email 不得為空」

  @client @p0 @interaction
  Scenario: 表單驗證：密碼為空時點擊登入顯示必填提示
    Given Email 已填，密碼輸入框為空
    When 玩家點擊「登入」按鈕
    Then 不發送任何 API 請求
    And 密碼輸入框切換為 Error 狀態
    And 顯示 Inline 錯誤「密碼不得為空」

  # ─── 訪客模式 ──────────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 點擊訪客模式快速進入（限制付費功能）
    # PRD AC-5（Boundary）：遊客模式不允許購買鑽石或 VIP
    Given LoginScene 顯示訪客模式按鈕（Secondary CTA）
    When 玩家點擊「訪客模式」按鈕
    Then 按鈕進入 Loading 狀態（Spinner）
    And API 建立臨時遊客帳號（POST /v1/auth/guest）
    And 成功後跳轉至 LobbyScene（Fade Out/In，300ms）
    And LobbyScene 的商城圖示顯示鎖定狀態（Disabled + 掛鎖圖示）

  # ─── 網路錯誤狀態 ─────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 登入 API 請求逾時後顯示網路錯誤提示
    Given 玩家填入有效帳密並點擊登入，但網路請求逾時（> 10s）
    When HttpClient 觸發 timeout 事件
    Then 「登入」按鈕恢復 Default 狀態
    And ErrorLabel 顯示「網路連線不穩，請確認網路後重試」
    And 顯示「重試」連結（可再次點擊觸發登入）

  # ─── 社交登入按鈕 ──────────────────────────────────────────────

  @client @p2 @visual
  Scenario: 登入頁面顯示社交登入選項（Google / LINE）
    Given LoginScene 已渲染
    When 頁面分隔線「或」下方區域可見
    Then 顯示 Google 登入按鈕（Google 官方標誌 + 白底，Secondary Button 規格）
    And 顯示 LINE 登入按鈕（LINE 綠色品牌色 + 白字，Secondary Button 規格）
    And 按鈕觸控熱區 ≥ 44×44 px（VDD 圖示按鈕規格）

  @client @p2 @interaction
  Scenario: 社交登入按鈕點擊後開啟對應 OAuth 流程
    Given LoginScene 社交登入按鈕可見
    When 玩家點擊 Google 登入按鈕
    Then 開啟 WebView 或系統瀏覽器顯示 Google OAuth 授權頁面
    And 登入按鈕進入 Loading 狀態（等待 OAuth 回調）
