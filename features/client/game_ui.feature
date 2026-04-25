# features/client/game_ui.feature
# 來源：PRD US-FISH-001, US-ROOM-001；PDD §5.4 GameScene HUD；VDD §5.x；FRONTEND.md §6 UI/UX 實作
# Client 層面：Cocos Creator HUD 顯示狀態、貨幣動畫、連線指示、玩家狀態

Feature: 遊戲 HUD 顯示
  作為一名玩家
  我希望在遊戲中看到清晰且即時更新的 HUD 資訊
  以便隨時掌握我的金幣餘額、排名與遊戲狀態

  # HUD 四態：空態（等待中）/ 加載中 / 正常遊戲中 / 錯誤（中斷）

  Background:
    Given 玩家已登入且位於遊戲房間中
    And 遊戲房間狀態為 "PLAYING"
    And Colyseus WebSocket 連線狀態為 "connected"

  # ─── 金幣餘額顯示 ────────────────────────────────────────────

  @client @p0 @visual
  Scenario: HUD 顯示玩家金幣餘額（正常態）
    When 玩家進入遊戲房間
    Then HUDComponent/CoinLabel 顯示玩家當前金幣餘額
    And 金幣餘額以千分位格式顯示（例如 "1,500"）
    And 金幣圖示（24×24 px Sprite）可見，使用 VDD token "--color-gold-400"（#F5C842）
    And 金幣 Label 字型使用 "text-hud-counter"（20px / font-weight-600）

  @client @p0 @interaction
  Scenario: 金幣增加滾動動畫（Tween 更新）
    Given 玩家當前金幣為 "1000"
    When 玩家擊殺一條魚獲得 "500" 金幣（Colyseus state patch 到達）
    Then HUD 金幣數字以 Tween 滾動動畫從 "1000" 更新至 "1,500"
    And 動畫時長符合 VDD "--duration-normal"（300ms）
    And 滾動動畫使用 easing expo-out
    And 動畫完成後數字靜止顯示 "1,500"

  @client @p0 @visual
  Scenario: HUD 顯示鑽石餘額
    When 玩家進入遊戲房間
    Then HUDComponent/DiamondLabel 顯示玩家鑽石餘額
    And 鑽石圖示（24×24 px）可見，顏色使用 VDD token "--color-neon-blue"（#00D4FF）
    And 鑽石 Label 字型使用 "text-hud-counter"

  @client @p0 @visual
  Scenario: HUD 顯示當前武器等級
    When 玩家進入遊戲房間
    Then HUDComponent/WeaponLevelLabel 顯示當前武器倍率（例如 "×3"）
    And 武器圖示（64×64 px）顯示對應武器類型（基礎砲 / 雷射炮 / 散射炮 / 鎖定炮）
    And 武器等級文字使用 "text-h3"（20px / font-weight-600）

  @client @p0 @visual
  Scenario: HUD 顯示玩家名稱與即時排名
    When 玩家進入遊戲房間
    Then HUDComponent/PlayerNameLabel 顯示玩家帳號名稱
    And HUDComponent/RankLabel 顯示當前局內排名（例如 "No.1"）
    And 排名文字顏色：第 1 名使用 "--color-gold-400"，其他使用 "--color-text-secondary"

  @client @p1 @interaction
  Scenario: 排名變化時即時更新動畫
    Given 玩家當前排名為 "No.2"
    When 玩家超越對手排名上升為 "No.1"（Colyseus state 更新）
    Then HUDComponent/RankLabel 以閃爍動畫（脈衝 2 次，200ms）更新至 "No.1"
    And 排名文字切換為 "--color-gold-400" 金色

  # ─── 連線狀態指示 ────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 連線中斷時顯示重連覆層
    Given 玩家正在遊戲中
    When Colyseus WebSocket 連線中斷（NetworkManager 偵測到 onLeave 事件）
    Then HUD 顯示「連線中斷，嘗試重連...」覆層（半透明遮罩 + 進度 Spinner）
    And 遮罩背景使用 VDD "--modal-overlay"（rgba(5,20,40,0.85) + backdrop-blur 8px）
    And 遊戲場景畫面模糊（blur 4px）
    And 玩家無法進行射擊操作

  @client @p0 @interaction
  Scenario: 5 秒內重連成功後恢復遊戲
    Given HUD 正顯示「連線中斷，嘗試重連...」覆層
    When NetworkManager 在 5 秒內成功重新建立 WebSocket 連線
    Then 覆層以 Fade Out 動畫（300ms）消失
    And 遊戲場景恢復清晰並繼續
    And HUD 所有數值同步 Colyseus 最新 state

  @client @p0 @interaction
  Scenario: 超過 5 秒未重連後顯示斷線彈窗
    Given HUD 正顯示重連覆層，已過 5 秒仍未成功
    When NetworkManager 觸發連線永久中斷判定
    Then 顯示 Modal 彈窗「已中斷連線，本局結果已儲存」
    And Modal 提供「返回大廳」按鈕（Primary Button）
    And 點擊後跳轉至 LobbyScene

  @client @p1 @visual
  Scenario: 載入狀態（正在進入房間）
    When 玩家從配對完成進入 GameScene 載入過程中
    Then HUD 所有元件以骨架佔位（Skeleton Loading 動畫）呈現
    And LoadingComponent 顯示全屏旋轉 Spinner
    And 背景顯示深海場景靜態底圖

  # ─── FPS 計數器（開發模式）────────────────────────────────

  @client @p2 @visual
  Scenario: 開發模式顯示 FPS 計數器
    Given 應用程式以 debug 模式啟動（`cocos build --debug`）
    When 玩家進入 GameScene
    Then HUD 右上角顯示 FPS 計數器（Roboto Mono 字型，12px）
    And FPS 數值每 1 秒更新一次

  @client @p2 @visual
  Scenario: 正式版本不顯示 FPS 計數器
    Given 應用程式以 release 模式啟動（`cocos build --release`）
    When 玩家進入 GameScene
    Then HUD 中不顯示 FPS 計數器節點

  # ─── 錯誤態（Colyseus 房間異常）────────────────────────────

  @client @p0 @interaction
  Scenario: 伺服器維護時進入房間失敗顯示錯誤提示
    Given 玩家嘗試快速匹配（Colyseus 服務回傳 503）
    When MatchmakingUI 接收到連線失敗事件
    Then HUD 顯示 Toast 訊息「伺服器忙碌，請稍後重試」
    And Toast 使用 "--color-feedback-warning"（#FF8080）背景色
    And Toast 在 3 秒後自動消失
    And 「重試」按鈕可見
