# features/client/shop_ui.feature
# 來源：PRD US-SHOP-001；PDD §5.6 ShopScene；VDD §2.5 商店場景美術規格；
# PDD §4.3.1 IAP 支付失敗流程；FRONTEND.md §6 dialogs/ShopDialog.ts
# Client 層面：商城開啟動畫、套餐卡片顯示、購買確認、成功動畫、失敗狀態

Feature: 商城 UI
  作為遊戲玩家
  我希望能在直覺的商城介面中快速選擇並完成鑽石充值
  以便在 3 步驟內完成付費並繼續遊戲

  Background:
    Given 玩家已登入（JWT token 有效）
    And 玩家年齡驗證通過（18+ 確認）
    And 網路連線正常

  # ─── 商城開啟動畫 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 點擊商城入口後商城以 Slide Up 動畫開啟
    Given 玩家在大廳（LobbyScene）或遊戲 HUD 點擊商城圖示
    When ShopDialog.open() 被呼叫
    Then ShopDialog 以 Slide Up 動畫（Tween translateY：屏幕高度→0，300ms，ease-out）出現
    And 背景遊戲場景以半透明遮罩覆蓋（color-bg-overlay：rgba(5,20,40,0.85) + backdrop-blur 8px）
    And 商城面板使用 VDD 商店場景底色（暗金色 #0F0A00，燈光舞台感）
    And 動畫完成後商品卡片區域可見

  @client @p0 @interaction
  Scenario: 商城關閉後 Slide Down 動畫退出
    Given 商城 ShopDialog 已開啟
    When 玩家點擊右上角關閉按鈕（Icon Button，×）或點擊遮罩
    Then ShopDialog 以 Slide Down 動畫（Tween translateY：0→屏幕高度，250ms，ease-in）消失
    And 背景遮罩同時 Fade Out（250ms）
    And 背景遊戲場景恢復清晰（blur 移除）

  # ─── IAP 套餐卡片顯示 ──────────────────────────────────────────

  @client @p0 @visual
  Scenario: 商城正確顯示所有鑽石充值套餐卡片
    Given ShopDialog 已開啟，API 取得套餐列表成功
    When 商城內容區域載入完成
    Then 顯示小額 / 中額 / 大額三種以上充值套餐卡片
    And 每張卡片顯示：鑽石數量 / 原價 / 特惠價 / 套餐名稱
    And 卡片使用 VDD shop-card 規格（rgba(15,10,0,0.9) 底色，1px 金色邊框，24px 圓角）
    And 推薦套餐（最高價值感）以高亮面板（2px color-gold-400 邊框）凸顯
    And 卡片上方顯示浮動金幣粒子環境動畫

  @client @p1 @visual
  Scenario: 特惠套餐顯示倒數計時標籤
    Given 當前有限時特惠套餐（有效期剩餘 2 小時）
    When 商城卡片渲染
    Then 限時套餐卡片右上角顯示「限時優惠」紅色角標
    And 角標包含倒數計時（font-family-mono，text-caption 12px，color-feedback-error #FF4444）
    And 倒數計時每秒更新（精度：分鐘:秒）

  @client @p0 @visual
  Scenario: VIP 訂閱入口在商城中高亮顯示
    Given ShopDialog 已開啟
    When 商城內容完整渲染
    Then VIP 訂閱卡片位於商城頂部或顯眼位置
    And VIP 卡片使用高亮面板（2px color-gold-400 邊框 + shadow-glow）
    And 「VIP 月費訂閱」標題使用 text-h2（24px / font-weight-600）+ color-gold-400
    And 「立即訂閱」按鈕使用 Primary Button 規格（#F5C842 金色，56px 高）

  # ─── 購買確認流程 ─────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 點擊購買套餐後顯示確認 Modal（Step 2：確認）
    Given 商城 ShopDialog 已開啟，顯示多個套餐卡片
    When 玩家點擊某套餐的「購買」按鈕（Primary Button）
    Then 確認 ConfirmDialog 以淡入動畫（Fade In 200ms）顯示
    And 確認 Modal 顯示：套餐名稱 / 鑽石數量 / 最終支付金額
    And 提供「確認購買」Primary Button 和「取消」Secondary Button
    And 兩按鈕均符合 VDD 觸控熱區規格（≥ 44×44 px）

  @client @p0 @interaction
  Scenario: 點擊取消後確認 Modal 關閉不執行購買
    Given 確認 ConfirmDialog 已顯示
    When 玩家點擊「取消」Secondary Button
    Then ConfirmDialog 以 Fade Out（200ms）關閉
    And 返回商城列表（ShopDialog 仍開啟）
    And 不呼叫任何 IAP API

  # ─── 購買成功動畫 ─────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 確認購買後按鈕進入 Loading 狀態（Step 3：等待）
    Given 確認 ConfirmDialog 已顯示，玩家點擊「確認購買」
    When IAP API 呼叫進行中
    Then 「確認購買」按鈕文字替換為 Loading Spinner（按鈕 scale 0.95，100ms press 動畫）
    And 按鈕進入 Disabled 狀態（防止重複點擊）
    And ConfirmDialog 背景遮罩保持

  @client @p0 @visual
  Scenario: IAP 購買成功後顯示鑽石發放動畫
    # PDD §4.3.1：支付成功 → 後端收據驗證 → 發放鑽石 → Toast「鑽石已到帳 +XXX」
    Given 玩家確認購買，IAP 支付成功，後端鑽石發放完成
    When 客戶端收到鑽石發放確認（REST API 回應或 Colyseus 事件）
    Then ConfirmDialog 關閉，ShopDialog 也關閉
    And 鑽石圖示從商城卡片位置飛向 HUD 鑽石餘額位置（Tween 弧線飛行，500ms）
    And HUD 鑽石餘額數字以 Tween 滾動動畫更新至新數值（300ms）
    And Toast 顯示「鑽石已到帳 +{數量}」（color-feedback-success #00FF88，3s）
    And 購買成功音效觸發（金幣叮噹聲）

  # ─── 購買失敗 / 錯誤狀態 ─────────────────────────────────────

  @client @p0 @interaction
  Scenario: IAP 支付失敗後顯示錯誤 Modal（非 Toast）
    # PDD §4.3.1：支付失敗使用 Modal（需明確回應），錯誤文字友好語氣
    Given 玩家確認購買，但 IAP 支付失敗（AppStore/Google Play 回傳錯誤）
    When 客戶端收到支付失敗事件
    Then 顯示錯誤 Modal（Fade In 200ms）：「付款遇到一點問題，請重試」
    And Modal 提供「重試」Primary Button 和「取消」Secondary Button
    And Modal 顯示訂單參考號（text-caption，color-text-secondary）供客服使用
    And 不清空玩家已選套餐，方便重試

  @client @p0 @interaction
  Scenario: 點擊重試後再次觸發 IAP 支付流程
    Given IAP 錯誤 Modal 正在顯示
    When 玩家點擊「重試」按鈕
    Then 錯誤 Modal 關閉
    And 重新呼叫 IAP API（相同訂單參數）
    And 「確認購買」按鈕再次進入 Loading 狀態

  @client @p1 @interaction
  Scenario: 後端收據驗證失敗時顯示異常訂單提示
    # PDD §4.3.1：後端收據驗證失敗 → 「訂單異常，請聯絡客服」+ 訂單號
    Given IAP 支付成功但後端收據驗證失敗
    When 客戶端收到驗證失敗事件
    Then 顯示 Modal「訂單異常，請聯絡客服」
    And Modal 顯示訂單編號（方便客服追蹤）
    And 提供「聯絡客服」按鈕（Secondary Button，連結至客服頁面）

  # ─── 網路錯誤狀態 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 商城套餐列表載入中顯示骨架屏
    Given ShopDialog 開啟，API 請求尚未完成
    When ShopDialog 內容區域處於載入中狀態
    Then 商品卡片區域顯示骨架佔位動畫（3 張卡片大小的灰色 Skeleton）
    And 骨架使用 shimmer 光效（左→右，1.5s loop）

  @client @p1 @interaction
  Scenario: 商城套餐列表 API 請求失敗時顯示重試入口
    Given ShopDialog 開啟，API 回傳 503 或逾時
    When 套餐列表載入失敗
    Then 商品卡片區域顯示「載入失敗」空態圖示（灰色圖示 + 說明文字）
    And 提供「重新載入」Secondary Button
    And 點擊後重新發送 API 請求並再次顯示骨架屏

  # ─── 演示模式（未成年用戶）──────────────────────────────────

  @client @p1 @visual
  Scenario: 演示模式下商城入口顯示鎖定狀態
    # PDD §4.3.2：演示模式 IAP 入口以灰色鎖定狀態顯示
    Given 玩家年齡驗證為未滿 18 歲（演示模式）
    When 玩家點擊商城圖示
    Then 不開啟 ShopDialog
    And 顯示 Toast「演示模式無法購買，請以成人身份登入」（color-text-secondary，2s）
    And 商城圖示以灰色 + 掛鎖 Overlay 顯示（Disabled 狀態）
